import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_user.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  static const String _sessionUserIdKey = 'logged_in_user_id';
  static const String _sessionUserEmailKey = 'logged_in_user_email';

  final AuthService _authService = AuthService.instance;

  AppUser? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  bool _obscurePassword = true;

  AppUser? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get obscurePassword => _obscurePassword;

  void toggleObscurePassword() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  void clearError() {
    if (_errorMessage == null) return;
    _errorMessage = null;
    notifyListeners();
  }

  /// Restores active session from SharedPreferences on app launch.
  Future<bool> restoreSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt(_sessionUserIdKey);
      final userEmail = prefs.getString(_sessionUserEmailKey);

      AppUser? user;
      if (userId != null) {
        user = await _authService.getUserById(userId);
      } else if (userEmail != null) {
        user = await _authService.getUserByEmail(userEmail);
      }

      if (user != null) {
        _currentUser = user;
        notifyListeners();
        return true;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error restoring session: $e');
      }
    }

    _currentUser = null;
    return false;
  }

  /// Authenticates user and persists session.
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final normalizedEmail = email.trim().toLowerCase();

    try {
      final user = await _authService.login(normalizedEmail, password);

      if (user == null) {
        _errorMessage = 'Incorrect email or password. Try again.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      _currentUser = user;
      await _saveSession(user);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Something went wrong. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Registers user and logs them in.
  Future<bool> registerUserFields({
    required String fName,
    required String lName,
    required String email,
    String? dob,
    String? mobileNumber,
    required String password,
  }) async {
    final user = AppUser(
      fName: fName,
      lName: lName,
      email: email.trim().toLowerCase(),
      dob: dob,
      mobileNumber: mobileNumber,
      password: password,
      createdAt: DateTime.now().toIso8601String(),
    );
    return await register(user);
  }

  Future<bool> register(AppUser user) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final normalizedUser = AppUser(
      id: user.id,
      fName: user.fName,
      lName: user.lName,
      email: user.email.trim().toLowerCase(),
      dob: user.dob,
      mobileNumber: user.mobileNumber,
      password: user.password,
      themePreference: user.themePreference,
      languagePreference: user.languagePreference,
      createdAt: user.createdAt,
    );

    try {
      final success = await _authService.register(normalizedUser);

      if (!success) {
        _errorMessage = 'An account with this email already exists.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final registeredUser = await _authService.getUserByEmail(normalizedUser.email);
      if (registeredUser != null) {
        _currentUser = registeredUser;
        await _saveSession(registeredUser);
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Registration failed. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Logs out current user and clears session storage.
  Future<void> logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionUserIdKey);
    await prefs.remove(_sessionUserEmailKey);
    notifyListeners();
  }

  /// Helper to persist user session data.
  Future<void> _saveSession(AppUser user) async {
    final prefs = await SharedPreferences.getInstance();
    if (user.id != null) {
      await prefs.setInt(_sessionUserIdKey, user.id!);
    }
    await prefs.setString(_sessionUserEmailKey, user.email);
  }
}
