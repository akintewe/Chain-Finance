import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nexa_prime/controllers/wallet_controller.dart';
import 'package:nexa_prime/utils/colors.dart';
import 'package:nexa_prime/utils/text_styles.dart';
import 'package:nexa_prime/utils/responsive_helper.dart';

class SendConfirmationScreen extends StatelessWidget {
  final bool isSendingToExternal;
  final Map<String, dynamic> transactionData;
  final Map<String, dynamic> selectedToken;

  const SendConfirmationScreen({
    super.key,
    required this.isSendingToExternal,
    required this.transactionData,
    required this.selectedToken,
  });

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
        title: Text(
          'Confirm Transaction',
          style: AppTextStyles.heading2.copyWith(fontSize: 20),
        ),
      ),
      body: Padding(
        padding: ResponsiveHelper.getResponsiveAllPadding(context, all: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Transaction Type Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.1),
                    AppColors.secondary.withOpacity(0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  Icon(
                    isSendingToExternal ? Icons.wallet_outlined : Icons.person_outline,
                    size: 48,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isSendingToExternal ? 'External Transfer' : 'Internal Transfer',
                    style: AppTextStyles.heading2.copyWith(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isSendingToExternal 
                      ? 'Sending to external wallet address'
                      : 'Sending to Nexa Prime user',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Transaction Details
            Text(
              'Transaction Details',
              style: AppTextStyles.heading2.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),

            // Token Information
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withOpacity(0.1)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      selectedToken['symbol']?.toString().toUpperCase() ?? 'N/A',
                      style: AppTextStyles.heading2.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          selectedToken['name'] ?? 'Unknown Token',
                          style: AppTextStyles.heading2.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${selectedToken['balance']} ${selectedToken['symbol']}',
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Amount
            _buildDetailRow(
              'Amount',
              '${transactionData['amount']} ${selectedToken['symbol']}',
              AppColors.primary,
            ),

            // Recipient
            _buildDetailRow(
              isSendingToExternal ? 'To Address' : 'To User',
              isSendingToExternal 
                ? transactionData['to_address'] ?? 'N/A'
                : transactionData['receiver_uuid'] ?? 'N/A',
              AppColors.text,
            ),

            // Note (for internal transactions)
            if (!isSendingToExternal && transactionData['note']?.isNotEmpty == true)
              _buildDetailRow(
                'Note',
                transactionData['note'] ?? '',
                AppColors.textSecondary,
              ),

            const Spacer(),

            // Confirm Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _confirmTransaction(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.surface,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  'Confirm & Send',
                  style: AppTextStyles.button.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Cancel Button
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, Color valueColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.05)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.body.copyWith(
              color: AppColors.textSecondary,
              fontSize: 16,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: AppTextStyles.body2.copyWith(
                color: valueColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmTransaction(BuildContext context) async {
    try {
      final walletController = Get.find<WalletController>();
      
      if (isSendingToExternal) {
        // Send external transaction
        await walletController.sendExternal({
          'to_address': transactionData['to_address'],
          'amount': transactionData['amount'],
          'token': selectedToken['symbol']?.toString().toUpperCase() ?? '',
        });
      } else {
        // Send internal transaction
        await walletController.sendInternal({
          'receiver_uuid': transactionData['receiver_uuid'],
          'amount': transactionData['amount'],
          'currency': selectedToken['symbol']?.toString().toUpperCase() ?? '',
          'note': transactionData['note'] ?? '',
        });
      }

      // Show success message
      Get.snackbar(
        'Success',
        'Transaction sent successfully!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );

      // Navigate back to wallet screen
      Navigator.of(context).popUntil((route) => route.isFirst);
      
    } catch (e) {
      // Show error message
      Get.snackbar(
        'Error',
        'Failed to send transaction: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
    }
  }
}
