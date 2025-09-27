import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../models/user_model.dart';
import 'database_service.dart';

class AuthService {
  final DatabaseService _databaseService = DatabaseService();
  static bool _demoUsersInitialized = false;

  AuthService() {
    _initializeDemoUsers();
  }

  // Initialize demo users on first run
  Future<void> _initializeDemoUsers() async {
    if (!_demoUsersInitialized) {
      try {
        await createDemoUsers();
        _demoUsersInitialized = true;
      } catch (e) {
        print('Error initializing demo users: $e');
      }
    }
  }

  // Hash password using SHA256
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Login user
  Future<UserModel?> login(String email, String password, UserType userType) async {
    try {
      final hashedPassword = _hashPassword(password);
      final user = await _databaseService.getUserByEmailAndPassword(email, hashedPassword);
      
      if (user != null && user.userType == userType) {
        return user;
      }
      return null;
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  // Register new user
  Future<UserModel?> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required UserType userType,
  }) async {
    try {
      // Check if user already exists
      final existingUser = await _databaseService.getUserByEmail(email);
      if (existingUser != null) {
        throw Exception('User with this email already exists');
      }

      final hashedPassword = _hashPassword(password);
      final newUser = UserModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        email: email,
        phone: phone,
        userType: userType,
        password: hashedPassword,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        totalEarnings: 0.0,
        totalReports: 0,
        rating: 5.0,
        profileImageUrl: null,
        address: null,
      );

      final userId = await _databaseService.insertUser(newUser);
      if (userId != null) {
        return newUser.copyWith(id: userId);
      }
      return null;
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  // Get current user by ID
  Future<UserModel?> getCurrentUser(String userId) async {
    try {
      return await _databaseService.getUserById(userId);
    } catch (e) {
      throw Exception('Failed to get current user: $e');
    }
  }

  // Update user profile
  Future<UserModel?> updateProfile(UserModel user) async {
    try {
      final updatedUser = user.copyWith(updatedAt: DateTime.now());
      final success = await _databaseService.updateUser(updatedUser);
      if (success) {
        return updatedUser;
      }
      return null;
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  // Logout user (mainly for cleanup if needed)
  Future<void> logout() async {
    // Perform any cleanup operations if needed
    // For now, this is just a placeholder
  }

  // Create demo users for testing
  Future<void> createDemoUsers() async {
    try {
      // Demo User
      final demoUser = UserModel(
        id: 'demo_user_1',
        name: 'John Doe',
        email: 'user@demo.com',
        phone: '+1234567890',
        userType: UserType.user,
        password: _hashPassword('password123'),
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        totalEarnings: 150.0,
        totalReports: 5,
        rating: 4.5,
        profileImageUrl: null,
        address: '123 Main St, City, Country',
      );

      // Demo Collection Worker
      final demoCollector = UserModel(
        id: 'demo_collector_1',
        name: 'Jane Smith',
        email: 'collector@demo.com',
        phone: '+1234567891',
        userType: UserType.collectionWorker,
        password: _hashPassword('password123'),
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        totalEarnings: 500.0,
        totalReports: 0,
        rating: 4.8,
        profileImageUrl: null,
        address: '456 Worker Ave, City, Country',
      );

      // Demo Dealer
      final demoDealer = UserModel(
        id: 'demo_dealer_1',
        name: 'Mike Johnson',
        email: 'dealer@demo.com',
        phone: '+1234567892',
        userType: UserType.dealer,
        password: _hashPassword('password123'),
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        totalEarnings: 1000.0,
        totalReports: 0,
        rating: 4.9,
        profileImageUrl: null,
        address: '789 Business Blvd, City, Country',
      );

      // Insert demo users if they don't exist
      final existingUser = await _databaseService.getUserByEmail('user@demo.com');
      if (existingUser == null) {
        await _databaseService.insertUser(demoUser);
      }

      final existingCollector = await _databaseService.getUserByEmail('collector@demo.com');
      if (existingCollector == null) {
        await _databaseService.insertUser(demoCollector);
      }

      final existingDealer = await _databaseService.getUserByEmail('dealer@demo.com');
      if (existingDealer == null) {
        await _databaseService.insertUser(demoDealer);
      }
    } catch (e) {
      throw Exception('Failed to create demo users: $e');
    }
  }
}