import 'package:nexa_prime/routes/routes.dart';
import 'package:nexa_prime/utils/custom_textfield.dart';
import 'package:nexa_prime/views/auth/forgot_password_screen.dart';
import 'package:nexa_prime/views/dashboard/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/colors.dart';
import '../../utils/text_styles.dart';
import '../../utils/button_style.dart';
import '../../controllers/auth_controller.dart';


class SignInScreen extends StatelessWidget {
  SignInScreen({super.key});

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final RxBool rememberMe = false.obs;
  final RxBool _isFormValid = false.obs;
  final AuthController _authController = Get.find<AuthController>();

  void validateForm() {
    final bool isEmailValid = emailController.text.isNotEmpty;
    final bool isPasswordValid = passwordController.text.isNotEmpty;

    _isFormValid.value = isEmailValid && isPasswordValid;
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
                
                Text('Welcome Back!', 
                  style: AppTextStyles.heading.copyWith(fontSize: 32),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sign in to continue to Nexa Prime',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 32),
                
                CustomTextField(
                  label: 'Email Address',
                  controller: emailController,
                  hintText: 'Enter your registered email',
                  prefixIcon: const Icon(
                    Icons.email_outlined,
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
                  hintText: 'Enter your password',
                  prefixIcon: const Icon(
                    Icons.lock_outline,
                    color: AppColors.textSecondary,
                  ),
                  onChanged: (val) => validateForm(),
                ),
                const SizedBox(height: 16),
                
                // Remember me and Forgot password row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Obx(() => Checkbox(
                          value: rememberMe.value,
                          onChanged: (value) => rememberMe.value = value!,
                          fillColor: MaterialStateProperty.resolveWith(
                            (states) => AppColors.secondary,
                          ),
                        )),
                        Text('Remember me', 
                          style: AppTextStyles.body.copyWith(color: AppColors.text),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () => Get.to(() => ForgotPasswordScreen()),
                      child: Text(
                        'Forgot Password?',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.secondary,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // Sign in button
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
                      ? () => _authController.login(
                          email: emailController.text,
                          password: passwordController.text,
                        )
                      : null,
                    child: Text('Sign In', style: AppTextStyles.button),
                  ),
                )),
                
                const SizedBox(height: 24),
                
                // Sign up link
                Center(
                  child: GestureDetector(
                    onTap: () => Routes.navigateToSignup(),
                    child: RichText(
                      text: TextSpan(
                        style: AppTextStyles.body,
                        children: [
                          const TextSpan(
                            text: "Don't have an account? ",
                          ),
                          TextSpan(
                            text: 'Sign Up',
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