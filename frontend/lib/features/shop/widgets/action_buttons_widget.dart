import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/shop_database_service.dart';

class ActionButtonsWidget extends StatelessWidget {
  final Product product;
  final int quantity;
  final int productId;
  final VoidCallback? onAddToCart;
  final VoidCallback? onBuyNow;
  final ShopDatabaseService? databaseService;

  const ActionButtonsWidget({
    Key? key,
    required this.product,
    required this.quantity,
    required this.productId,
    this.onAddToCart,
    this.onBuyNow,
    this.databaseService,
  }) : super(key: key);

  Future<void> _addToCart(BuildContext context) async {
    if (databaseService != null) {
      try {
        await databaseService!.addToCart(productId, quantity);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${product.name} added to cart!'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding to cart: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${product.name} added to cart!')),
      );
    }
    
    if (onAddToCart != null) {
      onAddToCart!();
    }
  }

  Future<void> _buyNow(BuildContext context) async {
    if (databaseService != null) {
      try {
        // Add to cart first
        await databaseService!.addToCart(productId, quantity);
        // Navigate to checkout (you can implement this)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Proceeding to checkout for ${product.name}'),
            backgroundColor: Colors.blue,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error processing purchase: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Proceeding to checkout for ${product.name}')),
      );
    }
    
    if (onBuyNow != null) {
      onBuyNow!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: () => _addToCart(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF197D7D),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                elevation: 0,
              ),
              child: const Text('Add to Cart'),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: () => _buyNow(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF197D7D),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                elevation: 0,
              ),
              child: const Text('Buy Now'),
            ),
          ),
        ],
      ),
    );
  }
} 