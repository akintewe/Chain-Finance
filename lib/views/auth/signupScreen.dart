import 'package:chain_finance/routes/routes.dart';
import 'package:chain_finance/utils/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/colors.dart';
import '../../utils/text_styles.dart';
import '../../utils/button_style.dart';
import 'package:chain_finance/controllers/auth_controller.dart';
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

  void validateForm() {
    final bool isEmailValid = emailController.text.isNotEmpty;
    final bool isUsernameValid = usernameController.text.isNotEmpty;
    final bool isPasswordValid = passwordController.text.isNotEmpty;
    final bool isConfirmPasswordValid = confirmPasswordController.text.isNotEmpty && 
                                      passwordController.text == confirmPasswordController.text;

    print('Email valid: $isEmailValid');
    print('Username valid: $isUsernameValid');
    print('Password valid: $isPasswordValid');
    print('Confirm password valid: $isConfirmPasswordValid');

    _isFormValid.value = isEmailValid && 
                        isUsernameValid && 
                        isPasswordValid && 
                        isConfirmPasswordValid;
    
    print('Form valid: ${_isFormValid.value}');
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
                Text('Sign Up', style: AppTextStyles.heading2),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => Routes.navigateToSignin(),
                  child: RichText(
                    text: TextSpan(
                      style: AppTextStyles.body,
                      children: [
                        const TextSpan(
                          text: 'If you already have an account registered, you can \n',
                        ),
                        TextSpan(
                          text: 'Login Here',
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
                  label: 'User name',
                  controller: usernameController,
                  hintText: 'JohnGrayy123',
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
                
                CustomTextField(
                  label: 'Confirm Password',
                  controller: confirmPasswordController,
                  isPassword: true,
                  hasIcon: true,
                  hintText: 'Re-enter Password',
                  onChanged: (val) => validateForm(),
                ),
                const SizedBox(height: 30),
                
              
                
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
                    child: Text('Get Started', style: AppTextStyles.button),
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