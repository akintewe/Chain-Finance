import 'package:nexa_prime/controllers/auth_controller.dart';
import 'package:nexa_prime/controllers/wallet_controller.dart';
import 'package:nexa_prime/utils/colors.dart';
import 'package:nexa_prime/utils/text_styles.dart';
import 'package:nexa_prime/utils/responsive_helper.dart';
import 'package:nexa_prime/views/home/receive_screen.dart';
import 'package:nexa_prime/views/home/send_screen.dart';
import 'package:nexa_prime/views/home/search_screen.dart';
import 'package:nexa_prime/views/home/notification_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:nexa_prime/views/home/token_info_screen.dart';
import 'package:nexa_prime/views/home/all_tokens_screen.dart';
import 'package:nexa_prime/views/home/edit_favorites_screen.dart';
import 'package:nexa_prime/views/home/my_tokens_screen.dart';
import 'package:nexa_prime/views/home/candlestick_chart_widget.dart';
import 'dart:async';
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';


class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> with TickerProviderStateMixin, WidgetsBindingObserver {
  final AuthController authController = Get.find();
  final WalletController walletController = Get.find();
  late String username = 'User';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  // Timer for pie chart updates
  Timer? _pieChartTimer;
  final RxMap<String, double> _pieChartData = <String, double>{}.obs;
  
  // Selected token for chart display
  String? _selectedChartToken;
  

  
  // Animation controllers for shooting stars
  late AnimationController _starsController;
  late List<ShootingStar> _shootingStars;
  final int _starCount = 15;

  // Price banner data
  final RxList<Map<String, dynamic>> _priceUpdates = <Map<String, dynamic>>[].obs;
  late AnimationController _bannerController;
  late Animation<double> _bannerAnimation;
  Timer? _priceUpdateTimer;

  // Chart colors for pie chart and legend
  final List<Color> chartColors = [
    AppColors.primary,
    AppColors.secondary,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.pink,
    Colors.blue,
    Colors.green,
    Colors.red,
    Colors.indigo,
  ];

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
    // Register lifecycle observer
    WidgetsBinding.instance.addObserver(this);
    _loadUserData();
    
    // Set price update callback
    walletController.setPriceUpdateCallback(() {
      if (mounted) {
        _updatePieChartData();
      }
    });
    
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
    
    // Initialize shooting stars animation
    _starsController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
    
    _initShootingStars();
    
    _starsController.addListener(() {
      setState(() {
        // Update shooting stars on animation tick
      });
    });

    // Ensure wallet controller starts loading prices
    if (!walletController.isLoading) {
      // Check if we need to update prices by seeing if any price is 0
      bool needsPriceUpdate = walletController.cryptoList.any((token) => 
        walletController.getPriceForToken(token['symbol'] ?? '') == 0.0);
      
      if (needsPriceUpdate) {
        walletController.updatePrices().then((_) {
          if (mounted) {
            Timer(const Duration(milliseconds: 500), () {
              if (mounted) _updatePieChartData();
            });
          }
        });
      }
    }

    // Initialize pie chart data immediately
    _updatePieChartData();
    

    
    // Also check after a short delay to catch any quick price updates
    Timer(const Duration(seconds: 2), () {
      if (mounted) _updatePieChartData();
    });
    Timer(const Duration(seconds: 5), () {
      if (mounted) _updatePieChartData();
    });
    
    // Set up timer for periodic updates - reduced frequency
    _pieChartTimer = Timer.periodic(const Duration(minutes: 15), (timer) {
      _updatePieChartData();
    });
    
    // Initialize price banner
    _initPriceBanner();
    _startPriceUpdates();
    
