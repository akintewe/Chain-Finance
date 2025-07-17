import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';

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

  // Get user profile including KYC status
  static Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      if (kDebugMode) {
        print('Fetching user profile');
        print('API URL: $baseUrl/user-profile');
        print('Token: ${_authController.token.isNotEmpty ? 'Present' : 'Missing'}');
      }
      
      final response = await http.get(
        Uri.parse('$baseUrl/user-profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_authController.token}',
          'Accept': 'application/json',
        },
      );

      if (kDebugMode) {
        print('User profile response status: ${response.statusCode}');
        print('User profile response body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (kDebugMode) {
          print('User profile fetched successfully');
        }
        return data;
      } else if (response.statusCode == 401) {
        if (kDebugMode) {
          print('Unauthorized access - token may be invalid');
        }
        return {'error': 'unauthorized', 'message': 'Authentication failed'};
      } else {
        if (kDebugMode) {
          print('Failed to fetch user profile: ${response.statusCode}');
          print('Error response: ${response.body}');
        }
        return {'error': 'api_error', 'message': 'Failed to fetch user profile'};
      }
    } catch (e) {
      if (kDebugMode) {
        print('Exception while fetching user profile: $e');
      }
      return {'error': 'network_error', 'message': 'Network connection failed'};
    }
  }

  // Submit KYC documents
  static Future<Map<String, dynamic>?> submitKYC({
    required File identificationCardFront,
    required File identificationCardBack,
    required File utilityBill,
  }) async {
    try {
      if (kDebugMode) {
        print('Submitting KYC documents');
        print('API URL: $baseUrl/kyc/submit');
        print('Front card path: ${identificationCardFront.path}');
        print('Back card path: ${identificationCardBack.path}');
        print('Utility bill path: ${utilityBill.path}');
        print('Front card exists: ${await identificationCardFront.exists()}');
        print('Back card exists: ${await identificationCardBack.exists()}');
        print('Utility bill exists: ${await utilityBill.exists()}');
        print('Front card size: ${await identificationCardFront.length()} bytes');
        print('Back card size: ${await identificationCardBack.length()} bytes');
        print('Utility bill size: ${await utilityBill.length()} bytes');
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/kyc/submit'),
      );

      // Add authorization header
      request.headers['Authorization'] = 'Bearer ${_authController.token}';
      request.headers['Accept'] = 'application/json';

      // Validate files exist before uploading
      if (!await identificationCardFront.exists()) {
        return {'error': 'file_error', 'message': 'Front card file not found'};
      }
      if (!await identificationCardBack.exists()) {
        return {'error': 'file_error', 'message': 'Back card file not found'};
      }
      if (!await utilityBill.exists()) {
        return {'error': 'file_error', 'message': 'Utility bill file not found'};
      }

      // Add files
      request.files.add(await http.MultipartFile.fromPath(
        'identification_card_front',
        identificationCardFront.path,
      ));
      request.files.add(await http.MultipartFile.fromPath(
        'identification_card_back',
        identificationCardBack.path,
      ));
      request.files.add(await http.MultipartFile.fromPath(
        'utility_bill',
        utilityBill.path,
      ));

      if (kDebugMode) {
        print('Request headers: ${request.headers}');
        print('Request files count: ${request.files.length}');
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (kDebugMode) {
        print('KYC submission response status: ${response.statusCode}');
        print('KYC submission response body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (kDebugMode) {
          print('KYC documents submitted successfully');
        }
        return data;
      } else if (response.statusCode == 401) {
        if (kDebugMode) {
          print('Unauthorized access - token may be invalid');
        }
        return {'error': 'unauthorized', 'message': 'Authentication failed'};
      } else if (response.statusCode == 422) {
        final data = jsonDecode(response.body);
        if (kDebugMode) {
          print('Validation error: ${data['message']}');
        }
        return {'error': 'validation_error', 'message': data['message'], 'errors': data['errors']};
      } else {
        if (kDebugMode) {
          print('Failed to submit KYC documents: ${response.statusCode}');
          print('Error response: ${response.body}');
        }
        return {'error': 'api_error', 'message': 'Failed to submit KYC documents'};
      }
    } catch (e) {
      if (kDebugMode) {
        print('Exception while submitting KYC documents: $e');
      }
      return {'error': 'network_error', 'message': 'Network connection failed'};
    }
  }

  // Get KYC status
  static Future<Map<String, dynamic>?> getKYCStatus() async {
    try {
      if (kDebugMode) {
        print('Fetching KYC status');
        print('API URL: $baseUrl/kyc/status');
      }
      
      final response = await http.get(
        Uri.parse('$baseUrl/kyc/status'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_authController.token}',
          'Accept': 'application/json',
        },
      );

      if (kDebugMode) {
        print('KYC status response status: ${response.statusCode}');
        print('KYC status response body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (kDebugMode) {
          print('KYC status fetched successfully');
        }
        return data;
      } else if (response.statusCode == 401) {
        if (kDebugMode) {
          print('Unauthorized access - token may be invalid');
        }
        return {'error': 'unauthorized', 'message': 'Authentication failed'};
      } else if (response.statusCode == 404) {
        if (kDebugMode) {
          print('KYC record not found');
        }
        return {'error': 'not_found', 'message': 'KYC record not found'};
      } else {
        if (kDebugMode) {
          print('Failed to fetch KYC status: ${response.statusCode}');
          print('Error response: ${response.body}');
        }
        return {'error': 'api_error', 'message': 'Failed to fetch KYC status'};
      }
    } catch (e) {
      if (kDebugMode) {
        print('Exception while fetching KYC status: $e');
      }
      return {'error': 'network_error', 'message': 'Network connection failed'};
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