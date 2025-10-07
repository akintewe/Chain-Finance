import 'package:flutter/foundation.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'onesignal_service.dart';
import 'att_debug_helper.dart';

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

  /// Request ATT permission if not already requested with enhanced retry logic
  static Future<void> requestPermissionIfNeeded() async {
    await ATTDebugHelper.logATTStatus('requestPermissionIfNeeded called');
    
    try {
      // Check if we've already requested permission in this session or previously
      final alreadyRequested = await hasRequestedPermission();
      await ATTDebugHelper.logATTStatus('Already requested check: $alreadyRequested');
      
      if (alreadyRequested) {
        if (kDebugMode) {
          print("ATT permission already requested, checking if we should retry...");
        }
        
        // Check current status - if still notDetermined, something went wrong, retry
        final currentStatus = await AppTrackingTransparency.trackingAuthorizationStatus;
        await ATTDebugHelper.logATTStatus('Current status when already requested: $currentStatus');
        
        if (currentStatus == TrackingStatus.notDetermined) {
          // Reset and try again - something went wrong last time
          await resetPermissionState();
          await ATTDebugHelper.logATTStatus('Reset permission state due to notDetermined status');
        } else {
          // Still request push notifications if not done yet
          _requestPushNotificationsAfterDelay();
          return;
        }
      }

      // Check current ATT status
      final status = await AppTrackingTransparency.trackingAuthorizationStatus;
      await ATTDebugHelper.logATTStatus('Current ATT status before request: $status');

      // Only show prompt if status is notDetermined
      if (status == TrackingStatus.notDetermined) {
        await ATTDebugHelper.logATTStatus('Requesting ATT permission...');
        
        if (kDebugMode) {
          print("Requesting ATT permission...");
        }

        // Add a small delay to ensure system is ready
        await Future.delayed(const Duration(milliseconds: 100));

        // Request permission immediately
        final result = await AppTrackingTransparency.requestTrackingAuthorization();
        
        await ATTDebugHelper.logATTStatus('ATT permission result: $result');
        
        if (kDebugMode) {
          print("ATT permission result: $result");
        }

        // Mark as requested regardless of result
        await _markPermissionAsRequested();

        // Wait longer before requesting push notifications (after ATT is handled)
        _requestPushNotificationsAfterDelay();
      } else {
        // Permission already determined (authorized, denied, or restricted)
        await ATTDebugHelper.logATTStatus('ATT permission already determined: $status');
        
        if (kDebugMode) {
          print("ATT permission already determined: $status");
        }
        
        // Mark as requested since we don't need to show the prompt
        await _markPermissionAsRequested();
        
        // Request push notifications after delay
        _requestPushNotificationsAfterDelay();
      }
    } catch (e) {
      await ATTDebugHelper.logATTStatus('Error in ATT permission request: $e');
      
      if (kDebugMode) {
        print("Error in ATT permission request: $e");
      }
      
      // Mark as requested to avoid repeated attempts
      await _markPermissionAsRequested();
      
      // Still try to request push notifications after delay
      _requestPushNotificationsAfterDelay();
    }
  }

  /// Request push notifications after a longer delay to ensure ATT is fully handled
  static void _requestPushNotificationsAfterDelay() {
    Future.delayed(const Duration(seconds: 3), () {
      if (kDebugMode) {
        print("Requesting push notifications after ATT handling delay...");
      }
      OneSignalService.requestPushNotificationPermissionOnly();
    });
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
