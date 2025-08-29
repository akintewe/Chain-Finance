import 'package:nexa_prime/controllers/wallet_controller.dart';
import 'package:nexa_prime/utils/colors.dart';
import 'package:nexa_prime/utils/text_styles.dart';
import 'package:nexa_prime/utils/responsive_helper.dart';
import 'package:nexa_prime/views/home/receive_qr_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ReceiveScreen extends StatefulWidget {
  const ReceiveScreen({super.key});

  @override
  State<ReceiveScreen> createState() => _ReceiveScreenState();
}

class _ReceiveScreenState extends State<ReceiveScreen> with SingleTickerProviderStateMixin {
  final TextEditingController searchController = TextEditingController();
  final WalletController walletController = Get.put(WalletController());
  List<Map<String, dynamic>> filteredTokens = [];
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    walletController.fetchWalletDetails();
    filteredTokens = walletController.tokens;
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void filterTokens(String query) {
    setState(() {
      filteredTokens = walletController.tokens
          .where((token) =>
              token['name'].toLowerCase().contains(query.toLowerCase()) ||
              token['symbol'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
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
                      onPressed: () => Navigator.pop(context),
        ),
        title: Text('Receive', style: AppTextStyles.heading2),
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            margin: ResponsiveHelper.getResponsiveAllPadding(context, all: 20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primary.withOpacity(0.1)),
            ),
            child: TextField(
              controller: searchController,
              onChanged: filterTokens,
              style: AppTextStyles.body.copyWith(color: AppColors.text),
              decoration: InputDecoration(
                hintText: 'Search tokens',
                hintStyle: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                ),
                border: InputBorder.none,
                prefixIcon: Container(
                  padding: const EdgeInsets.all(12),
                  child: Icon(
                    Icons.search,
                    color: AppColors.textSecondary,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
            ),
          ),

          // Token List
          Expanded(
            child: Obx(() => walletController.isLoading
                ? const Center(child: CircularProgressIndicator())
                :                   ListView.builder(
                    padding: ResponsiveHelper.getResponsivePadding(context, horizontal: 20),
                    itemCount: filteredTokens.length,
                    itemBuilder: (context, index) {
                      final token = filteredTokens[index];
                      return AnimatedBuilder(
                        animation: _controller,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _scaleAnimation.value,
                            child: GestureDetector(
                              onTap: () {
                                _controller.forward().then((_) {
                                  _controller.reverse();
                                  final tokenWithAddress = {
                                    ...token,
                                    'address': walletController.walletAddress,
                                  };
                                  Get.to(() => ReceiveQRScreen(token: tokenWithAddress));
                                });
                              },
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: AppColors.primary.withOpacity(0.1)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withOpacity(0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                  leading: Container(
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
                                  title: Text(
                                    token['name'],
                                    style: AppTextStyles.body2.copyWith(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      token['symbol'],
                                      style: AppTextStyles.body.copyWith(
                                        color: AppColors.textSecondary,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  trailing: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppColors.surface,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: AppColors.primary.withOpacity(0.1)),
                                    ),
                                    child: Icon(
                                      Icons.arrow_forward_ios,
                                      color: AppColors.textSecondary,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  )),
          ),
        ],
      ),
    );
  }
} 