import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/product_model.dart';

class ShopDatabaseService {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'shop_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create products table
    await db.execute('''
      CREATE TABLE products(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        imageAsset TEXT NOT NULL,
        price TEXT NOT NULL,
        description TEXT NOT NULL,
        rating REAL NOT NULL,
        reviewCount INTEGER NOT NULL
      )
    ''');

    // Create cart table
    await db.execute('''
      CREATE TABLE cart(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        productId INTEGER NOT NULL,
        quantity INTEGER NOT NULL,
        addedAt TEXT NOT NULL,
        FOREIGN KEY (productId) REFERENCES products (id)
      )
    ''');

    // Create wishlist table
    await db.execute('''
      CREATE TABLE wishlist(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        productId INTEGER NOT NULL,
        addedAt TEXT NOT NULL,
        FOREIGN KEY (productId) REFERENCES products (id)
      )
    ''');
  }

  // Product operations
  Future<int> insertProduct(Product product) async {
    final db = await database;
    return await db.insert('products', {
      'name': product.name,
      'imageAsset': product.imageAsset,
      'price': product.price,
      'description': product.description,
      'rating': product.rating,
      'reviewCount': product.reviewCount,
    });
  }

  Future<List<Product>> getAllProducts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('products');
    return List.generate(maps.length, (i) {
      return Product(
        name: maps[i]['name'],
        imageAsset: maps[i]['imageAsset'],
        price: maps[i]['price'],
        description: maps[i]['description'],
        rating: maps[i]['rating'],
        reviewCount: maps[i]['reviewCount'],
      );
    });
  }

  Future<Product?> getProductById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Product(
        name: maps[0]['name'],
        imageAsset: maps[0]['imageAsset'],
        price: maps[0]['price'],
        description: maps[0]['description'],
        rating: maps[0]['rating'],
        reviewCount: maps[0]['reviewCount'],
      );
    }
    return null;
  }

  // Cart operations
  Future<int> addToCart(int productId, int quantity) async {
    final db = await database;
    return await db.insert('cart', {
      'productId': productId,
      'quantity': quantity,
      'addedAt': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getCartItems() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT c.*, p.name, p.imageAsset, p.price, p.description, p.rating, p.reviewCount
      FROM cart c
      INNER JOIN products p ON c.productId = p.id
    ''');
  }

  Future<int> removeFromCart(int cartItemId) async {
    final db = await database;
    return await db.delete(
      'cart',
      where: 'id = ?',
      whereArgs: [cartItemId],
    );
  }

  // Wishlist operations
  Future<int> addToWishlist(int productId) async {
    final db = await database;
    return await db.insert('wishlist', {
      'productId': productId,
      'addedAt': DateTime.now().toIso8601String(),
    });
  }

  Future<int> removeFromWishlist(int productId) async {
    final db = await database;
    return await db.delete(
      'wishlist',
      where: 'productId = ?',
      whereArgs: [productId],
    );
  }

  Future<bool> isInWishlist(int productId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'wishlist',
      where: 'productId = ?',
      whereArgs: [productId],
    );
    return maps.isNotEmpty;
  }

  Future<List<Product>> getWishlistProducts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT p.*
      FROM products p
      INNER JOIN wishlist w ON p.id = w.productId
    ''');
    return List.generate(maps.length, (i) {
      return Product(
        name: maps[i]['name'],
        imageAsset: maps[i]['imageAsset'],
        price: maps[i]['price'],
        description: maps[i]['description'],
        rating: maps[i]['rating'],
        reviewCount: maps[i]['reviewCount'],
      );
    });
  }
} 