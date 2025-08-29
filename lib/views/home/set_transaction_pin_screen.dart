import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:nexa_prime/controllers/auth_controller.dart';
import 'package:nexa_prime/utils/colors.dart';
import 'package:nexa_prime/utils/text_styles.dart';
import 'package:nexa_prime/utils/button_style.dart';
import 'package:nexa_prime/utils/responsive_helper.dart';

class SetTransactionPinScreen extends StatelessWidget {
  SetTransactionPinScreen({super.key});

  final TextEditingController pinController = TextEditingController();
  final AuthController authController = Get.find();
  final RxBool _isComplete = false.obs;

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
        title: Text('Set Transaction PIN', style: AppTextStyles.button),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: ResponsiveHelper.getResponsiveAllPadding(context, all: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Create 4-digit PIN', 
                  style: AppTextStyles.heading.copyWith(fontSize: 32),
                ),
                const SizedBox(height: 12),
                Text(
                  'This PIN will be required to authorize transactions.',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 32),

                PinCodeTextField(
                  appContext: context,
                  length: 4,
                  controller: pinController,
                  cursorColor: AppColors.secondary,
                  keyboardType: TextInputType.number,
                  obscureText: true,
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
                    _isComplete.value = value.length == 4;
                  },
                ),

                const SizedBox(height: 32),

                Obx(() => Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: _isComplete.value
                            ? AppColors.primaryGradient
                            : LinearGradient(
                                colors: AppColors.primaryGradient.colors
                                    .map((c) => c.withOpacity(0.5))
                                    .toList(),
                                begin: AppColors.primaryGradient.begin,
                                end: AppColors.primaryGradient.end,
                              ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ElevatedButton(
                        style: AppButtonStyles.primaryButton,
                        onPressed: _isComplete.value
                            ? () => authController
                                .setTransactionPinForCurrentUser(pinController.text)
                            : null,
                        child: Text('Set PIN', style: AppTextStyles.button),
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


