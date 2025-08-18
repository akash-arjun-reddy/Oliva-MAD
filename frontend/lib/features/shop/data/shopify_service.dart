import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../config/env.dart';
import '../presentation/pages/shop_page.dart';

// Shopify Product model
class ShopifyProduct {
  final String id;
  final String title;
  final String description;
  final String vendor;
  final String productType;
  final List<String> tags;
  final String status;
  final List<ShopifyVariant> variants;
  final List<ShopifyImage> images;
  final String createdAt;
  final String updatedAt;

  ShopifyProduct({
    required this.id,
    required this.title,
    required this.description,
    required this.vendor,
    required this.productType,
    required this.tags,
    required this.status,
    required this.variants,
    required this.images,
    required this.createdAt,
    required this.updatedAt,
  });

      factory ShopifyProduct.fromJson(Map<String, dynamic> json) {
      return ShopifyProduct(
        id: json['id']?.toString() ?? '',
        title: json['title'] ?? '',
        description: json['body_html'] ?? '',
        vendor: json['vendor'] ?? '',
        productType: json['product_type'] ?? '',
        tags: json['tags'] != null 
            ? List<String>.from(json['tags'] is List ? json['tags'] : [])
            : [],
        status: json['status'] ?? '',
        variants: json['variants'] != null && json['variants'] is List
            ? (json['variants'] as List).map((v) => ShopifyVariant.fromJson(v)).toList()
            : [],
        images: json['images'] != null && json['images'] is List
            ? (json['images'] as List).map((i) => ShopifyImage.fromJson(i)).toList()
            : [],
        createdAt: json['created_at'] ?? '',
        updatedAt: json['updated_at'] ?? '',
      );
    }
}

class ShopifyVariant {
  final String id;
  final String title;
  final String price;
  final String sku;
  final int position;
  final String inventoryPolicy;
  final String compareAtPrice;
  final String fulfillmentService;
  final String inventoryManagement;
  final String option1;
  final String option2;
  final String option3;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool taxable;
  final String barcode;
  final int grams;
  final String imageId;
  final int weight;
  final String weightUnit;
  final int inventoryItemId;
  final int inventoryQuantity;
  final int oldInventoryQuantity;
  final bool requiresShipping;
  final String adminGraphqlApiId;

  ShopifyVariant({
    required this.id,
    required this.title,
    required this.price,
    required this.sku,
    required this.position,
    required this.inventoryPolicy,
    required this.compareAtPrice,
    required this.fulfillmentService,
    required this.inventoryManagement,
    required this.option1,
    required this.option2,
    required this.option3,
    required this.createdAt,
    required this.updatedAt,
    required this.taxable,
    required this.barcode,
    required this.grams,
    required this.imageId,
    required this.weight,
    required this.weightUnit,
    required this.inventoryItemId,
    required this.inventoryQuantity,
    required this.oldInventoryQuantity,
    required this.requiresShipping,
    required this.adminGraphqlApiId,
  });

      factory ShopifyVariant.fromJson(Map<String, dynamic> json) {
        // Helper function to safely convert num to int
        int safeInt(dynamic value) {
          if (value == null) return 0;
          if (value is int) return value;
          if (value is double) return value.toInt();
          if (value is String) {
            final parsed = double.tryParse(value);
            return parsed?.toInt() ?? 0;
          }
          return 0;
        }

        return ShopifyVariant(
          id: json['id']?.toString() ?? '',
          title: json['title'] ?? '',
          price: json['price']?.toString() ?? '0',
          sku: json['sku'] ?? '',
          position: safeInt(json['position']),
          inventoryPolicy: json['inventory_policy'] ?? '',
          compareAtPrice: json['compare_at_price']?.toString() ?? '',
          fulfillmentService: json['fulfillment_service'] ?? '',
          inventoryManagement: json['inventory_management'] ?? '',
          option1: json['option1'] ?? '',
          option2: json['option2'] ?? '',
          option3: json['option3'] ?? '',
          createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
          updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
          taxable: json['taxable'] ?? false,
          barcode: json['barcode'] ?? '',
          grams: safeInt(json['grams']),
          imageId: json['image_id']?.toString() ?? '',
          weight: safeInt(json['weight']),
          weightUnit: json['weight_unit'] ?? '',
          inventoryItemId: safeInt(json['inventory_item_id']),
          inventoryQuantity: safeInt(json['inventory_quantity']),
          oldInventoryQuantity: safeInt(json['old_inventory_quantity']),
          requiresShipping: json['requires_shipping'] ?? false,
          adminGraphqlApiId: json['admin_graphql_api_id'] ?? '',
        );
      }
}

