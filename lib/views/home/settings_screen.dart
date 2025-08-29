import 'package:nexa_prime/controllers/wallet_controller.dart';
import 'package:nexa_prime/controllers/auth_controller.dart';
import 'package:nexa_prime/controllers/price_alert_controller.dart';
import 'package:nexa_prime/controllers/kyc_controller.dart';
import 'package:nexa_prime/services/api_service.dart';
import 'package:nexa_prime/utils/colors.dart';
import 'package:nexa_prime/utils/text_styles.dart';
import 'package:nexa_prime/utils/button_style.dart';
import 'package:nexa_prime/utils/responsive_helper.dart';
import 'package:nexa_prime/routes/routes.dart';
import 'package:nexa_prime/views/home/edit_profile_screen.dart';
import 'package:nexa_prime/views/home/backup_wallet_screen.dart';
import 'package:nexa_prime/views/home/change_password_screen.dart';
import 'package:nexa_prime/views/home/set_transaction_pin_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
    
    // Refresh profile image when settings screen loads
    await authController.refreshProfileImage();
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

  Future<void> _deleteAccount() async {
    // First confirmation dialog
    final shouldProceed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone.\n\n'
          'All your data, including wallet balance, transaction history, and personal information will be permanently removed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete Account'),
          ),
        ],
      ),
    );

    if (shouldProceed != true) return;

    // Second confirmation dialog - ask user to type "DELETE" for confirmation
    final TextEditingController confirmationController = TextEditingController();
    final RxString errorText = ''.obs;
    final RxBool canContinue = false.obs;

    void validateConfirmation() {
      canContinue.value = confirmationController.text.toUpperCase() == 'DELETE';
      errorText.value = '';
    }

          final bool? confirmed = await Get.dialog<bool>(
        Dialog(
          insetPadding: ResponsiveHelper.getResponsivePadding(context, horizontal: 24),
          backgroundColor: Colors.transparent,
          child: Container(
            padding: ResponsiveHelper.getResponsiveAllPadding(context, all: 20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.warning, color: Colors.red),
                  const SizedBox(width: 8),
                  Text('Final Confirmation', style: AppTextStyles.heading2),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'This is your final chance to cancel. Type "DELETE" below to confirm account deletion.',
                style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              Obx(() => TextField(
                    controller: confirmationController,
                    onChanged: (_) => validateConfirmation(),
                    decoration: InputDecoration(
                      hintText: 'Type DELETE to confirm',
                      filled: true,
                      fillColor: Colors.black.withOpacity(0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      errorText: errorText.value.isEmpty ? null : errorText.value,
                    ),
                  )),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(result: false),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.primary.withOpacity(0.4)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Obx(() => ElevatedButton(
                          onPressed: canContinue.value
                              ? () {
                                  if (confirmationController.text.toUpperCase() == 'DELETE') {
                                    Get.back(result: true);
                                  } else {
                                    errorText.value = 'Please type "DELETE" to confirm';
                                  }
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Delete Forever', style: TextStyle(color: Colors.white)),
                        )),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );

    if (confirmed != true) return;

    // Show loading dialog
    Get.dialog(
      const Center(
        child: CircularProgressIndicator(),
      ),
      barrierDismissible: false,
    );

    try {
      // Get user UUID (you may need to modify this based on your auth controller)
      final userData = await authController.getUserData();
      final userUuid = userData['uuid'] ?? userData['id'];

      if (userUuid == null || userUuid.isEmpty) {
        Get.back(); // Close loading dialog
        Get.snackbar(
          'Error',
          'Unable to identify user account. Please try again.',
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.red,
        );
        return;
      }

      // Call delete API
      final result = await ApiService.deleteUser(userUuid.toString());

      Get.back(); // Close loading dialog

      if (result != null && result['success'] == true) {
        // Success - logout and navigate to login screen
        await authController.logout();
        Get.offAllNamed('/signin'); // Adjust route as needed

        Get.snackbar(
          'Account Deleted',
          'Your account has been successfully deleted.',
          backgroundColor: Colors.green.withOpacity(0.1),
          colorText: Colors.green,
          duration: const Duration(seconds: 5),
        );
      } else {
        // Handle different error types
        final message = result?['message'] ?? 'Failed to delete account';

        Get.snackbar(
          'Delete Failed',
          message,
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.red,
          duration: const Duration(seconds: 5),
        );
      }
    } catch (e) {
      Get.back(); // Close loading dialog
      Get.snackbar(
        'Error',
        'An unexpected error occurred. Please try again.',
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    }
  }

  Future<void> _promptPasswordAndOpenTransactionPin() async {
    final TextEditingController passwordController = TextEditingController();
    final storedPassword = await authController.getStoredLoginPassword();

    if (storedPassword == null || storedPassword.isEmpty) {
      Get.snackbar(
        'Security Check',
        'Please sign in again to access Transaction PIN settings.',
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
      return;
    }

    final RxBool isObscure = true.obs;
    final RxString errorText = ''.obs;
    final RxBool canContinue = false.obs;

    void validatePassword() {
      canContinue.value = passwordController.text.isNotEmpty;
      errorText.value = '';
    }

    final bool? verified = await Get.dialog<bool>(
      Dialog(
        insetPadding: ResponsiveHelper.getResponsivePadding(context, horizontal: 24),
        backgroundColor: Colors.transparent,
        child: Container(
          padding: ResponsiveHelper.getResponsiveAllPadding(context, all: 20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.lock_outline, color: AppColors.secondary),
                  const SizedBox(width: 8),
                  Text('Verify Password', style: AppTextStyles.heading2),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Enter your login password to continue',
                style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              Obx(() => TextField(
                    controller: passwordController,
                    obscureText: isObscure.value,
                    onChanged: (_) => validatePassword(),
                    decoration: InputDecoration(
                      hintText: 'Password',
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          isObscure.value ? Icons.visibility_off : Icons.visibility,
                          color: AppColors.textSecondary,
                        ),
                        onPressed: () => isObscure.value = !isObscure.value,
                      ),
                      filled: true,
                      fillColor: Colors.black.withOpacity(0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  )),
              const SizedBox(height: 8),
              Obx(() => errorText.value.isEmpty
                  ? const SizedBox.shrink()
                  : Text(
                      errorText.value,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    )),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(result: false),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.primary.withOpacity(0.4)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Obx(() => ElevatedButton(
                          onPressed: canContinue.value
                              ? () {
                                  if (passwordController.text == storedPassword) {
                                    Get.back(result: true);
                                  } else {
                                    errorText.value = 'Incorrect password';
                                  }
                                }
                              : null,
                          style: AppButtonStyles.primaryButton,
                          child: Text('Continue', style: AppTextStyles.button),
                        )),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );

    if (verified == true) {
      // Navigate using direct widget to avoid route list mismatch during hot reload
      Get.to(() => SetTransactionPinScreen());
    } else if (verified == false) {
      Get.snackbar(
        'Incorrect Password',
        'The password you entered is incorrect.',
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    }
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

  Widget _buildDefaultProfileAvatar() {
    return Container(
      width: 80,
      height: 80,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
      ),
      child: Center(
        child: Text(
          userName.value.isNotEmpty ? userName.value[0].toUpperCase() : 'N',
          style: AppTextStyles.heading.copyWith(
            color: AppColors.primary,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
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
            padding: ResponsiveHelper.getResponsiveAllPadding(context, all: 20.0),
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
                      Obx(() => Container(
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
                          child: ClipOval(
                            child: authController.profileImageUrl.isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: authController.profileImageUrl,
                                    fit: BoxFit.cover,
                                    width: 80,
                                    height: 80,
                                    placeholder: (context, url) => Container(
                                      width: 80,
                                      height: 80,
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
                                : _buildDefaultProfileAvatar(),
                          ),
                        ),
                      )),
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
                  title: 'Transaction PIN',
                  icon: Icons.push_pin_outlined,
                  onTap: _promptPasswordAndOpenTransactionPin,
                ),
                _buildSettingTile(
                  title: 'Privacy Policy',
                  icon: Icons.privacy_tip_outlined,
                  onTap: () => Get.toNamed(Routes.privacyPolicy),
                ),

                _buildSectionHeader('Account'),
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.withOpacity(0.2)),
                  ),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.delete_forever, color: Colors.red, size: 20),
                    ),
                    title: Text(
                      'Delete Account',
                      style: AppTextStyles.body2.copyWith(color: Colors.red),
                    ),
                    subtitle: Text(
                      'Permanently delete your account',
                      style: AppTextStyles.body.copyWith(
                        color: Colors.red.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.red,
                    ),
                    onTap: _deleteAccount,
                  ),
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