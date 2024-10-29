import 'package:flutter/material.dart';
import 'colors.dart';
import 'text_styles.dart';

class AppButtonStyles {
  static ButtonStyle primaryButton = ElevatedButton.styleFrom(
    foregroundColor: Colors.white,
    minimumSize: const Size(165, 56),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    padding: EdgeInsets.zero,
    elevation: 0,
  ).copyWith(
    backgroundColor: MaterialStateProperty.all(Colors.transparent),
    overlayColor: MaterialStateProperty.all(Colors.transparent),
  );

  static ButtonStyle outlinedButton = OutlinedButton.styleFrom(
    foregroundColor: AppColors.secondary,
    backgroundColor: Colors.black,
    minimumSize: const Size(165, 56),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    side: const BorderSide(color: AppColors.secondary),
  );
}