class ShopifyImage {
  final String id;
  final String productId;
  final int position;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String alt;
  final int width;
  final int height;
  final String src;
  final List<String> variantIds;
  final String adminGraphqlApiId;

  ShopifyImage({
    required this.id,
    required this.productId,
    required this.position,
    required this.createdAt,
    required this.updatedAt,
    required this.alt,
    required this.width,
    required this.height,
    required this.src,
    required this.variantIds,
    required this.adminGraphqlApiId,
  });

      factory ShopifyImage.fromJson(Map<String, dynamic> json) {
        // Helper function to safely convert num to int
        int safeInt(dynamic value) {
          if (value == null) return 0;
          if (value is int) return value;
          if (value is double) return value.toInt();
          if (value is String) {
            final parsed = double.tryParse(value);
            return parsed?.toInt() ?? 0;
          }
          return 0;
        }

        return ShopifyImage(
          id: json['id']?.toString() ?? '',
          productId: json['product_id']?.toString() ?? '',
          position: safeInt(json['position']),
          createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
          updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
          alt: json['alt'] ?? '',
          width: safeInt(json['width']),
          height: safeInt(json['height']),
          src: json['src'] ?? '',
          variantIds: json['variant_ids'] != null && json['variant_ids'] is List
              ? (json['variant_ids'] as List).map((id) => id.toString()).toList()
              : [],
          adminGraphqlApiId: json['admin_graphql_api_id'] ?? '',
        );
      }
}

class ShopifyService {
  static const String _baseUrl = 'https://oliva-clinic.myshopify.com';
  static const String _accessToken = Env.shopifyAccessToken;
  static const String _apiVersion = '2023-10'; // Using a more stable API version

  // Test API connection
  static Future<bool> testConnection() async {
    try {
      print('🔍 Testing Shopify API connection...');
      final response = await http.get(
        Uri.parse('$_baseUrl/admin/api/$_apiVersion/shop.json'),
        headers: {
          'X-Shopify-Access-Token': _accessToken,
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));
      
      print('🔍 Connection test response: ${response.statusCode}');
      print('🔍 Connection test body: ${response.body}');
      
      return response.statusCode == 200;
    } catch (e) {
      print('❌ Connection test failed: $e');
      return false;
    }
  }

