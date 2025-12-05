import 'package:flutter/material.dart';

/// Application color palette based on provided colors
/// E6FAFC, 9CFC97, 6BA368, 515B3A, 353D2F
class AppColors {
  // Primary Colors from palette
  static const Color lightCyan = Color(0xFFE6FAFC);      // E6FAFC
  static const Color lightGreen = Color(0xFF9CFC97);     // 9CFC97
  static const Color mediumGreen = Color(0xFF6BA368);    // 6BA368
  static const Color darkOlive = Color(0xFF515B3A);      // 515B3A
  static const Color darkGray = Color(0xFF353D2F);       // 353D2F
  
  // Application Theme Colors
  static const Color primary = mediumGreen;              // Main brand color
  static const Color secondary = lightGreen;             // Secondary actions
  static const Color tertiary = lightCyan;               // Backgrounds, highlights
  static const Color background = Color(0xFFF8FFFE);     // Very light background
  static const Color surface = Colors.white;             // Cards, surfaces
  
  // Text Colors
  static const Color textPrimary = darkGray;             // Primary text
  static const Color textSecondary = darkOlive;          // Secondary text
  
  // Sentiment Colors
  static const Color positive = Color(0xFF6BA368);       // Positive sentiment
  static const Color negative = Color(0xFFE57373);       // Negative sentiment
  static const Color neutral = Color(0xFFFFB74D);        // Neutral sentiment
  
  // Status Colors
  static const Color success = mediumGreen;
  static const Color warning = Color(0xFFFFB74D);
  static const Color error = Color(0xFFE57373);
  static const Color info = lightCyan;
}

