import 'package:chain_finance/utils/colors.dart';
import 'package:chain_finance/utils/custom_textfield.dart';
import 'package:chain_finance/utils/text_styles.dart';
import 'package:chain_finance/utils/button_style.dart';
import 'package:chain_finance/views/auth/otp_verification_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ForgotPasswordScreen extends StatelessWidget {
  ForgotPasswordScreen({super.key});

  final TextEditingController phoneController = TextEditingController();

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
                Text('Forgot Password', 
                  style: AppTextStyles.heading.copyWith(fontSize: 36),
                ),
                const SizedBox(height: 12),
                Text(
                  'Please enter the phone number you want an OTP to be sent to',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 32),
                
                
                const SizedBox(height: 8),
                CustomTextField(
                  label: 'Phone Number',
                  controller: phoneController,
                  hintText: 'Enter Phone number',
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
                      Get.to(() => OTPVerificationScreen());
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