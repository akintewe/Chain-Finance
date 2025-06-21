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
} 