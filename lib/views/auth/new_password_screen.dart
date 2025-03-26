import 'package:nexa_prime/routes/routes.dart';
import 'package:nexa_prime/utils/colors.dart';
import 'package:nexa_prime/utils/custom_textfield.dart';
import 'package:nexa_prime/utils/text_styles.dart';
import 'package:nexa_prime/utils/button_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NewPasswordScreen extends StatelessWidget {
  NewPasswordScreen({super.key});

  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.text),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('New Password', 
                  style: AppTextStyles.heading.copyWith(fontSize: 36),
                ),
                const SizedBox(height: 12),
                Text(
                  'Please enter your new password',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 32),
                
                CustomTextField(
                  controller: passwordController,
                  isPassword: true,
                  hasIcon: true,
                  hintText: 'Enter new password',
                  prefixIcon: const Icon(
                    Icons.lock_outline,
                    color: AppColors.textSecondary,
                  ), label: '',
                ),
                
                const SizedBox(height: 16),
                
                CustomTextField(label: '',
                  controller: confirmPasswordController,
                  isPassword: true,
                  hasIcon: true,
                  hintText: 'Confirm new password',
                  prefixIcon: const Icon(
                    Icons.lock_outline,
                    color: AppColors.textSecondary,
                  ),
                ),
                
                const SizedBox(height: 32),
                
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ElevatedButton(
                    style: AppButtonStyles.primaryButton,
                    onPressed: () {
                      // Implement password reset logic
                      Get.offAllNamed(Routes.signin); // Navigate to sign in
                    },
                    child: Text('Continue', style: AppTextStyles.button),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 