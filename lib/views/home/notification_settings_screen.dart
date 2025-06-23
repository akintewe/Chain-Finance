import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/colors.dart';
import '../../services/onesignal_service.dart';

class NotificationSettingsController extends GetxController {
  var isNotificationsEnabled = false.obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    checkNotificationStatus();
  }

  Future<void> checkNotificationStatus() async {
    isLoading.value = true;
    try {
      final hasPermission = await OneSignalService.getNotificationPermission();
      final isSubscribed = OneSignalService.isSubscribed();
      isNotificationsEnabled.value = hasPermission && isSubscribed;
    } catch (e) {
      print('Error checking notification status: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleNotifications(bool value) async {
    isLoading.value = true;
    try {
      await OneSignalService.setNotificationOptIn(value);
      isNotificationsEnabled.value = value;
      
      Get.snackbar(
        'Notifications ${value ? 'Enabled' : 'Disabled'}',
        'Push notifications have been ${value ? 'enabled' : 'disabled'}',
        backgroundColor: AppColors.surface,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    } catch (e) {
      print('Error toggling notifications: $e');
      Get.snackbar(
        'Error',
        'Failed to update notification settings',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> setUserTags() async {
    // Example of setting user tags for targeted notifications
    await OneSignalService.sendTags({
      'user_type': 'premium',
      'app_version': '1.0.0',
      'preferred_currency': 'USD',
    });
  }
}

class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NotificationSettingsController());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Notification Settings',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoCard(),
              const SizedBox(height: 24),
              _buildNotificationSettings(controller),
              const SizedBox(height: 24),
              _buildNotificationTypes(),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.notifications_outlined,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Stay Updated',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Get notified about important updates, transactions, and market changes.',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSettings(NotificationSettingsController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Push Notifications',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Enable Notifications',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Receive push notifications on your device',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: controller.isNotificationsEnabled.value,
                onChanged: controller.toggleNotifications,
                activeColor: AppColors.primary,
                activeTrackColor: AppColors.primary.withOpacity(0.3),
                inactiveThumbColor: Colors.grey,
                inactiveTrackColor: Colors.grey.withOpacity(0.3),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationTypes() {
    final notificationTypes = [
      {
        'title': 'Transaction Updates',
        'subtitle': 'Get notified when transactions are completed',
        'icon': Icons.account_balance_wallet_outlined,
        'enabled': true,
      },
      {
        'title': 'Price Alerts',
        'subtitle': 'Receive alerts when crypto prices change significantly',
        'icon': Icons.trending_up_outlined,
        'enabled': true,
      },
      {
        'title': 'Security Alerts',
        'subtitle': 'Important security-related notifications',
        'icon': Icons.security_outlined,
        'enabled': true,
      },
      {
        'title': 'News & Updates',
        'subtitle': 'App updates and crypto news',
        'icon': Icons.newspaper_outlined,
        'enabled': false,
      },
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Notification Types',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ...notificationTypes.map((type) => _buildNotificationTypeItem(
            title: type['title'] as String,
            subtitle: type['subtitle'] as String,
            icon: type['icon'] as IconData,
            enabled: type['enabled'] as bool,
          )),
        ],
      ),
    );
  }

  Widget _buildNotificationTypeItem({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool enabled,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: enabled,
            onChanged: (value) {
              // Handle individual notification type toggle
              Get.snackbar(
                title,
                '${value ? 'Enabled' : 'Disabled'} $title',
                backgroundColor: AppColors.surface,
                colorText: Colors.white,
                snackPosition: SnackPosition.BOTTOM,
                margin: const EdgeInsets.all(16),
              );
            },
            activeColor: AppColors.primary,
            activeTrackColor: AppColors.primary.withOpacity(0.3),
            inactiveThumbColor: Colors.grey,
            inactiveTrackColor: Colors.grey.withOpacity(0.3),
          ),
        ],
      ),
    );
  }
} 