import 'package:nexa_prime/controllers/auth_controller.dart';
import 'package:nexa_prime/utils/colors.dart';
import 'package:nexa_prime/utils/custom_textfield.dart';
import 'package:nexa_prime/utils/text_styles.dart';
import 'package:nexa_prime/utils/button_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController currentPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final AuthController authController = Get.find();
  final RxBool _isLoading = false.obs;
  final RxBool _isFormValid = false.obs;
  final RxString _passwordError = ''.obs;

  void _validateForm() {
    final bool isCurrentPasswordValid = currentPasswordController.text.length >= 8;
    final bool isNewPasswordValid = newPasswordController.text.length >= 8;
    final bool isConfirmPasswordValid = confirmPasswordController.text.isNotEmpty &&
        newPasswordController.text == confirmPasswordController.text;

    if (confirmPasswordController.text.isNotEmpty &&
        newPasswordController.text != confirmPasswordController.text) {
      _passwordError.value = 'Passwords do not match';
    } else if (newPasswordController.text.isNotEmpty &&
        newPasswordController.text.length < 8) {
      _passwordError.value = 'Password must be at least 8 characters';
    } else {
      _passwordError.value = '';
    }

    _isFormValid.value =
        isCurrentPasswordValid && isNewPasswordValid && isConfirmPasswordValid;
  }

  Future<void> _changePassword() async {
    try {
      _isLoading.value = true;
      // TODO: Implement change password API call
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call
      Get.back();
      Get.snackbar(
        'Success',
        'Password changed successfully',
        backgroundColor: Colors.green.withOpacity(0.1),
        colorText: Colors.green,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    } finally {
      _isLoading.value = false;
    }
  }

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
        title: Text('Change Password', style: AppTextStyles.button),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomTextField(
              label: 'Current Password',
              controller: currentPasswordController,
              isPassword: true,
              hasIcon: true,
              hintText: 'Enter current password',
              onChanged: (val) => _validateForm(),
            ),
            const SizedBox(height: 16),

            CustomTextField(
              label: 'New Password',
              controller: newPasswordController,
              isPassword: true,
              hasIcon: true,
              hintText: 'Enter new password',
              onChanged: (val) => _validateForm(),
            ),
            const SizedBox(height: 16),

            CustomTextField(
              label: 'Confirm New Password',
              controller: confirmPasswordController,
              isPassword: true,
              hasIcon: true,
              hintText: 'Confirm new password',
              onChanged: (val) => _validateForm(),
            ),

            Obx(() => _passwordError.value.isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      _passwordError.value,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                      ),
                    ),
                  )
                : const SizedBox.shrink()),

            const SizedBox(height: 32),

            // Password requirements
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Password Requirements:',
                    style: AppTextStyles.body2,
                  ),
                  const SizedBox(height: 8),
                  _buildRequirement('At least 8 characters long'),
                  _buildRequirement('Contains at least one uppercase letter'),
                  _buildRequirement('Contains at least one number'),
                  _buildRequirement('Contains at least one special character'),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Change Password Button
            Obx(() => Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: _isFormValid.value
                        ? AppColors.primaryGradient
                        : LinearGradient(
                            colors: AppColors.primaryGradient.colors
                                .map((color) => color.withOpacity(0.5))
                                .toList(),
                            begin: AppColors.primaryGradient.begin,
                            end: AppColors.primaryGradient.end,
                          ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ElevatedButton(
                    style: AppButtonStyles.primaryButton,
                    onPressed: _isFormValid.value && !_isLoading.value
                        ? _changePassword
                        : null,
                    child: _isLoading.value
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text('Change Password', style: AppTextStyles.button),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildRequirement(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_outline,
            color: AppColors.textSecondary,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: AppTextStyles.body.copyWith(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
} 