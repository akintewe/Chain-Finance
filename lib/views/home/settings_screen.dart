import 'package:nexa_prime/controllers/wallet_controller.dart';
import 'package:nexa_prime/controllers/auth_controller.dart';
import 'package:nexa_prime/controllers/price_alert_controller.dart';
import 'package:nexa_prime/controllers/kyc_controller.dart';
import 'package:nexa_prime/utils/colors.dart';
import 'package:nexa_prime/utils/text_styles.dart';
import 'package:nexa_prime/routes/routes.dart';
import 'package:nexa_prime/views/home/edit_profile_screen.dart';
import 'package:nexa_prime/views/home/backup_wallet_screen.dart';
import 'package:nexa_prime/views/home/change_password_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final WalletController walletController = Get.find();
  final AuthController authController = Get.find();
  final PriceAlertController priceAlertController = Get.find();
  final KYCController kycController = Get.put(KYCController());
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

  void _openEmailSupport() async {
    // Check if running on iOS simulator
    bool isIOSSimulator = false;
    try {
      // This will throw an exception on iOS simulator
      await canLaunchUrl(Uri.parse('mailto:test@test.com'));
    } catch (e) {
      if (e.toString().contains('channel-error') || e.toString().contains('Unable to establish connection')) {
        isIOSSimulator = true;
      }
    }
    
    if (isIOSSimulator) {
      // Show simulator-specific message
      Get.snackbar(
        'Email Support',
        'Please send an email to support@nexaprime.org\n(Email client not available in simulator)',
        backgroundColor: AppColors.primary.withOpacity(0.1),
        colorText: AppColors.primary,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 5),
      );
      return;
    }
    
    // Try different email URL schemes
    final List<Uri> emailUris = [
      Uri(
        scheme: 'mailto',
        path: 'support@nexaprime.org',
        query: 'subject=Support Request - Nexa Prime App',
      ),
      Uri.parse('mailto:support@nexaprime.org?subject=Support Request - Nexa Prime App'),
    ];
    
    bool launched = false;
    
    for (final emailUri in emailUris) {
      try {
        // Check if URL can be launched
        final canLaunch = await canLaunchUrl(emailUri);
        
        if (canLaunch) {
          // Launch email client
          await launchUrl(emailUri, mode: LaunchMode.externalApplication);
          launched = true;
          
          Get.snackbar(
            'Email Support',
            'Opening email client...',
            backgroundColor: AppColors.primary.withOpacity(0.1),
            colorText: AppColors.primary,
            snackPosition: SnackPosition.BOTTOM,
            margin: const EdgeInsets.all(16),
            borderRadius: 12,
            duration: const Duration(seconds: 3),
          );
          break;
        }
      } catch (e) {
        print('Error launching email with URI $emailUri: $e');
        continue;
      }
    }
    
    if (!launched) {
      // Fallback if email client cannot be opened
      Get.snackbar(
        'Email Support',
        'Please send an email to support@nexaprime.org',
        backgroundColor: AppColors.primary.withOpacity(0.1),
        colorText: AppColors.primary,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 5),
      );
    }
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

  Widget _buildKYCStatusTile() {
    final kycStatus = kycController.kycStatus.value;
    final isVerified = kycStatus == 'verified';
    final isPending = kycStatus == 'pending';
    final isRejected = kycStatus == 'rejected';

    IconData statusIcon;
    Color statusColor;
    String statusText;

    if (isVerified) {
      statusIcon = Icons.check_circle_outline;
      statusColor = Colors.green;
      statusText = 'Verified';
    } else if (isPending) {
      statusIcon = Icons.hourglass_empty;
      statusColor = Colors.orange;
      statusText = 'Pending';
    } else if (isRejected) {
      statusIcon = Icons.cancel_outlined;
      statusColor = Colors.red;
      statusText = 'Rejected';
    } else {
      statusIcon = Icons.pending_outlined;
      statusColor = Colors.grey;
      statusText = 'Not Submitted';
    }

    return _buildSettingTile(
      title: 'KYC Status',
      icon: Icons.verified_user_outlined,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            statusIcon,
            color: statusColor,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            statusText,
            style: AppTextStyles.body2.copyWith(
              fontWeight: FontWeight.w600,
              color: statusColor,
            ),
          ),
        ],
      ),
      onTap: () => Get.toNamed(Routes.kycStatus),
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
                  onTap: () => _openEmailSupport(),
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

                _buildSectionHeader('KYC Status'),
                Obx(() => _buildKYCStatusTile()),

                _buildSectionHeader('Security'),
                _buildSettingTile(
                  title: 'Change Password',
                  icon: Icons.lock_outline,
                  onTap: () => Get.to(() => const ChangePasswordScreen()),
                ),
                _buildSettingTile(
                  title: 'Privacy Policy',
                  icon: Icons.privacy_tip_outlined,
                  onTap: () => Get.toNamed(Routes.privacyPolicy),
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
                    onPressed: () async {
                      // Show confirmation dialog
                      final shouldLogout = await Get.dialog<bool>(
                        AlertDialog(
                          title: const Text('Logout'),
                          content: const Text('Are you sure you want to logout?'),
                          actions: [
                            TextButton(
                              onPressed: () => Get.back(result: false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Get.back(result: true),
                              child: const Text('Logout'),
                            ),
                          ],
                        ),
                      );
                      
                      if (shouldLogout == true) {
                        // Call the logout method from AuthController
                        final authController = Get.find<AuthController>();
                        await authController.logout();
                      }
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