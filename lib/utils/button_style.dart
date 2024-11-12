import 'package:flutter/material.dart';
import 'colors.dart';
import 'text_styles.dart';

class AppButtonStyles {
  static final LinearGradient _buttonGradient = const LinearGradient(
    colors: [
      Color.fromRGBO(62, 198, 235, 1),
      Color.fromRGBO(234, 105, 240, 1),
    ],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

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
    backgroundColor: Colors.black,
    minimumSize: const Size(165, 56),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    side: BorderSide(
      width: 1,
      color: Colors.transparent,
    ),
  ).copyWith(
    foregroundColor: MaterialStateProperty.all(
      const Color.fromRGBO(62, 198, 235, 1),
    ),
    overlayColor: MaterialStateProperty.all(Colors.transparent),
  );

  static Decoration get outlinedButtonDecoration => BoxDecoration(
    gradient: _buttonGradient,
    borderRadius: BorderRadius.circular(10),
    border: Border.all(
      width: 1,
      color: Colors.transparent,
    ),
  );

  static final disabledButton = ButtonStyle(
    backgroundColor: MaterialStateProperty.all(Colors.transparent),
    foregroundColor: MaterialStateProperty.all(Colors.white.withOpacity(0.5)),
    elevation: MaterialStateProperty.all(0),
    shape: MaterialStateProperty.all(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    ),
    padding: MaterialStateProperty.all(
      const EdgeInsets.symmetric(vertical: 16),
    ),
  );
}