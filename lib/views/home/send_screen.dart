import 'dart:async';

import 'package:nexa_prime/controllers/wallet_controller.dart';
import 'package:nexa_prime/utils/colors.dart';
import 'package:nexa_prime/utils/text_styles.dart';
import 'package:nexa_prime/utils/loader.dart';
import 'package:nexa_prime/utils/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SendScreen extends StatefulWidget {
  final bool isSendingToExternal;
  final Map<String, dynamic>? selectedToken;
  
  const SendScreen({
    super.key, 
    required this.isSendingToExternal,
    this.selectedToken,
  });

  @override
  State<SendScreen> createState() => _SendScreenState();
}

class _SendScreenState extends State<SendScreen> with SingleTickerProviderStateMixin {
  final TextEditingController amountController = TextEditingController();
  final TextEditingController uuidController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  final WalletController walletController = Get.find();
  String? selectedToken;
  String? selectedNetworkCode;
  final RxMap<String, dynamic> receiverData = <String, dynamic>{}.obs;
  final RxBool isLoadingUser = false.obs;
  Timer? _debounceTimer;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    walletController.fetchWalletDetails();
    
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
  }

  @override
  void dispose() {
    _controller.dispose();
    _debounceTimer?.cancel();
    amountController.dispose();
    uuidController.dispose();
    addressController.dispose();
    noteController.dispose();
    super.dispose();
  }

  void _onUUIDChanged(String uuid) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    if (uuid.length < 4) return;

    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      isLoadingUser.value = true;
      final userData = await walletController.getUserByUUID(uuid);
      if (userData != null) {
        receiverData.value = userData;
      } else {
        receiverData.clear();
      }
      isLoadingUser.value = false;
    });
  }

  void _showTokenSelector() {
    if (selectedNetworkCode == null) {
      Get.snackbar(
        'Select Network First',
        'Please select a network before choosing a token',
        backgroundColor: Colors.orange.withOpacity(0.1),
        colorText: Colors.orange,
      );
      return;
    }

    final networkTokens = walletController.allTokensByNetwork[selectedNetworkCode!];
    if (networkTokens == null || networkTokens.isEmpty) {
      Get.snackbar(
        'No Tokens Available',
        'No tokens found for the selected network',
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
      return;
    }

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
        padding: ResponsiveHelper.getResponsiveAllPadding(context, all: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
          children: [
            Text(
              'Select Token',
              style: AppTextStyles.heading2,
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      walletController.networks[selectedNetworkCode!] ?? selectedNetworkCode!,
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                  controller: scrollController,
                  itemCount: networkTokens.length,
                itemBuilder: (context, index) {
                    final tokenSymbol = networkTokens.keys.elementAt(index);
                    final tokenData = networkTokens[tokenSymbol];
                    // Use the symbol field from the API response if available, otherwise fallback to the key
                    final displaySymbol = tokenData['symbol'] ?? tokenSymbol;
                    
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                          selectedToken = displaySymbol;
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
                                displaySymbol,
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
                                    tokenData['name'] ?? displaySymbol,
                                  style: AppTextStyles.body2.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: _getTokenTypeColor(tokenData['type']).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          tokenData['type'] ?? 'unknown',
        style: AppTextStyles.body.copyWith(
                                            color: _getTokenTypeColor(tokenData['type']),
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      if (tokenData['contract'] != null) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: AppColors.secondary.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            'Contract',
                                            style: AppTextStyles.body.copyWith(
                                              color: AppColors.secondary,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                              ],
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
      ),
    );
  }

  Color _getTokenTypeColor(String? type) {
    switch (type?.toLowerCase()) {
      case 'native':
        return Colors.blue;
      case 'stablecoin':
        return Colors.green;
      case 'defi':
        return Colors.purple;
      case 'gaming':
        return Colors.orange;
      case 'nft':
        return Colors.pink;
      case 'bridge':
        return Colors.teal;
      case 'oracle':
        return Colors.indigo;
      case 'meme':
        return Colors.red;
      case 'utility':
        return Colors.cyan;
      default:
        return AppColors.textSecondary;
    }
  }

  Future<void> _openNetworkSelector() async {
    if (walletController.networks.isEmpty) {
      Loader.show();
      await walletController.fetchSupportedNetworksAndTokens();
      Loader.hide();
    }
    _showNetworkSelector();
  }

  void _showNetworkSelector() {
    final networks = walletController.networks; // code -> display name
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
          padding: ResponsiveHelper.getResponsiveAllPadding(context, all: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Select Network', style: AppTextStyles.heading2),
              const SizedBox(height: 16),
              if (networks.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Text('No networks available', style: AppTextStyles.body),
                  ),
                )
              else
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    children: networks.entries.map((entry) {
                      final code = entry.key;
                      final name = entry.value;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedNetworkCode = code;
                            // Clear selected token when network changes since tokens are network-specific
                            selectedToken = null;
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
                                child: const Icon(Icons.hub_outlined, color: AppColors.primary, size: 20),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(name, style: AppTextStyles.body2.copyWith(fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 4),
                                    Text(code.toUpperCase(), style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
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
                      onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.isSendingToExternal ? 'Send to External Wallet' : 'Send to Nexa Prime User',
          style: AppTextStyles.heading2.copyWith(fontSize: 20),
        ),
      ),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SingleChildScrollView(
                padding: ResponsiveHelper.getResponsiveAllPadding(context, all: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
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
                            widget.isSendingToExternal
                                ? '• Select your preferred blockchain network\n• Double-check the wallet address\n• Transaction cannot be reversed'
                                : '• Instant transfers to Nexa Prime users\n• No network fees\n• Secure and reliable',
                        style: AppTextStyles.body.copyWith(
                              color: AppColors.textSecondary,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Token Selection
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
                          Row(
                        children: [
                          Text(
                            'Select Token',
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.textSecondary,
                            ),
                              ),
                              if (selectedNetworkCode != null) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    walletController.networks[selectedNetworkCode!] ?? selectedNetworkCode!,
                                    style: AppTextStyles.body.copyWith(
                                      color: AppColors.primary,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 8),
                          if (selectedNetworkCode == null)
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.orange.withOpacity(0.3)),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.info_outline, color: Colors.orange, size: 20),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Select a network first to view available tokens',
                                      style: AppTextStyles.body.copyWith(
                                        color: Colors.orange,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                          GestureDetector(
                            onTap: _showTokenSelector,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.primary.withOpacity(0.1)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  if (selectedToken != null) ...[
                                    Row(
                                      children: [
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: AppColors.primary.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              selectedToken!,
                                              style: AppTextStyles.body2.copyWith(
                                                color: AppColors.primary,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          selectedToken!,
                                          style: AppTextStyles.body2.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ] else
                                    Text(
                                      'Select Token',
                                      style: AppTextStyles.body2.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    color: AppColors.textSecondary,
                                    size: 16,
                                  ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

            // Network Selection (for external sends only, but we can show for both if needed)
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
                    'Select Network',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _openNetworkSelector,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (selectedNetworkCode != null) ...[
                            Row(
                              children: [
                                const Icon(Icons.hub_outlined, size: 24, color: AppColors.textSecondary),
                                const SizedBox(width: 8),
                                Text(
                                  walletController.networks[selectedNetworkCode!] ?? selectedNetworkCode!,
                                  style: AppTextStyles.body2.copyWith(fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ] else
                            Text(
                              'Select Network',
                              style: AppTextStyles.body2.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          const Icon(Icons.arrow_forward_ios, color: AppColors.textSecondary, size: 16),
                                ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 24),

            if (widget.isSendingToExternal) ...[
              // Wallet Address Input
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
                              'Wallet Address',
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                controller: addressController,
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.text,
                              ),
                              decoration: InputDecoration(
                hintText: 'Enter wallet address',
                                hintStyle: AppTextStyles.body.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: AppColors.background,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
              ),
            ] else ...[
              // UUID Input with User Info
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
                              'Recipient ID',
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.textSecondary,
                              ),
              ),
              const SizedBox(height: 8),
                            TextField(
                              controller: uuidController,
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.text,
                              ),
                              onChanged: _onUUIDChanged,
                              decoration: InputDecoration(
                                hintText: 'Enter recipient\'s ID',
                                hintStyle: AppTextStyles.body.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: AppColors.background,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
              
              // User Info Section
              Obx(() => AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: isLoadingUser.value
                  ? const Center(child: CircularProgressIndicator())
                  : receiverData.isNotEmpty
                    ? Container(
                        padding: const EdgeInsets.all(16),
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
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.person,
                                        color: AppColors.primary,
                                        size: 24,
                                      ),
                            ),
                                    const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    receiverData['name'] ?? '',
                                            style: AppTextStyles.body2.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                  ),
                                  Text(
                                    receiverData['email'] ?? '',
                                    style: AppTextStyles.body.copyWith(
                                      color: AppColors.textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink(),
              )),
              
              const SizedBox(height: 24),
              
                      // Note Input
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
                              'Note (Optional)',
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                controller: noteController,
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.text,
                              ),
                              maxLines: 2,
                              decoration: InputDecoration(
                hintText: 'Add a note to this transfer',
                                hintStyle: AppTextStyles.body.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: AppColors.background,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                              ),
              ),
            ],
                        ),
                      ),
                    ],
            const SizedBox(height: 24),
            
            // Amount Input
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
                            'Amount',
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: amountController,
                            style: AppTextStyles.heading2.copyWith(
                              color: AppColors.text,
                            ),
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: '0.00',
                              hintStyle: AppTextStyles.heading2.copyWith(
                                color: AppColors.textSecondary,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: AppColors.background,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                            ),
                          ),
                          if (selectedToken != null) ...[
                            const SizedBox(height: 8),
                            Obx(() {
                              final balance = walletController.getBalanceForToken(selectedToken!);
                              return Text(
                                'Available Balance: $balance $selectedToken',
                                style: AppTextStyles.body.copyWith(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              );
                            }),
                          ],
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

            // Send Button
                    SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _handleSend(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.surface,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          'Send',
                          style: AppTextStyles.button.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
              ),
            ),
          ],
        ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _handleSend() async {
    if (selectedToken == null || amountController.text.isEmpty || selectedNetworkCode == null) {
      Get.snackbar('Error', 'Please fill in all required fields');
      return;
    }

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
              Text('You need at least 1 BNB in your wallet to make transactions.'),
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
                // You can add navigation to a BNB purchase screen here
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

    try {
      if (widget.isSendingToExternal) {
        await walletController.sendExternal({
          'to_address': addressController.text,
          'amount': double.parse(amountController.text),
          'token': selectedToken, // Add token parameter as required by API
        });
      } else {
        await walletController.sendInternal({
          'receiver_uuid': uuidController.text,
          'amount': double.parse(amountController.text),
          'currency': selectedToken,
          'note': noteController.text,
        });
      }
              Navigator.pop(context);
      Get.snackbar('Success', 'Transaction sent successfully');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }
} 