  // Fetch all products from Shopify with pagination
  static Future<List<ShopifyProduct>> fetchProducts() async {
    List<ShopifyProduct> allProducts = [];
    String? pageInfo;
    int limit = 250; // Use maximum limit for efficiency
    
    try {
      print('🚀 Starting Shopify API call...');
      print('📍 Base URL: $_baseUrl');
      print('🔧 API Version: $_apiVersion');
      
      do {
        // Build URL with pagination parameters
        String url = '$_baseUrl/admin/api/$_apiVersion/products.json?limit=$limit&status=active';
        if (pageInfo != null) {
          url += '&page_info=$pageInfo';
        }
        
        print('📡 Making request to: $url');
        
        final response = await http.get(
          Uri.parse(url),
          headers: {
            'X-Shopify-Access-Token': _accessToken,
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'User-Agent': 'Oliva-Clinic-App/1.0',
          },
        ).timeout(const Duration(seconds: 45));

        print('📊 Response status: ${response.statusCode}');
        
        if (response.statusCode == 200) {
          print('✅ API Response received successfully');
          print('📄 Raw response body: ${response.body}');
          
          final Map<String, dynamic> data = json.decode(response.body);
          final List<dynamic> productsJson = data['products'] ?? [];
          
          print('📦 Products in this page: ${productsJson.length}');
          print('🔍 Full response data keys: ${data.keys.toList()}');
          
          if (productsJson.isNotEmpty) {
            // Log first product for debugging
            print('🔍 Sample product data: ${productsJson.first['title']}');
            print('🔍 Sample product full data: ${productsJson.first}');
            if (productsJson.first['images'] != null && productsJson.first['images'].isNotEmpty) {
              print('🖼️ Sample image URL: ${productsJson.first['images'][0]['src']}');
            }
          } else {
            print('⚠️ No products found in API response');
            print('🔍 Response data: $data');
          }
          
          // Convert and add products to our list
          final pageProducts = productsJson
              .map((json) {
                try {
                  return ShopifyProduct.fromJson(json);
                } catch (e) {
                  print('⚠️ Error parsing product: $e');
                  return null;
                }
              })
              .where((product) => product != null)
              .cast<ShopifyProduct>()
              .toList();
          
          allProducts.addAll(pageProducts);
          
          // Check for pagination info in Link header
          pageInfo = _extractNextPageInfo(response.headers['link']);
          
          print('✅ Fetched ${pageProducts.length} products (Total: ${allProducts.length})');
          print('🔗 Next page info: $pageInfo');
          
          // If we got fewer products than the limit, we've reached the end
          if (pageProducts.length < limit) {
            pageInfo = null;
          }
        } else if (response.statusCode == 401) {
          print('🔐 Authentication failed - Invalid access token');
          throw Exception('Invalid Shopify access token. Please check credentials.');
        } else if (response.statusCode == 403) {
          print('🚫 Access forbidden - Insufficient permissions');
          throw Exception('Insufficient permissions. Please check API scope.');
        } else if (response.statusCode == 429) {
          print('⏳ Rate limit exceeded - Waiting before retry...');
          await Future.delayed(const Duration(seconds: 2));
          continue; // Retry the same request
        } else {
          print('❌ Shopify API Error: ${response.statusCode}');
          print('📄 Response body: ${response.body}');
          throw Exception('API Error ${response.statusCode}: ${response.body}');
        }
      } while (pageInfo != null);
      
      print('🎉 Total products fetched: ${allProducts.length}');
      
      if (allProducts.isEmpty) {
        print('⚠️ No products found in Shopify store');
        throw Exception('No products available in the store');
      }
      
      return allProducts;
      
    } catch (e) {
      print('💥 Shopify API Exception: $e');
      rethrow; // Don't fall back to mock data - let the UI handle the error
    }
  }
  
