import 'dart:async';

import 'package:chain_finance/controllers/wallet_controller.dart';
import 'package:chain_finance/utils/colors.dart';
import 'package:chain_finance/utils/custom_textfield.dart';
import 'package:chain_finance/utils/text_styles.dart';
import 'package:chain_finance/utils/button_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class SendScreen extends StatefulWidget {
  final bool isSendingToExternal;
  
  const SendScreen({
    super.key, 
    required this.isSendingToExternal,
  });

  @override
  State<SendScreen> createState() => _SendScreenState();
}

class _SendScreenState extends State<SendScreen> {
  final TextEditingController amountController = TextEditingController();
  final TextEditingController uuidController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  final WalletController walletController = Get.find();
  String? selectedToken;
  final RxMap<String, dynamic> receiverData = <String, dynamic>{}.obs;
  final RxBool isLoadingUser = false.obs;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    // Fetch wallet details when screen initializes
    walletController.fetchWalletDetails();
  }

  void _onUUIDChanged(String uuid) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    if (uuid.length < 4) return;

    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      isLoadingUser.value = true;
      final userData = await walletController.getUserByUUID(uuid);
      if (userData != null) {
        receiverData.value = userData;
      } else {
        receiverData.clear();
      }
      isLoadingUser.value = false;
    });
  }

  Widget _buildTokenDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Obx(() => DropdownButtonFormField<String>(
        value: selectedToken,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: AppColors.surface,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        dropdownColor: AppColors.surface,
        style: AppTextStyles.body.copyWith(
          color: AppColors.text,
        ),
        hint: Text('Select Token', style: AppTextStyles.body.copyWith(
          color: AppColors.textSecondary,
        )),
        items: walletController.tokens.map((token) {
          return DropdownMenuItem<String>(
            value: token['symbol'],
            child: Row(
              children: [
                Image.asset(
                  token['icon'],
                  width: 24,
                  height: 24,
                ),
                const SizedBox(width: 12),
                Text(token['name']),
              ],
            ),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            selectedToken = value;
          });
        },
      )),
    );
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
        title: Text(
          widget.isSendingToExternal ? 'Send to External Wallet' : 'Send to Chain Finance User',
          style: AppTextStyles.button
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.isSendingToExternal) ...[
              // Add alert message for external transfers
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.secondary.withOpacity(0.5),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: AppColors.secondary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Only send tokens through Binance Smart Chain Network',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.text,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
            // Token Selection
            Text('Select Token', style: AppTextStyles.body.copyWith(
              color: AppColors.text,
              fontSize: 16,
            )),
            const SizedBox(height: 8),
            _buildTokenDropdown(),
            const SizedBox(height: 24),

            if (widget.isSendingToExternal) ...[
              // Wallet Address Input
              CustomTextField(
                label: 'Wallet Address',
                controller: addressController,
                hintText: 'Enter wallet address',
              ),
            ] else ...[
              // UUID Input with User Info
              CustomTextField(
                label: 'Recipient ID',
                controller: uuidController,
                hintText: 'Enter recipient\'s ID',
                onChanged: _onUUIDChanged,
              ),
              const SizedBox(height: 8),
              
              // User Info Section
              Obx(() => AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: isLoadingUser.value
                  ? const Center(child: CircularProgressIndicator())
                  : receiverData.isNotEmpty
                    ? Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.primary.withOpacity(0.1)),
                        ),
                        child: Row(
                          children: [
                            const CircleAvatar(
                              radius: 20,
                              backgroundColor: AppColors.primary,
                              child: Icon(Icons.person, color: Colors.white),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    receiverData['name'] ?? '',
                                    style: AppTextStyles.body2,
                                  ),
                                  Text(
                                    receiverData['email'] ?? '',
                                    style: AppTextStyles.body.copyWith(
                                      color: AppColors.textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink(),
              )),
              
              const SizedBox(height: 24),
              
              // Note Input (only for internal transfers)
              CustomTextField(
                label: 'Note (Optional)',
                controller: noteController,
                hintText: 'Add a note to this transfer',
                maxLines: 2,
              ),
            ],

            const SizedBox(height: 24),
            
            // Amount Input
            _buildAmountField(),
            const SizedBox(height: 32),

            // Send Button
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: ElevatedButton(
                style: AppButtonStyles.primaryButton,
                onPressed: () => _handleSend(),
                child: Text('Send', style: AppTextStyles.button),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSend() async {
    if (selectedToken == null || amountController.text.isEmpty) {
      Get.snackbar('Error', 'Please fill in all required fields');
      return;
    }

    try {
      if (widget.isSendingToExternal) {
        await walletController.sendExternal({
          'to_address': addressController.text,
          'amount': double.parse(amountController.text),
        });
      } else {
        await walletController.sendInternal({
          'receiver_uuid': uuidController.text,
          'amount': double.parse(amountController.text),
          'currency': selectedToken,
          'note': noteController.text,
        });
      }
      Get.back();
      Get.snackbar('Success', 'Transaction sent successfully');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  Widget _buildAmountField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          label: 'Amount',
          controller: amountController,
          hintText: '0.00',
        ),
        if (selectedToken != null) ...[
          const SizedBox(height: 8),
          Obx(() {
            final balance = walletController.getBalanceForToken(selectedToken!);
            return Text(
              'Available Balance: $balance $selectedToken',
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            );
          }),
        ],
      ],
    );
  }
} 