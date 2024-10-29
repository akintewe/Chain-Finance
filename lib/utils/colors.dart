import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF6E8BFF);
  static const Color secondary = Color(0xFF00F8E2);
  static const Color background = Colors.black;
  static const Color surface = Color(0xFF1E1E1E);
  static const Color text = Colors.white;
  static const Color textSecondary = Color(0xFF8E8E93);
  
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF00F8E2), Color(0xFF6E8BFF)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}