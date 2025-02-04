import 'package:chain_finance/controllers/auth_controller.dart';
import 'package:chain_finance/controllers/wallet_controller.dart';
import 'package:chain_finance/utils/colors.dart';
import 'package:chain_finance/utils/text_styles.dart';
import 'package:chain_finance/views/home/receive_screen.dart';
import 'package:chain_finance/views/home/send_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'dart:math';
import 'package:chain_finance/views/home/token_info_screen.dart';
import 'package:chain_finance/views/home/all_tokens_screen.dart';
import 'package:chain_finance/views/home/edit_favorites_screen.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> with SingleTickerProviderStateMixin {
  final AuthController authController = Get.find();
  final WalletController walletController = Get.find();
  late String username = 'User';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<Map<String, dynamic>> favorites = [
    {
      'name': 'Tron (TRX)',
      'symbol': 'TRX',
      'amount': '\$456.7',
      'change': '+0.45%',
      'icon': 'assets/icons/Cryptocurrency.png',
    },
    {
      'name': 'Ethereum (ETH)',
      'symbol': 'ETH',
      'amount': '\$486.7',
      'change': '+0.45%',
      'icon': 'assets/icons/Cryptocurrency (1).png',
    },
     {
      'name': 'Bitcoin',
      'symbol': 'BTC',
      'price': '\$3,676.76',
      'change': '+0.45%',
      'icon': 'assets/icons/Cryptocurrency (2).png',
    },
    {
      'name': 'United States Dollar',
      'symbol': 'USDT',
      'price': '\$3,676.76',
      'change': '+0.45%',
      'icon': 'assets/icons/Cryptocurrency (3).png',
    },
  ];

  // Add state variables for filter selections
  final Map<String, bool> _filterSelections = {
    'All Crypto': true,
    'Winners': false,
    'Losers': false,
    'Newest': false,
  };

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));

    _animationController.forward();
  }

  Future<void> _loadUserData() async {
    final userData = await authController.getUserData();
    setState(() {
      username = userData['name'] ?? 'User';
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _showSendOptions() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Send To',
              style: AppTextStyles.heading.copyWith(fontSize: 24),
            ),
            const SizedBox(height: 24),
            
            // Chain Finance User Option
            InkWell(
              onTap: () {
                Get.back();
                Get.to(() => const SendScreen(isSendingToExternal: false));
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withOpacity(0.1)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.person_outline, color: AppColors.primary),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Chain Finance User',
                            style: AppTextStyles.body2.copyWith(fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Send to another Chain Finance user',
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textSecondary),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // External Wallet Option
            InkWell(
              onTap: () {
                Get.back();
                Get.to(() => const SendScreen(isSendingToExternal: true));
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.secondary.withOpacity(0.1)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.wallet_outlined, color: AppColors.secondary),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'External Wallet',
                            style: AppTextStyles.body2.copyWith(fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Send to any blockchain wallet address',
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textSecondary),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
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
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Hey ${username}!',
                    style: AppTextStyles.heading.copyWith(fontSize: 30),
                  ),
                  Row(
                    children: [
                     SvgPicture.asset('assets/icons/Search.svg', color: AppColors.text,),
                     SizedBox(width: 10,),
                     Image.asset('assets/icons/ion_notifications.png', color: AppColors.text,),
                     SizedBox(width: 10,),
                      const CircleAvatar(
                        radius: 20,
                        backgroundImage: AssetImage('assets/icons/Photo by Brooke Cagle.png'),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Balance Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2E4E6B), Color(0xFF3D2A54)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Balance',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            '↑ 23.5%',
                            style: TextStyle(color: Colors.green),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            children: const [
                              Text(
                                'USD',
                                style: TextStyle(color: AppColors.text),
                              ),
                              Icon(Icons.keyboard_arrow_down, color: AppColors.text),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Obx(() => Text(
                      '\$${walletController.getTotalBalance()}',
                      style: AppTextStyles.heading.copyWith(
                        color: AppColors.text,
                        fontSize: 24,
                      ),
                    )),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Send/Receive Buttons
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.blue, Colors.purple],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: _showSendOptions,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Send', style: AppTextStyles.body2,),
                            const Icon(Icons.arrow_upward, size: 16, color: AppColors.white,),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.blue.withOpacity(0.5)),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                       onPressed: () => Get.to(() => const ReceiveScreen()),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children:  [
                            Text('Receive',style: AppTextStyles.body2,),
                            Icon(Icons.arrow_downward, size: 16, color: AppColors.white,),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Favorites Section
              if (walletController.favoritesList.isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Favorites',
                      style: TextStyle(
                        color: AppColors.text,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () => Get.to(() => const EditFavoritesScreen()),
                      child: const Text('Edit'),
                    ),
                  ],
                ),
                
                SizedBox(
                  height: 120,
                  child: Obx(() => ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: walletController.favoritesList.length,
                    itemBuilder: (context, index) {
                      final token = walletController.favoritesList[index];
                      final price = walletController.getPriceForToken(token['symbol']);
                      final priceChange = walletController.getPriceChangeForToken(token['symbol']);
                      
                      return GestureDetector(
                        onTap: () => Get.to(() => TokenInfoScreen(
                          token: token,
                          currentPrice: price,
                          priceChange: priceChange,
                        )),
                        child: Container(
                          width: 150,
                          margin: EdgeInsets.only(
                            right: 12,
                            left: index == 0 ? 0 : 0,
                          ),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Image.asset(
                                    token['icon'],
                                    width: 24,
                                    height: 24,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    token['symbol'],
                                    style: const TextStyle(
                                      color: AppColors.text,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              Text(
                                '\$${price.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: AppColors.text,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${priceChange >= 0 ? '+' : ''}${priceChange.toStringAsFixed(2)}%',
                                style: TextStyle(
                                  color: priceChange >= 0 ? Colors.green : Colors.red,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  )),
                ),
                const SizedBox(height: 20),
              ],

              const SizedBox(height: 20),

              // Crypto Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Crypto',
                    style: TextStyle(
                      color: AppColors.text,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () => Get.to(() => const AllTokensScreen()),
                    child: const Text('See All'),
                  ),
                ],
              ),

              // Updated Filter Chips
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: _filterSelections.entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(entry.key),
                        selected: entry.value,
                        onSelected: (bool selected) {
                          if (selected) { // Only handle selection, not deselection
                            setState(() {
                              // First set all to false
                              _filterSelections.forEach((key, value) {
                                _filterSelections[key] = false;
                              });
                              // Then set the selected one to true
                              _filterSelections[entry.key] = true;
                            });
                          }
                        },
                        backgroundColor: AppColors.surface,
                        selectedColor: AppColors.primary.withOpacity(0.2),
                        checkmarkColor: Colors.black,
                        showCheckmark: true,
                        labelStyle: TextStyle(
                          color: entry.value ? Colors.black : AppColors.textSecondary,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              // Crypto List
              Expanded(
                child: Obx(() => ListView.builder(
                  itemCount: walletController.cryptoList.length,
                  itemBuilder: (context, index) {
                    final token = walletController.cryptoList[index];
                    final price = walletController.getPriceForToken(token['symbol']);
                    final priceChange = walletController.getPriceChangeForToken(token['symbol']);
                    
                    return ListTile(
                      onTap: () => Get.to(() => TokenInfoScreen(
                        token: token,
                        currentPrice: price,
                        priceChange: priceChange,
                      )),
                      leading: Image.asset(
                        token['icon'],
                        width: 40,
                        height: 40,
                      ),
                      title: Text(
                        token['name'],
                        style: const TextStyle(color: AppColors.text),
                      ),
                      subtitle: Text(
                        token['symbol'],
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '\$${price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: AppColors.text,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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
                )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}