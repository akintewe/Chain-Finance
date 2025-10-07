import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nexa_prime/controllers/virtual_account_controller.dart';
import 'package:nexa_prime/utils/colors.dart';
import 'package:nexa_prime/utils/text_styles.dart';
import 'package:nexa_prime/utils/responsive_helper.dart';

class FundVirtualAccountScreen extends StatefulWidget {
  const FundVirtualAccountScreen({super.key});

  @override
  State<FundVirtualAccountScreen> createState() => _FundVirtualAccountScreenState();
}

class _FundVirtualAccountScreenState extends State<FundVirtualAccountScreen> {
  late VirtualAccountController controller;
  final TextEditingController _amountController = TextEditingController();
  String _selectedMethod = 'bank_transfer';
  double _selectedAmount = 0.0;
  double _currentBalance = 5420.50; // Mock data

  final List<Map<String, dynamic>> _fundingMethods = [
    {
      'id': 'bank_transfer',
      'name': 'Bank Transfer',
      'description': 'Free • 1-3 business days',
      'icon': Icons.account_balance,
      'color': AppColors.primary,
    },
    {
      'id': 'crypto',
      'name': 'Cryptocurrency',
      'description': 'Free • 15-30 minutes',
      'icon': Icons.currency_bitcoin,
      'color': Color(0xFFF7931A),
    },
    {
      'id': 'card',
      'name': 'Debit/Credit Card',
      'description': '2.5% fee • Instant',
      'icon': Icons.credit_card,
      'color': Color(0xFF00A86B),
    },
  ];

  final List<double> _quickAmounts = [50, 100, 250, 500, 1000, 2500];

  @override
  void initState() {
    super.initState();
    // Initialize controller with error handling
    try {
      controller = Get.find<VirtualAccountController>();
    } catch (e) {
      controller = Get.put(VirtualAccountController());
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Fund Account',
          style: AppTextStyles.heading2.copyWith(
            color: AppColors.text,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.text),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: ResponsiveHelper.getResponsiveAllPadding(context, all: 20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCurrentBalance(),
              const SizedBox(height: 24),
              _buildAmountSection(),
              const SizedBox(height: 24),
              _buildFundingMethods(),
              const SizedBox(height: 32),
              _buildFundButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentBalance() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.surface,
            AppColors.surface.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.2),
                  AppColors.secondary.withOpacity(0.2),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.account_balance_wallet,
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
                  'Current Balance',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${_currentBalance.toStringAsFixed(2)}',
                  style: AppTextStyles.heading2.copyWith(
                    color: AppColors.text,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Amount to Add',
          style: AppTextStyles.heading2.copyWith(
            color: AppColors.text,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.1),
            ),
          ),
          child: Column(
            children: [
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                style: AppTextStyles.heading.copyWith(
                  color: AppColors.text,
                  fontSize: 32,
                ),
                decoration: InputDecoration(
                  hintText: '0.00',
                  hintStyle: AppTextStyles.heading.copyWith(
                    color: AppColors.textSecondary.withOpacity(0.3),
                    fontSize: 32,
                  ),
                  prefixText: '\$ ',
                  prefixStyle: AppTextStyles.heading.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 32,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: (value) {
                  setState(() {
                    _selectedAmount = double.tryParse(value) ?? 0.0;
                  });
                },
              ),
              const SizedBox(height: 20),
              const Divider(color: AppColors.textSecondary, height: 1),
              const SizedBox(height: 20),
              GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 2.2,
                children: _quickAmounts.map((amount) {
                  final isSelected = _selectedAmount == amount;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedAmount = amount;
                        _amountController.text = amount.toString();
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: isSelected ? AppColors.primaryGradient : null,
                        color: isSelected ? null : AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? Colors.transparent
                              : AppColors.primary.withOpacity(0.2),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '\$${amount.toStringAsFixed(0)}',
                          style: AppTextStyles.body.copyWith(
                            color: isSelected ? Colors.white : AppColors.text,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFundingMethods() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Payment Method',
          style: AppTextStyles.heading2.copyWith(
            color: AppColors.text,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ..._fundingMethods.map((method) => _buildFundingMethodCard(method)),
      ],
    );
  }

  Widget _buildFundingMethodCard(Map<String, dynamic> method) {
    final isSelected = _selectedMethod == method['id'];
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMethod = method['id'];
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.1),
                    AppColors.secondary.withOpacity(0.1),
                  ],
                )
              : null,
          color: isSelected ? null : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.primary.withOpacity(0.1),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (method['color'] as Color).withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                method['icon'],
                color: method['color'],
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    method['name'],
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.text,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    method['description'],
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 16,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFundButton() {
    return Column(
      children: [
        if (_selectedAmount > 0)
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.1),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'New Balance',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${(_currentBalance + _selectedAmount).toStringAsFixed(2)}',
                      style: AppTextStyles.heading2.copyWith(
                        color: AppColors.text,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.green.withOpacity(0.2),
                        Colors.green.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.trending_up,
                        color: Colors.green,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '+\$${_selectedAmount.toStringAsFixed(2)}',
                        style: AppTextStyles.body.copyWith(
                          color: Colors.green,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        SizedBox(
          width: double.infinity,
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              gradient: _selectedAmount > 0
                  ? AppColors.primaryGradient
                  : null,
              color: _selectedAmount > 0 ? null : AppColors.textSecondary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
              boxShadow: _selectedAmount > 0
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ]
                  : null,
            ),
            child: ElevatedButton(
              onPressed: _selectedAmount > 0 ? _fundAccount : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                disabledBackgroundColor: Colors.transparent,
              ),
              child: Text(
                'Add \$${_selectedAmount.toStringAsFixed(2)} to Account',
                style: AppTextStyles.body2.copyWith(
                  color: _selectedAmount > 0 ? Colors.white : AppColors.textSecondary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _fundAccount() {
    // Show success animation
    Get.snackbar(
      'Success',
      'Account funded successfully!',
      backgroundColor: Colors.green.withOpacity(0.1),
      colorText: Colors.green,
      duration: const Duration(seconds: 2),
    );
    
    // Navigate back after a delay
    Future.delayed(const Duration(seconds: 1), () {
      Get.back();
    });
  }
}
