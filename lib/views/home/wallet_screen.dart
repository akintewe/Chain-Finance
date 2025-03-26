import 'package:nexa_prime/controllers/auth_controller.dart';
import 'package:nexa_prime/controllers/wallet_controller.dart';
import 'package:nexa_prime/utils/colors.dart';
import 'package:nexa_prime/utils/text_styles.dart';
import 'package:nexa_prime/views/home/receive_screen.dart';
import 'package:nexa_prime/views/home/send_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'dart:math';
import 'package:nexa_prime/views/home/token_info_screen.dart';
import 'package:nexa_prime/views/home/all_tokens_screen.dart';
import 'package:nexa_prime/views/home/edit_favorites_screen.dart';

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
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
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
            
            // Nexa Prime User Option
            InkWell(
              onTap: () {
                Get.back();
                Get.to(() => const SendScreen(isSendingToExternal: false));
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withOpacity(0.2)),
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
                            'Nexa Prime User',
                            style: AppTextStyles.body2.copyWith(fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Send to another Nexa Prime user',
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
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.secondary.withOpacity(0.2)),
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
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: SvgPicture.asset('assets/icons/Search.svg', color: AppColors.text),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Image.asset('assets/icons/ion_notifications.png', color: AppColors.text),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppColors.primaryGradient,
                        ),
                        child: const CircleAvatar(
                          radius: 20,
                          backgroundImage: AssetImage('assets/icons/Photo by Brooke Cagle.png'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Total Balance Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.surface,
                      AppColors.surface.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.1),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Balance',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          '\$',
                          style: AppTextStyles.heading.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 24,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Obx(() => Text(
                          walletController.getTotalBalance(),
                          style: AppTextStyles.heading.copyWith(
                            fontSize: 32,
                          ),
                        )),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStatItem(
                          '24h Change',
                          '+2.5%',
                          Colors.green,
                        ),
                        _buildStatItem(
                          '24h High',
                          '\$12,500',
                          AppColors.text,
                        ),
                        _buildStatItem(
                          '24h Low',
                          '\$11,800',
                          AppColors.text,
                        ),
                      ],
                    ),
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
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        onPressed: _showSendOptions,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Send', style: AppTextStyles.body2.copyWith(color: Colors.white)),
                            const Icon(Icons.arrow_upward, size: 16, color: Colors.white),
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
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
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
                          children: [
                            Text('Receive', style: AppTextStyles.body2),
                            const Icon(Icons.arrow_downward, size: 16, color: AppColors.text),
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
                            border: Border.all(color: AppColors.primary.withOpacity(0.1)),
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
              Container(
                height: 48,
                margin: const EdgeInsets.symmetric(vertical: 16),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: _filterSelections.entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _filterSelections.forEach((key, value) {
                              _filterSelections[key] = false;
                            });
                            _filterSelections[entry.key] = true;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: entry.value 
                              ? AppColors.primary.withOpacity(0.1)
                              : AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: entry.value 
                                ? AppColors.primary
                                : AppColors.primary.withOpacity(0.1),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (entry.value) ...[
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.check,
                                    size: 12,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 8),
                              ],
                              Text(
                                entry.key,
                                style: AppTextStyles.body2.copyWith(
                                  color: entry.value 
                                    ? AppColors.primary
                                    : AppColors.textSecondary,
                                  fontWeight: entry.value 
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
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
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
                      ),
                      child: ListTile(
                        onTap: () => Get.to(() => TokenInfoScreen(
                          token: token,
                          currentPrice: price,
                          priceChange: priceChange,
                        )),
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Image.asset(
                            token['icon'],
                            width: 24,
                            height: 24,
                          ),
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

  Widget _buildStatItem(String label, String value, Color valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.body.copyWith(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.body2.copyWith(
            color: valueColor,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}