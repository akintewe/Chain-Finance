import 'package:nexa_prime/controllers/wallet_controller.dart';
import 'package:nexa_prime/utils/colors.dart';
import 'package:nexa_prime/utils/text_styles.dart';
import 'package:nexa_prime/utils/button_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SwapScreen extends StatefulWidget {
  const SwapScreen({super.key});

  @override
  State<SwapScreen> createState() => _SwapScreenState();
}

class _SwapScreenState extends State<SwapScreen> {
  final TextEditingController fromAmountController = TextEditingController();
  final TextEditingController toAmountController = TextEditingController();
  final WalletController walletController = Get.put(WalletController());
  
  String? selectedFromToken;
  String? selectedToToken;
  final RxDouble conversionRate = 0.0.obs;
  final RxBool isCalculating = false.obs;

  // Dummy conversion rates (you would fetch these from an API in production)
  final Map<String, double> conversionRates = {
    'BTC': 35000.0,
    'ETH': 2200.0,
    'TRX': 0.08,
    'USDT': 1.0,
  };

  void calculateToAmount(String fromAmount) {
    if (fromAmount.isEmpty || selectedFromToken == null || selectedToToken == null) {
      toAmountController.text = '';
      conversionRate.value = 0.0;
      return;
    }

    try {
      isCalculating.value = true;
      double amount = double.parse(fromAmount);
      double fromRate = conversionRates[selectedFromToken]!;
      double toRate = conversionRates[selectedToToken]!;
      
      double convertedAmount = (amount * fromRate) / toRate;
      conversionRate.value = convertedAmount / amount;
      toAmountController.text = convertedAmount.toStringAsFixed(8);
    } catch (e) {
      toAmountController.text = '';
      conversionRate.value = 0.0;
    } finally {
      isCalculating.value = false;
    }
  }

  Widget _buildTokenSelector({
    required String label,
    required String? selectedToken,
    required Function(String?) onChanged,
    TextEditingController? controller,
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.body2),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.1),
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller,
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.text,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        keyboardType: TextInputType.number,
                        readOnly: readOnly,
                        onChanged: (value) => calculateToAmount(value),
                        decoration: InputDecoration(
                          hintText: '0.00',
                          hintStyle: AppTextStyles.body.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.1),
                        ),
                      ),
                      child: Obx(() => DropdownButton<String>(
                        value: selectedToken,
                        hint: Text('Select', style: AppTextStyles.body2),
                        underline: const SizedBox(),
                        dropdownColor: AppColors.surface,
                        items: walletController.tokens.map((token) {
                          return DropdownMenuItem<String>(
                            value: token['symbol'],
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.asset(
                                  token['icon'],
                                  width: 24,
                                  height: 24,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  token['symbol'],
                                  style: AppTextStyles.body2,
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: onChanged,
                      )),
                    ),
                  ],
                ),
              ),
              if (selectedToken != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: AppColors.textSecondary.withOpacity(0.1),
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Available Balance',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Obx(() => Text(
                        walletController.getBalanceForToken(selectedToken),
                        style: AppTextStyles.body2,
                      )),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    walletController.fetchWalletDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Swap',
                style: AppTextStyles.heading.copyWith(fontSize: 32),
              ),
              const SizedBox(height: 24),
              
              _buildTokenSelector(
                label: 'From',
                selectedToken: selectedFromToken,
                onChanged: (value) {
                  setState(() {
                    selectedFromToken = value;
                    calculateToAmount(fromAmountController.text);
                  });
                },
                controller: fromAmountController,
              ),
              
              const SizedBox(height: 16),
              
              // Swap direction button
              Center(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.1),
                    ),
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.swap_vert,
                      color: AppColors.secondary,
                    ),
                    onPressed: () {
                      setState(() {
                        final tempToken = selectedFromToken;
                        selectedFromToken = selectedToToken;
                        selectedToToken = tempToken;
                        calculateToAmount(fromAmountController.text);
                      });
                    },
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              _buildTokenSelector(
                label: 'To',
                selectedToken: selectedToToken,
                onChanged: (value) {
                  setState(() {
                    selectedToToken = value;
                    calculateToAmount(fromAmountController.text);
                  });
                },
                controller: toAmountController,
                readOnly: true,
              ),
              
              if (conversionRate.value > 0) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.1),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Exchange Rate',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        '1 ${selectedFromToken} = ${conversionRate.value.toStringAsFixed(8)} ${selectedToToken}',
                        style: AppTextStyles.body2,
                      ),
                    ],
                  ),
                ),
              ],
              
              const Spacer(),
              
              // Swap button
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  gradient: selectedFromToken != null && 
                           selectedToToken != null && 
                           fromAmountController.text.isNotEmpty
                      ? AppColors.primaryGradient
                      : LinearGradient(
                          colors: AppColors.primaryGradient.colors
                              .map((color) => color.withOpacity(0.5))
                              .toList(),
                          begin: AppColors.primaryGradient.begin,
                          end: AppColors.primaryGradient.end,
                        ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: selectedFromToken != null && 
                           selectedToToken != null && 
                           fromAmountController.text.isNotEmpty
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ]
                      : null,
                ),
                child: ElevatedButton(
                  style: AppButtonStyles.primaryButton,
                  onPressed: selectedFromToken != null && 
                           selectedToToken != null && 
                           fromAmountController.text.isNotEmpty
                      ? () {
                          // Implement swap functionality
                          Get.snackbar(
                            'Success',
                            'Swap executed successfully',
                            backgroundColor: AppColors.surface,
                            colorText: AppColors.text,
                          );
                        }
                      : null,
                  child: Obx(() => isCalculating.value
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text('Swap', style: AppTextStyles.button),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}