  // Mock products for testing when API fails
  static List<ShopifyProduct> _getMockShopifyProducts() {
    return [
      ShopifyProduct(
        id: '1',
        title: 'Vitamin C Serum',
        description: 'Brightening vitamin C serum for radiant skin',
        vendor: 'Oliva Clinic',
        productType: 'Skincare',
        tags: ['vitamin-c', 'serum', 'brightening'],
        status: 'active',
        variants: [
          ShopifyVariant(
            id: '1',
            title: 'Default Title',
            price: '899',
            sku: 'VIT-C-001',
            position: 1,
            inventoryPolicy: 'deny',
            compareAtPrice: '1199',
            fulfillmentService: 'manual',
            inventoryManagement: 'shopify',
            option1: 'Default Title',
            option2: '',
            option3: '',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            taxable: true,
            barcode: '',
            grams: 50,
            imageId: '',
            weight: 50,
            weightUnit: 'g',
            inventoryItemId: 1,
            inventoryQuantity: 100,
            oldInventoryQuantity: 100,
            requiresShipping: true,
            adminGraphqlApiId: 'gid://shopify/ProductVariant/1',
          ),
        ],
        images: [
          ShopifyImage(
            id: '1',
            productId: '1',
            position: 1,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            alt: 'Vitamin C Serum',
            width: 500,
            height: 500,
            src: 'assets/images/gentle_face_cleanser.png',
            variantIds: ['1'],
            adminGraphqlApiId: 'gid://shopify/ProductImage/1',
          ),
        ],
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      ),
      ShopifyProduct(
        id: '2',
        title: 'Hyaluronic Acid Moisturizer',
        description: 'Deep hydrating moisturizer with hyaluronic acid',
        vendor: 'Oliva Clinic',
        productType: 'Skincare',
        tags: ['moisturizer', 'hyaluronic-acid', 'hydrating'],
        status: 'active',
        variants: [
          ShopifyVariant(
            id: '2',
            title: 'Default Title',
            price: '1299',
            sku: 'HA-MOIST-001',
            position: 1,
            inventoryPolicy: 'deny',
            compareAtPrice: '1599',
            fulfillmentService: 'manual',
            inventoryManagement: 'shopify',
            option1: 'Default Title',
            option2: '',
            option3: '',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            taxable: true,
            barcode: '',
            grams: 75,
            imageId: '',
            weight: 75,
            weightUnit: 'g',
            inventoryItemId: 2,
            inventoryQuantity: 50,
            oldInventoryQuantity: 50,
            requiresShipping: true,
            adminGraphqlApiId: 'gid://shopify/ProductVariant/2',
          ),
        ],
        images: [
          ShopifyImage(
            id: '2',
            productId: '2',
            position: 1,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            alt: 'Hyaluronic Acid Moisturizer',
            width: 500,
            height: 500,
            src: 'assets/images/skin_radiance_essence.png',
            variantIds: ['2'],
            adminGraphqlApiId: 'gid://shopify/ProductImage/2',
          ),
        ],
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      ),
      ShopifyProduct(
        id: '3',
        title: 'Niacinamide Treatment',
        description: 'Pore-minimizing treatment with niacinamide',
        vendor: 'Oliva Clinic',
        productType: 'Skincare',
        tags: ['niacinamide', 'treatment', 'pore-minimizing'],
        status: 'active',
        variants: [
          ShopifyVariant(
            id: '3',
            title: 'Default Title',
            price: '749',
            sku: 'NIA-TREAT-001',
            position: 1,
            inventoryPolicy: 'deny',
            compareAtPrice: '999',
            fulfillmentService: 'manual',
            inventoryManagement: 'shopify',
            option1: 'Default Title',
            option2: '',
            option3: '',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            taxable: true,
            barcode: '',
            grams: 30,
            imageId: '',
            weight: 30,
            weightUnit: 'g',
            inventoryItemId: 3,
            inventoryQuantity: 75,
            oldInventoryQuantity: 75,
            requiresShipping: true,
            adminGraphqlApiId: 'gid://shopify/ProductVariant/3',
          ),
        ],
        images: [
          ShopifyImage(
            id: '3',
            productId: '3',
            position: 1,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            alt: 'Niacinamide Treatment',
            width: 500,
            height: 500,
            src: 'assets/images/skin_essential_kit.png',
            variantIds: ['3'],
            adminGraphqlApiId: 'gid://shopify/ProductImage/3',
          ),
        ],
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      ),
      ShopifyProduct(
        id: '4',
        title: 'Retinol Night Cream',
        description: 'Anti-aging night cream with retinol',
        vendor: 'Oliva Clinic',
        productType: 'Skincare',
        tags: ['retinol', 'night-cream', 'anti-aging'],
        status: 'active',
        variants: [
          ShopifyVariant(
            id: '4',
            title: 'Default Title',
            price: '1599',
            sku: 'RET-NIGHT-001',
            position: 1,
            inventoryPolicy: 'deny',
            compareAtPrice: '1999',
            fulfillmentService: 'manual',
            inventoryManagement: 'shopify',
            option1: 'Default Title',
            option2: '',
            option3: '',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            taxable: true,
            barcode: '',
            grams: 50,
            imageId: '',
            weight: 50,
            weightUnit: 'g',
            inventoryItemId: 4,
            inventoryQuantity: 30,
            oldInventoryQuantity: 30,
            requiresShipping: true,
            adminGraphqlApiId: 'gid://shopify/ProductVariant/4',
          ),
        ],
        images: [
          ShopifyImage(
            id: '4',
            productId: '4',
            position: 1,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            alt: 'Retinol Night Cream',
            width: 500,
            height: 500,
            src: 'assets/images/gentle_face_cleanser.png',
            variantIds: ['4'],
            adminGraphqlApiId: 'gid://shopify/ProductImage/4',
          ),
        ],
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      ),
      ShopifyProduct(
        id: '5',
        title: 'Gentle Cleanser',
        description: 'Mild daily cleanser for all skin types',
        vendor: 'Oliva Clinic',
        productType: 'Skincare',
        tags: ['cleanser', 'gentle', 'daily-use'],
        status: 'active',
        variants: [
          ShopifyVariant(
            id: '5',
            title: 'Default Title',
            price: '649',
            sku: 'GENTLE-CLEAN-001',
            position: 1,
            inventoryPolicy: 'deny',
            compareAtPrice: '799',
            fulfillmentService: 'manual',
            inventoryManagement: 'shopify',
            option1: 'Default Title',
            option2: '',
            option3: '',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            taxable: true,
            barcode: '',
            grams: 150,
            imageId: '',
            weight: 150,
            weightUnit: 'g',
            inventoryItemId: 5,
            inventoryQuantity: 80,
            oldInventoryQuantity: 80,
            requiresShipping: true,
            adminGraphqlApiId: 'gid://shopify/ProductVariant/5',
          ),
        ],
        images: [
          ShopifyImage(
            id: '5',
            productId: '5',
            position: 1,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            alt: 'Gentle Cleanser',
            width: 500,
            height: 500,
            src: 'assets/images/skin_radiance_essence.png',
            variantIds: ['5'],
            adminGraphqlApiId: 'gid://shopify/ProductImage/5',
          ),
        ],
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      ),
    ];
  }
  
