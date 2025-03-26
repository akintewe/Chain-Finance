import 'package:nexa_prime/views/home/settings_screen.dart';
import 'package:nexa_prime/views/home/swap_screen.dart';
import 'package:nexa_prime/views/home/transaction_screen.dart';
import 'package:nexa_prime/views/home/wallet_screen.dart';
import 'package:flutter/material.dart';
import '../../utils/colors.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  
  
  final List<Widget> _screens = [
    const WalletScreen(),
    const SwapScreen(),
    const TransactionScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.bottomNavBackground,
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNavItem(0, 'Wallet', 'assets/icons/9035549_wallet_outline_icon.png'),
              _buildNavItem(1, 'Swap', 'assets/icons/material-symbols_change-circle-outline.png'),
              _buildNavItem(2, 'Transactions', 'assets/icons/7340522_e-commerce_online_shopping_ui_receipt_icon.png'),
              _buildNavItem(3, 'Settings', 'assets/icons/8666615_settings_icon.png'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, String label, String icon) {
    bool isSelected = _currentIndex == index;
    
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Image.asset(
              icon,
              color: isSelected ? AppColors.primary : AppColors.bottomNavUnselected,
              height: 22,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
} 