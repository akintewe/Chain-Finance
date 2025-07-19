import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../services/price_alert_service.dart';
import 'auth_controller.dart';

class PriceAlertController extends GetxController {
  static PriceAlertController get instance => Get.find();
  
  final _isMonitoring = false.obs;
  final _monitoredTokens = <String>[].obs;
  final _previousPrices = <String, double>{}.obs;
  
  bool get isMonitoring => _isMonitoring.value;
  List<String> get monitoredTokens => _monitoredTokens;
  Map<String, double> get previousPrices => _previousPrices;
  
  @override
  void onInit() {
    super.onInit();
    _loadSettings();
  }
  
  @override
  void onClose() {
    // Stop monitoring when controller is disposed
    if (_isMonitoring.value) {
      stopPriceMonitoring();
    }
    super.onClose();
  }
  
  /// Load settings and start monitoring if enabled
  void _loadSettings() {
    // You can load from shared preferences here
    // For now, we'll start monitoring by default
    _monitoredTokens.value = PriceAlertService.monitoredTokens;
    
    // Only start monitoring if user is logged in
    try {
      final authController = Get.find<AuthController>();
      if (authController.token.isNotEmpty) {
    startPriceMonitoring();
      } else {
        print('User not logged in, skipping price monitoring start');
      }
    } catch (e) {
      print('Error checking auth status for price monitoring: $e');
    }
  }
  
  /// Start price monitoring
  void startPriceMonitoring() {
    try {
      PriceAlertService.startPriceMonitoring();
      _isMonitoring.value = true;
      _updatePriceData();
      
      // Only show snackbar if context is ready
      if (Get.context != null && Get.isSnackbarOpen == false) {
      Get.snackbar(
        'Price Alerts',
        'Price monitoring started successfully',
        backgroundColor: Colors.green.withOpacity(0.1),
        colorText: Colors.green,
        icon: const Icon(Icons.trending_up, color: Colors.green),
        duration: const Duration(seconds: 2),
      );
      }
    } catch (e) {
      // Only show snackbar if context is ready
      if (Get.context != null && Get.isSnackbarOpen == false) {
      Get.snackbar(
        'Error',
        'Failed to start price monitoring',
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
        icon: const Icon(Icons.error, color: Colors.red),
      );
      }
    }
  }
  
  /// Stop price monitoring
  void stopPriceMonitoring() {
    try {
      PriceAlertService.stopPriceMonitoring();
      _isMonitoring.value = false;
      
      // Only show snackbar if context is ready
      if (Get.context != null && Get.isSnackbarOpen == false) {
      Get.snackbar(
        'Price Alerts',
        'Price monitoring stopped',
        backgroundColor: Colors.orange.withOpacity(0.1),
        colorText: Colors.orange,
        icon: const Icon(Icons.trending_down, color: Colors.orange),
        duration: const Duration(seconds: 2),
      );
      }
    } catch (e) {
      // Only show snackbar if context is ready
      if (Get.context != null && Get.isSnackbarOpen == false) {
      Get.snackbar(
        'Error',
        'Failed to stop price monitoring',
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
        icon: const Icon(Icons.error, color: Colors.red),
      );
      }
    }
  }
  
  /// Toggle price monitoring
  void togglePriceMonitoring() {
    if (_isMonitoring.value) {
      stopPriceMonitoring();
    } else {
      startPriceMonitoring();
    }
  }
  
  /// Update price data for UI display
  void _updatePriceData() {
    _previousPrices.value = PriceAlertService.previousPrices;
  }
  
  /// Send custom announcement to all users
  Future<void> sendCustomAnnouncement({
    required String title,
    required String message,
    String type = 'announcement',
  }) async {
    try {
      // Show loading dialog with better error handling
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(),
        ),
        barrierDismissible: false,
      );
      
      final success = await PriceAlertService.sendCustomAnnouncement(
        title: title,
        message: message,
        type: type,
      );
      
      // Close loading dialog safely
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
      
      // Wait a bit before showing snackbar
      await Future.delayed(const Duration(milliseconds: 300));
      
      if (success) {
        Get.showSnackbar(
          GetSnackBar(
            title: 'Success',
            message: 'Announcement sent to all users',
            backgroundColor: Colors.green.withOpacity(0.1),
            icon: const Icon(Icons.check_circle, color: Colors.green),
            duration: const Duration(seconds: 3),
            snackPosition: SnackPosition.BOTTOM,
            margin: const EdgeInsets.all(16),
            borderRadius: 12,
          ),
        );
      } else {
        Get.showSnackbar(
          GetSnackBar(
            title: 'Error',
            message: 'Failed to send announcement. Check OneSignal configuration.',
            backgroundColor: Colors.red.withOpacity(0.1),
            icon: const Icon(Icons.error, color: Colors.red),
            duration: const Duration(seconds: 3),
            snackPosition: SnackPosition.BOTTOM,
            margin: const EdgeInsets.all(16),
            borderRadius: 12,
          ),
        );
      }
    } catch (e) {
      // Close loading dialog safely
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
      
      await Future.delayed(const Duration(milliseconds: 300));
      
             Get.showSnackbar(
         GetSnackBar(
           title: 'Error',
           message: 'Network error occurred',
           backgroundColor: Colors.red.withOpacity(0.1),
           icon: const Icon(Icons.error, color: Colors.red),
           duration: const Duration(seconds: 3),
           snackPosition: SnackPosition.BOTTOM,
           margin: const EdgeInsets.all(16),
           borderRadius: 12,
         ),
       );
    }
  }
  
  /// Send market update notification
  Future<void> sendMarketUpdate({
    required String title,
    required String message,
    Map<String, dynamic>? marketData,
  }) async {
    try {
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(),
        ),
        barrierDismissible: false,
      );
      
      final success = await PriceAlertService.sendMarketUpdate(
        title: title,
        message: message,
        marketData: marketData,
      );
      
      Get.back(); // Close loading dialog
      
      if (success) {
        Get.snackbar(
          'Success',
          'Market update sent to all users',
          backgroundColor: Colors.blue.withOpacity(0.1),
          colorText: Colors.blue,
          icon: const Icon(Icons.trending_up, color: Colors.blue),
        );
      } else {
        Get.snackbar(
          'Error',
          'Failed to send market update',
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.red,
          icon: const Icon(Icons.error, color: Colors.red),
        );
      }
    } catch (e) {
      Get.back(); // Close loading dialog
      Get.snackbar(
        'Error',
        'An error occurred while sending market update',
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
        icon: const Icon(Icons.error, color: Colors.red),
      );
    }
  }
  
  /// Show announcement dialog
  void showAnnouncementDialog() {
    final titleController = TextEditingController();
    final messageController = TextEditingController();
    
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF1E1E2E),
        title: const Text(
          'Send Announcement',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Title',
                labelStyle: TextStyle(color: Colors.grey),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF6C5CE7)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: messageController,
              style: const TextStyle(color: Colors.white),
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Message',
                labelStyle: TextStyle(color: Colors.grey),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF6C5CE7)),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isNotEmpty && messageController.text.isNotEmpty) {
                Get.back();
                sendCustomAnnouncement(
                  title: titleController.text,
                  message: messageController.text,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C5CE7),
            ),
            child: const Text('Send', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
  
  /// Refresh price data
  void refreshPriceData() {
    _updatePriceData();
  }

  // Reset price alert controller state
  void resetState() {
    _isMonitoring.value = false;
    _monitoredTokens.clear();
    _previousPrices.clear();
    print('Price alert controller state reset');
  }
} 