/// API service for communicating with the backend
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/review.dart';
import '../models/analytics.dart';
import '../models/business.dart';

class ApiService {
  // Ngrok URL for accessing backend from anywhere
  // Change back to 'http://10.0.2.2:8000/api' for local emulator
  static const String baseUrl = 'https://5fac33336699.ngrok-free.app/api';
  
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? 'Login failed');
      }
    } catch (e) {
      throw Exception('Error during login: $e');
    }
  }
  
  Future<List<Map<String, String>>> getDemoAccounts() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/demo-accounts'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((account) => {
          'email': account['email'] as String,
          'password': account['password'] as String,
          'businessName': account['businessName'] as String,
          'businessType': account['businessType'] as String,
        }).toList();
      } else {
        return [];
      }
    } catch (e) {
      print('Error loading demo accounts: $e');
      return [];
    }
  }

  Future<List<Business>> fetchBusinesses() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/businesses'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) {
          return Business(
            id: json['id'] as String,
            name: json['name'] as String,
            type: json['type'] as String,
            description: json['description'] as String?,
            imageUrl: json['image_url'] as String?,
          );
        }).toList();
      } else {
        throw Exception('Failed to load businesses');
      }
    } catch (e) {
      throw Exception('Error fetching businesses: $e');
    }
  }

  Future<List<Review>> fetchReviews(String businessId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/businesses/$businessId/reviews'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Review.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load reviews');
      }
    } catch (e) {
      throw Exception('Error fetching reviews: $e');
    }
  }

  Future<Analytics?> fetchAnalytics(String businessId, String period) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/businesses/$businessId/analytics?period=$period'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data.containsKey('message')) {
          return null;
        }
        
        return Analytics.fromMap(data);
      } else {
        throw Exception('Failed to load analytics: ${response.statusCode}');
      }
    } catch (e) {
      print('Analytics fetch error: $e');
      throw Exception('Error fetching analytics: $e');
    }
  }

  Future<bool> checkServerStatus() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:8000/'),
      ).timeout(const Duration(seconds: 5));
      
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}

