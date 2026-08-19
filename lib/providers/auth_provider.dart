import 'package:flutter/foundation.dart';

import '../models/app_user.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService.instance;

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void clearError() {
    if (_errorMessage == null) return;

    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _authService.login(
        email,
        password,
      );

      if (user == null) {
        _errorMessage =
            'Incorrect email or password. Try again.';

        _isLoading = false;
        notifyListeners();

        return false;
      }

      _isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      _errorMessage =
          'Something went wrong. Please try again.';

      _isLoading = false;
      notifyListeners();

      return false;
    }
  }

  Future<bool> register(AppUser user) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _authService.register(user);

      if (!success) {
        _errorMessage =
            'An account with this email already exists.';

        _isLoading = false;
        notifyListeners();

        return false;
      }

      _isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      _errorMessage =
          'Registration failed. Please try again.';

      _isLoading = false;
      notifyListeners();

      return false;
    }
  }
}