import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  bool _isAuthenticated = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;

  final AuthService _authService = AuthService();

  AuthProvider() {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    _setLoading(true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');
      final userType = prefs.getString('user_type');
      
      if (userId != null && userType != null) {
        // Simulate getting user data from storage/API
        _currentUser = await _authService.getCurrentUser(userId);
        _isAuthenticated = true;
      }
    } catch (e) {
      debugPrint('Error checking auth status: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> login(String email, String password, UserType userType) async {
    _setLoading(true);
    try {
      final user = await _authService.login(email, password, userType);
      if (user != null) {
        _currentUser = user;
        _isAuthenticated = true;
        await _saveUserSession(user);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Login error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required UserType userType,
  }) async {
    _setLoading(true);
    try {
      final user = await _authService.register(
        name: name,
        email: email,
        password: password,
        phone: phone,
        userType: userType,
      );
      
      if (user != null) {
        _currentUser = user;
        _isAuthenticated = true;
        await _saveUserSession(user);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Registration error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    try {
      await _authService.logout();
      await _clearUserSession();
      _currentUser = null;
      _isAuthenticated = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Logout error: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateProfile(UserModel updatedUser) async {
    _setLoading(true);
    try {
      final user = await _authService.updateProfile(updatedUser);
      if (user != null) {
        _currentUser = user;
        await _saveUserSession(user);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Update profile error: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _saveUserSession(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', user.id);
    await prefs.setString('user_type', user.userType.toString().split('.').last);
    await prefs.setString('user_data', user.toJson().toString());
  }

  Future<void> _clearUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
    await prefs.remove('user_type');
    await prefs.remove('user_data');
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
