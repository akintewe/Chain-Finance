import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nexa_prime/controllers/virtual_account_controller.dart';
import 'package:nexa_prime/models/virtual_card.dart';
import 'package:nexa_prime/utils/colors.dart';
import 'package:nexa_prime/utils/text_styles.dart';
import 'package:nexa_prime/utils/responsive_helper.dart';
import 'package:nexa_prime/views/home/fund_virtual_account_screen.dart';
import 'package:nexa_prime/views/home/virtual_card_selection_screen.dart';

class VirtualAccountScreen extends StatefulWidget {
  final CardDesign? selectedDesign;

  const VirtualAccountScreen({
    super.key,
    this.selectedDesign,
  });

  @override
  State<VirtualAccountScreen> createState() => _VirtualAccountScreenState();
}

class _VirtualAccountScreenState extends State<VirtualAccountScreen> {
  late VirtualAccountController controller;
  final double _accountBalance = 5420.50; // Mock data
  final List<Map<String, dynamic>> _mockCards = []; // Start with no cards for demo

  @override
  void initState() {
    super.initState();
    // Initialize controller with error handling
    try {
      controller = Get.find<VirtualAccountController>();
    } catch (e) {
      controller = Get.put(VirtualAccountController());
    }
    
    // Set selected design if provided
    if (widget.selectedDesign != null) {
      controller.selectDesign(widget.selectedDesign!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Virtual Account',
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
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: AppColors.text),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: ResponsiveHelper.getResponsiveAllPadding(context, all: 20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBalanceCard(),
              const SizedBox(height: 20),
              _buildQuickActions(),
              const SizedBox(height: 24),
              _buildCardsSection(),
              const SizedBox(height: 24),
              _buildTransactionsSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Balance',
                    style: AppTextStyles.body.copyWith(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        '\$',
                        style: AppTextStyles.heading.copyWith(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _accountBalance.toStringAsFixed(2),
                        style: AppTextStyles.heading.copyWith(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.account_balance_wallet,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.trending_up,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  '+12.5% this month',
                  style: AppTextStyles.body.copyWith(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            icon: Icons.add,
            label: 'Fund',
            onTap: () => Get.to(() => FundVirtualAccountScreen()),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            icon: Icons.credit_card,
            label: 'New Card',
            onTap: () => Get.to(() => const VirtualCardSelectionScreen()),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            icon: Icons.swap_horiz,
            label: 'Transfer',
            onTap: () {},
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            icon: Icons.more_horiz,
            label: 'More',
            onTap: () {},
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
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
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.2),
                    AppColors.secondary.withOpacity(0.2),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppTextStyles.body.copyWith(
                color: AppColors.text,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'My Cards',
              style: AppTextStyles.heading2.copyWith(
                color: AppColors.text,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton.icon(
              onPressed: () => Get.to(() => const VirtualCardSelectionScreen()),
              icon: const Icon(
                Icons.add_circle_outline,
                color: AppColors.primary,
                size: 20,
              ),
              label: Text(
                'Add New',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_mockCards.isEmpty)
          _buildEmptyCardsState()
        else
          _buildCardsList(),
      ],
    );
  }

  Widget _buildEmptyCardsState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.1),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.1),
                  AppColors.secondary.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.credit_card_outlined,
              color: AppColors.primary,
              size: 48,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'No Cards Yet',
            style: AppTextStyles.heading2.copyWith(
              color: AppColors.text,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first virtual card to start\nmaking online payments',
            style: AppTextStyles.body.copyWith(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () => Get.to(() => const VirtualCardSelectionScreen()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Create First Card',
                  style: AppTextStyles.body2.copyWith(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardsList() {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.1),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 32,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.credit_card,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Premium Blue Card',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.text,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '**** **** **** 1234',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$2,500.00',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.text,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Active',
                      style: AppTextStyles.body.copyWith(
                        color: Colors.green,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Transactions',
              style: AppTextStyles.heading2.copyWith(
                color: AppColors.text,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                'See All',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildEmptyTransactionsState(),
      ],
    );
  }

  Widget _buildEmptyTransactionsState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.1),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.1),
                  AppColors.secondary.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.receipt_long_outlined,
              color: AppColors.primary,
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No Transactions Yet',
            style: AppTextStyles.heading2.copyWith(
              color: AppColors.text,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your transaction history will appear here',
            style: AppTextStyles.body.copyWith(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
