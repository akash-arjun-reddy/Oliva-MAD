import requests
import json
from typing import List, Dict, Optional
from fastapi import HTTPException

class ShopifyService:
    def __init__(self):
        self.store_name = "oliva-clinic"
        self.access_token = os.getenv("SHOPIFY_ACCESS_TOKEN", "")
        self.base_url = f"https://{self.store_name}.myshopify.com/admin/api/2024-04"
        
    def _get_headers(self):
        return {
            "X-Shopify-Access-Token": self.access_token,
            "Content-Type": "application/json",
            "Accept": "application/json"
        }
    
    def get_products(self) -> List[Dict]:
        """Fetch all products from Shopify"""
        try:
            url = f"{self.base_url}/products.json"
            response = requests.get(url, headers=self._get_headers())
            
            if response.status_code == 200:
                data = response.json()
                return data.get('products', [])
            else:
                raise HTTPException(
                    status_code=response.status_code,
                    detail=f"Failed to fetch products: {response.text}"
                )
        except Exception as e:
            raise HTTPException(status_code=500, detail=f"Error fetching products: {str(e)}")
    
    def get_product_variants(self, product_id: int) -> List[Dict]:
        """Fetch variants for a specific product"""
        try:
            url = f"{self.base_url}/products/{product_id}/variants.json"
            response = requests.get(url, headers=self._get_headers())
            
            if response.status_code == 200:
                data = response.json()
                return data.get('variants', [])
            else:
                raise HTTPException(
                    status_code=response.status_code,
                    detail=f"Failed to fetch variants: {response.text}"
                )
        except Exception as e:
            raise HTTPException(status_code=500, detail=f"Error fetching variants: {str(e)}")
    
    def create_order(self, order_data: Dict, financial_status: str = "paid") -> Dict:
        """Create a new order in Shopify"""
        try:
            url = f"{self.base_url}/orders.json"
            
            # Prepare the order payload
            payload = {
                "order": {
                    "line_items": order_data.get("line_items", []),
                    "customer": order_data.get("customer", {}),
                    "shipping_address": order_data.get("shipping_address", {}),
                    "financial_status": financial_status,
                    "inventory_behaviour": "bypass",
                    "send_receipt": True,
                    "send_fulfillment_receipt": True
                }
            }
            
            response = requests.post(url, json=payload, headers=self._get_headers())
            
            if response.status_code == 201:
                return response.json()
            else:
                print(f"Shopify API Error: {response.status_code} - {response.text}")
                raise HTTPException(
                    status_code=response.status_code,
                    detail=f"Failed to create order: {response.text}"
                )
        except Exception as e:
            raise HTTPException(status_code=500, detail=f"Error creating order: {str(e)}")
    
    def create_order_from_payment(self, payment_data: Dict) -> Dict:
        """Create order from payment data"""
        try:
            # Extract customer info from payment data
            customer_info = payment_data.get("personal_info", {})
            address_info = payment_data.get("address_info", {})
            
            # Prepare customer data
            customer = {
                "first_name": customer_info.get("first_name", ""),
                "last_name": customer_info.get("last_name", ""),
                "email": customer_info.get("email", "")
            }
            
            # Prepare shipping address
            shipping_address = {
                "first_name": customer_info.get("first_name", ""),
                "last_name": customer_info.get("last_name", ""),
                "address1": address_info.get("address_1", ""),
                "phone": customer_info.get("mobile_number", ""),
                "city": address_info.get("city", ""),
                "province": self._get_province_from_state(address_info.get("state_id", "")),
                "country": "India",
                "zip": address_info.get("zip_code", "")
            }
            
            # Prepare line items (you'll need to map your products to Shopify variant IDs)
            line_items = self._prepare_line_items(payment_data.get("products", []))
            
            order_data = {
                "line_items": line_items,
                "customer": customer,
                "shipping_address": shipping_address
            }
            
            return self.create_order(order_data)
            
        except Exception as e:
            raise HTTPException(status_code=500, detail=f"Error creating order from payment: {str(e)}")
    
    def _prepare_line_items(self, products: List[Dict]) -> List[Dict]:
        """Prepare line items for Shopify order"""
        line_items = []
        
        # This is a mapping of your app products to Shopify variant IDs
        # You'll need to update this based on your actual Shopify products
        product_variant_mapping = {
            "Gentle Face Cleanser 80ml": 123456789,  # Replace with actual variant ID
            "Skin Radiance Essence": 123456790,       # Replace with actual variant ID
            "Skin Essential Kit": 123456791,          # Replace with actual variant ID
            "Anti-Age Treatment": 123456792,          # Replace with actual variant ID
            "Acne Fade Solution": 123456793,          # Replace with actual variant ID
            "Blemish Control": 123456794,             # Replace with actual variant ID
        }
        
        for product in products:
            product_name = product.get("name", "")
            variant_id = product_variant_mapping.get(product_name)
            
            if variant_id:
                line_items.append({
                    "variant_id": variant_id,
                    "quantity": product.get("quantity", 1)
                })
            else:
                # Fallback: create a custom line item
                line_items.append({
                    "title": product_name,
                    "price": product.get("price", "0"),
                    "quantity": product.get("quantity", 1)
                })
        
        return line_items
    
    def _get_province_from_state(self, state_id: int) -> str:
        """Convert state ID to province name"""
        state_mapping = {
            -2: "Telangana",
            1: "Andhra Pradesh",
            2: "Maharashtra",
            # Add more state mappings as needed
        }
        return state_mapping.get(state_id, "Telangana")
    
    def fulfill_order(self, order_id: int) -> Dict:
        """Mark an order as fulfilled"""
        try:
            url = f"{self.base_url}/orders/{order_id}/fulfillments.json"
            
            payload = {
                "fulfillment": {
                    "status": "success"
                }
            }
            
            response = requests.post(url, json=payload, headers=self._get_headers())
            
            if response.status_code == 201:
                return response.json()
            else:
                raise HTTPException(
                    status_code=response.status_code,
                    detail=f"Failed to fulfill order: {response.text}"
                )
        except Exception as e:
            raise HTTPException(status_code=500, detail=f"Error fulfilling order: {str(e)}")
    
    def get_order(self, order_id: int) -> Dict:
        """Get order details"""
        try:
            url = f"{self.base_url}/orders/{order_id}.json"
            response = requests.get(url, headers=self._get_headers())
            
            if response.status_code == 200:
                return response.json()
            else:
                raise HTTPException(
                    status_code=response.status_code,
                    detail=f"Failed to get order: {response.text}"
                )
        except Exception as e:
            raise HTTPException(status_code=500, detail=f"Error getting order: {str(e)}")

# Create a global instance
shopify_service = ShopifyService() 