import 'package:nexa_prime/controllers/wallet_controller.dart';
import 'package:nexa_prime/controllers/auth_controller.dart';
import 'package:nexa_prime/controllers/price_alert_controller.dart';
import 'package:nexa_prime/utils/colors.dart';
import 'package:nexa_prime/utils/text_styles.dart';
import 'package:nexa_prime/routes/routes.dart';
import 'package:nexa_prime/views/home/edit_profile_screen.dart';
import 'package:nexa_prime/views/home/backup_wallet_screen.dart';
import 'package:nexa_prime/views/home/change_password_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final WalletController walletController = Get.find();
  final AuthController authController = Get.find();
  final PriceAlertController priceAlertController = Get.find();
  final RxBool _pushNotifications = true.obs;
  final RxBool _emailNotifications = false.obs;
  final RxBool _transactionAlerts = true.obs;
  final RxString userName = ''.obs;
  final RxString userEmail = ''.obs;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  void loadUserData() async {
    final userData = await authController.getUserData();
    userName.value = userData['name'] ?? '';
    userEmail.value = userData['email'] ?? '';
  }

  void _showCustomerServiceOptions() {
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
              'Customer Service',
              style: AppTextStyles.heading2.copyWith(fontSize: 20),
            ),
            const SizedBox(height: 24),
            
            // Live Chat Option
            _buildServiceOption(
              icon: Icons.chat_bubble_outline,
              title: 'Live Chat',
              subtitle: 'Chat with our support team',
              onTap: () {
                Navigator.pop(context);
                _startLiveChat();
              },
            ),
            
            const SizedBox(height: 16),
            
            // Email Support Option
            _buildServiceOption(
              icon: Icons.email_outlined,
              title: 'Email Support',
              subtitle: 'Send us an email for assistance',
              onTap: () {
                Navigator.pop(context);
                _openEmailSupport();
              },
            ),
            
            const SizedBox(height: 16),
            
            // FAQ Option
            _buildServiceOption(
              icon: Icons.help_outline,
              title: 'FAQ',
              subtitle: 'Browse frequently asked questions',
              onTap: () {
                Navigator.pop(context);
                _openFAQ();
              },
            ),
            
            const SizedBox(height: 16),
            
            // Report Issue Option
            _buildServiceOption(
              icon: Icons.report_outlined,
              title: 'Report an Issue',
              subtitle: 'Report bugs or technical problems',
              onTap: () {
                Navigator.pop(context);
                _reportIssue();
              },
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildServiceOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.1),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
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
                    title,
                    style: AppTextStyles.body2.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  void _startLiveChat() {
    // In a real app, this would open a chat widget or navigate to a chat screen
    Get.snackbar(
      'Live Chat',
      'Connecting you to our support team...',
      backgroundColor: AppColors.primary.withOpacity(0.1),
      colorText: AppColors.primary,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
    );
  }

  void _openEmailSupport() {
    // In a real app, this would open the email client or a contact form
    Get.snackbar(
      'Email Support',
      'Opening email client to contact support@nexaprime.com',
      backgroundColor: AppColors.primary.withOpacity(0.1),
      colorText: AppColors.primary,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
    );
  }

  void _openFAQ() {
    // In a real app, this would navigate to an FAQ screen or web page
    Get.snackbar(
      'FAQ',
      'Opening frequently asked questions...',
      backgroundColor: AppColors.primary.withOpacity(0.1),
      colorText: AppColors.primary,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
    );
  }

  void _reportIssue() {
    // In a real app, this would open a bug report form
    Get.snackbar(
      'Report Issue',
      'Opening issue report form...',
      backgroundColor: AppColors.primary.withOpacity(0.1),
      colorText: AppColors.primary,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
    );
  }

  Widget _buildSettingTile({
    required String title,
    required IconData icon,
    Widget? trailing,
    VoidCallback? onTap,
    Color iconColor = AppColors.textSecondary,
    bool showDivider = true,
  }) {
    return Column(
      children: [
        Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: AppColors.primary, size: 20),
            ),
        title: Text(title, style: AppTextStyles.body2),
        trailing: trailing ?? const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: AppColors.textSecondary,
        ),
        onTap: onTap,
          ),
        ),
        if (showDivider) const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(
        title,
        style: AppTextStyles.body2.copyWith(
          color: AppColors.textSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Section
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                  children: [
                      // Profile Picture
                      Container(
                        width: 80,
                        height: 80,
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
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                          child: Center(
                            child: Text(
                              'N',
                              style: AppTextStyles.heading.copyWith(
                                color: AppColors.primary,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Obx(() => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userName.value,
                            style: AppTextStyles.heading.copyWith(fontSize: 24),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            userEmail.value,
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      )),
                    ),
                  ],
                ),
                ),

                _buildSectionHeader('Account Settings'),
                _buildSettingTile(
                  title: 'Edit Profile',
                  icon: Icons.person_outline,
                  onTap: () => Get.to(() => const EditProfileScreen()),
                ),
                _buildSettingTile(
                  title: 'Backup Wallet',
                  icon: Icons.backup_outlined,
                  onTap: () => Get.to(() => BackupWalletScreen()),
                ),
                _buildSettingTile(
                  title: 'Customer Service',
                  icon: Icons.support_agent_outlined,
                  onTap: () => _showCustomerServiceOptions(),
                ),

                _buildSectionHeader('Notifications'),
                _buildSettingTile(
                  title: 'Notification Settings',
                  icon: Icons.notifications_outlined,
                  onTap: () => Get.toNamed(Routes.notificationSettings),
                ),
                Obx(() => _buildSettingTile(
                  title: 'Push Notifications',
                  icon: Icons.notifications_none,
                  trailing: Switch(
                    value: _pushNotifications.value,
                    onChanged: (value) => _pushNotifications.value = value,
                    activeColor: AppColors.primary,
                  ),
                )),
                Obx(() => _buildSettingTile(
                  title: 'Transaction Alerts',
                  icon: Icons.account_balance_wallet_outlined,
                  trailing: Switch(
                    value: _transactionAlerts.value,
                    onChanged: (value) => _transactionAlerts.value = value,
                    activeColor: AppColors.primary,
                  ),
                )),

                _buildSectionHeader('Price Alerts'),
                Obx(() => _buildSettingTile(
                  title: 'Auto Price Monitoring',
                  icon: Icons.trending_up,
                  trailing: Switch(
                    value: priceAlertController.isMonitoring,
                    onChanged: (value) => priceAlertController.togglePriceMonitoring(),
                    activeColor: AppColors.primary,
                  ),
                )),

                _buildSectionHeader('Security'),
                _buildSettingTile(
                  title: 'Change Password',
                  icon: Icons.lock_outline,
                  onTap: () => Get.to(() => const ChangePasswordScreen()),
                ),

                const SizedBox(height: 32),

                // Logout Button
                Container(
                  width: double.infinity,
                  height: 50,
                  margin: const EdgeInsets.only(bottom: 20),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.withOpacity(0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Get.offAllNamed(Routes.signin);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.logout,
                          color: Colors.red,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Logout',
                          style: AppTextStyles.button.copyWith(
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}