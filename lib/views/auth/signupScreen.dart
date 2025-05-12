import 'package:nexa_prime/routes/routes.dart';
import 'package:nexa_prime/utils/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/colors.dart';
import '../../utils/text_styles.dart';
import '../../utils/button_style.dart';
import 'package:nexa_prime/controllers/auth_controller.dart';
import 'package:flutter_rx/flutter_rx.dart';

class SignUpScreen extends StatelessWidget {
  SignUpScreen({super.key});

  final TextEditingController emailController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController referralController = TextEditingController();

  final AuthController authController = Get.find();

  final RxBool _isFormValid = false.obs;
  final RxString _passwordError = ''.obs;

  void validateForm() {
    final bool isEmailValid = emailController.text.isNotEmpty;
    final bool isUsernameValid = usernameController.text.isNotEmpty;
    final bool isPasswordValid = passwordController.text.isNotEmpty;
    final bool isConfirmPasswordValid = confirmPasswordController.text.isNotEmpty && 
                                      passwordController.text == confirmPasswordController.text;

    if (confirmPasswordController.text.isNotEmpty && 
        passwordController.text != confirmPasswordController.text) {
      _passwordError.value = 'Passwords do not match';
    } else {
      _passwordError.value = '';
    }

    _isFormValid.value = isEmailValid && 
                        isUsernameValid && 
                        isPasswordValid && 
                        isConfirmPasswordValid;
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
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    margin: const EdgeInsets.only(bottom: 32),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppColors.primaryGradient,
                        ),
                    child: Image.asset(
                      'assets/images/WhatsApp Image 2025-03-25 at 10.07.55 AM.jpeg',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                
                Text('Create Account', 
                  style: AppTextStyles.heading.copyWith(fontSize: 32),
                ),
                const SizedBox(height: 8),
                Text(
                  'Join Nexa Prime and start your crypto journey',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 32),
                
                CustomTextField(
                  label: 'Email Address',
                  controller: emailController,
                  hintText: 'Enter your email address',
                  prefixIcon: const Icon(
                    Icons.email_outlined,
                    color: AppColors.textSecondary,
                  ),
                  onChanged: (val) => validateForm(),
                ),
                const SizedBox(height: 16),
                
                CustomTextField(
                  label: 'Username',
                  controller: usernameController,
                  hintText: 'Choose a username',
                  prefixIcon: const Icon(
                    Icons.person_outline,
                    color: AppColors.textSecondary,
                  ),
                  onChanged: (val) => validateForm(),
                ),
                const SizedBox(height: 16),
                
                CustomTextField(
                  label: 'Password',
                  controller: passwordController,
                  isPassword: true,
                  hasIcon: true,
                  hintText: 'Create a strong password',
                  prefixIcon: const Icon(
                    Icons.lock_outline,
                    color: AppColors.textSecondary,
                  ),
                  onChanged: (val) => validateForm(),
                ),
                const SizedBox(height: 16),
                
                CustomTextField(
                  label: 'Confirm Password',
                  controller: confirmPasswordController,
                  isPassword: true,
                  hasIcon: true,
                  hintText: 'Re-enter your password',
                  prefixIcon: const Icon(
                    Icons.lock_outline,
                    color: AppColors.textSecondary,
                  ),
                  onChanged: (val) => validateForm(),
                ),
                
                Obx(() => _passwordError.value.isNotEmpty
                  ? Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        _passwordError.value,
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                        ),
                      ),
                    )
                  : const SizedBox.shrink()
                ),
                
                const SizedBox(height: 24),
                
                // Terms and Conditions
                Row(
                  children: [
                    Obx(() => Checkbox(
                      value: _isFormValid.value,
                      onChanged: (value) => _isFormValid.value = value!,
                      fillColor: MaterialStateProperty.resolveWith(
                        (states) => AppColors.secondary,
                      ),
                    )),
                    Expanded(
                      child: Text(
                        'I agree to the Terms of Service and Privacy Policy',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // Sign up button
                Obx(() => Container(
                  width: double.infinity,
                  height: 56,
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
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: _isFormValid.value ? [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ] : null,
                  ),
                  child: ElevatedButton(
                    style: AppButtonStyles.primaryButton,
                    onPressed: _isFormValid.value 
                      ? () {
                          authController.registerUser(
                            name: usernameController.text,
                            email: emailController.text,
                            username: usernameController.text,
                            password: passwordController.text,
                            passwordConfirmation: confirmPasswordController.text,
                          );
                        }
                      : null,
                    child: Text('Create Account', style: AppTextStyles.button),
                  ),
                )),
                
                const SizedBox(height: 24),
                
                // Sign in link
                Center(
                  child: GestureDetector(
                    onTap: () => Routes.navigateToSignin(),
                    child: RichText(
                      text: TextSpan(
                        style: AppTextStyles.body,
                        children: [
                          const TextSpan(
                            text: "Already have an account? ",
                          ),
                          TextSpan(
                            text: 'Sign In',
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.secondary,
                              decoration: TextDecoration.underline,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
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