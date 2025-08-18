import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/payment_service.dart';
import '../../services/user_profile_service.dart';
import '../../services/shopify_api_service.dart';
import 'order_tracking_page.dart';

class PaymentPage extends StatefulWidget {
  final double totalAmount;
  final String selectedAddress;
  
  const PaymentPage({
    Key? key,
    required this.totalAmount,
    required this.selectedAddress,
  }) : super(key: key);

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String? _selectedPaymentMethod;
  String? _selectedUPIApp;
  final _upiIdController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _cardholderController = TextEditingController();
  bool _saveCard = false;

  final List<Map<String, dynamic>> _upiApps = [
    {'name': 'PhonePe', 'icon': Icons.phone_android, 'color': Colors.purple},
    {'name': 'Google Pay', 'icon': Icons.payment, 'color': Colors.blue},
    {'name': 'Paytm', 'icon': Icons.account_balance_wallet, 'color': Colors.blue[700]},
    {'name': 'Amazon Pay', 'icon': Icons.shopping_cart, 'color': Colors.orange},
    {'name': 'BHIM', 'icon': Icons.account_balance, 'color': Colors.green},
    {'name': 'Cred UPI', 'icon': Icons.credit_card, 'color': Colors.purple[600]},
    {'name': 'WhatsApp UPI', 'icon': Icons.message, 'color': Colors.green},
    {'name': 'Freecharge', 'icon': Icons.flash_on, 'color': Colors.orange[600]},
    {'name': 'Mobikwik', 'icon': Icons.account_balance_wallet, 'color': Colors.blue[800]},
    {'name': 'Airtel Payments Bank', 'icon': Icons.account_balance, 'color': Colors.red},
  ];

  final List<Map<String, dynamic>> _wallets = [
    {'name': 'Paytm Wallet', 'icon': Icons.account_balance_wallet, 'color': Colors.blue[700]},
    {'name': 'Mobikwik', 'icon': Icons.account_balance_wallet, 'color': Colors.blue[800]},
    {'name': 'Freecharge', 'icon': Icons.flash_on, 'color': Colors.orange[600]},
  ];

  final List<Map<String, dynamic>> _netbanking = [
    {'name': 'HDFC Bank', 'icon': Icons.account_balance, 'color': Colors.blue},
    {'name': 'ICICI Bank', 'icon': Icons.account_balance, 'color': Colors.orange},
    {'name': 'SBI Bank', 'icon': Icons.account_balance, 'color': Colors.blue[700]},
    {'name': 'Axis Bank', 'icon': Icons.account_balance, 'color': Colors.red},
  ];

