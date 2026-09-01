/// Input field validation utilities for authentication and forms.
class AppValidators {
  AppValidators._();

  /// Validates required text fields.
  static String? validateRequired(String? value, [String fieldName = 'Field']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validates email address format.
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  /// Validates password strength & length requirements.
  /// Enforces minimum 8 characters with at least one letter and one number.
  static String? validatePassword(String? value, {int minLength = 8}) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < minLength) {
      return 'Minimum $minLength characters required';
    }
    if (!RegExp(r'[a-zA-Z]').hasMatch(value)) {
      return 'Password must contain at least one letter';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain at least one number';
    }
    return null;
  }

  /// Validates phone numbers (required by default).
  static String? validatePhone(String? value, {bool isRequired = true}) {
    if (value == null || value.trim().isEmpty) {
      if (isRequired) {
        return 'Phone number is required';
      }
      return null;
    }

    final cleanPhone = value.replaceAll(RegExp(r'[\s\-\(\)\+]'), '');
    if (!RegExp(r'^[0-9]+$').hasMatch(cleanPhone) ||
        cleanPhone.length < 10 ||
        cleanPhone.length > 10) {
      return 'Enter a valid 10-digit phone number';
    }
    return null;
  }
}
