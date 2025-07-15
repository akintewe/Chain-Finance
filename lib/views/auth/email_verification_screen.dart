import 'dart:async';
import 'package:nexa_prime/utils/colors.dart';
import 'package:nexa_prime/utils/text_styles.dart';
import 'package:nexa_prime/utils/button_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:nexa_prime/controllers/auth_controller.dart';

class EmailVerificationScreen extends StatefulWidget {
  final String email;
  const EmailVerificationScreen({super.key, required this.email});

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final TextEditingController otpController = TextEditingController();
  final AuthController authController = Get.find();
  Timer? _timer;
  final RxInt _remainingTime = 60.obs;
  final RxBool _canResend = false.obs;
  final RxBool _isOtpComplete = false.obs;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    _canResend.value = false;
    _remainingTime.value = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime.value > 0) {
        _remainingTime.value--;
      } else {
        _canResend.value = true;
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    otpController.dispose();
    super.dispose();
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
                Text('Verify Email', 
                  style: AppTextStyles.heading.copyWith(fontSize: 36),
                ),
                const SizedBox(height: 12),
                Text(
                  'Please enter the verification code sent to your email',
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
                  },
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
                    Obx(() => TextButton(
                      onPressed: _canResend.value 
                        ? () {
                            authController.resendOTP(widget.email);
                            startTimer();
                          }
                        : null,
                      child: Text(
                        _canResend.value 
                          ? 'Resend' 
                          : 'Resend in ${_remainingTime.value}s',
                        style: AppTextStyles.body.copyWith(
                          color: _canResend.value 
                            ? AppColors.secondary
                            : AppColors.textSecondary,
                          decoration: _canResend.value 
                            ? TextDecoration.underline
                            : null,
                        ),
                      ),
                    )),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                Obx(() => Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: _isOtpComplete.value 
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
                    style: _isOtpComplete.value 
                      ? AppButtonStyles.primaryButton
                      : AppButtonStyles.disabledButton,
                    onPressed: _isOtpComplete.value
                      ? () => authController.verifyEmailOTP(otpController.text, widget.email)
                      : null,
                    child: Text('Verify', style: AppTextStyles.button),
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