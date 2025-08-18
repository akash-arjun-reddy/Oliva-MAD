from typing import Dict, List, Optional
from datetime import datetime, timedelta
import uuid
import json
from sqlalchemy.orm import Session
from models.order_models import Order, OrderItem, PaymentTransaction, OrderEvent, Customer, Product, InventoryLog
from models.order_models import OrderStatus, PaymentStatus, PaymentMethod
from shopify_service import shopify_service

class AdvancedOrderService:
    def __init__(self, db_session: Session):
        self.db = db_session
    
    def create_order(self, order_data: Dict) -> Dict:
        """Create a new order with comprehensive validation"""
        try:
            # Generate unique order ID
            order_id = f"ORD-{datetime.now().strftime('%Y%m%d')}-{uuid.uuid4().hex[:8].upper()}"
            
            # Validate inventory
            inventory_check = self._validate_inventory(order_data.get('items', []))
            if not inventory_check['success']:
                return inventory_check
            
            # Create order record
            order = Order(
                order_id=order_id,
                customer_id=order_data.get('customer_id'),
                order_status=OrderStatus.PENDING,
                payment_status=PaymentStatus.PENDING,
                total_amount=order_data.get('total_amount', 0),
                subtotal_amount=order_data.get('subtotal_amount', 0),
                tax_amount=order_data.get('tax_amount', 0),
                shipping_amount=order_data.get('shipping_amount', 0),
                discount_amount=order_data.get('discount_amount', 0),
                shipping_address=order_data.get('shipping_address'),
                billing_address=order_data.get('billing_address'),
                payment_method=PaymentMethod(order_data.get('payment_method', 'upi')),
                payment_gateway=order_data.get('payment_gateway', 'razorpay')
            )
            
            self.db.add(order)
            self.db.flush()  # Get the order ID
            
            # Create order items
            for item_data in order_data.get('items', []):
                order_item = OrderItem(
                    order_id=order.id,
                    product_id=item_data.get('product_id'),
                    variant_id=item_data.get('variant_id'),
                    product_name=item_data.get('name'),
                    product_sku=item_data.get('sku'),
                    quantity=item_data.get('quantity', 1),
                    unit_price=item_data.get('unit_price', 0),
                    total_price=item_data.get('total_price', 0),
                    tax_amount=item_data.get('tax_amount', 0),
                    discount_amount=item_data.get('discount_amount', 0)
                )
                self.db.add(order_item)
            
            # Create order event
            event = OrderEvent(
                order_id=order.id,
                event_type='order.created',
                event_data={'order_id': order_id},
                description='Order created successfully'
            )
            self.db.add(event)
            
            # Reserve inventory
            self._reserve_inventory(order_data.get('items', []), order_id)
            
            self.db.commit()
            
            return {
                'success': True,
                'order_id': order_id,
                'order': order,
                'message': 'Order created successfully'
            }
            
        except Exception as e:
            self.db.rollback()
            return {
                'success': False,
                'error': str(e)
            }
    
    def process_payment(self, order_id: str, payment_data: Dict) -> Dict:
        """Process payment for an order"""
        try:
            # Get order
            order = self.db.query(Order).filter(Order.order_id == order_id).first()
            if not order:
                return {'success': False, 'error': 'Order not found'}
            
            # Create payment transaction
            transaction_id = f"TXN-{datetime.now().strftime('%Y%m%d')}-{uuid.uuid4().hex[:8].upper()}"
            
            payment_transaction = PaymentTransaction(
                transaction_id=transaction_id,
                order_id=order.id,
                payment_method=PaymentMethod(payment_data.get('payment_method', 'upi')),
                payment_gateway=payment_data.get('payment_gateway', 'razorpay'),
                amount=payment_data.get('amount', 0),
                status=PaymentStatus.PENDING,
                gateway_response=payment_data.get('gateway_response', {})
            )
            
            self.db.add(payment_transaction)
            
            # Create event
            event = OrderEvent(
                order_id=order.id,
                event_type='payment.initiated',
                event_data={'transaction_id': transaction_id},
                description='Payment initiated'
            )
            self.db.add(event)
            
            self.db.commit()
            
            return {
                'success': True,
                'transaction_id': transaction_id,
                'payment_transaction': payment_transaction
            }
            
        except Exception as e:
            self.db.rollback()
            return {'success': False, 'error': str(e)}
    
    def confirm_payment(self, order_id: str, payment_data: Dict) -> Dict:
        """Confirm payment and update order status"""
        try:
            # Get order
            order = self.db.query(Order).filter(Order.order_id == order_id).first()
            if not order:
                return {'success': False, 'error': 'Order not found'}
            
            # Update payment transaction
            payment_transaction = self.db.query(PaymentTransaction).filter(
                PaymentTransaction.order_id == order.id
            ).first()
            
            if payment_transaction:
                payment_transaction.status = PaymentStatus.PAID
                payment_transaction.gateway_transaction_id = payment_data.get('gateway_transaction_id')
                payment_transaction.gateway_response = payment_data.get('gateway_response', {})
            
            # Update order status
            order.payment_status = PaymentStatus.PAID
            order.order_status = OrderStatus.CONFIRMED
            
            # Create events
            events = [
                OrderEvent(
                    order_id=order.id,
                    event_type='payment.success',
                    event_data={'transaction_id': payment_transaction.transaction_id if payment_transaction else None},
                    description='Payment successful'
                ),
                OrderEvent(
                    order_id=order.id,
                    event_type='order.confirmed',
                    event_data={'order_id': order_id},
                    description='Order confirmed'
                )
            ]
            
            for event in events:
                self.db.add(event)
            
            # Create Shopify order
            shopify_result = self._create_shopify_order(order, payment_data)
            if shopify_result.get('success'):
                order.shopify_order_id = shopify_result.get('shopify_order_id')
            
            self.db.commit()
            
            return {
                'success': True,
                'order_status': order.order_status.value,
                'payment_status': order.payment_status.value,
                'shopify_order_id': order.shopify_order_id
            }
            
        except Exception as e:
            self.db.rollback()
            return {'success': False, 'error': str(e)}
    
    def update_order_status(self, order_id: str, new_status: str, tracking_number: str = None) -> Dict:
        """Update order status (for fulfillment)"""
        try:
            order = self.db.query(Order).filter(Order.order_id == order_id).first()
            if not order:
                return {'success': False, 'error': 'Order not found'}
            
            # Update status
            order.order_status = OrderStatus(new_status)
            if tracking_number:
                order.tracking_number = tracking_number
            
            # Create event
            event = OrderEvent(
                order_id=order.id,
                event_type=f'order.{new_status}',
                event_data={'tracking_number': tracking_number},
                description=f'Order status updated to {new_status}'
            )
            self.db.add(event)
            
            self.db.commit()
            
            return {
                'success': True,
                'order_status': new_status,
                'tracking_number': tracking_number
            }
            
        except Exception as e:
            self.db.rollback()
            return {'success': False, 'error': str(e)}
    
    def get_order_details(self, order_id: str) -> Dict:
        """Get comprehensive order details"""
        try:
            order = self.db.query(Order).filter(Order.order_id == order_id).first()
            if not order:
                return {'success': False, 'error': 'Order not found'}
            
            # Get related data
            items = self.db.query(OrderItem).filter(OrderItem.order_id == order.id).all()
            payments = self.db.query(PaymentTransaction).filter(PaymentTransaction.order_id == order.id).all()
            events = self.db.query(OrderEvent).filter(OrderEvent.order_id == order.id).order_by(OrderEvent.created_at).all()
            
            return {
                'success': True,
                'order': {
                    'order_id': order.order_id,
                    'shopify_order_id': order.shopify_order_id,
                    'status': order.order_status.value,
                    'payment_status': order.payment_status.value,
                    'total_amount': float(order.total_amount),
                    'subtotal_amount': float(order.subtotal_amount),
                    'tax_amount': float(order.tax_amount),
                    'shipping_amount': float(order.shipping_amount),
                    'discount_amount': float(order.discount_amount),
                    'shipping_address': order.shipping_address,
                    'billing_address': order.billing_address,
                    'tracking_number': order.tracking_number,
                    'estimated_delivery_date': order.estimated_delivery_date.isoformat() if order.estimated_delivery_date else None,
                    'created_at': order.created_at.isoformat(),
                    'updated_at': order.updated_at.isoformat()
                },
                'items': [
                    {
                        'product_name': item.product_name,
                        'product_sku': item.product_sku,
                        'quantity': item.quantity,
                        'unit_price': float(item.unit_price),
                        'total_price': float(item.total_price)
                    }
                    for item in items
                ],
                'payments': [
                    {
                        'transaction_id': payment.transaction_id,
                        'payment_method': payment.payment_method.value,
                        'amount': float(payment.amount),
                        'status': payment.status.value,
                        'created_at': payment.created_at.isoformat()
                    }
                    for payment in payments
                ],
                'events': [
                    {
                        'event_type': event.event_type,
                        'description': event.description,
                        'created_at': event.created_at.isoformat()
                    }
                    for event in events
                ]
            }
            
        except Exception as e:
            return {'success': False, 'error': str(e)}
    
    def _validate_inventory(self, items: List[Dict]) -> Dict:
        """Validate inventory availability"""
        for item in items:
            product = self.db.query(Product).filter(Product.product_id == item.get('product_id')).first()
            if not product:
                return {'success': False, 'error': f'Product {item.get("product_id")} not found'}
            
            if product.inventory_quantity < item.get('quantity', 1):
                return {
                    'success': False, 
                    'error': f'Insufficient inventory for {product.name}. Available: {product.inventory_quantity}, Requested: {item.get("quantity", 1)}'
                }
        
        return {'success': True}
    
    def _reserve_inventory(self, items: List[Dict], order_id: str):
        """Reserve inventory for order"""
        for item in items:
            product = self.db.query(Product).filter(Product.product_id == item.get('product_id')).first()
            if product:
                previous_quantity = product.inventory_quantity
                product.inventory_quantity -= item.get('quantity', 1)
                
                # Log inventory change
                inventory_log = InventoryLog(
                    product_id=item.get('product_id'),
                    change_type='order_placed',
                    quantity_change=-item.get('quantity', 1),
                    previous_quantity=previous_quantity,
                    new_quantity=product.inventory_quantity,
                    order_id=order_id
                )
                self.db.add(inventory_log)
    
    def _create_shopify_order(self, order: Order, payment_data: Dict) -> Dict:
        """Create order in Shopify"""
        try:
            # Prepare Shopify order data
            shopify_order_data = {
                'line_items': [
                    {
                        'title': item.product_name,
                        'price': str(item.unit_price),
                        'quantity': item.quantity
                    }
                    for item in order.items
                ],
                'customer': {
                    'first_name': order.shipping_address.get('first_name', ''),
                    'last_name': order.shipping_address.get('last_name', ''),
                    'email': payment_data.get('customer_email', '')
                },
                'shipping_address': order.shipping_address,
                'financial_status': 'paid'
            }
            
            # Create Shopify order
            result = shopify_service.create_order(shopify_order_data)
            
            if result.get('order'):
                return {
                    'success': True,
                    'shopify_order_id': result['order']['order']['id']
                }
            else:
                return {'success': False, 'error': 'Failed to create Shopify order'}
                
        except Exception as e:
            return {'success': False, 'error': str(e)}
    
    def get_order_analytics(self) -> Dict:
        """Get order analytics (like big e-commerce companies)"""
        try:
            # Total orders
            total_orders = self.db.query(Order).count()
            
            # Orders by status
            orders_by_status = self.db.query(Order.order_status, self.db.func.count(Order.id)).group_by(Order.order_status).all()
            
            # Revenue analytics
            total_revenue = self.db.query(self.db.func.sum(Order.total_amount)).scalar() or 0
            
            # Recent orders
            recent_orders = self.db.query(Order).order_by(Order.created_at.desc()).limit(10).all()
            
            return {
                'success': True,
                'analytics': {
                    'total_orders': total_orders,
                    'total_revenue': float(total_revenue),
                    'orders_by_status': {status.value: count for status, count in orders_by_status},
                    'recent_orders': [
                        {
                            'order_id': order.order_id,
                            'status': order.order_status.value,
                            'total_amount': float(order.total_amount),
                            'created_at': order.created_at.isoformat()
                        }
                        for order in recent_orders
                    ]
                }
            }
            
        except Exception as e:
            return {'success': False, 'error': str(e)} 