import 'package:chain_finance/utils/colors.dart';
import 'package:chain_finance/utils/text_styles.dart';
import 'package:chain_finance/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Notification settings
  final RxBool _pushNotifications = true.obs;
  final RxBool _emailNotifications = false.obs;
  final RxBool _transactionAlerts = true.obs;

  Widget _buildSettingTile({
    required String title,
    required IconData icon,
    Widget? trailing,
    VoidCallback? onTap,
    Color iconColor = AppColors.textSecondary,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: iconColor),
        title: Text(title, style: AppTextStyles.body2),
        trailing: trailing ?? const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: AppColors.textSecondary,
        ),
        onTap: onTap,
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
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 40,
                      backgroundImage: AssetImage('assets/icons/Photo by Brooke Cagle.png'),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Jason Gray',
                          style: AppTextStyles.heading.copyWith(fontSize: 24),
                        ),
                        Text(
                          'jason.gray@example.com',
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                Text(
                  'Account Settings',
                  style: AppTextStyles.body2.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 16),

                // Profile Settings
                _buildSettingTile(
                  title: 'Edit Profile',
                  icon: Icons.person_outline,
                  onTap: () {},
                ),

                _buildSettingTile(
                  title: 'Backup Wallet',
                  icon: Icons.backup_outlined,
                  onTap: () {},
                ),

                const SizedBox(height: 24),

                Text(
                  'Notifications',
                  style: AppTextStyles.body2.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 16),

                // Notification Settings
                Obx(() => _buildSettingTile(
                  title: 'Push Notifications',
                  icon: Icons.notifications_none,
                  trailing: Switch(
                    value: _pushNotifications.value,
                    onChanged: (value) => _pushNotifications.value = value,
                    activeColor: AppColors.secondary,
                  ),
                )),

                Obx(() => _buildSettingTile(
                  title: 'Email Notifications',
                  icon: Icons.email_outlined,
                  trailing: Switch(
                    value: _emailNotifications.value,
                    onChanged: (value) => _emailNotifications.value = value,
                    activeColor: AppColors.secondary,
                  ),
                )),

                Obx(() => _buildSettingTile(
                  title: 'Transaction Alerts',
                  icon: Icons.account_balance_wallet_outlined,
                  trailing: Switch(
                    value: _transactionAlerts.value,
                    onChanged: (value) => _transactionAlerts.value = value,
                    activeColor: AppColors.secondary,
                  ),
                )),

                const SizedBox(height: 24),

                Text(
                  'Security',
                  style: AppTextStyles.body2.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 16),

                _buildSettingTile(
                  title: 'Change Password',
                  icon: Icons.lock_outline,
                  onTap: () {},
                ),

                _buildSettingTile(
                  title: 'Two-Factor Authentication',
                  icon: Icons.security,
                  onTap: () {},
                ),

                const SizedBox(height: 24),

                // Logout Button
                Container(
                  width: double.infinity,
                  height: 50,
                  margin: const EdgeInsets.only(top: 8),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      // Implement logout functionality
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