  @override
  void dispose() {
    _upiIdController.dispose();
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _cardholderController.dispose();
    super.dispose();
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
          'Payment Options',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: _updatePhoneNumber,
            icon: const Icon(Icons.phone, color: Colors.black),
            tooltip: 'Update Phone Number',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(40),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: const Text(
              'Pay via UPI App',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Widget 1: UPI App Options
            _buildUPIAppOptions(),
            const SizedBox(height: 16),
            
            // Widget 2: Enter UPI ID Manually
            _buildUPIIdSection(),
            const SizedBox(height: 16),
            
            // Widget 3: Add Debit/Credit Card
            _buildCardPaymentSection(),
            const SizedBox(height: 16),
            
            // Widget 4: More Payment Options
            _buildMorePaymentOptions(),
            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildUPIAppOptions() {
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
            'UPI Apps',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.2,
            ),
            itemCount: _upiApps.length,
            itemBuilder: (context, index) {
              final app = _upiApps[index];
              final isSelected = _selectedUPIApp == app['name'];
              
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedPaymentMethod = 'UPI';
                    _selectedUPIApp = app['name'];
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? app['color'].withOpacity(0.1) : Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? app['color'] : Colors.grey[300]!,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: app['color'],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          app['icon'],
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        app['name'],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? app['color'] : Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildUPIIdSection() {
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
            'Enter UPI ID Manually',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _upiIdController,
            decoration: InputDecoration(
              hintText: 'Enter your UPI ID',
              prefixIcon: const Icon(Icons.payment, color: Color(0xFF00B2B8)),
              filled: true,
              fillColor: Colors.grey[50],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF00B2B8), width: 2),
              ),
            ),
            onChanged: (value) {
              if (value.isNotEmpty) {
                setState(() {
                  _selectedPaymentMethod = 'UPI';
                  _selectedUPIApp = null;
                });
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCardPaymentSection() {
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
            'Add Debit/Credit Card',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _cardNumberController,
            decoration: InputDecoration(
              hintText: 'Card Number',
              prefixIcon: const Icon(Icons.credit_card, color: Color(0xFF00B2B8)),
              filled: true,
              fillColor: Colors.grey[50],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (value) {
              if (value.isNotEmpty) {
                setState(() {
                  _selectedPaymentMethod = 'Card';
                });
              }
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _expiryController,
                  decoration: InputDecoration(
                    hintText: 'MM/YY',
                    prefixIcon: const Icon(Icons.calendar_today, color: Color(0xFF00B2B8)),
                    filled: true,
                    fillColor: Colors.grey[50],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _cvvController,
                  decoration: InputDecoration(
                    hintText: 'CVV',
                    prefixIcon: const Icon(Icons.security, color: Color(0xFF00B2B8)),
                    filled: true,
                    fillColor: Colors.grey[50],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _cardholderController,
            decoration: InputDecoration(
              hintText: 'Cardholder Name',
              prefixIcon: const Icon(Icons.person, color: Color(0xFF00B2B8)),
              filled: true,
              fillColor: Colors.grey[50],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Checkbox(
                value: _saveCard,
                onChanged: (value) {
                  setState(() {
                    _saveCard = value ?? false;
                  });
                },
                activeColor: const Color(0xFF00B2B8),
              ),
              const Text('Save card for future payments'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMorePaymentOptions() {
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
            'More Payment Options',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          
          // Wallets
          _buildPaymentCategory('Wallets', _wallets),
          const SizedBox(height: 16),
          
          // Netbanking
          _buildPaymentCategory('Netbanking', _netbanking),
          const SizedBox(height: 16),
          
          // Pay Later
          _buildPayLaterSection(),
          const SizedBox(height: 16),
          
          // COD
          _buildCODSection(),
        ],
      ),
    );
  }

  Widget _buildPaymentCategory(String title, List<Map<String, dynamic>> options) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        ...options.map((option) => _buildPaymentOption(option)),
      ],
    );
  }

  Widget _buildPaymentOption(Map<String, dynamic> option) {
    final isSelected = _selectedPaymentMethod == option['name'];
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = option['name'];
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? option['color'].withOpacity(0.1) : Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? option['color'] : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: option['color'],
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                option['icon'],
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                option['name'],
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? option['color'] : Colors.black87,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: option['color'],
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPayLaterSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pay Later',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        _buildPaymentOption({
          'name': 'Cred Pay',
          'icon': Icons.credit_card,
          'color': Colors.purple[600]!,
        }),
      ],
    );
  }

