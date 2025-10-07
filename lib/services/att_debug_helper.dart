import 'package:flutter/foundation.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ATTDebugHelper {
  static const String _debugLogKey = 'att_debug_log';
  
  /// Log debug information about ATT status
  static Future<void> logATTStatus(String event) async {
    try {
      final status = await AppTrackingTransparency.trackingAuthorizationStatus;
      final timestamp = DateTime.now().toIso8601String();
      final logEntry = '$timestamp - $event - Status: $status';
      
      if (kDebugMode) {
        print('ATT DEBUG: $logEntry');
      }
      
      // Store in SharedPreferences for debugging
      final prefs = await SharedPreferences.getInstance();
      final existingLog = prefs.getString(_debugLogKey) ?? '';
      await prefs.setString(_debugLogKey, '$existingLog\n$logEntry');
    } catch (e) {
      if (kDebugMode) {
        print('ATT DEBUG ERROR: $e');
      }
    }
  }
  
  /// Get the full debug log
  static Future<String> getDebugLog() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_debugLogKey) ?? 'No debug log available';
    } catch (e) {
      return 'Error getting debug log: $e';
    }
  }
  
  /// Clear the debug log
  static Future<void> clearDebugLog() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_debugLogKey);
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing debug log: $e');
      }
    }
  }
  
  /// Force show debug info dialog in the app
  static Future<Map<String, String>> getATTDebugInfo() async {
    try {
      final status = await AppTrackingTransparency.trackingAuthorizationStatus;
      final prefs = await SharedPreferences.getInstance();
      final hasRequested = prefs.getBool('att_permission_requested') ?? false;
      final log = await getDebugLog();
      
      return {
        'current_status': status.toString(),
        'has_requested_before': hasRequested.toString(),
        'ios_version': '${DateTime.now().millisecondsSinceEpoch}', // Placeholder
        'debug_log': log,
      };
    } catch (e) {
      return {
        'error': e.toString(),
      };
    }
  }
}
