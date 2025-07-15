import 'package:nexa_prime/utils/colors.dart';
import 'package:nexa_prime/utils/custom_textfield.dart';
import 'package:nexa_prime/utils/text_styles.dart';
import 'package:nexa_prime/utils/button_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:nexa_prime/views/auth/new_password_screen.dart';
import 'package:nexa_prime/controllers/auth_controller.dart';

class OTPVerificationScreen extends StatelessWidget {
  OTPVerificationScreen({super.key});

  final TextEditingController otpController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final RxBool _isOtpComplete = false.obs;
  final RxBool _isFormValid = false.obs;
  final RxString _passwordError = ''.obs;
  final AuthController authController = Get.find();

  void validateForm() {
    final bool isOtpValid = otpController.text.length == 4;
    final bool isPasswordValid = passwordController.text.isNotEmpty;
    final bool isConfirmPasswordValid = confirmPasswordController.text.isNotEmpty && 
                                    passwordController.text == confirmPasswordController.text;

    if (confirmPasswordController.text.isNotEmpty && 
        passwordController.text != confirmPasswordController.text) {
      _passwordError.value = 'Passwords do not match';
    } else {
      _passwordError.value = '';
    }

    _isFormValid.value = isOtpValid && isPasswordValid && isConfirmPasswordValid;
  }

  @override
  Widget build(BuildContext context) {
    final String email = Get.arguments as String;
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.text),
                      onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Reset Password', 
                  style: AppTextStyles.heading.copyWith(fontSize: 36),
                ),
                const SizedBox(height: 12),
                Text(
                  'Enter the verification code and your new password',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 32),
                
                PinCodeTextField(
                  appContext: context,
                  length: 4,
                  controller: otpController,
                  cursorColor: AppColors.secondary,
                  keyboardType: TextInputType.number,
                  textStyle: AppTextStyles.heading2.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  pinTheme: PinTheme(
                    shape: PinCodeFieldShape.box,
                    borderRadius: BorderRadius.circular(10),
                    fieldHeight: 60,
                    fieldWidth: 60,
                    activeFillColor: AppColors.surface,
                    inactiveFillColor: AppColors.surface,
                    selectedFillColor: AppColors.surface,
                    activeColor: AppColors.secondary,
                    inactiveColor: AppColors.surface,
                    selectedColor: AppColors.secondary,
                  ),
                  enableActiveFill: true,
                  onChanged: (value) {
                    _isOtpComplete.value = value.length == 4;
                    validateForm();
                  },
                ),
                
                const SizedBox(height: 24),
                
                CustomTextField(
                  label: 'New Password',
                  controller: passwordController,
                  isPassword: true,
                  hasIcon: true,
                  hintText: 'Enter new password',
                  onChanged: (val) => validateForm(),
                ),
                
                const SizedBox(height: 16),
                
                CustomTextField(
                  label: 'Confirm Password',
                  controller: confirmPasswordController,
                  isPassword: true,
                  hasIcon: true,
                  hintText: 'Confirm new password',
                  onChanged: (val) => validateForm(),
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
                  : const SizedBox.shrink()
                ),
                
                const SizedBox(height: 32),
                
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
                    onPressed: _isFormValid.value
                      ? () => authController.resetPassword(
                          email,
                          otpController.text,
                          passwordController.text,
                          confirmPasswordController.text,
                        )
                      : null,
                    child: Text('Reset Password', style: AppTextStyles.button),
                  ),
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 