  // Extract next page info from Link header
  static String? _extractNextPageInfo(String? linkHeader) {
    if (linkHeader == null) return null;
    
    // Parse Link header to find next page info
    final nextLinkRegex = RegExp(r'<[^>]*[?&]page_info=([^&>]+)[^>]*>; rel="next"');
    final match = nextLinkRegex.firstMatch(linkHeader);
    
    return match?.group(1);
  }

  // Convert Shopify product to our app's Product model
  static Product convertToAppProduct(ShopifyProduct shopifyProduct) {
    try {
      // Get the first variant for price (with better error handling)
      final firstVariant = shopifyProduct.variants.isNotEmpty 
          ? shopifyProduct.variants.first 
          : null;
      
      // Get the first image for display (prioritize actual product images)
      final firstImage = shopifyProduct.images.isNotEmpty 
          ? shopifyProduct.images.first 
          : null;
      
      // Clean and format price
      String formattedPrice = '₹0';
      if (firstVariant?.price != null && firstVariant!.price.isNotEmpty) {
        final priceValue = double.tryParse(firstVariant.price) ?? 0;
        formattedPrice = '₹${priceValue.toInt()}';
      }
      
      // Clean description (remove HTML tags and limit length)
      String cleanDescription = shopifyProduct.description
          .replaceAll(RegExp(r'<[^>]*>'), '') // Remove HTML tags
          .replaceAll(RegExp(r'\s+'), ' ') // Normalize whitespace
          .trim();
      
      if (cleanDescription.isEmpty) {
        cleanDescription = 'Premium ${shopifyProduct.productType} from ${shopifyProduct.vendor}';
      }
      
      // Limit description length for UI
      if (cleanDescription.length > 150) {
        cleanDescription = '${cleanDescription.substring(0, 147)}...';
      }
      
      // Use actual Shopify image URL or fallback to placeholder
      String imageUrl = 'assets/images/placeholder.png';
      if (firstImage?.src != null && firstImage!.src.isNotEmpty) {
        imageUrl = firstImage.src;
        print('🖼️ Using Shopify image: $imageUrl');
      } else {
        print('⚠️ No image found for product: ${shopifyProduct.title}');
      }
      
      // Generate realistic rating based on product data
      double rating = 4.5; // Default good rating
      int reviewCount = 10; // Default review count
      
      // Vary rating slightly based on product characteristics
      if (shopifyProduct.tags.contains('bestseller') || shopifyProduct.tags.contains('popular')) {
        rating = 5.0;
        reviewCount = 25;
      } else if (shopifyProduct.tags.contains('new') || shopifyProduct.tags.contains('latest')) {
        rating = 4.3;
        reviewCount = 5;
      }

      final product = Product(
        name: shopifyProduct.title,
        imageAsset: imageUrl,
        price: formattedPrice,
        description: cleanDescription,
        rating: rating,
        reviewCount: reviewCount,
      );
      
      print('✅ Converted product: ${product.name} - ${product.price}');
      return product;
      
    } catch (e) {
      print('⚠️ Error converting product ${shopifyProduct.title}: $e');
      // Return a basic product even if conversion fails
      return Product(
        name: shopifyProduct.title,
        imageAsset: 'assets/images/placeholder.png',
        price: '₹0',
        description: 'Product from ${shopifyProduct.vendor}',
        rating: 4.0,
        reviewCount: 0,
      );
    }
  }

