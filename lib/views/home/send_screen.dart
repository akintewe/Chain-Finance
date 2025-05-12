import 'dart:async';

import 'package:nexa_prime/controllers/wallet_controller.dart';
import 'package:nexa_prime/utils/colors.dart';
import 'package:nexa_prime/utils/text_styles.dart';
import 'package:nexa_prime/utils/button_style.dart';
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

class _SendScreenState extends State<SendScreen> with SingleTickerProviderStateMixin {
  final TextEditingController amountController = TextEditingController();
  final TextEditingController uuidController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  final WalletController walletController = Get.find();
  String? selectedToken;
  final RxMap<String, dynamic> receiverData = <String, dynamic>{}.obs;
  final RxBool isLoadingUser = false.obs;
  Timer? _debounceTimer;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    walletController.fetchWalletDetails();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _debounceTimer?.cancel();
    amountController.dispose();
    uuidController.dispose();
    addressController.dispose();
    noteController.dispose();
    super.dispose();
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

  void _showTokenSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Token',
              style: AppTextStyles.heading2,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: walletController.tokens.length,
                itemBuilder: (context, index) {
                  final token = walletController.tokens[index];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedToken = token['symbol'];
                      });
                      Get.back();
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Image.asset(
                              token['icon'],
                              width: 32,
                              height: 32,
          ),
        ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  token['name'],
                                  style: AppTextStyles.body2.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${token['balance']} ${token['symbol']}',
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
          );
                },
              ),
            ),
          ],
        ),
      ),
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
          widget.isSendingToExternal ? 'Send to External Wallet' : 'Send to Nexa Prime User',
          style: AppTextStyles.heading2,
        ),
      ),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
                    // Quick Info Card
              Container(
                padding: const EdgeInsets.all(16),
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
                                child: Icon(
                      Icons.info_outline,
                                  color: AppColors.primary,
                                  size: 20,
                                ),
                    ),
                    const SizedBox(width: 12),
                              Text(
                                'Quick Info',
                                style: AppTextStyles.body2.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            widget.isSendingToExternal
                                ? '• Only send tokens through Binance Smart Chain Network\n• Double-check the wallet address\n• Transaction cannot be reversed'
                                : '• Instant transfers to Nexa Prime users\n• No network fees\n• Secure and reliable',
                        style: AppTextStyles.body.copyWith(
                              color: AppColors.textSecondary,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Token Selection
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Select Token',
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: _showTokenSelector,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.primary.withOpacity(0.1)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  if (selectedToken != null) ...[
                                    Row(
                                      children: [
                                        Image.asset(
                                          walletController.tokens
                                              .firstWhere((t) => t['symbol'] == selectedToken)['icon'],
                                          width: 24,
                                          height: 24,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          selectedToken!,
                                          style: AppTextStyles.body2.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ] else
                                    Text(
                                      'Select Token',
                                      style: AppTextStyles.body2.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    color: AppColors.textSecondary,
                                    size: 16,
                                  ),
                                ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 24),

            if (widget.isSendingToExternal) ...[
              // Wallet Address Input
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.primary.withOpacity(0.1)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Wallet Address',
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                controller: addressController,
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.text,
                              ),
                              decoration: InputDecoration(
                hintText: 'Enter wallet address',
                                hintStyle: AppTextStyles.body.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: AppColors.background,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
              ),
            ] else ...[
              // UUID Input with User Info
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.primary.withOpacity(0.1)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Recipient ID',
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.textSecondary,
                              ),
              ),
              const SizedBox(height: 8),
                            TextField(
                              controller: uuidController,
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.text,
                              ),
                              onChanged: _onUUIDChanged,
                              decoration: InputDecoration(
                                hintText: 'Enter recipient\'s ID',
                                hintStyle: AppTextStyles.body.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: AppColors.background,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
              
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
                                  borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.primary.withOpacity(0.1)),
                        ),
                        child: Row(
                          children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.person,
                                        color: AppColors.primary,
                                        size: 24,
                                      ),
                            ),
                                    const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    receiverData['name'] ?? '',
                                            style: AppTextStyles.body2.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
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
              
                      // Note Input
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.primary.withOpacity(0.1)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Note (Optional)',
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                controller: noteController,
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.text,
                              ),
                              maxLines: 2,
                              decoration: InputDecoration(
                hintText: 'Add a note to this transfer',
                                hintStyle: AppTextStyles.body.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: AppColors.background,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                              ),
              ),
            ],
                        ),
                      ),
                    ],
            const SizedBox(height: 24),
            
            // Amount Input
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Amount',
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: amountController,
                            style: AppTextStyles.heading2.copyWith(
                              color: AppColors.text,
                            ),
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: '0.00',
                              hintStyle: AppTextStyles.heading2.copyWith(
                                color: AppColors.textSecondary,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: AppColors.background,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                            ),
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
                      ),
                    ),
                    const SizedBox(height: 24),

            // Send Button
                    SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _handleSend(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.surface,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          'Send',
                          style: AppTextStyles.button.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
              ),
            ),
          ],
        ),
              ),
            ),
          );
        },
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
} 