import 'package:chain_finance/routes/routes.dart';
import 'package:chain_finance/utils/custom_textfield.dart';
import 'package:chain_finance/views/auth/forgot_password_screen.dart';
import 'package:chain_finance/views/dashboard/dashboard_screen.dart';
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
                Text('Sign in', style: AppTextStyles.heading2),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => Routes.navigateToSignup(),
                  child: RichText(
                    text: TextSpan(
                      style: AppTextStyles.body,
                      children: [
                        const TextSpan(
                          text: "If you don't have an account created, you can \n",
                        ),
                        TextSpan(
                          text: 'Sign Up here!',
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.secondary,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                
                CustomTextField(
                  label: 'Email',
                  controller: emailController,
                  hintText: 'johngray@gmail.com',
                  onChanged: (val) => validateForm(),
                ),
                const SizedBox(height: 16),
                
                CustomTextField(
                  label: 'Password',
                  controller: passwordController,
                  isPassword: true,
                  hasIcon: true,
                  hintText: '**************',
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
                        Text('Remember me?', 
                          style: AppTextStyles.body.copyWith(color: AppColors.text),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () => Get.to(() => ForgotPasswordScreen()),
                      child: Text(
                        'Forgot password?',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.secondary,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // Sign in button
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
                      ? () => _authController.login(
                          email: emailController.text,
                          password: passwordController.text,
                        )
                      : null,
                    child: Text('Sign In', style: AppTextStyles.button),
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