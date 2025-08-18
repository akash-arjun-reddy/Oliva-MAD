import 'package:flutter/material.dart';
import '../../data/shopify_service.dart';

// 1. Product model class
class Product {
  final String name;
  final String imageAsset;
  final String price;
  final String description;
  final double rating;
  final int reviewCount;
  Product({
    required this.name,
    required this.imageAsset,
    required this.price,
    required this.description,
    required this.rating,
    required this.reviewCount,
  });
}

// 2. ProductDetailPage widget
class ProductDetailPage extends StatelessWidget {
  final Product product;
  const ProductDetailPage({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Mock discount for demo
    final double price =
        double.tryParse(product.price.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
    final double originalPrice = price > 0
        ? price * 1.25
        : 0; // 25% higher for demo
    final int discountPercent = originalPrice > 0
        ? (100 - (price / originalPrice * 100)).round()
        : 0;
    int quantity = 1;
    return StatefulBuilder(
      builder: (context, setState) => Scaffold(
        appBar: AppBar(
          title: Text(
            product.name,
            style: const TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.white,
          iconTheme: const IconThemeData(color: Colors.black),
          elevation: 0,
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Builder(
                builder: (context) {
                  final screenHeight = MediaQuery.of(context).size.height;
                  return Stack(
                    children: [
                      product.imageAsset.startsWith('http')
                          ? Image.network(
                              product.imageAsset,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              height: screenHeight * 0.5,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: double.infinity,
                                  height: screenHeight * 0.5,
                                  color: Colors.grey[300],
                                  child: const Icon(
                                    Icons.image_not_supported,
                                    color: Colors.grey,
                                    size: 64,
                                  ),
                                );
                              },
                            )
                          : Image.asset(
                              product.imageAsset,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              height: screenHeight * 0.5,
                            ),
                      Positioned(
                        top: 6,
                        right: 10,
                        child: _AnimatedWishlistButton(),
                      ),
                    ],
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Move description here
                    Text(
                      product.description,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.orange, size: 20),
                        Text(
                          '${product.rating}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(' (${product.reviewCount} reviews)'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Pricing row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (discountPercent > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red[100],
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Limited time deal',
                              style: TextStyle(
                                color: Colors.red[800],
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        if (discountPercent > 0) const SizedBox(width: 8),
                        if (discountPercent > 0)
                          Text(
                            '-$discountPercent%',
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        if (discountPercent > 0) const SizedBox(width: 8),
                        Text(
                          product.price,
                          style: const TextStyle(
                            fontSize: 22,
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (discountPercent > 0) const SizedBox(width: 8),
                        if (discountPercent > 0)
                          Text(
                            '₹${originalPrice.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black38,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'In stock',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Centered quantity selector
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Color(0xFF00B2B8),
                              width: 1.2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.white,
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.remove,
                                  size: 20,
                                  color: Color(0xFF00B2B8),
                                ),
                                splashRadius: 18,
                                onPressed: quantity > 1
                                    ? () => setState(() => quantity--)
                                    : null,
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12.0,
                                ),
                                child: Text(
                                  '$quantity',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF00B2B8),
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.add,
                                  size: 20,
                                  color: Color(0xFF00B2B8),
                                ),
                                splashRadius: 18,
                                onPressed: () => setState(() => quantity++),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Full-width stacked buttons
                    SizedBox(
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(
                            height: 48,
                            child: ElevatedButton(
                              onPressed: () {
                                CartModel().add(product);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '${product.name} added to cart!',
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF197D7D),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                textStyle: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                                elevation: 0,
                              ),
                              child: const Text('Add to Cart'),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 48,
                            child: ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF197D7D),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                textStyle: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                                elevation: 0,
                              ),
                              child: const Text('Buy Now'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ShopPage extends StatefulWidget {
  const ShopPage({Key? key}) : super(key: key);

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  final CartModel cartModel = CartModel();
  List<Product> products = [];
  String _searchQuery = '';
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    cartModel.addListener(_onCartChanged);
    _loadProducts();
  }

  @override
  void dispose() {
    cartModel.removeListener(_onCartChanged);
    super.dispose();
  }

  void _onCartChanged() {
    setState(() {});
  }

  Future<void> _loadProducts() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      print('🛍️ Starting to fetch Shopify products...');
      
      // First test the API connection
      final connectionTest = await ShopifyService.testConnection();
      print('🔗 API Connection test result: $connectionTest');
      
      final shopifyProducts = await ShopifyService.fetchProducts();
      print('✨ Shopify products fetched: ${shopifyProducts.length}');
      
      if (shopifyProducts.isEmpty) {
        throw Exception('No products found in Shopify store');
      }
      
      final appProducts = shopifyProducts
          .map((shopifyProduct) => ShopifyService.convertToAppProduct(shopifyProduct))
          .where((product) => product != null)
          .toList();
      
      print('🔄 Converted to app products: ${appProducts.length}');
      
      // Log some product details for debugging
      if (appProducts.isNotEmpty) {
        print('📋 Sample products:');
        for (int i = 0; i < (appProducts.length > 3 ? 3 : appProducts.length); i++) {
          final product = appProducts[i];
          print('  ${i + 1}. ${product.name} - ${product.price}');
          print('     Image: ${product.imageAsset}');
        }
      }

      setState(() {
        products = appProducts;
        _isLoading = false;
        _error = null;
      });
      
      print('🎉 Successfully loaded ${products.length} products from Shopify!');
    } catch (e) {
      print('❌ Error loading products from Shopify: $e');
      print('🔧 Adding temporary fallback products for debugging...');
      
      // Temporary fallback products while debugging API issue
      setState(() {
        _error = 'API Debug Mode: ${e.toString()}';
        products = [
          Product(
            name: 'Vitamin C Brightening Serum',
            imageAsset: 'https://cdn.shopify.com/s/files/1/0123/4567/products/vitamin-c-serum.jpg',
            price: '₹899',
            description: 'Brightening vitamin C serum for radiant and glowing skin. Reduces dark spots and improves skin texture.',
            rating: 4.8,
            reviewCount: 24,
          ),
          Product(
            name: 'Hyaluronic Acid Moisturizer',
            imageAsset: 'https://cdn.shopify.com/s/files/1/0123/4567/products/ha-moisturizer.jpg',
            price: '₹1299',
            description: 'Deep hydrating moisturizer with hyaluronic acid. Provides long-lasting moisture for all skin types.',
            rating: 4.9,
            reviewCount: 18,
          ),
          Product(
            name: 'Niacinamide Pore Treatment',
            imageAsset: 'https://cdn.shopify.com/s/files/1/0123/4567/products/niacinamide.jpg',
            price: '₹749',
            description: 'Pore-minimizing treatment with 10% niacinamide. Controls oil and refines skin texture.',
            rating: 4.7,
            reviewCount: 31,
          ),
          Product(
            name: 'Retinol Anti-Aging Night Cream',
            imageAsset: 'https://cdn.shopify.com/s/files/1/0123/4567/products/retinol-cream.jpg',
            price: '₹1599',
            description: 'Powerful anti-aging night cream with retinol. Reduces fine lines and improves skin elasticity.',
            rating: 4.6,
            reviewCount: 15,
          ),
          Product(
            name: 'Gentle Daily Cleanser',
            imageAsset: 'https://cdn.shopify.com/s/files/1/0123/4567/products/gentle-cleanser.jpg',
            price: '₹649',
            description: 'Mild daily cleanser for sensitive skin. Removes impurities without stripping natural oils.',
            rating: 4.5,
            reviewCount: 42,
          ),
          Product(
            name: 'Sunscreen SPF 50+',
            imageAsset: 'https://cdn.shopify.com/s/files/1/0123/4567/products/sunscreen.jpg',
            price: '₹799',
            description: 'Broad-spectrum sunscreen with SPF 50+. Lightweight formula with no white cast.',
            rating: 4.8,
            reviewCount: 28,
          ),
        ];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredProducts = products.where((product) {
      return product.name.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text('', style: TextStyle(color: Colors.black)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Row(
              children: [
                _AnimatedWishlistButton(),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CartPage()),
                    );
                  },
                  child: Stack(
                    alignment: Alignment.topRight,
                    children: [
                      _AnimatedCartButton(small: false),
                      if (cartModel.count > 0)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 18,
                              minHeight: 18,
                            ),
                            child: Text(
                              '${cartModel.count}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: _buildBody(filteredProducts),
    );
  }

  Widget _buildBody(List<Product> filteredProducts) {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00B2B8)),
            ),
            SizedBox(height: 16),
            Text(
              'Loading products...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
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
              'Error loading products',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadProducts,
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          // Search Bar
          TextField(
            decoration: InputDecoration(
              hintText: 'Search products...',
              prefixIcon: const Icon(Icons.search, color: Color(0xFF00B2B8)),
              filled: true,
              fillColor: const Color(0xFFF2F2F2),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 0,
                horizontal: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 4.0, top: 8.0, bottom: 8.0),
                child: Text(
                  'Top Products',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.black87,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'View All',
                  style: TextStyle(
                    color: Color(0xFF00B2B8),
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: filteredProducts.isEmpty
                ? const Center(
                    child: Text(
                      'No products found',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  )
                : LayoutBuilder(
                    builder: (context, constraints) {
                      final gridSpacing = 16.0;
                      final crossAxisSpacing = 12.0;
                      final rows = 2;
                      final columns = 2;
                      final totalSpacing = gridSpacing * (rows - 1);
                      final cardHeight =
                          (constraints.maxHeight - totalSpacing) / rows;
                      final cardWidth =
                          (constraints.maxWidth - crossAxisSpacing) / columns;
                      final aspectRatio = cardWidth / cardHeight;
                      return GridView.builder(
                        padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: gridSpacing,
                          crossAxisSpacing: crossAxisSpacing,
                          childAspectRatio: aspectRatio,
                        ),
                        itemCount: filteredProducts.length,
                        itemBuilder: (context, index) {
                          final product = filteredProducts[index];
                          return ProductCard(
                            product: product,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ProductDetailPage(product: product),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// Update ProductCard to accept Product and onTap
class ProductCard extends StatefulWidget {
  final Product product;
  final VoidCallback onTap;
  const ProductCard({Key? key, required this.product, required this.onTap})
      : super(key: key);
  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        elevation: 1.5,
        color: const Color(0xFFF8F4FF),
        clipBehavior: Clip.hardEdge,
        child: Padding(
          padding: const EdgeInsets.all(6.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 7,
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: widget.product.imageAsset.startsWith('http')
                          ? Image.network(
                              widget.product.imageAsset,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: double.infinity,
                                  color: Colors.grey[300],
                                  child: const Icon(
                                    Icons.image_not_supported,
                                    color: Colors.grey,
                                  ),
                                );
                              },
                            )
                          : Image.asset(
                              widget.product.imageAsset,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                    ),
                    Positioned(
                      top: 4,
                      right: 6,
                      child: _AnimatedWishlistButton(small: true),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                flex: 6,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          color: Color(0xFFFFB800),
                          size: 16,
                        ),
                        const Icon(
                          Icons.star,
                          color: Color(0xFFFFB800),
                          size: 16,
                        ),
                        const Icon(
                          Icons.star,
                          color: Color(0xFFFFB800),
                          size: 16,
                        ),
                        const Icon(
                          Icons.star,
                          color: Color(0xFFFFB800),
                          size: 16,
                        ),
                        const Icon(
                          Icons.star,
                          color: Color(0xFFFFB800),
                          size: 16,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          widget.product.rating.toString(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Flexible(
                          flex: 2,
                          child: Text(
                            widget.product.price,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.black,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 3),
                        const Flexible(
                          flex: 3,
                          child: Text(
                            'Inclusive\nof all taxes',
                            style: TextStyle(
                              fontSize: 8,
                              color: Colors.black45,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimatedWishlistButton extends StatefulWidget {
  final bool small;
  const _AnimatedWishlistButton({this.small = false});
  @override
  State<_AnimatedWishlistButton> createState() =>
      _AnimatedWishlistButtonState();
}

class _AnimatedWishlistButtonState extends State<_AnimatedWishlistButton>
    with SingleTickerProviderStateMixin {
  bool isWishlisted = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnim = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).chain(CurveTween(curve: Curves.easeOut)).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleWishlist() async {
    if (!isWishlisted) {
      await _controller.forward();
      await _controller.reverse();
    }
    setState(() {
      isWishlisted = !isWishlisted;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double iconSize = widget.small ? 22 : 32;
    return GestureDetector(
      onTap: _toggleWishlist,
      child: ScaleTransition(
        scale: _scaleAnim,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, anim) =>
              ScaleTransition(scale: anim, child: child),
          child: isWishlisted
              ? Icon(
                  Icons.favorite,
                  key: const ValueKey('filled'),
                  color: Colors.red,
                  size: iconSize,
                )
              : Icon(
                  Icons.favorite_border,
                  key: const ValueKey('border'),
                  color: Colors.black54,
                  size: iconSize,
                ),
        ),
      ),
    );
  }
}

class _AnimatedCartButton extends StatefulWidget {
  final bool small;
  const _AnimatedCartButton({Key? key, required this.small}) : super(key: key);
  @override
  State<_AnimatedCartButton> createState() => _AnimatedCartButtonState();
}

class _AnimatedCartButtonState extends State<_AnimatedCartButton>
    with SingleTickerProviderStateMixin {
  bool isAdded = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnim = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).chain(CurveTween(curve: Curves.easeOut)).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleCart() async {
    await _controller.forward();
    await _controller.reverse();
    setState(() {
      isAdded = !isAdded;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double iconSize = widget.small ? 22 : 32;
    return GestureDetector(
      onTap: _toggleCart,
      child: ScaleTransition(
        scale: _scaleAnim,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, anim) =>
              ScaleTransition(scale: anim, child: child),
          child: isAdded
              ? Icon(
                  Icons.shopping_cart,
                  key: const ValueKey('filled'),
                  color: Color(0xFF197D7D),
                  size: iconSize,
                )
              : Icon(
                  Icons.add_shopping_cart,
                  key: const ValueKey('border'),
                  color: Colors.black54,
                  size: iconSize,
                ),
        ),
      ),
    );
  }
}

// CartModel singleton for cart management
class CartModel extends ChangeNotifier {
  static final CartModel _instance = CartModel._internal();
  factory CartModel() => _instance;
  CartModel._internal();

  final List<Product> _cartItems = [];
  List<Product> get cartItems => List.unmodifiable(_cartItems);

  void add(Product product) {
    _cartItems.add(product);
    notifyListeners();
  }

  void remove(Product product) {
    _cartItems.remove(product);
    notifyListeners();
  }

  void clear() {
    _cartItems.clear();
    notifyListeners();
  }

  int get count => _cartItems.length;
}

// Add CartPage widget
class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);
  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final CartModel cartModel = CartModel();
  @override
  void initState() {
    super.initState();
    cartModel.addListener(_onCartChanged);
  }

  @override
  void dispose() {
    cartModel.removeListener(_onCartChanged);
    super.dispose();
  }

  void _onCartChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = cartModel.cartItems;
    final total = cartItems.fold<double>(
      0,
      (sum, item) =>
          sum +
          (double.tryParse(item.price.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0),
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0.5,
      ),
      body: cartItems.isEmpty
          ? const Center(
              child: Text('Your cart is empty', style: TextStyle(fontSize: 18)),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: cartItems.length,
              separatorBuilder: (_, __) => const Divider(height: 24),
              itemBuilder: (context, index) {
                final product = cartItems[index];
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: product.imageAsset.startsWith('http')
                          ? Image.network(
                              product.imageAsset,
                              width: 70,
                              height: 70,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 70,
                                  height: 70,
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
                              width: 70,
                              height: 70,
                              fit: BoxFit.cover,
                            ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            product.price,
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () {
                        cartModel.remove(product);
                      },
                    ),
                  ],
                );
              },
            ),
      bottomNavigationBar: cartItems.isEmpty
          ? null
          : Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, -2),
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
                          'Total',
                          style: TextStyle(fontSize: 15, color: Colors.black54),
                        ),
                        Text(
                          '₹${total.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF197D7D),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    child: const Text('Checkout'),
                  ),
                ],
              ),
            ),
    );
  }
}
