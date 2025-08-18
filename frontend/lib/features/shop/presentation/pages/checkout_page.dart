import 'package:flutter/material.dart';
import 'shop_page.dart';
import 'coupon_page.dart';
import 'address_entry_page.dart';
import 'payment_page.dart';

class CheckoutPage extends StatefulWidget {
  final List<Product> selectedProducts;
  final double totalAmount;
  
  const CheckoutPage({
    Key? key, 
    required this.selectedProducts, 
    required this.totalAmount,
  }) : super(key: key);

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  String? selectedAddress;
  String? selectedCoupon;
  double savedAmount = 0.0;
  String deliveryType = 'Standard';
  String tip = 'No Tip';
  String instructions = 'No special instructions';
  
  final List<Map<String, String>> _savedAddresses = [
    {
      'name': 'John Doe',
      'phone': '+91 98765 43210',
      'street': '123 Main Street, Apartment 4B',
      'landmark': 'Near Central Park',
      'city': 'Mumbai',
      'state': 'Maharashtra',
      'pincode': '400001',
      'country': 'India',
      'type': 'Home',
    },
    {
      'name': 'John Doe',
      'phone': '+91 98765 43210',
      'street': '456 Business Plaza, Floor 8',
      'landmark': 'Opposite Metro Station',
      'city': 'Mumbai',
      'state': 'Maharashtra',
      'pincode': '400002',
      'country': 'India',
      'type': 'Work',
    },
  ];

