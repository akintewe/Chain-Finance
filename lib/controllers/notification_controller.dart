import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class NotificationController extends GetxController {
  static NotificationController get instance => Get.find();
  
  final _isLoading = false.obs;
  final _notifications = <Map<String, dynamic>>[].obs;
  
  bool get isLoading => _isLoading.value;
  List<Map<String, dynamic>> get notifications => _notifications;
  
  int get unreadCount => _notifications.where((n) => !(n['read'] ?? false)).length;
  
  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
  }
  
  // Fetch notifications from API
  Future<void> fetchNotifications() async {
    try {
      _isLoading.value = true;
      
      final response = await ApiService.getNotifications();
      
      if (response != null) {
        // Check if response contains an error
        if (response.containsKey('error')) {
          String errorMessage = response['message'] ?? 'Unknown error';
          
          if (response['error'] == 'server_error') {
            // Server error (500) - show user-friendly message but don't show snackbar
            print('Server error: $errorMessage');
            _notifications.clear();
            return;
          } else if (response['error'] == 'unauthorized') {
            // Authentication error - might need to re-login
            Get.snackbar(
              'Authentication Error',
              'Please log in again',
              backgroundColor: Colors.orange.withOpacity(0.1),
              colorText: Colors.orange,
              duration: const Duration(seconds: 3),
            );
            _notifications.clear();
            return;
          } else {
            // Other API errors
            Get.snackbar(
              'Error',
              errorMessage,
              backgroundColor: Colors.red.withOpacity(0.1),
              colorText: Colors.red,
              duration: const Duration(seconds: 3),
            );
            _notifications.clear();
            return;
          }
        }
        
        // Success case
        if (response['success'] == true) {
          final List<dynamic> notificationData = response['data'] ?? [];
          
          // Convert API response to local format with additional UI properties
          _notifications.value = notificationData.map((notification) {
            return {
              'id': notification['id'].toString(),
              'title': notification['title'] ?? 'Notification',
              'message': notification['message'] ?? '',
              'type': notification['type'] ?? 'general',
              'isRead': notification['read'] ?? false,
              'time': _formatTime(notification['created_at']),
              'created_at': notification['created_at'],
              'icon': _getIconForType(notification['type'] ?? 'general'),
              'color': _getColorForType(notification['type'] ?? 'general'),
              'crypto': _getCryptoFromMessage(notification['message'] ?? ''),
            };
          }).toList();
          
          // Sort by creation date (newest first)
          _notifications.sort((a, b) => 
            DateTime.parse(b['created_at']).compareTo(DateTime.parse(a['created_at']))
          );
        } else {
          // API returned success: false
          _notifications.clear();
        }
      } else {
        // Response is null
        _notifications.clear();
      }
    } catch (e) {
      print('Exception in fetchNotifications: $e');
      Get.snackbar(
        'Error',
        'Failed to load notifications',
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
        duration: const Duration(seconds: 3),
      );
      _notifications.clear();
    } finally {
      _isLoading.value = false;
    }
  }
  
  // Mark notification as read (local only for now)
  void markAsRead(String notificationId) {
    final index = _notifications.indexWhere((n) => n['id'] == notificationId);
    if (index != -1) {
      _notifications[index]['isRead'] = true;
      _notifications.refresh();
    }
  }
  
  // Mark all notifications as read (local only for now)
  void markAllAsRead() {
    for (var notification in _notifications) {
      notification['isRead'] = true;
    }
    _notifications.refresh();
  }
  
  // Refresh notifications
  Future<void> refreshNotifications() async {
    await fetchNotifications();
  }
  
  // Format timestamp to relative time
  String _formatTime(String? timestamp) {
    if (timestamp == null) return 'Unknown time';
    
    try {
      final DateTime notificationTime = DateTime.parse(timestamp);
      final DateTime now = DateTime.now();
      final Duration difference = now.difference(notificationTime);
      
      if (difference.inMinutes < 1) {
        return 'Just now';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes} minute${difference.inMinutes != 1 ? 's' : ''} ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours} hour${difference.inHours != 1 ? 's' : ''} ago';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} day${difference.inDays != 1 ? 's' : ''} ago';
      } else {
        return '${(difference.inDays / 7).floor()} week${(difference.inDays / 7).floor() != 1 ? 's' : ''} ago';
      }
    } catch (e) {
      return 'Unknown time';
    }
  }
  
  // Get icon for notification type
  IconData _getIconForType(String type) {
    switch (type.toLowerCase()) {
      case 'price_alert':
      case 'price':
        return Icons.trending_up;
      case 'transaction':
      case 'payment':
        return Icons.check_circle;
      case 'security':
        return Icons.security;
      case 'feature':
      case 'update':
        return Icons.new_releases;
      case 'report':
        return Icons.analytics;
      case 'news':
        return Icons.article;
      case 'wallet':
        return Icons.account_balance_wallet;
      case 'system':
        return Icons.settings;
      default:
        return Icons.notifications;
    }
  }
  
  // Get color for notification type
  Color _getColorForType(String type) {
    switch (type.toLowerCase()) {
      case 'price_alert':
      case 'price':
        return Colors.green;
      case 'transaction':
      case 'payment':
        return const Color(0xFF6C5CE7);
      case 'security':
        return Colors.red;
      case 'feature':
      case 'update':
        return const Color(0xFF00B894);
      case 'report':
        return Colors.blue;
      case 'news':
        return Colors.purple;
      case 'wallet':
        return const Color(0xFF0984E3);
      case 'system':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
  
  // Extract crypto symbol from message (simple pattern matching)
  String? _getCryptoFromMessage(String message) {
    final cryptoPatterns = ['BTC', 'ETH', 'USDT', 'BNB', 'SOL', 'ADA', 'XRP', 'DOGE', 'MATIC', 'TRX'];
    
    for (String crypto in cryptoPatterns) {
      if (message.toUpperCase().contains(crypto)) {
        return crypto;
      }
    }
    return null;
  }

  // Reset notification controller state
  void resetState() {
    _isLoading.value = false;
    _notifications.clear();
    print('Notification controller state reset');
  }
} 