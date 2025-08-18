import 'package:flutter/material.dart';
import '../services/shop_database_service.dart';

class ProductImageWidget extends StatefulWidget {
  final String imageAsset;
  final int productId;
  final VoidCallback? onWishlistPressed;
  final ShopDatabaseService? databaseService;

  const ProductImageWidget({
    Key? key,
    required this.imageAsset,
    required this.productId,
    this.onWishlistPressed,
    this.databaseService,
  }) : super(key: key);

  @override
  _ProductImageWidgetState createState() => _ProductImageWidgetState();
}

class _ProductImageWidgetState extends State<ProductImageWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isWishlisted = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _checkWishlistStatus();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _checkWishlistStatus() async {
    if (widget.databaseService != null) {
      try {
        final isWishlisted = await widget.databaseService!.isInWishlist(widget.productId);
        setState(() {
          _isWishlisted = isWishlisted;
          _isLoading = false;
        });
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleWishlist() async {
    if (widget.databaseService != null) {
      try {
        if (_isWishlisted) {
          await widget.databaseService!.removeFromWishlist(widget.productId);
        } else {
          await widget.databaseService!.addToWishlist(widget.productId);
        }
        setState(() {
          _isWishlisted = !_isWishlisted;
        });
        _controller.forward().then((_) => _controller.reverse());
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating wishlist: $e')),
        );
      }
    } else {
      setState(() {
        _isWishlisted = !_isWishlisted;
      });
      _controller.forward().then((_) => _controller.reverse());
    }
    
    if (widget.onWishlistPressed != null) {
      widget.onWishlistPressed!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Stack(
      children: [
        Image.asset(
          widget.imageAsset,
          width: double.infinity,
          fit: BoxFit.cover,
          height: screenHeight * 0.5,
        ),
        Positioned(
          top: 6,
          right: 10,
          child: AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(
                            _isWishlisted ? Icons.favorite : Icons.favorite_border,
                            color: _isWishlisted ? Colors.red : Colors.grey,
                            size: 24,
                          ),
                    onPressed: _isLoading ? null : _toggleWishlist,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
} 