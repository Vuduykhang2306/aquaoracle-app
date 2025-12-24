import 'package:flutter/material.dart';

class AppColors {
  // Ocean Blue Theme - iOS Style
  static const Color oceanPrimary = Color(0xFF006994); // Deep Ocean Blue
  static const Color oceanSecondary = Color(0xFF00A8CC); // Bright Ocean Blue
  static const Color oceanAccent = Color(0xFF4DD0E1); // Light Cyan
  
  // Bảng màu Light Mode - Ocean Theme
  static const Color lightPrimary = Color(0xFF006994);
  static const Color lightPrimaryDark = Color(0xFF004D6D);
  static const Color lightBackground = Color(0xFFF0F9FF); // Very light blue
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightText = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF64748B);
  
  // Glass effect colors
  static const Color glassWhite = Color(0xFFFFFFFF);
  static const Color glassBorder = Color(0x33FFFFFF);

  // Bảng màu Dark Mode - Ocean Theme
  static const Color darkPrimary = Color(0xFF4DD0E1);
  static const Color darkBackground = Color(0xFF001F3F); // Deep Navy
  static const Color darkCard = Color(0xFF003D5C); // Ocean Dark
  static const Color darkText = Color(0xFFE2E8F0);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  
  // Gradient colors for ocean effect
  static const oceanGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF006994),
      Color(0xFF00A8CC),
      Color(0xFF4DD0E1),
    ],
  );
  
  static const darkOceanGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF001F3F),
      Color(0xFF003D5C),
      Color(0xFF006994),
    ],
  );
}