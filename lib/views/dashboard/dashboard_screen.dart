import 'package:nexa_prime/views/home/settings_screen.dart';
import 'package:nexa_prime/views/home/swap_screen.dart';
import 'package:nexa_prime/views/home/transaction_screen.dart';
import 'package:nexa_prime/views/home/wallet_screen.dart';
import 'package:nexa_prime/controllers/dashboard_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/colors.dart';
import 'dart:ui';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  final DashboardController dashboardController = Get.put(DashboardController());
  
  final List<Widget> _screens = [
    const WalletScreen(),
    const SwapScreen(),
    const TransactionScreen(),
    const SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Obx(() => _screens[dashboardController.currentIndex]),
      extendBody: true,
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(16),
        height: 65,
        child: Stack(
          children: [
            // Blurred background
            ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
        decoration: BoxDecoration(
                    color: AppColors.bottomNavBackground.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                ),
              ),
        ),
            // Content
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Obx(() => Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNavItem(0, 'Wallet', 'assets/icons/9035549_wallet_outline_icon.png'),
              _buildNavItem(1, 'Swap', 'assets/icons/material-symbols_change-circle-outline.png'),
              _buildNavItem(2, 'Transactions', 'assets/icons/7340522_e-commerce_online_shopping_ui_receipt_icon.png'),
              _buildNavItem(3, 'Settings', 'assets/icons/8666615_settings_icon.png'),
            ],
              )),
          ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, String label, String icon) {
    bool isSelected = dashboardController.currentIndex == index;
    
    return GestureDetector(
      onTap: () {
        if (dashboardController.currentIndex != index) {
          dashboardController.updateIndex(index);
          _controller.forward().then((_) => _controller.reverse());
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 16 : 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          gradient: isSelected ? AppColors.primaryGradient : null,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected ? [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ] : null,
        ),
        child: Row(
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.scale(
                  scale: isSelected ? _scaleAnimation.value : 1.0,
                  child: Image.asset(
              icon,
                    color: isSelected ? Colors.white : AppColors.bottomNavUnselected,
                    height: 20,
                  ),
                );
              },
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: isSelected ? 6 : 0,
            ),
            ClipRect(
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 300),
                alignment: Alignment.centerLeft,
                widthFactor: isSelected ? 1 : 0,
                child: Row(
                  children: [
              Text(
                label,
                style: TextStyle(
                        color: isSelected ? Colors.white : AppColors.bottomNavUnselected,
                  fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 