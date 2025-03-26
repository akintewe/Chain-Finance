import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF6E8BFF);
  static const Color secondary = Color(0xFF00F8E2);
  static const Color background = Color(0xFF0A1929); // Deep navy blue background
  static const Color surface = Color(0xFF1A2939); // Slightly lighter navy for surface
  static const Color text = Colors.white;
  static const Color textSecondary = Color(0xFF8E8E93);
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);
  static Color gradient = Color.fromRGBO(62, 198, 235, 1);
  static const Color bottomNavBackground = Color(0xFF1A2939); // Matching surface color
  static const Color bottomNavSelected = Color(0xFF6E8BFF); // Matching primary color
  static const Color bottomNavUnselected = Color(0xFF8E8E93); // Matching textSecondary color
  
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF00F8E2), Color(0xFF6E8BFF)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}