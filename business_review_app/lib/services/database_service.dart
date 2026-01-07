/// Database service for local SQLite storage with backend sync
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/business.dart';
import '../models/review.dart';
import '../models/analytics.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() => _instance;

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'business_reviews.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE businesses (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        description TEXT,
        image_url TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE reviews (
        id TEXT PRIMARY KEY,
        business_id TEXT NOT NULL,
        text TEXT NOT NULL,
        customer_name TEXT,
        rating REAL,
        date TEXT NOT NULL,
        overall_sentiment TEXT,
        FOREIGN KEY (business_id) REFERENCES businesses (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE aspect_sentiments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        review_id TEXT NOT NULL,
        aspect_term TEXT,
        category TEXT,
        sentiment TEXT,
        FOREIGN KEY (review_id) REFERENCES reviews (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE analytics (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        business_id TEXT NOT NULL,
        period TEXT NOT NULL,
        analysis_date TEXT NOT NULL,
        total_reviews INTEGER,
        positive_count INTEGER,
        negative_count INTEGER,
        neutral_count INTEGER,
        top_issues TEXT,
        recommendations TEXT,
        category_breakdown TEXT,
        FOREIGN KEY (business_id) REFERENCES businesses (id)
      )
    ''');
  }

  Future<void> insertBusiness(Business business) async {
    final db = await database;
    await db.insert(
      'businesses',
      {
        'id': business.id,
        'name': business.name,
        'type': business.type,
        'description': business.description,
        'image_url': business.imageUrl,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Business>> getBusinesses() async {
    final db = await database;
    final maps = await db.query('businesses');

    return maps.map((map) {
      return Business(
        id: map['id'] as String,
        name: map['name'] as String,
        type: map['type'] as String,
        description: map['description'] as String?,
        imageUrl: map['image_url'] as String?,
      );
    }).toList();
  }

  Future<void> insertReview(Review review, String businessId) async {
    final db = await database;

    await db.insert('reviews', {
      'id': review.id,
      'business_id': businessId,
      'text': review.text,
      'customer_name': review.customerName,
      'rating': review.rating,
      'date': review.date.toIso8601String(),
      'overall_sentiment': review.overallSentiment,
    });

    for (var aspect in review.aspects) {
      await db.insert('aspect_sentiments', {
        'review_id': review.id,
        'aspect_term': aspect.aspectTerm,
        'category': aspect.category,
        'sentiment': aspect.sentiment,
      });
    }
  }

  Future<List<Review>> getReviewsForBusiness(String businessId) async {
    final db = await database;
    final reviewMaps = await db.query(
      'reviews',
      where: 'business_id = ?',
      whereArgs: [businessId],
      orderBy: 'date DESC',
    );

    List<Review> reviews = [];
    for (var reviewMap in reviewMaps) {
      final aspectMaps = await db.query(
        'aspect_sentiments',
        where: 'review_id = ?',
        whereArgs: [reviewMap['id']],
      );

      final aspects = aspectMaps.map((aspectMap) {
        return AspectSentiment(
          aspectTerm: aspectMap['aspect_term'] as String,
          category: aspectMap['category'] as String,
          sentiment: aspectMap['sentiment'] as String,
        );
      }).toList();

      reviews.add(Review(
        id: reviewMap['id'] as String,
        text: reviewMap['text'] as String,
        date: DateTime.parse(reviewMap['date'] as String),
        aspects: aspects,
        customerName: reviewMap['customer_name'] as String?,
        rating: reviewMap['rating'] as double?,
      ));
    }

    return reviews;
  }

  Future<void> insertAnalytics(Analytics analytics) async {
    final db = await database;
    
    await db.delete(
      'analytics',
      where: 'business_id = ? AND period = ?',
      whereArgs: [analytics.businessId, analytics.period],
    );
    
    await db.insert('analytics', analytics.toMap());
  }

  Future<Analytics?> getLatestAnalytics(String businessId, String period) async {
    final db = await database;
    final maps = await db.query(
      'analytics',
      where: 'business_id = ? AND period = ?',
      whereArgs: [businessId, period],
      orderBy: 'analysis_date DESC',
      limit: 1,
    );

    if (maps.isEmpty) return null;

    return Analytics.fromMap(maps.first);
  }

  Future<void> clearAllReviews() async {
    final db = await database;
    await db.delete('aspect_sentiments');
    await db.delete('reviews');
  }

  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('aspect_sentiments');
    await db.delete('reviews');
    await db.delete('analytics');
    await db.delete('businesses');
  }
}


