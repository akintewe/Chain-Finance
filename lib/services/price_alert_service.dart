import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'price_service.dart';

class PriceAlertService {
  static const String _oneSignalAppId = "a70b21d8-05d8-476c-8050-b72807a22e9d";
  static const String _oneSignalRestApiKey = "os_v2_app_u4fsdwaf3bdwzacqw4uapirotxh6i7okyvdu4i4tiiegchh3ulds3wx2zw26ny26fghqfihcxk6wgjoqzsqyiupms2n6gvdddeyloyy";
  
  // Store previous prices for comparison
  static final Map<String, double> _previousPrices = {};
  static final Map<String, DateTime> _lastAlertTime = {};
  
  // Minimum time between alerts for the same token (to avoid spam)
  static const Duration _alertCooldown = Duration(hours: 1);
  
  // Minimum percentage change to trigger alert
  static const double _minPercentageChange = 5.0; // 5% change
  
  static Timer? _priceMonitorTimer;
  
  // List of tokens to monitor
  static const List<String> _tokensToMonitor = [
    'BTC', 'ETH', 'USDT', 'BNB', 'SOL', 'ADA', 'XRP', 'DOGE', 'MATIC', 'TRX'
  ];
  
  /// Start monitoring prices and sending alerts
  static void startPriceMonitoring() {
    if (kDebugMode) {
      print('Starting price monitoring service...');
    }
    
    // Check prices every 30 minutes
    _priceMonitorTimer = Timer.periodic(const Duration(minutes: 30), (timer) {
      _checkPriceChanges();
    });
    
    // Initial check
    _checkPriceChanges();
  }
  
  /// Stop price monitoring
  static void stopPriceMonitoring() {
    _priceMonitorTimer?.cancel();
    _priceMonitorTimer = null;
    if (kDebugMode) {
      print('Price monitoring stopped');
    }
  }
  
  /// Check price changes for all monitored tokens
  static Future<void> _checkPriceChanges() async {
    if (kDebugMode) {
      print('Checking price changes...');
    }
    
    for (String token in _tokensToMonitor) {
      try {
        await _checkTokenPriceChange(token);
      } catch (e) {
        if (kDebugMode) {
          print('Error checking price for $token: $e');
        }
      }
    }
  }
  
  /// Check price change for a specific token
  static Future<void> _checkTokenPriceChange(String token) async {
    try {
      // Get current price
      final currentPrice = await PriceService.getSpecificRate(token, 'USD');
      
      if (_previousPrices.containsKey(token)) {
        final previousPrice = _previousPrices[token]!;
        final percentageChange = ((currentPrice - previousPrice) / previousPrice) * 100;
        
        if (kDebugMode) {
          print('$token: Previous: \$${previousPrice.toStringAsFixed(2)}, Current: \$${currentPrice.toStringAsFixed(2)}, Change: ${percentageChange.toStringAsFixed(2)}%');
        }
        
        // Check if change is significant and cooldown period has passed
        if (percentageChange.abs() >= _minPercentageChange && _canSendAlert(token)) {
          await _sendPriceAlert(token, previousPrice, currentPrice, percentageChange);
          _lastAlertTime[token] = DateTime.now();
        }
      }
      
      // Update previous price
      _previousPrices[token] = currentPrice;
      
    } catch (e) {
      if (kDebugMode) {
        print('Error checking price change for $token: $e');
      }
    }
  }
  
  /// Check if we can send an alert (cooldown period check)
  static bool _canSendAlert(String token) {
    if (!_lastAlertTime.containsKey(token)) {
      return true;
    }
    
    final lastAlert = _lastAlertTime[token]!;
    final now = DateTime.now();
    return now.difference(lastAlert) >= _alertCooldown;
  }
  
  /// Send price alert notification to all users
  static Future<void> _sendPriceAlert(String token, double previousPrice, double currentPrice, double percentageChange) async {
    try {
      final isIncrease = percentageChange > 0;
      final emoji = isIncrease ? '📈' : '📉';
      final direction = isIncrease ? 'increased' : 'decreased';
      final color = isIncrease ? 'green' : 'red';
      
      final title = '$emoji $token Price Alert';
      final message = '$token has $direction by ${percentageChange.abs().toStringAsFixed(1)}% to \$${currentPrice.toStringAsFixed(2)}';
      
      if (kDebugMode) {
        print('Sending price alert: $title - $message');
      }
      
      final success = await _sendOneSignalNotification(
        title: title,
        message: message,
        data: {
          'type': 'price_alert',
          'token': token,
          'previous_price': previousPrice,
          'current_price': currentPrice,
          'percentage_change': percentageChange,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      
      if (success) {
        if (kDebugMode) {
          print('Price alert sent successfully for $token');
        }
      } else {
        if (kDebugMode) {
          print('Failed to send price alert for $token');
        }
      }
      
    } catch (e) {
      if (kDebugMode) {
        print('Error sending price alert: $e');
      }
    }
  }
  
  /// Send notification via OneSignal REST API
  static Future<bool> _sendOneSignalNotification({
    required String title,
    required String message,
    Map<String, dynamic>? data,
  }) async {
    try {
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Basic $_oneSignalRestApiKey',
      };
      
      final body = {
        'app_id': _oneSignalAppId,
        'included_segments': ['All'], // Send to all users
        'headings': {'en': title},
        'contents': {'en': message},
        'data': data ?? {},
        'android_accent_color': 'FF6C5CE7', // Your app's primary color
        'small_icon': 'ic_stat_onesignal_default',
        'large_icon': 'https://your-app-icon-url.com/icon.png', // Optional: your app icon URL
      };
      
      if (kDebugMode) {
        print('Sending OneSignal notification...');
        print('Headers: $headers');
        print('Body: ${jsonEncode(body)}');
      }
      
      final response = await http.post(
        Uri.parse('https://onesignal.com/api/v1/notifications'),
        headers: headers,
        body: jsonEncode(body),
      );
      
      if (kDebugMode) {
        print('OneSignal response status: ${response.statusCode}');
        print('OneSignal response body: ${response.body}');
      }
      
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['id'] != null) {
          return true;
        }
      }
      
      return false;
      
    } catch (e) {
      if (kDebugMode) {
        print('Error sending OneSignal notification: $e');
      }
      return false;
    }
  }
  
  /// Send custom announcement to all users
  static Future<bool> sendCustomAnnouncement({
    required String title,
    required String message,
    String type = 'announcement',
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final data = {
        'type': type,
        'timestamp': DateTime.now().toIso8601String(),
        ...?additionalData,
      };
      
      return await _sendOneSignalNotification(
        title: title,
        message: message,
        data: data,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error sending custom announcement: $e');
      }
      return false;
    }
  }
  
  /// Send market update notification
  static Future<bool> sendMarketUpdate({
    required String title,
    required String message,
    Map<String, dynamic>? marketData,
  }) async {
    return await sendCustomAnnouncement(
      title: title,
      message: message,
      type: 'market_update',
      additionalData: marketData,
    );
  }
  
  /// Get current monitoring status
  static bool get isMonitoring => _priceMonitorTimer?.isActive ?? false;
  
  /// Get monitored tokens
  static List<String> get monitoredTokens => List.from(_tokensToMonitor);
  
  /// Get previous prices (for debugging)
  static Map<String, double> get previousPrices => Map.from(_previousPrices);
} 