    // Fetch wallet details after the build is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      walletController.fetchWalletDetails();
    });
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // This method is called when dependencies change (including hot reload)
    // Refresh wallet data to ensure it's up to date
    if (mounted) {
      walletController.fetchWalletDetails();
      // Also refresh pie chart data on hot reload
      _updatePieChartData();
    }
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Refresh wallet data when app becomes visible again
    if (state == AppLifecycleState.resumed && mounted) {
      walletController.fetchWalletDetails();
    }
  }
  
  void _initShootingStars() {
    final random = Random();
    _shootingStars = List.generate(_starCount, (index) {
      return ShootingStar(
        startX: random.nextDouble() * 1.2,
        startY: random.nextDouble() * 0.5,
        endX: random.nextDouble() * 0.5 - 0.5,
        endY: random.nextDouble() * 0.5 + 0.5,
        speed: random.nextDouble() * 0.3 + 0.1,
        size: random.nextDouble() * 1.5 + 0.5,
        delay: random.nextDouble(),
        color: Color.fromRGBO(
          random.nextInt(100) + 155, 
          random.nextInt(100) + 155, 
          random.nextInt(55) + 200, 
          random.nextDouble() * 0.7 + 0.3,
        ),
      );
    });
  }

  void _updatePieChartData() {
    print('Updating pie chart data at ${DateTime.now()}');
    final cryptoData = walletController.cryptoList;
    Map<String, double> newData = {};
    
    // Check if wallet controller is still loading prices
    if (walletController.isLoading) {
      print('Wallet controller is still loading, skipping pie chart update');
      return;
    }
    
    for (var token in cryptoData) {
      final price = walletController.getPriceForToken(token['symbol'] ?? '');
      if (price > 0) {
        newData[token['symbol'] ?? ''] = price;
      }
    }
    
    // Only update if we have actual data or if data changed to prevent unnecessary rebuilds
    if (newData.isNotEmpty && (newData.length != _pieChartData.length || 
        !newData.keys.every((key) => _pieChartData.containsKey(key) && _pieChartData[key] == newData[key]))) {
      _pieChartData.clear();
      _pieChartData.addAll(newData);
      print('Pie chart data updated with ${_pieChartData.length} items');
    } else if (newData.isEmpty && _pieChartData.isEmpty) {
      print('No price data available yet, retrying in 5 seconds...');
      // Retry after a short delay if no data is available
      Timer(const Duration(seconds: 5), () {
        if (mounted) _updatePieChartData();
      });
    }
    
    print('Next scheduled update will be at ${DateTime.now().add(const Duration(minutes: 1))}');
  }

  // Method to manually refresh pie chart (can be called from wallet controller)
  void refreshPieChart() {
    if (mounted) {
      _updatePieChartData();
    }
  }
  
  // Price Banner Methods
  void _initPriceBanner() {
    _bannerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 90),
    );
    
    _bannerAnimation = Tween<double>(
      begin: 1.0,
      end: -1.0,
    ).animate(CurvedAnimation(
      parent: _bannerController,
      curve: Curves.linear,
    ));
    
    // Use repeat() for truly continuous animation
    _bannerController.repeat();
  }
  
  void _startPriceUpdates() {
    // First, add sample data immediately for testing
    _addSamplePriceUpdates();
    
    // Start animation immediately with sample data
    if (mounted) {
      _bannerController.repeat(); // Use repeat() for continuous animation
    }
    
    // Then try to fetch real data from the crypto prices endpoint
    _fetchPriceUpdates().then((_) {
      // Update data but keep animation running
      if (mounted && _priceUpdates.isNotEmpty) {
        print('Banner updated with real data: ${_priceUpdates.length} tokens');
      }
    });
    
    // Set up a timer to check for new prices when wallet controller finishes loading
    Timer.periodic(const Duration(seconds: 2), (timer) {
      if (!walletController.isLoading && mounted && _priceUpdates.isEmpty) {
        _fetchPriceUpdates();
        timer.cancel(); // Stop checking once we have data
      }
    });
    
    // Set up timer for periodic price updates
    _priceUpdateTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      _fetchPriceUpdates();
    });
  }
  
  void _addSamplePriceUpdates() {
    final sampleUpdates = [
      {
        'symbol': 'BTC',
        'price': 43250.75,
        'change': 1250.50,
        'changePercent': 2.98,
        'isPositive': true,
      },
      {
        'symbol': 'ETH',
        'price': 2650.25,
        'change': -45.75,
        'changePercent': -1.70,
        'isPositive': false,
      },
      {
        'symbol': 'BNB',
        'price': 315.80,
        'change': 12.40,
        'changePercent': 4.08,
        'isPositive': true,
      },
      {
        'symbol': 'ADA',
        'price': 0.485,
        'change': 0.025,
        'changePercent': 5.43,
        'isPositive': true,
      },
    ];
    
    _priceUpdates.assignAll(sampleUpdates);
  }
  
  Future<void> _fetchPriceUpdates() async {
    try {
      // Wait for wallet controller to finish loading prices (same as pie chart)
      while (walletController.isLoading) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      
      // Get current prices from wallet controller (same data as pie chart)
      final cryptoData = walletController.cryptoList;
      final List<Map<String, dynamic>> updates = [];
      
      for (var token in cryptoData) {
        final symbol = token['symbol'] ?? '';
        final price = walletController.getPriceForToken(symbol);
        final priceChange = walletController.getPriceChangeForToken(symbol);
        
        if (price > 0 && priceChange != 0) {
          final changePercent = priceChange;
          final isPositive = changePercent >= 0;
          
          updates.add({
            'symbol': symbol,
            'price': price,
            'change': priceChange,
            'changePercent': changePercent.abs(),
            'isPositive': isPositive,
          });
        }
      }
      
      if (updates.isNotEmpty) {
        _priceUpdates.assignAll(updates);
        print('Banner prices updated from wallet controller: ${updates.length} tokens');
      }
    } catch (e) {
      print('Error fetching price updates: $e');
    }
  }

  Future<void> _loadUserData() async {
    final userData = await authController.getUserData();
    username = userData['name'] ?? 'User';
    
    // Load profile image if not already loaded
    if (authController.profileImageUrl.isEmpty) {
      await authController.loadProfileImage();
    }
  }

  Widget _buildDefaultProfileAvatar() {
    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
      ),
      child: Center(
        child: Text(
          username.isNotEmpty ? username[0].toUpperCase() : 'U',
          style: AppTextStyles.heading.copyWith(
            color: AppColors.primary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _starsController.dispose();
    _pieChartTimer?.cancel();
    _bannerController.dispose();
    _priceUpdateTimer?.cancel();
    super.dispose();
  }

  void _showSendOptions() {
    Get.bottomSheet(
      Container(
        padding: ResponsiveHelper.getResponsiveAllPadding(context, all: 24),
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
      body: Stack(
        children: [
          // Shooting stars background
          Positioned.fill(
            child: CustomPaint(
              painter: ShootingStarsPainter(
                shootingStars: _shootingStars,
                animationValue: _starsController.value,
              ),
            ),
          ),
          
          // Main content
          SafeArea(
            child: RefreshIndicator(
              onRefresh: () async {
                // Refresh both wallet data and market data
                await walletController.fetchWalletDetails();
              },
              color: AppColors.primary,
              backgroundColor: AppColors.surface,
            child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(), // Required for RefreshIndicator to work
        child: Padding(
          padding: ResponsiveHelper.getResponsiveAllPadding(context, all: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hey ${username}!',
                                style: AppTextStyles.heading.copyWith(
                                  fontSize: 25,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Welcome back',
                                style: AppTextStyles.body.copyWith(
                                  color: AppColors.textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                  ),
                  Row(
                    children: [
                              GestureDetector(
                                onTap: () => Get.to(() => const SearchScreen()),
                                child: Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: AppColors.surface,
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: AppColors.primary.withOpacity(0.1),
                                          ),
                                        ),
                                        child: SvgPicture.asset(
                                          'assets/icons/Search.svg',
                                          color: AppColors.textSecondary,
                                          width: 20,
                                          height: 20,
                                        ),
                                      ),
                              ),
                              SizedBox(
                                width: 10,
                              ),

              GestureDetector(
                onTap: () => Get.to(() => const NotificationScreen()),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.1),
                    ),
                  ),
                  child: Stack(
                    children: [
                      Image.asset(
                        'assets/icons/ion_notifications.png',
                        color: AppColors.textSecondary,
                        width: 20,
                        height: 20,
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: AppColors.secondary,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.surface,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
                              const SizedBox(width: 12),
                        Container(
                                padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: AppColors.primaryGradient,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                  ),
                                  child: ClipOval(
                                    child: Obx(() => authController.profileImageUrl.isNotEmpty
                                        ? CachedNetworkImage(
                                            imageUrl: authController.profileImageUrl,
                                            fit: BoxFit.cover,
                                            width: 40,
                                            height: 40,
                                            placeholder: (context, url) => Container(
                                              width: 40,
                                              height: 40,
                                              decoration: const BoxDecoration(
                                                color: Colors.white,
                                                shape: BoxShape.circle,
                                              ),
                                              child: Center(
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                                                ),
                                              ),
                                            ),
                                            errorWidget: (context, url, error) => _buildDefaultProfileAvatar(),
                                          )
                                        : _buildDefaultProfileAvatar()),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
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
                              Obx(() => _buildStatItem(
                                '24h Change',
                                walletController.getPortfolio24hChange(),
                                walletController.getPortfolio24hChangeColor(),
                              )),
                              Obx(() => _buildStatItem(
                                '24h High',
                                walletController.getPortfolio24hHigh(),
                                AppColors.text,
                              )),
                              Obx(() => _buildStatItem(
                                '24h Low',
                                walletController.getPortfolio24hLow(),
                                AppColors.text,
                              )),
                            ],
                          ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // BNB Balance Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
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
                        'BNB',
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
                            'BNB Balance',
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Obx(() {
                            final bnbBalance = walletController.getFormattedBNBBalance();
                            final hasSufficient = walletController.hasSufficientBNBBalance();
                            return Row(
                              children: [
                                Text(
                                  '$bnbBalance BNB',
                                  style: AppTextStyles.heading2.copyWith(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: hasSufficient ? Colors.green : Colors.red,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  hasSufficient ? Icons.check_circle : Icons.warning,
                                  color: hasSufficient ? Colors.green : Colors.red,
                                  size: 20,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  hasSufficient ? 'Sufficient' : 'Insufficient',
                                  style: AppTextStyles.body.copyWith(
                                    color: hasSufficient ? Colors.green : Colors.red,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            );
                          }),
                          const SizedBox(height: 4),
                          Text(
                            'Required for transaction fees',
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
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

              // View My Tokens and Balances Section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primary.withOpacity(0.1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'My Tokens & Balances',
                          style: AppTextStyles.heading2.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Get.to(() => const MyTokensScreen()),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'View All',
                                  style: AppTextStyles.body2.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  color: AppColors.primary,
                                  size: 14,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Quick preview of top 3 tokens
                    Obx(() {
                      final tokens = walletController.tokens.take(3).toList();
                      if (tokens.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(20),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.wallet_outlined,
                                  size: 32,
                                  color: AppColors.textSecondary,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'No tokens found',
                                  style: AppTextStyles.body.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      
                      return Column(
                        children: tokens.map((token) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.primary.withOpacity(0.05)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    token['symbol'] ?? 'N/A',
                                    style: AppTextStyles.body2.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
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
                                        style: AppTextStyles.body2.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${token['balance']} ${token['symbol']}',
                                        style: AppTextStyles.body.copyWith(
                                          color: AppColors.textSecondary,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    'View',
                                    style: AppTextStyles.body2.copyWith(
                                      color: AppColors.primary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      );
                    }),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Price Updates Banner
              Obx(() {
                if (_priceUpdates.isEmpty) {
                  return Container(
                    height: 60,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withOpacity(0.1),
                          AppColors.secondary.withOpacity(0.1),
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            'Loading price updates...',
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                
                return Container(
                  height: 60,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withOpacity(0.1),
                        AppColors.secondary.withOpacity(0.1),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(
                      children: [
                        // Content
                        Center(
                          child: ClipRect(
                            child: AnimatedBuilder(
                              animation: _bannerAnimation,
                              builder: (context, child) {
                                return Transform.translate(
                                  offset: Offset(
                                    MediaQuery.of(context).size.width * _bannerAnimation.value,
                                    0,
                                  ),
                                  child: OverflowBox(
                                    maxWidth: MediaQuery.of(context).size.width * 4.0,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                    children: _priceUpdates.map((update) {
                                      final isPositive = update['isPositive'] ?? false;
                                      final changePercent = update['changePercent'] ?? 0.0;
                                      final symbol = update['symbol'] ?? '';
                                      final price = update['price'] ?? 0.0;
                                      
                                      // Create ultra-compact text
                                      String changeText = isPositive ? '+' : '';
                                      
                                                                              return Container(
                                          width: 140, // Slightly wider for better spacing
                                          margin: const EdgeInsets.symmetric(horizontal: 20),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              // Trending icon
                                              Icon(
                                                isPositive ? Icons.trending_up : Icons.trending_down,
                                                color: isPositive ? Colors.green : Colors.red,
                                                size: 10,
                                              ),
                                              const SizedBox(width: 4),
                                              // Symbol (with overflow protection)
                                              Expanded(
                                                child: Text(
                                                  symbol,
                                                  style: AppTextStyles.body.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                    color: AppColors.primary,
                                                    fontSize: 11,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              // Action text (shortened)
                                              Text(
                                                isPositive ? '↗' : '↘',
                                                style: AppTextStyles.body.copyWith(
                                                  color: isPositive ? Colors.green : Colors.red,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              // Price (with overflow protection)
                                              Expanded(
                                                child: Text(
                                                  '\$${price.toStringAsFixed(1)}',
                                                  style: AppTextStyles.body.copyWith(
                                                    color: AppColors.text,
                                                    fontSize: 11,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              // Change percentage (with overflow protection)
                                              Expanded(
                                                child: Text(
                                                  '$changeText${changePercent.toStringAsFixed(1)}%',
                                                  style: AppTextStyles.body.copyWith(
                                                    color: isPositive ? Colors.green : Colors.red,
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 10,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                    }).toList(),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                    )],
                    ),
                  ),
                );
              }),

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
                  child: Obx(() {
                    final favoritesList = walletController.favoritesList;
                    if (favoritesList.isEmpty) {
                      return Center(
                        child: Text(
                          'No favorites added yet',
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      );
                    }
                    
                    return ListView.builder(
                    scrollDirection: Axis.horizontal,
                      itemCount: favoritesList.length,
                    itemBuilder: (context, index) {
                        final token = favoritesList[index];
                        final price = walletController.getPriceForToken(token['symbol'] ?? '');
                        final priceChange = walletController.getPriceChangeForToken(token['symbol'] ?? '');
                      
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
                                      token['icon'] ?? 'assets/icons/Cryptocurrency.png',
                                    width: 24,
                                    height: 24,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                      token['symbol'] ?? '',
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
                    );
                  }),
                ),
              ],

              const SizedBox(height: 24),

              // Price Chart
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primary.withOpacity(0.1)),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Price Chart',
                          style: AppTextStyles.heading2.copyWith(fontSize: 18),
                        ),
                        GestureDetector(
                          onTap: () {
                            _updatePieChartData();
                            setState(() {}); // Force refresh
                            // Force refresh of candlestick chart
                            if (mounted) {
                              setState(() {});
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.refresh,
                              color: AppColors.primary,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
              const SizedBox(height: 20),
                    SizedBox(
                      height: 300, // Increased from 200 to 300
                      child: CandlestickChartWidget(
                        chartData: _pieChartData,
                        chartColors: chartColors,
                        selectedToken: _selectedChartToken,
                      ),
                    ),
                    const SizedBox(height: 16), // Reduced from 20 to 16
                    // Legend - Made more compact
                    Wrap(
                      spacing: 8, // Reduced from 12 to 8
                      runSpacing: 6, // Reduced from 8 to 6
                      children: [
                        for (var i = 0; i < _pieChartData.length; i++)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3), // Reduced padding
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(8), // Reduced from 12 to 8
                              border: Border.all(color: AppColors.primary.withOpacity(0.1)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 8, // Reduced from 12 to 8
                                  height: 8, // Reduced from 12 to 8
                                  decoration: BoxDecoration(
                                    color: chartColors[i % chartColors.length],
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: chartColors[i % chartColors.length].withOpacity(0.3),
                                        blurRadius: 2, // Reduced from 4 to 2
                                        offset: const Offset(0, 1), // Reduced from 2 to 1
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 4), // Reduced from 6 to 4
                                Text(
                                  _pieChartData.keys.elementAt(i),
                                  style: AppTextStyles.body.copyWith(
                                    fontSize: 10, // Reduced from 12 to 10
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

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
                    Obx(() {
                      final cryptoList = walletController.cryptoList;
                      if (cryptoList.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(height: 20),
                              Text(
                                'No crypto data available',
                                style: AppTextStyles.body.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: cryptoList.length,
                  itemBuilder: (context, index) {
                          final token = cryptoList[index];
                          final price = walletController.getPriceForToken(token['symbol'] ?? '');
                          final priceChange = walletController.getPriceChangeForToken(token['symbol'] ?? '');
                          final isSelected = _selectedChartToken == token['symbol'];
                          
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primary.withOpacity(0.1) : AppColors.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected 
                                  ? AppColors.primary 
                                  : AppColors.primary.withOpacity(0.1),
                              ),
                            ),
                            child: ListTile(
                      onTap: () {
                        // Update selected token for chart
                        setState(() {
                          _selectedChartToken = token['symbol'];
                        });
                      },
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Image.asset(
                                  token['icon'] ?? 'assets/icons/Cryptocurrency.png',
                                  width: 24,
                                  height: 24,
                                ),
                      ),
                      title: Text(
                                token['name'] ?? 'Unknown Token',
                        style: const TextStyle(color: AppColors.text),
                      ),
                      subtitle: Text(
                                token['symbol'] ?? '',
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
                      );
                    }),
                  ],
                ),
              ),
            ),
              ),
          ),
      ]),
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

// Shooting Star class to represent a single shooting star
class ShootingStar {
  final double startX;
  final double startY;
  final double endX;
  final double endY;
  final double speed;
  final double size;
  final double delay;
  final Color color;
  
  ShootingStar({
    required this.startX,
    required this.startY,
    required this.endX,
    required this.endY,
    required this.speed,
    required this.size,
    required this.delay,
    required this.color,
  });
}

// CustomPainter for drawing shooting stars
class ShootingStarsPainter extends CustomPainter {
  final List<ShootingStar> shootingStars;
  final double animationValue;
  
  ShootingStarsPainter({
    required this.shootingStars,
    required this.animationValue,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    for (final star in shootingStars) {
      // Calculate the current position based on animation value and delay
      double currentTime = (animationValue + star.delay) % 1.0;
      
      // Only show star during its "active" phase
      if (currentTime < star.speed) {
        // Normalize time to 0-1 range during active phase
        double normalizedTime = currentTime / star.speed;
        
        // Calculate the current position
        double currentX = star.startX + (star.endX - star.startX) * normalizedTime;
        double currentY = star.startY + (star.endY - star.startY) * normalizedTime;
        
        // Calculate tail start position (25% behind the current position)
        double tailX = currentX - (star.endX - star.startX) * 0.25 * normalizedTime;
        double tailY = currentY - (star.endY - star.startY) * 0.25 * normalizedTime;
        
        // Convert to actual coordinates
        Offset start = Offset(tailX * size.width, tailY * size.height);
        Offset end = Offset(currentX * size.width, currentY * size.height);
        
        // Create a gradient for the tail
        final paint = Paint()
          ..shader = LinearGradient(
            colors: [
              star.color.withOpacity(0.0),
              star.color,
            ],
            stops: const [0.0, 1.0],
          ).createShader(Rect.fromPoints(start, end))
          ..strokeWidth = star.size
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke;
        
        // Draw the shooting star
        canvas.drawLine(start, end, paint);
        
        // Draw the star "head" as a small circle
        final headPaint = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill;
        
        canvas.drawCircle(end, star.size, headPaint);
      }
    }
  }
  
  @override
  bool shouldRepaint(covariant ShootingStarsPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

// Add the Badge widget class
class _Badge extends StatelessWidget {
  final String symbol;
  final Color color;

  const _Badge(this.symbol, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        symbol,
        style: AppTextStyles.body.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
