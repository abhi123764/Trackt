import 'package:flutter/material.dart';

class AppColors {

  static const Color tealDark = Color(0xFF0B4F52);
  static const Color tealPrimary = Color(0xFF12716F);
  static const Color tealLight = Color(0xFF1A8C89);
  static const Color accentGreen = Color(0xFF3FB94A);


  static const Color background = Color(0xFFF5F7F8);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF16232B);
  static const Color textSecondary = Color(0xFF6B7A80);
  static const Color divider = Color(0xFFE4E9EA);
  static const Color inputFill = Color(0xFFF0F2F3);

 
  static const Color danger = Color(0xFFD9453D);
  static const Color dangerBg = Color(0xFFFCE7E6);
  static const Color success = Color(0xFF3FB94A);

  static const LinearGradient tealGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [tealDark, tealLight],
  );
}

class AppTextStyles {
  static const String _fontFamily =
      'Poppins'; 

  static const TextStyle heading1 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 26,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle heading2 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle body = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    letterSpacing: 0.4,
  );

  static const TextStyle label = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
    letterSpacing: 0.6,
  );
}

class AppTheme {
  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.tealPrimary,
        primary: AppColors.tealPrimary,
        secondary: AppColors.accentGreen,
      ),
      fontFamily: 'Poppins',
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.tealDark,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          elevation: 0,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.inputFill,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        hintStyle: const TextStyle(color: AppColors.textSecondary),
      ),
    );
  }
}