  @override
  void initState() {
    super.initState();
    // Calculate saved amount (mock calculation)
    savedAmount = widget.totalAmount * 0.15; // 15% savings
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Checkout',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.green[200]!),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.savings, color: Colors.green, size: 16),
                const SizedBox(width: 4),
                Text(
                  'Saved ₹${savedAmount.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Widget 1: Selected Products Summary
                  _buildProductsSummary(),
                  const SizedBox(height: 16),
                  
                  // Widget 2: Product Suggestions
                  _buildProductSuggestions(),
                  const SizedBox(height: 16),
                  
                  // Widget 3: Apply Coupon Section
                  _buildCouponSection(),
                  const SizedBox(height: 16),
                  
                  // Widget 4: Delivery Instructions
                  _buildDeliveryInstructions(),
                  const SizedBox(height: 16),
                  
                  // Widget 5: Final Price Breakdown
                  _buildPriceBreakdown(),
                  const SizedBox(height: 20),
                  
                  // Terms & Conditions
                  _buildTermsAndConditions(),
                ],
              ),
            ),
          ),
          
          // Bottom Bar
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildProductsSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Selected Products',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          ...widget.selectedProducts.map((product) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: product.imageAsset.startsWith('http')
                        ? Image.network(
                            product.imageAsset,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[300],
                                child: const Icon(
                                  Icons.image_not_supported,
                                  color: Colors.grey,
                                ),
                              );
                            },
                          )
                        : Image.asset(
                            product.imageAsset,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[300],
                                child: const Icon(
                                  Icons.image_not_supported,
                                  color: Colors.grey,
                                ),
                              );
                            },
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Qty: 1',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  product.price,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildProductSuggestions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'You might also like',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 5,
              itemBuilder: (context, index) {
                return Container(
                  width: 100,
                  margin: const EdgeInsets.only(right: 12),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.image,
                            color: Colors.grey,
                            size: 40,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Product ${index + 1}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCouponSection() {
    return GestureDetector(
      onTap: () => _navigateToCouponPage(),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.local_offer,
                color: Colors.orange,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Saving Corner',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    selectedCoupon ?? 'Apply Coupon',
                    style: TextStyle(
                      fontSize: 14,
                      color: selectedCoupon != null ? Colors.green : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryInstructions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Delivery Instructions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildSelectionButton(
                  'Delivery Type',
                  deliveryType,
                  () => _showDeliveryTypeDialog(),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildSelectionButton(
                  'Tips',
                  tip,
                  () => _showTipDialog(),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildSelectionButton(
                  'Instructions',
                  instructions,
                  () => _showInstructionsDialog(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionButton(String title, String value, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceBreakdown() {
    final subtotal = widget.totalAmount;
    final gst = subtotal * 0.18; // 18% GST
    final discount = savedAmount;
    final finalPrice = subtotal + gst - discount;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Price Breakdown',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          _buildPriceRow('Subtotal', '₹${subtotal.toStringAsFixed(0)}'),
          _buildPriceRow('GST & Taxes', '₹${gst.toStringAsFixed(0)}'),
          _buildPriceRow('Discount', '-₹${discount.toStringAsFixed(0)}', isDiscount: true),
          const Divider(),
          _buildPriceRow(
            'Total Payable',
            '₹${finalPrice.toStringAsFixed(0)}',
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String amount, {bool isDiscount = false, bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: isDiscount ? Colors.green : (isTotal ? Colors.black87 : Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermsAndConditions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Terms & Conditions',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 80,
            child: ListView(
              children: [
                Text(
                  '• Orders are processed within 24 hours\n'
                  '• Delivery within 3-5 business days\n'
                  '• Returns accepted within 7 days\n'
                  '• Free shipping on orders above ₹500\n'
                  '• All prices include applicable taxes',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
                  child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        selectedAddress != null ? 'Pay using' : 'Delivery Address',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (selectedAddress != null)
                        Text(
                          selectedAddress!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        )
                      else
                        TextButton(
                          onPressed: () => _showAddAddressDialog(),
                          child: const Text(
                            'Add Address',
                            style: TextStyle(
                              color: Color(0xFF00B2B8),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: selectedAddress != null ? _navigateToPaymentPage : null,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: selectedAddress != null ? const Color(0xFF00B2B8) : Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      selectedAddress != null ? 'Pay' : '',
                      style: TextStyle(
                        color: selectedAddress != null ? Colors.white : Colors.grey[600],
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  void _navigateToCouponPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CouponPage(),
      ),
    ).then((coupon) {
      if (coupon != null) {
        setState(() {
          selectedCoupon = coupon;
        });
      }
    });
  }

  void _showDeliveryTypeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Delivery Type'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['Standard', 'Express', 'Same Day'].map((type) {
            return ListTile(
              title: Text(type),
              onTap: () {
                setState(() {
                  deliveryType = type;
                });
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showTipDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Tip'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['No Tip', '₹10', '₹20', '₹50'].map((tipAmount) {
            return ListTile(
              title: Text(tipAmount),
              onTap: () {
                setState(() {
                  tip = tipAmount;
                });
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showInstructionsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delivery Instructions'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            'No special instructions',
            'Leave at door',
            'Call before delivery',
            'Ring doorbell',
          ].map((instruction) {
            return ListTile(
              title: Text(instruction),
              onTap: () {
                setState(() {
                  instructions = instruction;
                });
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showAddAddressDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Add Address',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  // Saved addresses
                  if (_savedAddresses.isNotEmpty) ...[
                    const Text(
                      'Saved Addresses',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ..._savedAddresses.map((address) => _buildAddressCard(address)),
                    const SizedBox(height: 20),
                  ],
                  // Add new address button
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      _navigateToAddressEntryPage();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00B2B8),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Add New Address',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildAddressCard(Map<String, String> address) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getAddressTypeColor(address['type']!),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  address['type']!,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                address['name']!,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            address['street']!,
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            '${address['city']!}, ${address['state']!} - ${address['pincode']!}',
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            'Phone: ${address['phone']!}',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Color _getAddressTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'home':
        return Colors.blue;
      case 'work':
        return Colors.green;
      case 'other':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  void _navigateToAddressEntryPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddressEntryPage(),
      ),
    ).then((newAddress) {
      if (newAddress != null) {
        setState(() {
          _savedAddresses.add(newAddress);
          selectedAddress = '${newAddress['name']} - ${newAddress['street']}';
        });
      }
    });
  }

  void _navigateToPaymentPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentPage(
          totalAmount: widget.totalAmount,
          selectedAddress: selectedAddress!,
        ),
      ),
    );
  }
} 