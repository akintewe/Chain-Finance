import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nexa_prime/utils/colors.dart';
import 'package:nexa_prime/utils/text_styles.dart';
import 'package:nexa_prime/utils/responsive_helper.dart';
import 'package:nexa_prime/controllers/wallet_controller.dart';
import 'package:nexa_prime/views/home/token_info_screen.dart';

class AllTokensScreen extends StatefulWidget {
  const AllTokensScreen({Key? key}) : super(key: key);

  @override
  State<AllTokensScreen> createState() => _AllTokensScreenState();
}

class _AllTokensScreenState extends State<AllTokensScreen> {
  final WalletController walletController = Get.find();
  final searchController = TextEditingController();
  List<Map<String, dynamic>> filteredTokens = [];

  @override
  void initState() {
    super.initState();
    filteredTokens = walletController.cryptoList;
  }

  void filterTokens(String query) {
    setState(() {
      filteredTokens = walletController.cryptoList.where((token) {
        final name = token['name'].toString().toLowerCase();
        final symbol = token['symbol'].toString().toLowerCase();
        final searchLower = query.toLowerCase();
        return name.contains(searchLower) || symbol.contains(searchLower);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.white,),
                      onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: AppColors.background,
        title: Text('All Tokens', style: AppTextStyles.body2),
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: ResponsiveHelper.getResponsiveAllPadding(context, all: 16.0),
            child: TextField(
              controller: searchController,
              onChanged: filterTokens,
              decoration: InputDecoration(
                hintText: 'Search tokens...',
                prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredTokens.length,
              itemBuilder: (context, index) {
                final token = filteredTokens[index];
                final price = walletController.getPriceForToken(token['symbol']);
                final priceChange = walletController.getPriceChangeForToken(token['symbol']);
                
                return ListTile(
                  onTap: () => Get.to(() => TokenInfoScreen(
                    token: token,
                    currentPrice: price,
                    priceChange: priceChange,
                  )),
                  leading: Image.asset(token['icon'], width: 40, height: 40),
                  title: Text(token['name'], style: AppTextStyles.body2),
                  subtitle: Text(token['symbol'], style: TextStyle(color: AppColors.textSecondary)),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('\$${price.toStringAsFixed(2)}',
                          style: AppTextStyles.body2),
                      Text(
                        '${priceChange >= 0 ? '+' : ''}${priceChange.toStringAsFixed(2)}%',
                        style: TextStyle(
                          color: priceChange >= 0 ? Colors.green : Colors.red,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
} 