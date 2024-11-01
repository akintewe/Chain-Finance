import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../utils/text_styles.dart';

class CustomTextField extends StatefulWidget {
  final String label;
  final bool isPassword;
  final String? hintText;
  final TextEditingController controller;
  final bool hasIcon;

  const CustomTextField({
    super.key,
    required this.label,
    this.isPassword = false,
    this.hintText,
    required this.controller,
    this.hasIcon = false,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: AppTextStyles.body.copyWith(
            color: AppColors.text,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextField(
            controller: widget.controller,
            obscureText: widget.isPassword ? _obscureText : false,
            style: AppTextStyles.body.copyWith(
              color: AppColors.text,
              fontSize: 16,
            ),
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: AppColors.surface,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              suffixIcon: widget.isPassword && widget.hasIcon
                  ? IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility_off : Icons.visibility,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}