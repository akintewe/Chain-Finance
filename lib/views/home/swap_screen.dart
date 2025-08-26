import 'package:nexa_prime/controllers/wallet_controller.dart';
import 'package:nexa_prime/controllers/dashboard_controller.dart';
import 'package:nexa_prime/utils/colors.dart';
import 'package:nexa_prime/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SwapScreen extends StatefulWidget {
  final bool isFromMyTokens;
  final Map<String, dynamic>? selectedFromToken;
  
  const SwapScreen({
    super.key,
    this.isFromMyTokens = false,
    this.selectedFromToken,
  });

  @override
  State<SwapScreen> createState() => _SwapScreenState();
}

class _SwapScreenState extends State<SwapScreen> with SingleTickerProviderStateMixin {
  final WalletController walletController = Get.find<WalletController>();
  final DashboardController dashboardController = Get.find<DashboardController>();
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  Map<String, dynamic>? fromToken;
  Map<String, dynamic>? toToken;
  final TextEditingController fromAmountController = TextEditingController();
  final TextEditingController toAmountController = TextEditingController();
  String? amountError;

  @override
  void initState() {
    super.initState();
    
    // Pre-select the token if provided
    if (widget.selectedFromToken != null) {
      fromToken = widget.selectedFromToken;
    }
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );

    _controller.forward();
    
    // Add listener to validate amount input
    fromAmountController.addListener(_validateAmount);
    