  // Enhanced product filtering and search functionality
  static List<ShopifyProduct> filterProducts({
    List<ShopifyProduct>? products,
    String? searchQuery,
    String? category,
    List<String>? tags,
    double? minPrice,
    double? maxPrice,
    bool? inStock,
  }) {
    List<ShopifyProduct> filteredProducts = products ?? _getMockShopifyProducts();
    
    // Search by title or description
    if (searchQuery != null && searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      filteredProducts = filteredProducts.where((product) {
        return product.title.toLowerCase().contains(query) ||
               product.description.toLowerCase().contains(query) ||
               product.vendor.toLowerCase().contains(query) ||
               product.productType.toLowerCase().contains(query);
      }).toList();
    }
    
    // Filter by category/product type
    if (category != null && category.isNotEmpty) {
      filteredProducts = filteredProducts.where((product) {
        return product.productType.toLowerCase() == category.toLowerCase();
      }).toList();
    }
    
    // Filter by tags
    if (tags != null && tags.isNotEmpty) {
      filteredProducts = filteredProducts.where((product) {
        return tags.any((tag) => product.tags.contains(tag));
      }).toList();
    }
    
    // Filter by price range
    if (minPrice != null || maxPrice != null) {
      filteredProducts = filteredProducts.where((product) {
        if (product.variants.isEmpty) return false;
        
        final price = double.tryParse(product.variants.first.price) ?? 0;
        
        if (minPrice != null && price < minPrice) return false;
        if (maxPrice != null && price > maxPrice) return false;
        
        return true;
      }).toList();
    }
    
    // Filter by stock availability
    if (inStock != null) {
      filteredProducts = filteredProducts.where((product) {
        if (product.variants.isEmpty) return false;
        
        final quantity = product.variants.first.inventoryQuantity;
        return inStock ? quantity > 0 : quantity <= 0;
      }).toList();
    }
    
    return filteredProducts;
  }

  // Get product categories/types
  static List<String> getProductCategories() {
    final products = _getMockShopifyProducts();
    final categories = <String>{};
    
    for (final product in products) {
      if (product.productType.isNotEmpty) {
        categories.add(product.productType);
      }
    }
    
    return categories.toList()..sort();
  }

  // Get all available tags
  static List<String> getAllTags() {
    final products = _getMockShopifyProducts();
    final tags = <String>{};
    
    for (final product in products) {
      tags.addAll(product.tags);
    }
    
    return tags.toList()..sort();
  }

  // Get product recommendations based on tags and category
  static List<ShopifyProduct> getRecommendations(ShopifyProduct baseProduct, {int limit = 5}) {
    final allProducts = _getMockShopifyProducts();
    final recommendations = <ShopifyProduct>[];
    
    // Score products based on similarity
    final scoredProducts = <MapEntry<ShopifyProduct, double>>[];
    
    for (final product in allProducts) {
      if (product.id == baseProduct.id) continue; // Skip the same product
      
      double score = 0;
      
      // Same category gets high score
      if (product.productType == baseProduct.productType) {
        score += 3;
      }
      
      // Same vendor gets medium score
      if (product.vendor == baseProduct.vendor) {
        score += 2;
      }
      
      // Shared tags get points
      final sharedTags = baseProduct.tags.where((tag) => product.tags.contains(tag)).length;
      score += sharedTags * 1.5;
      
      if (score > 0) {
        scoredProducts.add(MapEntry(product, score));
      }
    }
    
    // Sort by score and return top recommendations
    scoredProducts.sort((a, b) => b.value.compareTo(a.value));
    
    for (int i = 0; i < limit && i < scoredProducts.length; i++) {
      recommendations.add(scoredProducts[i].key);
    }
    
    return recommendations;
  }

  // Public method to get mock products for external use
  static List<ShopifyProduct> getMockProducts() {
    return _getMockShopifyProducts();
  }
}