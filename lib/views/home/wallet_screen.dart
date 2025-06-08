import 'package:nexa_prime/controllers/auth_controller.dart';
import 'package:nexa_prime/controllers/wallet_controller.dart';
import 'package:nexa_prime/utils/colors.dart';
import 'package:nexa_prime/utils/text_styles.dart';
import 'package:nexa_prime/views/home/receive_screen.dart';
import 'package:nexa_prime/views/home/send_screen.dart';
import 'package:nexa_prime/views/home/search_screen.dart';
import 'package:nexa_prime/views/home/notification_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'dart:math';
import 'package:nexa_prime/views/home/token_info_screen.dart';
import 'package:nexa_prime/views/home/all_tokens_screen.dart';
import 'package:nexa_prime/views/home/edit_favorites_screen.dart';
import 'package:fl_chart/fl_chart.dart' as fl;
import 'dart:async';
import 'package:get/get.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> with TickerProviderStateMixin {
  final AuthController authController = Get.find();
  final WalletController walletController = Get.find();
  late String username = 'User';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  // Timer for pie chart updates
  Timer? _pieChartTimer;
  Map<String, double> _pieChartData = {};
  
  // Animation controllers for shooting stars
  late AnimationController _starsController;
  late List<ShootingStar> _shootingStars;
  final int _starCount = 15;

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
      setState(() {
        _pieChartData = newData;
      });
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

  Future<void> _loadUserData() async {
    final userData = await authController.getUserData();
    setState(() {
      username = userData['name'] ?? 'User';
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _starsController.dispose();
    _pieChartTimer?.cancel();
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
            child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
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
                                  fontSize: 28,
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
                              const SizedBox(width: 12),
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
                                  child: Center(
                                    child: Text(
                                      username[0].toUpperCase(),
                                      style: AppTextStyles.heading.copyWith(
                                        color: AppColors.primary,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
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
                      height: 200,
                      child: PieChartWidget(
                        pieChartData: _pieChartData,
                        chartColors: chartColors,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Legend
                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      children: [
                        for (var i = 0; i < _pieChartData.length; i++)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.primary.withOpacity(0.1)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: chartColors[i % chartColors.length],
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: chartColors[i % chartColors.length].withOpacity(0.3),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _pieChartData.keys.elementAt(i),
                                  style: AppTextStyles.body.copyWith(
                                    fontSize: 12,
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
            ],
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

// Add this class at the bottom of the file after the _Badge class
class PieChartWidget extends StatefulWidget {
  final Map<String, double> pieChartData;
  final List<Color> chartColors;

  const PieChartWidget({
    Key? key,
    required this.pieChartData,
    required this.chartColors,
  }) : super(key: key);

  @override
  State<PieChartWidget> createState() => _PieChartWidgetState();
}

class _PieChartWidgetState extends State<PieChartWidget> {
  late fl.PieChartData _cachedChartData;
  bool _hasBuiltChart = false;
  Map<String, double> _lastDataSnapshot = {};

  @override
  void didUpdateWidget(PieChartWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only rebuild the chart data if the actual data changes significantly
    if (!_mapsEqual(oldWidget.pieChartData, widget.pieChartData)) {
      _hasBuiltChart = false;
      _lastDataSnapshot = Map.from(widget.pieChartData);
    }
  }

  bool _mapsEqual(Map<String, double> map1, Map<String, double> map2) {
    if (map1.length != map2.length) return false;
    for (var key in map1.keys) {
      if (!map2.containsKey(key) || map1[key] != map2[key]) return false;
    }
    return true;
  }

  fl.PieChartData _buildChartData() {
    if (!_hasBuiltChart) {
      _cachedChartData = fl.PieChartData(
        sections: widget.pieChartData.entries.map((entry) {
          final index = widget.pieChartData.keys.toList().indexOf(entry.key);
          return fl.PieChartSectionData(
            value: entry.value,
            title: '${(entry.value / widget.pieChartData.values.reduce((a, b) => a + b) * 100).toStringAsFixed(1)}%',
            radius: 80,
            titleStyle: AppTextStyles.body2.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            color: widget.chartColors[index % widget.chartColors.length],
            showTitle: entry.value > 0,
            badgeWidget: _Badge(
              entry.key,
              widget.chartColors[index % widget.chartColors.length],
            ),
            badgePositionPercentageOffset: 1.2,
          );
        }).toList(),
        sectionsSpace: 2,
        centerSpaceRadius: 40,
        startDegreeOffset: -90,
        pieTouchData: fl.PieTouchData(
          touchCallback: (fl.FlTouchEvent event, fl.PieTouchResponse? pieTouchResponse) {
            // Removed the snackbar popup that was causing Bitcoin price to appear at bottom
            // Instead, just handle the touch event silently or add other feedback if needed
            if (event is! fl.FlPointerHoverEvent && pieTouchResponse?.touchedSection != null) {
              // Chart section tapped - you can add other feedback here if needed
              print('Chart section ${pieTouchResponse!.touchedSection!.touchedSectionIndex} tapped');
            }
          },
        ),
      );
      _hasBuiltChart = true;
    }
    return _cachedChartData;
  }

  @override
  Widget build(BuildContext context) {
    // Skip rebuilding if data is empty
    if (widget.pieChartData.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Loading price data...',
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    // Use RepaintBoundary to isolate this widget's rendering
    return RepaintBoundary(
      child: fl.PieChart(
        _buildChartData(),
        swapAnimationDuration: Duration.zero, // Disable animations to prevent rebuilds
      ),
    );
  }
}