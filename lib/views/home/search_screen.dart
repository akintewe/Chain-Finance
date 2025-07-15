import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nexa_prime/controllers/wallet_controller.dart';
import 'package:nexa_prime/utils/colors.dart';
import 'package:nexa_prime/utils/text_styles.dart';
import 'package:nexa_prime/views/home/token_info_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> with SingleTickerProviderStateMixin {
  final WalletController walletController = Get.find<WalletController>();
  final TextEditingController searchController = TextEditingController();
  
  List<Map<String, dynamic>> filteredTokens = [];
  List<Map<String, dynamic>> allTokens = [];
  String searchQuery = '';
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _loadAllTokens();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_animationController);
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    searchController.dispose();
    super.dispose();
  }

  void _loadAllTokens() {
    // Load all available cryptocurrencies
    allTokens = List.from(walletController.cryptoList);
    
    // Add some additional popular cryptocurrencies for search
    final additionalTokens = [
      {
        'name': 'Litecoin',
        'symbol': 'LTC',
        'icon': 'assets/icons/Cryptocurrency.png',
      },
      {
        'name': 'Chainlink',
        'symbol': 'LINK',
        'icon': 'assets/icons/Cryptocurrency.png',
      },
      {
        'name': 'Polkadot',
        'symbol': 'DOT',
        'icon': 'assets/icons/Cryptocurrency.png',
      },
      {
        'name': 'Avalanche',
        'symbol': 'AVAX',
        'icon': 'assets/icons/Cryptocurrency.png',
      },
      {
        'name': 'Uniswap',
        'symbol': 'UNI',
        'icon': 'assets/icons/Cryptocurrency.png',
      },
    ];
    
    // Add tokens that aren't already in the list
    for (var token in additionalTokens) {
      if (!allTokens.any((t) => t['symbol'] == token['symbol'])) {
        allTokens.add(token);
      }
    }
    
    filteredTokens = List.from(allTokens);
  }

  void _filterTokens(String query) {
    setState(() {
      searchQuery = query;
      if (query.isEmpty) {
        filteredTokens = List.from(allTokens);
      } else {
        filteredTokens = allTokens.where((token) {
          final name = token['name']?.toString().toLowerCase() ?? '';
          final symbol = token['symbol']?.toString().toLowerCase() ?? '';
          final searchLower = query.toLowerCase();
          
          return name.contains(searchLower) || symbol.contains(searchLower);
        }).toList();
      }
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
        title: Text('Search Cryptocurrencies', style: AppTextStyles.body2),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // Search Bar
            Container(
              margin: const EdgeInsets.all(20),
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
              child: TextField(
                controller: searchController,
                onChanged: _filterTokens,
                style: AppTextStyles.body.copyWith(color: AppColors.text),
                decoration: InputDecoration(
                  hintText: 'Search by name or symbol (e.g., Bitcoin, BTC)',
                  hintStyle: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  border: InputBorder.none,
                  prefixIcon: Container(
                    padding: const EdgeInsets.all(12),
                    child: Icon(
                      Icons.search,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  suffixIcon: searchQuery.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            searchController.clear();
                            _filterTokens('');
                          },
                          icon: Icon(
                            Icons.clear,
                            color: AppColors.textSecondary,
                            size: 20,
                          ),
                        )
                      : null,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
              ),
            ),

            // Search Results Count
            if (searchQuery.isNotEmpty)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Text(
                      '${filteredTokens.length} result${filteredTokens.length != 1 ? 's' : ''} found',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 16),

            // Token List
            Expanded(
              child: filteredTokens.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: filteredTokens.length,
                      itemBuilder: (context, index) {
                        final token = filteredTokens[index];
                        final price = walletController.getPriceForToken(token['symbol'] ?? '');
                        final priceChange = walletController.getPriceChangeForToken(token['symbol'] ?? '');
                        
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.primary.withOpacity(0.1)),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ListTile(
                            onTap: () => Get.to(() => TokenInfoScreen(
                              token: token,
                              currentPrice: price,
                              priceChange: priceChange,
                            )),
                            contentPadding: const EdgeInsets.all(16),
                            leading: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Image.asset(
                                token['icon'] ?? 'assets/icons/Cryptocurrency.png',
                                width: 32,
                                height: 32,
                              ),
                            ),
                            title: Text(
                              token['name'] ?? 'Unknown Token',
                              style: AppTextStyles.body2.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                token['symbol'] ?? '',
                                style: AppTextStyles.body.copyWith(
                                  color: AppColors.textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '\$${price.toStringAsFixed(2)}',
                                  style: AppTextStyles.body2.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: (priceChange >= 0 ? Colors.green : Colors.red).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '${priceChange >= 0 ? '+' : ''}${priceChange.toStringAsFixed(2)}%',
                                    style: TextStyle(
                                      color: priceChange >= 0 ? Colors.green : Colors.red,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    if (searchQuery.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search,
                size: 48,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Search for Cryptocurrencies',
              style: AppTextStyles.heading2.copyWith(fontSize: 20),
            ),
            const SizedBox(height: 12),
            Text(
              'Enter a cryptocurrency name or symbol\nto view price charts and details',
              textAlign: TextAlign.center,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),
      );
    } else {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.textSecondary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_off,
                size: 48,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Results Found',
              style: AppTextStyles.heading2.copyWith(fontSize: 20),
            ),
            const SizedBox(height: 12),
            Text(
              'Try searching with a different\ncryptocurrency name or symbol',
              textAlign: TextAlign.center,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),
      );
    }
  }
} 