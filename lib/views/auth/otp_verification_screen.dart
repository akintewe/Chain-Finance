import 'package:chain_finance/utils/colors.dart';
import 'package:chain_finance/utils/text_styles.dart';
import 'package:chain_finance/utils/button_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:chain_finance/views/auth/new_password_screen.dart';

class OTPVerificationScreen extends StatelessWidget {
  OTPVerificationScreen({super.key});

  final TextEditingController otpController = TextEditingController();

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
                Text('Enter OTP', 
                  style: AppTextStyles.heading.copyWith(fontSize: 36),
                ),
                const SizedBox(height: 12),
                Text(
                  'Please enter the verification code sent to your phone',
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
                  onChanged: (value) {},
                ),
                
                const SizedBox(height: 24),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Didn't receive code? ",
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        'Resend',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.secondary,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
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
                    onPressed: () => Get.to(() => NewPasswordScreen()),
                    child: Text('Verify', style: AppTextStyles.button),
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