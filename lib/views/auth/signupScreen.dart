import 'package:chain_finance/routes/routes.dart';
import 'package:chain_finance/utils/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/colors.dart';
import '../../utils/text_styles.dart';
import '../../utils/button_style.dart';


class SignUpScreen extends StatelessWidget {
  SignUpScreen({super.key});

  final TextEditingController emailController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController referralController = TextEditingController();

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
                ),
                const SizedBox(height: 16),
                
                CustomTextField(
                  label: 'User name',
                  controller: usernameController,
                  hintText: 'JohnGrayy123',
                ),
                const SizedBox(height: 16),
                
                CustomTextField(
                  label: 'Password',
                  controller: passwordController,
                  isPassword: true,
                  hasIcon: true,
                  hintText: '**************',
                ),
                const SizedBox(height: 16),
                
                CustomTextField(
                  label: 'Confirm Password',
                  controller: confirmPasswordController,
                  isPassword: true,
                  hasIcon: true,
                  hintText: 'Re-enter Password',
                ),
                const SizedBox(height: 30),
                
              
                
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ElevatedButton(
                    style: AppButtonStyles.primaryButton,
                    onPressed: () {},
                    child: Text('Get Started', style: AppTextStyles.button),
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