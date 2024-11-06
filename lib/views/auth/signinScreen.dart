import 'package:chain_finance/routes/routes.dart';
import 'package:chain_finance/utils/custom_textfield.dart';
import 'package:chain_finance/views/auth/forgot_password_screen.dart';
import 'package:chain_finance/views/dashboard/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/colors.dart';
import '../../utils/text_styles.dart';
import '../../utils/button_style.dart';


class SignInScreen extends StatelessWidget {
  SignInScreen({super.key});

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final RxBool rememberMe = false.obs;

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
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ElevatedButton(
                    style: AppButtonStyles.primaryButton,
                    onPressed: () {
                      Get.off(
                        () => const DashboardScreen(),
                        transition: Transition.fade,
                        duration: const Duration(milliseconds: 500),
                      );
                    },
                    child: Text('Sign in', style: AppTextStyles.button),
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