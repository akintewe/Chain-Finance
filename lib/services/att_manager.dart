import 'package:flutter/foundation.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'onesignal_service.dart';

class ATTManager {
  static const String _attRequestedKey = 'att_permission_requested';
  static bool _hasRequestedPermission = false;

  /// Check if ATT permission has been requested before
  static Future<bool> hasRequestedPermission() async {
    if (_hasRequestedPermission) return true;
    
    final prefs = await SharedPreferences.getInstance();
    _hasRequestedPermission = prefs.getBool(_attRequestedKey) ?? false;
    return _hasRequestedPermission;
  }

  /// Mark that ATT permission has been requested
  static Future<void> _markPermissionAsRequested() async {
    _hasRequestedPermission = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_attRequestedKey, true);
  }

  /// Request ATT permission if not already requested
  static Future<void> requestPermissionIfNeeded() async {
    try {
      // Check if we've already requested permission in this session or previously
      final alreadyRequested = await hasRequestedPermission();
      if (alreadyRequested) {
        if (kDebugMode) {
          print("ATT permission already requested, skipping...");
        }
        return;
      }

      // Check current ATT status
      final status = await AppTrackingTransparency.trackingAuthorizationStatus;
      if (kDebugMode) {
        print("Current ATT status: $status");
      }

      // Only show prompt if status is notDetermined
      if (status == TrackingStatus.notDetermined) {
        if (kDebugMode) {
          print("Requesting ATT permission...");
        }

        // Request permission
        final result = await AppTrackingTransparency.requestTrackingAuthorization();
        
        if (kDebugMode) {
          print("ATT permission result: $result");
        }

        // Mark as requested regardless of result
        await _markPermissionAsRequested();

        // Now request push notifications
        await OneSignalService.requestPushNotificationPermissionOnly();
      } else {
        // Permission already determined (authorized, denied, or restricted)
        if (kDebugMode) {
          print("ATT permission already determined: $status");
        }
        
        // Mark as requested since we don't need to show the prompt
        await _markPermissionAsRequested();
        
        // Still request push notifications
        await OneSignalService.requestPushNotificationPermissionOnly();
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error in ATT permission request: $e");
      }
      
      // Mark as requested to avoid repeated attempts
      await _markPermissionAsRequested();
      
      // Still try to request push notifications
      await OneSignalService.requestPushNotificationPermissionOnly();
    }
  }

  /// Get current ATT status
  static Future<TrackingStatus> getCurrentStatus() async {
    try {
      return await AppTrackingTransparency.trackingAuthorizationStatus;
    } catch (e) {
      if (kDebugMode) {
        print("Error getting ATT status: $e");
      }
      return TrackingStatus.notDetermined;
    }
  }

  /// Check if tracking is authorized
  static Future<bool> isTrackingAuthorized() async {
    final status = await getCurrentStatus();
    return status == TrackingStatus.authorized;
  }

  /// Reset permission request state (for testing)
  static Future<void> resetPermissionState() async {
    if (kDebugMode) {
      _hasRequestedPermission = false;
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_attRequestedKey);
      print("ATT permission state reset for testing");
    }
  }
}
