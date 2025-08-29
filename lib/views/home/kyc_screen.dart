import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import '../../controllers/kyc_controller.dart';
import '../../utils/colors.dart';
import '../../utils/responsive_helper.dart';


class KYCScreen extends StatelessWidget {
  const KYCScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(KYCController());

    // Navigation is now handled directly in the controller

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'KYC Verification',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: ResponsiveHelper.getResponsiveAllPadding(context, all: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(),
            const SizedBox(height: 24),
            _buildDocumentSection(
              title: 'Identification Card',
              subtitle: 'Upload both front and back sides of your ID card',
              controller: controller,
            ),
            const SizedBox(height: 24),
            _buildDocumentSection(
              title: 'Utility Bill',
              subtitle: 'Upload a recent utility bill as proof of address',
              controller: controller,
              isUtilityBill: true,
            ),
            const SizedBox(height: 32),
            _buildSubmitButton(controller),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.verified_user_outlined,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'KYC Verification Required',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Please upload the required documents to complete your verification. This helps ensure account security and regulatory compliance.',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentSection({
    required String title,
    required String subtitle,
    required KYCController controller,
    bool isUtilityBill = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          if (!isUtilityBill) ...[
            _buildFileUploadCard(
              title: 'Front Side',
              subtitle: 'Upload the front of your ID card',
              icon: Icons.credit_card,
              onTap: () => controller.pickFile('front'),
              file: controller.identificationCardFront,
              error: controller.frontCardError,
            ),
            const SizedBox(height: 12),
            _buildFileUploadCard(
              title: 'Back Side',
              subtitle: 'Upload the back of your ID card',
              icon: Icons.credit_card,
              onTap: () => controller.pickFile('back'),
              file: controller.identificationCardBack,
              error: controller.backCardError,
            ),
          ] else ...[
            _buildFileUploadCard(
              title: 'Utility Bill',
              subtitle: 'Upload a recent utility bill (electricity, water, gas)',
              icon: Icons.receipt_long,
              onTap: () => controller.pickFile('utility'),
              file: controller.utilityBill,
              error: controller.utilityBillError,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFileUploadCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    required Rx<File?> file,
    required RxString error,
  }) {
    return Obx(() {
      final hasFile = file.value != null;
      final hasError = error.value.isNotEmpty;

      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: hasFile 
              ? AppColors.primary.withOpacity(0.1)
              : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: hasError 
                ? Colors.red.withOpacity(0.5)
                : hasFile 
                    ? AppColors.primary.withOpacity(0.3)
                    : Colors.grey.withOpacity(0.3),
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: hasFile 
                        ? AppColors.primary.withOpacity(0.2)
                        : Colors.grey.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    hasFile ? Icons.check_circle : icon,
                    color: hasFile ? AppColors.primary : Colors.grey,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: hasFile ? Colors.white : Colors.grey,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        hasFile 
                            ? 'File selected: ${file.value!.path.split('/').last}'
                            : subtitle,
                        style: TextStyle(
                          color: hasFile ? AppColors.primary : Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                      if (hasError) ...[
                        const SizedBox(height: 4),
                        Text(
                          error.value,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  Icons.upload_file,
                  color: hasFile ? AppColors.primary : Colors.grey,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildSubmitButton(KYCController controller) {
    return Obx(() {
      final hasAllFiles = controller.identificationCardFront.value != null &&
          controller.identificationCardBack.value != null &&
          controller.utilityBill.value != null;

      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: hasAllFiles ? controller.submitKYC : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: hasAllFiles ? AppColors.primary : Colors.grey.withOpacity(0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              'Submit KYC Documents',
              style: TextStyle(
                color: hasAllFiles ? Colors.white : Colors.grey,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      );
    });
  }
} 