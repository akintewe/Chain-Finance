import 'package:nexa_prime/controllers/wallet_controller.dart';
import 'package:nexa_prime/controllers/dashboard_controller.dart';
import 'package:nexa_prime/utils/colors.dart';
import 'package:nexa_prime/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nexa_prime/views/home/swap_screen.dart';
import 'package:nexa_prime/views/home/send_screen.dart';

class MyTokensScreen extends StatefulWidget {
  const MyTokensScreen({super.key});

  @override
  State<MyTokensScreen> createState() => _MyTokensScreenState();
}

class _MyTokensScreenState extends State<MyTokensScreen> {
  final WalletController walletController = Get.find();
  final DashboardController dashboardController = Get.find();
  String searchQuery = '';
  String selectedFilter = 'All';
  bool showOnlyWithBalance = false;

  final List<String> filterOptions = ['All', 'Favorites', 'Gainers', 'Losers'];

  @override
  void initState() {
    super.initState();
    // Refresh wallet data after the build is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      walletController.fetchWalletDetails();
    });
  }

  // Reactive computed property for filtered tokens
  List<Map<String, dynamic>> get filteredTokens {
    List<Map<String, dynamic>> tokens = walletController.tokens;
    
    // Apply search filter
    if (searchQuery.isNotEmpty) {
      tokens = tokens.where((token) {
        final name = token['name']?.toString().toLowerCase() ?? '';
        final symbol = token['symbol']?.toString().toLowerCase() ?? '';
        final query = searchQuery.toLowerCase();
        return name.contains(query) || symbol.contains(query);
      }).toList();
    }
    
    // Apply balance filter
    if (showOnlyWithBalance) {
      tokens = tokens.where((token) {
        final balance = double.tryParse(token['balance']?.toString() ?? '0') ?? 0.0;
        return balance > 0;
      }).toList();
    }
    
    // Apply category filter
    switch (selectedFilter) {
      case 'Favorites':
        // You can implement favorites logic here
        break;
      case 'Gainers':
        // Sort by positive 24h change - use try-catch to avoid errors
        try {
          tokens.sort((a, b) {
            final aChange = walletController.getMarketData(a['symbol'])?['change_24h'] ?? 0.0;
            final bChange = walletController.getMarketData(b['symbol'])?['change_24h'] ?? 0.0;
            return bChange.compareTo(aChange);
          });
        } catch (e) {
          // If sorting fails, return tokens as-is
          print('Error sorting gainers: $e');
        }
        break;
      case 'Losers':
        // Sort by negative 24h change - use try-catch to avoid errors
        try {
          tokens.sort((a, b) {
            final aChange = walletController.getMarketData(a['symbol'])?['change_24h'] ?? 0.0;
            final bChange = walletController.getMarketData(b['symbol'])?['change_24h'] ?? 0.0;
            return aChange.compareTo(bChange);
          });
        } catch (e) {
          // If sorting fails, return tokens as-is
          print('Error sorting losers: $e');
        }
        break;
    }
    
    return tokens;
  }

  void _showTokenActions(Map<String, dynamic> token) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Token info header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(16),
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
                    child: Text(
                      token['symbol'] ?? 'N/A',
                      style: AppTextStyles.heading2.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          token['name'] ?? 'Unknown Token',
                          style: AppTextStyles.heading2.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${token['balance']} ${token['symbol']}',
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
            
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Get.to(() => SwapScreen(
                        isFromMyTokens: true,
                        selectedFromToken: token, // Pass the selected token
                      ));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.surface,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.swap_horiz, size: 20),
                        const SizedBox(width: 8),
                        Text('Swap', style: AppTextStyles.button),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Get.to(() => SendScreen(
                        isSendingToExternal: true,
                        selectedToken: token, // Pass the selected token
                      ));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.surface,
                      foregroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: AppColors.primary),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.send, size: 20),
                        const SizedBox(width: 8),
                        Text('Send', style: AppTextStyles.button),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Cancel button
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
        title: Text(
          'My Tokens',
          style: AppTextStyles.heading2.copyWith(fontSize: 20),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.text),
            onPressed: () async {
              await walletController.fetchWalletDetails();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Bar
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Search bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary.withOpacity(0.1)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.search,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          onChanged: (value) {
                            setState(() {
                              searchQuery = value;
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'Search tokens...',
                            hintStyle: AppTextStyles.body.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                // Filter chips
                Row(
                  children: [
                    // Balance toggle
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          showOnlyWithBalance = !showOnlyWithBalance;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: showOnlyWithBalance 
                              ? AppColors.primary 
                              : AppColors.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: showOnlyWithBalance 
                                ? AppColors.primary 
                                : AppColors.primary.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          'With Balance',
                          style: AppTextStyles.body2.copyWith(
                            color: showOnlyWithBalance 
                                ? AppColors.surface 
                                : AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    
                    // Filter options
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: filterOptions.map((filter) {
                            final isSelected = selectedFilter == filter;
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedFilter = filter;
                                });
                              },
                              child: Container(
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isSelected 
                                      ? AppColors.primary 
                                      : AppColors.surface,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isSelected 
                                        ? AppColors.primary 
                                        : AppColors.primary.withOpacity(0.3),
                                  ),
                                ),
                                child: Text(
                                  filter,
                                  style: AppTextStyles.body2.copyWith(
                                    color: isSelected 
                                        ? AppColors.surface 
                                        : AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Tokens List
          Expanded(
            child: Obx(() {
              if (walletController.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              
              final filteredTokens = this.filteredTokens;
              
              if (filteredTokens.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.wallet_outlined,
                        size: 64,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        searchQuery.isNotEmpty 
                            ? 'No tokens found for "$searchQuery"'
                            : 'No tokens available',
                        style: AppTextStyles.heading2.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 18,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Try adjusting your search or filters',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }
              
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: filteredTokens.length,
                itemBuilder: (context, index) {
                  final token = filteredTokens[index];
                  final marketData = walletController.getMarketData(token['symbol']);
                  final balance = double.tryParse(token['balance']?.toString() ?? '0') ?? 0.0;
                  final price = marketData?['price'] ?? 0.0;
                  final change24h = marketData?['change_24h'] ?? 0.0;
                  final totalValue = balance * price;
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.primary.withOpacity(0.1)),
                    ),
                    child: Row(
                      children: [
                        // Token icon/symbol
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            token['symbol'] ?? 'N/A',
                            style: AppTextStyles.heading2.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        
                        // Token info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    token['name'] ?? 'Unknown Token',
                                    style: AppTextStyles.heading2.copyWith(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    '\$${totalValue.toStringAsFixed(2)}',
                                    style: AppTextStyles.heading2.copyWith(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${balance.toStringAsFixed(8)} ${token['symbol']}',
                                    style: AppTextStyles.body.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: change24h >= 0 
                                          ? Colors.green.withOpacity(0.1)
                                          : Colors.red.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '${change24h >= 0 ? '+' : ''}${change24h.toStringAsFixed(2)}%',
                                      style: AppTextStyles.body2.copyWith(
                                        color: change24h >= 0 ? Colors.green : Colors.red,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        
                        // Action button
                        GestureDetector(
                          onTap: () => _showTokenActions(token),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.more_vert,
                              color: AppColors.primary,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
