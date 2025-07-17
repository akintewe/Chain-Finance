import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/kyc_controller.dart';
import '../../utils/colors.dart';
import '../../utils/text_styles.dart';
import '../../routes/routes.dart';

class KYCStatusScreen extends StatelessWidget {
  const KYCStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    print('Building KYC Status Screen...');
    
    // Initialize KYC controller safely
    KYCController controller;
    try {
      controller = Get.put(KYCController());
      print('KYC Controller initialized successfully');
    } catch (e) {
      print('Error initializing KYC controller: $e');
      controller = Get.find<KYCController>();
    }

    print('KYC Status: ${controller.kycStatus.value}');

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
          'KYC Status',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status Card
              _buildStatusCard(controller),
              
              const SizedBox(height: 32),
              
              // Information Section
              _buildInfoSection(),
              
              const SizedBox(height: 32),
              
              // Action Buttons
              _buildActionButtons(controller),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard(KYCController controller) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          // Status Icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: _getStatusColor(controller.kycStatus.value).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getStatusIcon(controller.kycStatus.value),
              color: _getStatusColor(controller.kycStatus.value),
              size: 40,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Status Title
          Text(
            _getStatusTitle(controller.kycStatus.value),
            style: AppTextStyles.heading.copyWith(fontSize: 24),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 8),
          
          // Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _getStatusColor(controller.kycStatus.value).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _getStatusColor(controller.kycStatus.value).withOpacity(0.3),
              ),
            ),
            child: Text(
              controller.kycStatus.value.toUpperCase(),
              style: TextStyle(
                color: _getStatusColor(controller.kycStatus.value),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Status Message
          Text(
            _getStatusMessage(controller.kycStatus.value),
            style: AppTextStyles.body.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.info_outline,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'About KYC Verification',
                style: AppTextStyles.body2.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Text(
            'KYC (Know Your Customer) verification is a regulatory requirement that helps ensure the security of your account and compliance with financial regulations.',
            style: AppTextStyles.body.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          
          const SizedBox(height: 12),
          
          Text(
            '• Required documents: Government-issued ID and utility bill\n• Processing time: 1-3 business days\n• You will be notified once verification is complete',
            style: AppTextStyles.body.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(KYCController controller) {
    return Column(
      children: [
        // Update KYC Button (only show if not verified)
        if (controller.kycStatus.value != 'verified')
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Get.toNamed(Routes.kycScreen);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Update KYC Documents',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        
        const SizedBox(height: 16),
        
        // Back to Settings Button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {
              Get.back();
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: BorderSide(color: AppColors.primary),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Back to Settings',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'verified':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      case 'not_submitted':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'verified':
        return Icons.check_circle;
      case 'pending':
        return Icons.hourglass_empty;
      case 'rejected':
        return Icons.cancel;
      case 'not_submitted':
        return Icons.pending;
      default:
        return Icons.help_outline;
    }
  }

  String _getStatusTitle(String status) {
    switch (status.toLowerCase()) {
      case 'verified':
        return 'KYC Verified!';
      case 'pending':
        return 'KYC Under Review';
      case 'rejected':
        return 'KYC Rejected';
      case 'not_submitted':
        return 'KYC Not Submitted';
      default:
        return 'KYC Status Unknown';
    }
  }

  String _getStatusMessage(String status) {
    switch (status.toLowerCase()) {
      case 'verified':
        return 'Your KYC verification has been completed successfully. You now have full access to all features.';
      case 'pending':
        return 'Your KYC documents are currently being reviewed by our team. This process typically takes 1-3 business days.';
      case 'rejected':
        return 'Your KYC verification was not approved. Please update your documents and try again.';
      case 'not_submitted':
        return 'You haven\'t submitted your KYC documents yet. Please complete the verification process to access all features.';
      default:
        return 'Unable to determine your KYC status. Please contact support if you need assistance.';
    }
  }
} 