    // Fetch wallet data after the build is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      walletController.fetchWalletDetails();
    });
  }

  // Validate the entered amount against available balance
  void _validateAmount() {
    if (fromToken == null) {
      setState(() {
        amountError = null;
      });
      return;
    }
    
    final enteredAmount = double.tryParse(fromAmountController.text) ?? 0.0;
    final availableBalance = double.tryParse(fromToken!['balance'] ?? '0') ?? 0.0;
    
    if (enteredAmount > availableBalance) {
      setState(() {
        amountError = 'Insufficient balance. Available: ${availableBalance.toStringAsFixed(8)} ${fromToken!['symbol']}';
      });
    } else if (enteredAmount <= 0) {
      setState(() {
        amountError = 'Amount must be greater than 0';
      });
    } else {
      setState(() {
        amountError = null;
      });
    }
  }
  
  // Set the maximum available amount for the selected token
  void _setMaxAmount() {
    if (fromToken != null) {
      final availableBalance = double.tryParse(fromToken!['balance'] ?? '0') ?? 0.0;
      fromAmountController.text = availableBalance.toStringAsFixed(8);
      _validateAmount();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    fromAmountController.dispose();
    toAmountController.dispose();
    super.dispose();
  }

  void _showTokenSelector(bool isFrom) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
            Text(
              isFrom ? 'Select Token to Swap From' : 'Select Token to Swap To',
              style: AppTextStyles.heading2,
            ),
            const SizedBox(height: 16),
                    Expanded(
                child: Obx(() {
                  if (walletController.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  
                  if (walletController.tokens.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.wallet_outlined,
                            size: 48,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No tokens available',
                            style: AppTextStyles.body2.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Please ensure your wallet is connected',
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }
                  
                  return ListView.builder(
                    controller: scrollController,
                itemCount: walletController.tokens.length,
                itemBuilder: (context, index) {
                  final token = walletController.tokens[index];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isFrom) {
                          fromToken = token;
                              // Clear amount when token changes
                              fromAmountController.clear();
                              amountError = null;
                        } else {
                          toToken = token;
                        }
                      });
                      Navigator.pop(context);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
                      ),
                            child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                                child: Text(
                                  token['symbol'],
                                  style: AppTextStyles.body2.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  token['name'],
                                  style: AppTextStyles.body2.copyWith(
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
                  );
                },
                  );
                }),
                ),
              ],
          ),
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
          onPressed: () {
            if (widget.isFromMyTokens) {
              Navigator.pop(context);
            } else {
              dashboardController.goToWallet();
            }
          },
        ),
        title: Text('Swap', style: AppTextStyles.heading2),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.text),
            onPressed: () {
              walletController.fetchWalletDetails();
            },
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Obx(() {
                  if (walletController.isLoading) {
                    return const Center(
                child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Loading wallet data...'),
                        ],
                      ),
                    );
                  }
                  
                  return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Quick Info Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary.withOpacity(0.1),
                            AppColors.secondary.withOpacity(0.1),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                      ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.info_outline,
                                  color: AppColors.primary,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Quick Info',
                                style: AppTextStyles.body2.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
              Text(
                            '• Best rates guaranteed\n• No hidden fees\n• Instant swaps\n• Secure transactions',
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.textSecondary,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
              ),
              const SizedBox(height: 24),
              
                    // From Token
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'From',
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      TextField(
                controller: fromAmountController,
                                  keyboardType: TextInputType.number,
                                  style: AppTextStyles.heading2.copyWith(
                                    color: AppColors.text,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: '0.0',
                                    hintStyle: AppTextStyles.heading2.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.zero,
                                        ),
                                      ),
                                      if (amountError != null) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          amountError!,
                                          style: AppTextStyles.body.copyWith(
                                            color: Colors.red,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Max Button
                                if (fromToken != null)
                                  GestureDetector(
                                    onTap: _setMaxAmount,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                                      ),
                                      child: Text(
                                        'MAX',
                                        style: AppTextStyles.body2.copyWith(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12,
                                        ),
                                  ),
                                ),
                              ),
                                const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () => _showTokenSelector(true),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.background,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppColors.primary.withOpacity(0.1)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (fromToken != null) ...[
                                        Image.asset(
                                          fromToken!['icon'],
                                          width: 24,
                                          height: 24,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          fromToken!['symbol'],
                                          style: AppTextStyles.body2.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ] else
                                        Text(
                                          'Select',
                                          style: AppTextStyles.body2.copyWith(
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                      
                      // Available Balance Display
                      if (fromToken != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Available Balance:',
                                style: AppTextStyles.body.copyWith(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                '${fromToken!['balance']} ${fromToken!['symbol']}',
                                style: AppTextStyles.body.copyWith(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      
              const SizedBox(height: 16),
              
                      // Swap Direction Icon
              Center(
                child: Container(
                        padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    shape: BoxShape.circle,
                          border: Border.all(color: AppColors.primary.withOpacity(0.1)),
                  ),
                        child: Icon(
                      Icons.swap_vert,
                          color: AppColors.primary,
                          size: 24,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // To Token
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'To',
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: toAmountController,
                                  keyboardType: TextInputType.number,
                                  style: AppTextStyles.heading2.copyWith(
                                    color: AppColors.text,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: '0.0',
                                    hintStyle: AppTextStyles.heading2.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ),
                              ),
                                const SizedBox(width: 16),
                              GestureDetector(
                                onTap: () => _showTokenSelector(false),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.background,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppColors.primary.withOpacity(0.1)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (toToken != null) ...[
                                        Image.asset(
                                          toToken!['icon'],
                                          width: 24,
                                          height: 24,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          toToken!['symbol'],
                                          style: AppTextStyles.body2.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ] else
                                        Text(
                                          'Select',
                                          style: AppTextStyles.body2.copyWith(
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                    ],
                  ),
                ),
              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // BNB Balance Display
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
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
                              'BNB',
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
                                  'BNB Balance (Transaction Fees)',
                                  style: AppTextStyles.body.copyWith(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
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
                                        style: AppTextStyles.body2.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: hasSufficient ? Colors.green : Colors.red,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Icon(
                                        hasSufficient ? Icons.check_circle : Icons.warning,
                                        color: hasSufficient ? Colors.green : Colors.red,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        hasSufficient ? 'Sufficient' : 'Insufficient',
                                        style: AppTextStyles.body.copyWith(
                                          color: hasSufficient ? Colors.green : Colors.red,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  );
                                }),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Swap Button
                    SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                          onPressed: fromToken != null && toToken != null && amountError == null
                      ? () async {
                          // Check BNB balance before proceeding
                          if (!walletController.hasSufficientBNBBalance()) {
                            final currentBNB = walletController.getFormattedBNBBalance();
                            Get.dialog(
                              AlertDialog(
                                title: Text('Insufficient BNB Balance'),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('You need at least 1 BNB in your wallet to make swaps.'),
                                    const SizedBox(height: 16),
                                    Text('Current BNB Balance: $currentBNB BNB'),
                                    const SizedBox(height: 8),
                                    Text(
                                      'BNB is required to pay for transaction fees on the Binance Smart Chain network.',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(),
                                    child: Text('OK'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      Get.snackbar(
                                        'Info',
                                        'Please add BNB to your wallet to continue',
                                        backgroundColor: Colors.orange,
                                        colorText: Colors.white,
                                      );
                                    },
                                    child: Text('Get BNB'),
                                  ),
                                ],
                              ),
                            );
                            return;
                          }

                          // Implement swap functionality
                          try {
                            final amount = double.tryParse(fromAmountController.text) ?? 0.0;
                            if (amount <= 0) {
                              Get.snackbar('Error', 'Please enter a valid amount');
                              return;
                            }
                            
                            // Call the swap API
                            await walletController.swapCrypto({
                              'tokenFrom': fromToken!['symbol']?.toString().toUpperCase() ?? '',
                              'tokenTo': toToken!['symbol']?.toString().toUpperCase() ?? '',
                              'amount': amount,
                            });
                            
                            Get.snackbar(
                              'Success', 
                              'Swap initiated successfully!',
                              backgroundColor: Colors.green,
                              colorText: Colors.white,
                            );
                            
                            // Clear the form
                            fromAmountController.clear();
                            toAmountController.clear();
                            setState(() {
                              fromToken = null;
                              toToken = null;
                              amountError = null;
                            });
                            
                          } catch (e) {
                            Get.snackbar(
                              'Error', 
                              'Failed to initiate swap: $e',
                              backgroundColor: Colors.red,
                              colorText: Colors.white,
                            );
                          }
                        }
                      : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.surface,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          'Swap',
                          style: AppTextStyles.button.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
                  );
                }),
        ),
            ),
          );
        },
      ),
    );
  }
}