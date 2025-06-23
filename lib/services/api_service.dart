import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import 'package:flutter/foundation.dart';

class ApiService {
  static const String baseUrl = 'https://chdevapi.com.ng/api';
  
  static AuthController get _authController => Get.find<AuthController>();
  
  // Update OneSignal player ID
  static Future<bool> updatePlayerID(String playerId) async {
    try {
      if (kDebugMode) {
        print('Updating player ID: $playerId');
      }
      
      final response = await http.post(
        Uri.parse('$baseUrl/user/player-id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_authController.token}',
        },
        body: jsonEncode({
          'player_id': playerId,
        }),
      );

      if (kDebugMode) {
        print('Player ID update response status: ${response.statusCode}');
        print('Player ID update response body: ${response.body}');
      }

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('Player ID updated successfully');
        }
        return true;
      } else {
        if (kDebugMode) {
          print('Failed to update player ID: ${response.statusCode}');
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating player ID: $e');
      }
      return false;
    }
  }

  // Get user notifications
  static Future<Map<String, dynamic>?> getNotifications() async {
    try {
      if (kDebugMode) {
        print('Fetching user notifications');
        print('API URL: $baseUrl/notifications');
        print('Token: ${_authController.token.isNotEmpty ? 'Present' : 'Missing'}');
      }
      
      final response = await http.get(
        Uri.parse('$baseUrl/notifications'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_authController.token}',
          'Accept': 'application/json',
        },
      );

      if (kDebugMode) {
        print('Notifications response status: ${response.statusCode}');
        print('Notifications response headers: ${response.headers}');
        print('Notifications response body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (kDebugMode) {
          print('Notifications fetched successfully');
        }
        return data;
      } else if (response.statusCode == 401) {
        if (kDebugMode) {
          print('Unauthorized access - token may be invalid');
        }
        return {'error': 'unauthorized', 'message': 'Authentication failed'};
      } else if (response.statusCode == 500) {
        if (kDebugMode) {
          print('Server error (500) - Backend issue');
        }
        return {'error': 'server_error', 'message': 'Server temporarily unavailable'};
      } else {
        if (kDebugMode) {
          print('Failed to fetch notifications: ${response.statusCode}');
          print('Error response: ${response.body}');
        }
        return {'error': 'api_error', 'message': 'Failed to fetch notifications'};
      }
    } catch (e) {
      if (kDebugMode) {
        print('Exception while fetching notifications: $e');
      }
      return {'error': 'network_error', 'message': 'Network connection failed'};
    }
  }
} 