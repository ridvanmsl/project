import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/business.dart';

/// Provider for managing authentication state
class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  String? _userEmail;
  Business? _currentBusiness;
  
  bool get isAuthenticated => _isAuthenticated;
  String? get userEmail => _userEmail;
  Business? get currentBusiness => _currentBusiness;
  String? get businessName => _currentBusiness?.name;
  String? get businessId => _currentBusiness?.id;
  String? get businessType => _currentBusiness?.type;
  
  Future<bool> login(String email, String password) async {
    try {
      final apiService = ApiService();
      final response = await apiService.login(email, password);
      
      if (response['success'] == true) {
        _isAuthenticated = true;
        _userEmail = response['user']['email'];
        _currentBusiness = Business.fromJson(response['business']);
        notifyListeners();
        return true;
      }
      
      return false;
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }
  
  void logout() {
    _isAuthenticated = false;
    _userEmail = null;
    _currentBusiness = null;
    notifyListeners();
  }
}

