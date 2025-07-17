import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/colors.dart';
import '../../services/onesignal_service.dart';

class NotificationSettingsController extends GetxController {
  var isNotificationsEnabled = false.obs;
  var isLoading = false.obs;
  
  // Individual notification type states
  var transactionUpdates = true.obs;
  var priceAlerts = true.obs;
  var securityAlerts = true.obs;
  var newsUpdates = false.obs;

  @override
  void onInit() {
    super.onInit();
    checkNotificationStatus();
    loadNotificationPreferences();
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

  Future<void> loadNotificationPreferences() async {
    // Load saved preferences from local storage or API
    // For now, using default values
    // TODO: Implement actual preference loading from SharedPreferences or API
  }

  Future<void> saveNotificationPreferences() async {
    // Save preferences to local storage or API
    // TODO: Implement actual preference saving to SharedPreferences or API
    await OneSignalService.sendTags({
      'transaction_updates': transactionUpdates.value.toString(),
      'price_alerts': priceAlerts.value.toString(),
      'security_alerts': securityAlerts.value.toString(),
      'news_updates': newsUpdates.value.toString(),
    });
  }

  Future<void> toggleNotifications(bool value) async {
    isLoading.value = true;
    try {
      await OneSignalService.setNotificationOptIn(value);
      isNotificationsEnabled.value = value;
      
      // If notifications are disabled, also disable all individual types
      if (!value) {
        transactionUpdates.value = false;
        priceAlerts.value = false;
        securityAlerts.value = false;
        newsUpdates.value = false;
        await saveNotificationPreferences();
      }
      
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

  Future<void> toggleNotificationType(String type, bool value) async {
    // Don't allow enabling individual types if main notifications are disabled
    if (value && !isNotificationsEnabled.value) {
      Get.snackbar(
        'Notifications Disabled',
        'Please enable notifications first to configure individual types',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return;
    }
    
    try {
      switch (type) {
        case 'transaction_updates':
          transactionUpdates.value = value;
          break;
        case 'price_alerts':
          priceAlerts.value = value;
          break;
        case 'security_alerts':
          securityAlerts.value = value;
          break;
        case 'news_updates':
          newsUpdates.value = value;
          break;
      }
      
      await saveNotificationPreferences();
      
      Get.snackbar(
        'Settings Updated',
        '$type ${value ? 'enabled' : 'disabled'}',
        backgroundColor: AppColors.surface,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      print('Error toggling notification type: $e');
      Get.snackbar(
        'Error',
        'Failed to update notification type',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
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
    final controller = Get.find<NotificationSettingsController>();
    
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
          _buildNotificationTypeItem(
            title: 'Transaction Updates',
            subtitle: 'Get notified when transactions are completed',
            icon: Icons.account_balance_wallet_outlined,
            type: 'transaction_updates',
            controller: controller,
          ),
          _buildNotificationTypeItem(
            title: 'Price Alerts',
            subtitle: 'Receive alerts when crypto prices change significantly',
            icon: Icons.trending_up_outlined,
            type: 'price_alerts',
            controller: controller,
          ),
          _buildNotificationTypeItem(
            title: 'Security Alerts',
            subtitle: 'Important security-related notifications',
            icon: Icons.security_outlined,
            type: 'security_alerts',
            controller: controller,
          ),
          _buildNotificationTypeItem(
            title: 'News & Updates',
            subtitle: 'App updates and crypto news',
            icon: Icons.newspaper_outlined,
            type: 'news_updates',
            controller: controller,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationTypeItem({
    required String title,
    required String subtitle,
    required IconData icon,
    required String type,
    required NotificationSettingsController controller,
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
          Obx(() {
            bool isEnabled = false;
            switch (type) {
              case 'transaction_updates':
                isEnabled = controller.transactionUpdates.value;
                break;
              case 'price_alerts':
                isEnabled = controller.priceAlerts.value;
                break;
              case 'security_alerts':
                isEnabled = controller.securityAlerts.value;
                break;
              case 'news_updates':
                isEnabled = controller.newsUpdates.value;
                break;
            }
            
            return Switch(
              value: isEnabled,
              onChanged: controller.isNotificationsEnabled.value ? (value) {
                controller.toggleNotificationType(type, value);
              } : null,
              activeColor: AppColors.primary,
              activeTrackColor: AppColors.primary.withOpacity(0.3),
              inactiveThumbColor: Colors.grey,
              inactiveTrackColor: Colors.grey.withOpacity(0.3),
            );
          }),
        ],
      ),
    );
  }
} 