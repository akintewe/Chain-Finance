import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'colors.dart';

class AppTextStyles {
  static TextStyle get heading => GoogleFonts.manrope(
    fontSize: 40,
    fontWeight: FontWeight.w700,
    color: AppColors.text,
    height: 1.2,
  );

  static TextStyle get heading2 => GoogleFonts.manrope(
    fontSize: 30,
    fontWeight: FontWeight.w400,
    color: AppColors.text,
    
  );

  static TextStyle get body => GoogleFonts.manrope(
    fontSize: 12,
    fontWeight: FontWeight.w300,
    color: AppColors.textSecondary,
  );

  static TextStyle get body2 => GoogleFonts.manrope(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
  );

  static TextStyle get button => GoogleFonts.manrope(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );
}