import 'package:nexa_prime/controllers/wallet_controller.dart';
import 'package:nexa_prime/utils/colors.dart';
import 'package:nexa_prime/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SendDialog extends StatefulWidget {
  final Map<String, dynamic> token;

  const SendDialog({super.key, required this.token});

  @override
  State<SendDialog> createState() => _SendDialogState();
}

class _SendDialogState extends State<SendDialog> with SingleTickerProviderStateMixin {
  final TextEditingController addressController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final WalletController walletController = Get.put(WalletController());
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
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

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Dialog(
              backgroundColor: AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Container(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Send ${widget.token['symbol']}',
                          style: AppTextStyles.heading2,
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: AppColors.textSecondary),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Token Info
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Image.asset(
                              widget.token['icon'],
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
                                  widget.token['name'],
                                  style: AppTextStyles.body2.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Balance: ${widget.token['balance']} ${widget.token['symbol']}',
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
                    const SizedBox(height: 24),

                    // Address Input
                    TextField(
                      controller: addressController,
                      style: AppTextStyles.body.copyWith(color: AppColors.text),
                      decoration: InputDecoration(
                        labelText: 'Recipient Address',
                        labelStyle: AppTextStyles.body.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        hintText: 'Enter wallet address',
                        hintStyle: AppTextStyles.body.copyWith(
                          color: AppColors.textSecondary.withOpacity(0.5),
                        ),
                        filled: true,
                        fillColor: AppColors.background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: Container(
                          padding: const EdgeInsets.all(12),
                          child: Icon(
                            Icons.account_balance_wallet,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Amount Input
                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      style: AppTextStyles.body.copyWith(color: AppColors.text),
                      decoration: InputDecoration(
                        labelText: 'Amount',
                        labelStyle: AppTextStyles.body.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        hintText: 'Enter amount',
                        hintStyle: AppTextStyles.body.copyWith(
                          color: AppColors.textSecondary.withOpacity(0.5),
                        ),
                        filled: true,
                        fillColor: AppColors.background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: Container(
                          padding: const EdgeInsets.all(12),
                          child: Text(
                            widget.token['symbol'],
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Send Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // Implement send functionality
                          Get.back();
                        },
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
          ),
        );
      },
    );
  }
} 