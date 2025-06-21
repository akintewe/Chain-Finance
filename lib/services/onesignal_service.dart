import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:flutter/foundation.dart';
import 'api_service.dart';

class OneSignalService {
  static final OneSignalService _instance = OneSignalService._internal();
  factory OneSignalService() => _instance;
  OneSignalService._internal();

  // Initialize OneSignal
  static Future<void> initialize() async {
    // Replace with your OneSignal App ID
    const String appId = "a70b21d8-05d8-476c-8050-b72807a22e9d"; // Your actual OneSignal App ID
    
    if (kDebugMode) {
      print("Initializing OneSignal...");
    }

    // Initialize OneSignal
    OneSignal.initialize(appId);

    // Request permission for push notifications
    await OneSignal.Notifications.requestPermission(true);

    // Set up notification event listeners
    OneSignal.Notifications.addForegroundWillDisplayListener((event) {
      if (kDebugMode) {
        print('FOREGROUND WILL DISPLAY LISTENER CALLED WITH: ${event.notification.jsonRepresentation()}');
      }
      
      // Display the notification
      event.preventDefault();
      event.notification.display();
    });

    OneSignal.Notifications.addClickListener((event) {
      if (kDebugMode) {
        print('NOTIFICATION CLICK LISTENER CALLED WITH: ${event.notification.jsonRepresentation()}');
      }
      // Handle notification click
      _handleNotificationClick(event.notification);
    });

    OneSignal.Notifications.addPermissionObserver((state) {
      if (kDebugMode) {
        print("Has permission: ${state}");
      }
    });

    OneSignal.User.addObserver((state) {
      if (kDebugMode) {
        print("OneSignal user changed: ${state.current.jsonRepresentation()}");
      }
    });

    // Set external user ID (optional - use your user ID)
    // OneSignal.login("your_user_id");

    // Note: Player ID will be sent to backend after user login
    // to ensure proper authentication
  }

  // Handle notification clicks
  static void _handleNotificationClick(OSNotification notification) {
    if (kDebugMode) {
      print("Notification clicked: ${notification.title}");
    }
    
    // Handle deep linking based on notification data
    final additionalData = notification.additionalData;
    if (additionalData != null) {
      // Navigate to specific screen based on notification data
      // Example: Get.toNamed('/transaction', arguments: additionalData['transactionId']);
    }
  }

  // Send tags (user properties)
  static Future<void> sendTags(Map<String, dynamic> tags) async {
    OneSignal.User.addTags(tags);
    if (kDebugMode) {
      print("Tags sent: $tags");
    }
  }

  // Remove tags
  static Future<void> removeTags(List<String> keys) async {
    OneSignal.User.removeTags(keys);
    if (kDebugMode) {
      print("Tags removed: $keys");
    }
  }

  // Set external user ID
  static Future<void> setExternalUserId(String userId) async {
    OneSignal.login(userId);
    if (kDebugMode) {
      print("External user ID set: $userId");
    }
  }

  // Remove external user ID
  static Future<void> removeExternalUserId() async {
    OneSignal.logout();
    if (kDebugMode) {
      print("External user ID removed");
    }
  }

  // Get notification permission status
  static Future<bool> getNotificationPermission() async {
    final permission = await OneSignal.Notifications.permission;
    return permission;
  }

  // Get OneSignal player ID
  static String? getPlayerId() {
    return OneSignal.User.pushSubscription.id;
  }

  // Opt in/out of notifications
  static Future<void> setNotificationOptIn(bool optIn) async {
    OneSignal.User.pushSubscription.optIn();
    if (kDebugMode) {
      print("Notification opt-in set to: $optIn");
    }
  }

  // Check if user is subscribed to notifications
  static bool isSubscribed() {
    return OneSignal.User.pushSubscription.optedIn ?? false;
  }

  // Send player ID to backend
  static Future<void> _sendPlayerIdToBackend() async {
    try {
      // Wait a bit to ensure player ID is available
      await Future.delayed(const Duration(seconds: 2));
      
      final playerId = getPlayerId();
      if (playerId != null && playerId.isNotEmpty) {
        if (kDebugMode) {
          print("Sending player ID to backend: $playerId");
        }
        
        final success = await ApiService.updatePlayerID(playerId);
        if (success) {
          if (kDebugMode) {
            print("Player ID successfully sent to backend");
          }
        } else {
          if (kDebugMode) {
            print("Failed to send player ID to backend");
          }
        }
      } else {
        if (kDebugMode) {
          print("Player ID not available yet, will retry later");
        }
        // Retry after a longer delay if player ID is not available
        await Future.delayed(const Duration(seconds: 5));
        final retryPlayerId = getPlayerId();
        if (retryPlayerId != null && retryPlayerId.isNotEmpty) {
          await ApiService.updatePlayerID(retryPlayerId);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error sending player ID to backend: $e");
      }
    }
  }

  // Public method to manually send player ID (useful for when user logs in)
  static Future<void> sendPlayerIdToBackend() async {
    await _sendPlayerIdToBackend();
  }
} 