  Widget _buildCODSection() {
    final isSelected = _selectedPaymentMethod == 'COD';
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Cash on Delivery',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () {
            setState(() {
              _selectedPaymentMethod = 'COD';
            });
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected ? Colors.green.withOpacity(0.1) : Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? Colors.green : Colors.grey[300]!,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.money,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Cash on Delivery (COD)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (isSelected)
                  const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 20,
                  ),
              ],
            ),
          ),
        ),
      ],
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
                const Text(
                  'Total Amount',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '₹${widget.totalAmount.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton(
            onPressed: _selectedPaymentMethod != null ? _processPayment : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00B2B8),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              _selectedPaymentMethod == 'COD' ? 'Place Order' : 'Pay Now',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _processPayment() async {
    if (_selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a payment method'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Check if it's a COD order
    final isCOD = _selectedPaymentMethod == 'COD';
    
    if (isCOD) {
      // For COD orders, go directly to order creation
      _processCODOrder();
      return;
    }

    // Show payment processing dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00B2B8)),
            ),
            SizedBox(width: 16),
            Text('Processing payment...'),
          ],
        ),
      ),
    );

    try {
      // Initialize payment service
      await PaymentService.initialize();

      // Get user profile
      final userProfile = await UserProfileService.getUserProfile();
      
      // Debug: Show current phone number
      print('Current phone number: ${userProfile['phone']}');
      
      // Prepare payment data
      final paymentData = {
        'customer_name': userProfile['name']!,
        'phone_number': userProfile['phone']!,
        'email': userProfile['email']!,
        'amount': widget.totalAmount,
        'center': 'Oliva Clinic',
        'center_id': '90e79e59-6202-4feb-a64f-b647801469e4',
        'personal_info': {
          'user_name': null,
          'first_name': userProfile['name']!.split(' ').first,
          'last_name': userProfile['name']!.split(' ').length > 1 ? userProfile['name']!.split(' ').last : '',
          'middle_name': null,
          'email': userProfile['email']!,
          'mobile_country_code': 91,
          'mobile_number': userProfile['phone']!.replaceAll(RegExp(r'[^\d]'), '').length > 10 ? userProfile['phone']!.replaceAll(RegExp(r'[^\d]'), '').substring(userProfile['phone']!.replaceAll(RegExp(r'[^\d]'), '').length - 10) : userProfile['phone']!.replaceAll(RegExp(r'[^\d]'), ''),
          'work_country_code': 91,
          'work_number': null,
          'home_country_code': 91,
          'home_number': null,
          'gender': '1',
          'date_of_birth': '1990-01-01',
          'is_minor': false,
          'nationality_id': 91,
          'anniversary_date': null,
          'lock_guest_custom_data': false,
          'pan': null,
        },
        'address_info': {
          'address_1': widget.selectedAddress,
          'address_2': null,
          'city': 'Mumbai',
          'country_id': 95,
          'state_id': -2,
          'state_other': null,
          'zip_code': '400001',
        },
        'preferences': {
          'receive_transactional_email': true,
          'receive_transactional_sms': true,
          'receive_marketing_email': true,
          'receive_marketing_sms': true,
          'recieve_lp_stmt': true,
          'preferred_therapist_id': null,
        },
      };

      // Get payment URL
      final paymentUrl = await PaymentService.getPaymentUrl(
        paymentMethod: _selectedPaymentMethod!,
        paymentData: paymentData,
      );

      Navigator.pop(context); // Close loading dialog

      if (paymentUrl != null && paymentUrl.isNotEmpty) {
        // Launch payment URL
        final Uri url = Uri.parse(paymentUrl);
        
        // Show payment link dialog with order creation
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Payment Link Generated'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Your payment link has been created successfully.'),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Payment Link:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      SelectableText(
                        paymentUrl,
                        style: const TextStyle(
                          fontSize: 12,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Please complete the payment and then click "Create Order" to create your Shopify order.',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Go back to previous page
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  try {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Could not open link: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                child: const Text('Open Link'),
              ),
              ElevatedButton(
                onPressed: () => _createShopifyOrder(paymentData),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00B2B8),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Create Order'),
              ),
            ],
          ),
        );
      } else {
        // Show manual payment instructions if no URL is provided
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Payment Instructions'),
            content: const Text('Your payment has been created successfully. Please complete the payment using your selected payment method and return to the app.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Go back to previous page
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      
      // Show error dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Payment Failed'),
          content: Text('Error: ${e.toString()}'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  // Method to process COD orders
  void _processCODOrder() async {
    try {
      // Get user profile
      final userProfile = await UserProfileService.getUserProfile();
      
      // Prepare payment data for COD
      final paymentData = {
        'customer_name': userProfile['name']!,
        'phone_number': userProfile['phone']!,
        'email': userProfile['email']!,
        'amount': widget.totalAmount,
        'center': 'Oliva Clinic',
        'center_id': '90e79e59-6202-4feb-a64f-b647801469e4',
        'personal_info': {
          'user_name': null,
          'first_name': userProfile['name']!.split(' ').first,
          'last_name': userProfile['name']!.split(' ').length > 1 ? userProfile['name']!.split(' ').last : '',
          'middle_name': null,
          'email': userProfile['email']!,
          'mobile_country_code': 91,
          'mobile_number': userProfile['phone']!.replaceAll(RegExp(r'[^\d]'), '').length > 10 ? userProfile['phone']!.replaceAll(RegExp(r'[^\d]'), '').substring(userProfile['phone']!.replaceAll(RegExp(r'[^\d]'), '').length - 10) : userProfile['phone']!.replaceAll(RegExp(r'[^\d]'), ''),
          'work_country_code': 91,
          'work_number': null,
          'home_country_code': 91,
          'home_number': null,
          'gender': '1',
          'date_of_birth': '1990-01-01',
          'is_minor': false,
          'nationality_id': 91,
          'anniversary_date': null,
          'lock_guest_custom_data': false,
          'pan': null,
        },
        'address_info': {
          'address_1': widget.selectedAddress,
          'address_2': null,
          'city': 'Mumbai',
          'country_id': 95,
          'state_id': -2,
          'state_other': null,
          'zip_code': '400001',
        },
        'preferences': {
          'receive_transactional_email': true,
          'receive_transactional_sms': true,
          'receive_marketing_email': true,
          'receive_marketing_sms': true,
          'recieve_lp_stmt': true,
          'preferred_therapist_id': null,
        },
      };

      // Create order directly for COD
      _createShopifyOrder(paymentData);
    } catch (e) {
      // Show error dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Order Failed'),
          content: Text('Error: ${e.toString()}'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  // Method to create Shopify order
  void _createShopifyOrder(Map<String, dynamic> paymentData) async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00B2B8)),
              ),
              SizedBox(width: 16),
              Text('Creating order...'),
            ],
          ),
        ),
      );

      // Prepare products data
      final products = [
        {
          'name': 'Sample Product',
          'quantity': 1,
          'price': widget.totalAmount.toString(),
        }
      ];

      // Check if it's a COD order
      final isCOD = _selectedPaymentMethod == 'COD';
      
      Map<String, dynamic> result;
      
      if (isCOD) {
        // For COD orders, create order directly without payment
        result = await ShopifyApiService.createOrderDirectly(
          paymentData: paymentData,
          products: products,
          paymentMethod: 'COD',
        );
      } else {
        // For other payment methods, use the payment success flow
        result = await ShopifyApiService.handlePaymentSuccess(
          paymentId: DateTime.now().millisecondsSinceEpoch.toString(),
          paymentData: paymentData,
          products: products,
        );
      }

      Navigator.pop(context); // Close loading dialog

      // Show success dialog with appropriate message
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(isCOD ? 'Order Accepted' : 'Order Created Successfully'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(isCOD 
                ? 'Your COD order has been accepted successfully!'
                : 'Your Shopify order has been created successfully!'
              ),
              const SizedBox(height: 16),
              if (result['database_order_id'] != null) ...[
                Text('Order ID: ${result['database_order_id']}'),
                if (result['shopify_order_id'] != null)
                  Text('Shopify Order ID: ${result['shopify_order_id']}'),
              ],
              const SizedBox(height: 16),
              Text(
                isCOD 
                  ? 'You will receive an email confirmation shortly. Please have the exact amount ready when the delivery person arrives.'
                  : 'You will receive an email confirmation shortly. Your order will be shipped to your provided address.',
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Go back to previous page
              },
              child: const Text('OK'),
            ),
            if (result['database_order_id'] != null)
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  // Navigate to order tracking page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OrderTrackingPage(
                        orderId: result['database_order_id'].toString(),
                        customerEmail: paymentData['personal_info']['email'] ?? '',
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00B2B8),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Track Order'),
              ),
          ],
        ),
      );
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      
      // Show error dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(_selectedPaymentMethod == 'COD' ? 'Order Acceptance Failed' : 'Order Creation Failed'),
          content: Text('Error: ${e.toString()}'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  // Method to update user phone number
  void _updatePhoneNumber() async {
    final TextEditingController phoneController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Phone Number'),
        content: TextField(
          controller: phoneController,
          decoration: const InputDecoration(
            hintText: 'Enter your phone number',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.phone,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (phoneController.text.isNotEmpty) {
                await UserProfileService.setUserPhone(phoneController.text);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Phone number updated: ${phoneController.text}'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
} 