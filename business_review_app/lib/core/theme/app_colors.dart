import 'package:flutter/material.dart';

/// Application color palette based on provided colors
/// E6FAFC, 9CFC97, 6BA368, 515B3A, 353D2F
class AppColors {
  static const Color lightCyan = Color(0xFFE6FAFC);
  static const Color lightGreen = Color(0xFF9CFC97);
  static const Color mediumGreen = Color(0xFF6BA368);
  static const Color darkOlive = Color(0xFF515B3A);
  static const Color darkGray = Color(0xFF353D2F);
  
  static const Color primary = mediumGreen;
  static const Color secondary = lightGreen;
  static const Color tertiary = lightCyan;
  static const Color background = Color(0xFFF8FFFE);
  static const Color surface = Colors.white;
  
  static const Color textPrimary = darkGray;
  static const Color textSecondary = darkOlive;
  
  static const Color positive = Color(0xFF6BA368);
  static const Color negative = Color(0xFFE57373);
  static const Color neutral = Color(0xFFFFB74D);
  
  static const Color success = mediumGreen;
  static const Color warning = Color(0xFFFFB74D);
  static const Color error = Color(0xFFE57373);
  static const Color info = lightCyan;
}

