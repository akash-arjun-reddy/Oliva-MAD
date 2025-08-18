import 'package:flutter/material.dart';
import '../../services/shopify_api_service.dart';

class OrderTrackingPage extends StatefulWidget {
  final String orderId;
  final String customerEmail;

  const OrderTrackingPage({
    Key? key,
    required this.orderId,
    required this.customerEmail,
  }) : super(key: key);

  @override
  State<OrderTrackingPage> createState() => _OrderTrackingPageState();
}

class _OrderTrackingPageState extends State<OrderTrackingPage> {
  Map<String, dynamic>? orderDetails;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadOrderDetails();
  }

  Future<void> _loadOrderDetails() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      final orderId = int.tryParse(widget.orderId);
      if (orderId == null) {
        throw Exception('Invalid order ID');
      }

      final result = await ShopifyApiService.getOrderDetails(orderId);
      setState(() {
        orderDetails = result['order'];
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Tracking'),
        backgroundColor: const Color(0xFF00B2B8),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00B2B8)),
              ),
            )
          : error != null
              ? _buildErrorWidget()
              : _buildOrderDetails(),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            'Error loading order',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            error!,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadOrderDetails,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00B2B8),
              foregroundColor: Colors.white,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderDetails() {
    if (orderDetails == null) {
      return const Center(
        child: Text('Order not found'),
      );
    }

    final order = orderDetails!['order'];
    final lineItems = order['line_items'] as List? ?? [];
    final shippingAddress = order['shipping_address'];
    final customer = order['customer'];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order Status Card
          _buildStatusCard(order),
          const SizedBox(height: 16),

          // Order Details Card
          _buildOrderInfoCard(order),
          const SizedBox(height: 16),

          // Customer Details Card
          _buildCustomerCard(customer),
          const SizedBox(height: 16),

          // Shipping Address Card
          _buildShippingCard(shippingAddress),
          const SizedBox(height: 16),

          // Products Card
          _buildProductsCard(lineItems),
          const SizedBox(height: 16),

          // Payment Details Card
          _buildPaymentCard(order),
        ],
      ),
    );
  }

  Widget _buildStatusCard(Map<String, dynamic> order) {
    final status = order['financial_status'] ?? 'unknown';
    final fulfillmentStatus = order['fulfillment_status'] ?? 'unfulfilled';
    
    Color statusColor;
    String statusText;
    IconData statusIcon;

    if (status == 'paid') {
      if (fulfillmentStatus == 'fulfilled') {
        statusColor = Colors.green;
        statusText = 'Delivered';
        statusIcon = Icons.check_circle;
      } else {
        statusColor = Colors.orange;
        statusText = 'Processing';
        statusIcon = Icons.pending;
      }
    } else {
      statusColor = Colors.red;
      statusText = 'Payment Pending';
      statusIcon = Icons.payment;
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              statusIcon,
              color: statusColor,
              size: 32,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order Status',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderInfoCard(Map<String, dynamic> order) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Information',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Order ID', '#${order['id']}'),
            _buildInfoRow('Order Date', _formatDate(order['created_at'])),
            _buildInfoRow('Total Amount', '₹${order['total_price']}'),
            _buildInfoRow('Payment Status', order['financial_status'] ?? 'N/A'),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerCard(Map<String, dynamic> customer) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Customer Details',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Name', '${customer['first_name']} ${customer['last_name']}'),
            _buildInfoRow('Email', customer['email'] ?? 'N/A'),
            _buildInfoRow('Phone', customer['phone'] ?? 'N/A'),
          ],
        ),
      ),
    );
  }

  Widget _buildShippingCard(Map<String, dynamic> shippingAddress) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Shipping Address',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Text(
              '${shippingAddress['first_name']} ${shippingAddress['last_name']}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 4),
            Text(
              shippingAddress['address1'] ?? '',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 4),
            Text(
              '${shippingAddress['city']}, ${shippingAddress['province']} ${shippingAddress['zip']}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 4),
            Text(
              shippingAddress['country'] ?? '',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'Phone: ${shippingAddress['phone']}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductsCard(List lineItems) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Products Ordered',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            ...lineItems.map<Widget>((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['title'] ?? 'Unknown Product',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          Text(
                            'Qty: ${item['quantity']}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '₹${item['price']}',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentCard(Map<String, dynamic> order) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Payment Details',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Subtotal', '₹${order['subtotal_price']}'),
            _buildInfoRow('Tax', '₹${order['total_tax']}'),
            _buildInfoRow('Shipping', '₹${order['total_shipping_price_set']?['shop_money']?['amount'] ?? '0'}'),
            const Divider(),
            _buildInfoRow('Total', '₹${order['total_price']}', isTotal: true),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'N/A';
    }
  }
} 