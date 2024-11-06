import 'package:chain_finance/utils/colors.dart';
import 'package:chain_finance/utils/custom_textfield.dart';
import 'package:chain_finance/utils/text_styles.dart';
import 'package:chain_finance/utils/button_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SendScreen extends StatefulWidget {
  const SendScreen({super.key});

  @override
  State<SendScreen> createState() => _SendScreenState();
}

class _SendScreenState extends State<SendScreen> {
  final TextEditingController amountController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  String? selectedToken;

  // Dummy data for tokens
  final List<Map<String, dynamic>> tokens = [
    {
      'name': 'Bitcoin (BTC)',
      'symbol': 'BTC',
      'icon': 'assets/icons/Cryptocurrency (2).png',
    },
    {
      'name': 'Ethereum (ETH)',
      'symbol': 'ETH',
      'icon': 'assets/icons/Cryptocurrency (1).png',
    },
    {
      'name': 'Tron (TRX)',
      'symbol': 'TRX',
      'icon': 'assets/icons/Cryptocurrency.png',
    },
    {
      'name': 'USDT',
      'symbol': 'USDT',
      'icon': 'assets/icons/Cryptocurrency (3).png',
    },
  ];

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
        title: Text('Send', style: AppTextStyles.button),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Alert message
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
                          'All tokens are to be sent through Binance Smart Chain Network',
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.text,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Token Selection Dropdown
                Text('Select Token', style: AppTextStyles.body.copyWith(
                  color: AppColors.text,
                  fontSize: 16,
                )),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: DropdownButtonFormField<String>(
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
                    items: tokens.map((token) {
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
                  ),
                ),
                const SizedBox(height: 24),

                // Amount Input
                CustomTextField(
                  label: 'Amount',
                  controller: amountController,
                  hintText: '0.00',
                ),
                const SizedBox(height: 24),

                // Address Input
                CustomTextField(
                  label: 'Recipient Address',
                  controller: addressController,
                  hintText: 'Enter wallet address',
                ),
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
                    onPressed: () {
                      // Implement send functionality
                    },
                    child: Text('Send', style: AppTextStyles.button),
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