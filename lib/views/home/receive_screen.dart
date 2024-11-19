import 'package:chain_finance/controllers/wallet_controller.dart';
import 'package:chain_finance/utils/colors.dart';
import 'package:chain_finance/utils/text_styles.dart';
import 'package:chain_finance/views/home/receive_qr_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ReceiveScreen extends StatefulWidget {
  const ReceiveScreen({super.key});

  @override
  State<ReceiveScreen> createState() => _ReceiveScreenState();
}

class _ReceiveScreenState extends State<ReceiveScreen> {
  final TextEditingController searchController = TextEditingController();
  final WalletController walletController = Get.put(WalletController());
  List<Map<String, dynamic>> filteredTokens = [];

  @override
  void initState() {
    super.initState();
    walletController.fetchWalletDetails();
    filteredTokens = walletController.tokens;
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
          onPressed: () => Get.back(),
        ),
        title: Text('Receive', style: AppTextStyles.button),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Search Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextField(
                controller: searchController,
                onChanged: filterTokens,
                style: const TextStyle(color: AppColors.text),
                decoration: InputDecoration(
                  hintText: 'Search tokens',
                  hintStyle: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  border: InputBorder.none,
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Token List
            Expanded(
              child: Obx(() => walletController.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: filteredTokens.length,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemBuilder: (context, index) {
                        final token = filteredTokens[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 8,
                            ),
                            onTap: () {
                              final tokenWithAddress = {
                                ...token,
                                'address': walletController.walletAddress,
                              };
                              Get.to(() => ReceiveQRScreen(token: tokenWithAddress));
                            },
                            leading: Image.asset(
                              token['icon'],
                              width: 40,
                              height: 40,
                            ),
                            title: Text(
                              token['name'],
                              style: AppTextStyles.body2.copyWith(
                                fontSize: 16,
                                color: AppColors.text,
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                token['symbol'],
                                style: AppTextStyles.body.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                            trailing: Container(
                              padding: const EdgeInsets.only(left: 16),
                              child: const Icon(
                                Icons.arrow_forward_ios,
                                color: AppColors.textSecondary,
                                size: 16,
                              ),
                            ),
                          ),
                        );
                      },
                    )),
            ),
          ],
        ),
      ),
    );
  }
} 