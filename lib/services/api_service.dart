import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';

class ApiService {
  static const String baseUrl = 'http://173.212.228.47:8888/api';
  
  static AuthController get _authController => Get.find<AuthController>();
  
  // Update OneSignal player ID
  static Future<bool> updatePlayerID(String playerId) async {
    try {
      if (kDebugMode) {
        print('Updating player ID: $playerId');
        print('Token: ${_authController.token.isNotEmpty ? 'Present' : 'Missing'}');
        print('Token value: ${_authController.token}');
        print('Token length: ${_authController.token.length}');
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
      } else if (response.statusCode == 500) {
        if (kDebugMode) {
          print('Server error - session may have expired');
        }
        // Trigger session expired dialog through auth controller
        _authController.showSessionExpiredDialog();
        return {'error': 'session_expired', 'message': 'Session expired'};
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

  // Upload profile image
  static Future<Map<String, dynamic>?> uploadProfileImage(File imageFile) async {
    try {
      if (kDebugMode) {
        print('Uploading profile image');
        print('API URL: $baseUrl/user/profile-image');
        print('Image path: ${imageFile.path}');
        print('Image exists: ${await imageFile.exists()}');
        print('Image size: ${await imageFile.length()} bytes');
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/user/profile-image'),
      );

      // Add authorization header
      request.headers['Authorization'] = 'Bearer ${_authController.token}';
      request.headers['Accept'] = 'application/json';

      // Validate file exists before uploading
      if (!await imageFile.exists()) {
        return {'error': 'file_error', 'message': 'Profile image file not found'};
      }

      // Add file
      request.files.add(await http.MultipartFile.fromPath(
        'profile_image',
        imageFile.path,
      ));

      if (kDebugMode) {
        print('Request headers: ${request.headers}');
        print('Request files count: ${request.files.length}');
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (kDebugMode) {
        print('Profile image upload response status: ${response.statusCode}');
        print('Profile image upload response body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (kDebugMode) {
          print('Profile image uploaded successfully');
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
          print('Failed to upload profile image: ${response.statusCode}');
          print('Error response: ${response.body}');
        }
        return {'error': 'api_error', 'message': 'Failed to upload profile image'};
      }
    } catch (e) {
      if (kDebugMode) {
        print('Exception while uploading profile image: $e');
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

  // Get user transactions
  static Future<Map<String, dynamic>?> getUserTransactions() async {
    try {
      if (kDebugMode) {
        print('Fetching user transactions');
        print('API URL: $baseUrl/user/transactions');
        print('Token: ${_authController.token.isNotEmpty ? 'Present' : 'Missing'}');
        print('Token value: ${_authController.token}');
        print('Token length: ${_authController.token.length}');
      }
      
      final response = await http.get(
        Uri.parse('$baseUrl/user/transactions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_authController.token}',
          'Accept': 'application/json',
        },
      );

      if (kDebugMode) {
        print('Transactions response status: ${response.statusCode}');
        print('Transactions response body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (kDebugMode) {
          print('User transactions fetched successfully');
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
          print('Failed to fetch user transactions: ${response.statusCode}');
          print('Error response: ${response.body}');
        }
        return {'error': 'api_error', 'message': 'Failed to fetch user transactions'};
      }
    } catch (e) {
      if (kDebugMode) {
        print('Exception while fetching user transactions: $e');
      }
      return {'error': 'network_error', 'message': 'Network connection failed'};
    }
  }

  // Delete user account
  static Future<Map<String, dynamic>?> deleteUser(String userUuid) async {
    try {
      if (kDebugMode) {
        print('Deleting user account');
        print('API URL: $baseUrl/users/$userUuid');
        print('Token: ${_authController.token.isNotEmpty ? 'Present' : 'Missing'}');
      }

      final response = await http.delete(
        Uri.parse('$baseUrl/users/$userUuid'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_authController.token}',
          'Accept': 'application/json',
        },
      );

      if (kDebugMode) {
        print('Delete user response status: ${response.statusCode}');
        print('Delete user response body: ${response.body}');
      }

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('User account deleted successfully');
        }
        return {'success': true, 'message': 'User deleted successfully'};
      } else if (response.statusCode == 401) {
        if (kDebugMode) {
          print('Unauthorized access - token may be invalid');
        }
        return {'error': 'unauthorized', 'message': 'Authentication failed'};
      } else if (response.statusCode == 404) {
        if (kDebugMode) {
          print('User not found');
        }
        return {'error': 'not_found', 'message': 'User not found'};
      } else if (response.statusCode == 500) {
        if (kDebugMode) {
          print('Server error - could not delete user');
        }
        return {'error': 'server_error', 'message': 'Could not delete user'};
      } else {
        if (kDebugMode) {
          print('Failed to delete user: ${response.statusCode}');
          print('Error response: ${response.body}');
        }
        return {'error': 'api_error', 'message': 'Failed to delete user'};
      }
    } catch (e) {
      if (kDebugMode) {
        print('Exception while deleting user: $e');
      }
      return {'error': 'network_error', 'message': 'Network connection failed'};
    }
  }

  // Virtual Account API Methods
  static Future<Map<String, dynamic>?> getVirtualAccount(String token) async {
    try {
      if (kDebugMode) {
        print('Getting virtual account');
        print('API URL: $baseUrl/virtual-account');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/virtual-account'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (kDebugMode) {
        print('Get virtual account response status: ${response.statusCode}');
        print('Get virtual account response body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else if (response.statusCode == 404) {
        return {'success': false, 'message': 'Virtual account not found'};
      } else {
        return {'success': false, 'message': 'Failed to get virtual account'};
      }
    } catch (e) {
      if (kDebugMode) {
        print('Exception while getting virtual account: $e');
      }
      return {'success': false, 'message': 'Network connection failed'};
    }
  }

  static Future<Map<String, dynamic>?> createVirtualAccount(String token, String accountName) async {
    try {
      if (kDebugMode) {
        print('Creating virtual account');
        print('API URL: $baseUrl/virtual-account');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/virtual-account'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'accountName': accountName,
        }),
      );

      if (kDebugMode) {
        print('Create virtual account response status: ${response.statusCode}');
        print('Create virtual account response body: ${response.body}');
      }

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': 'Failed to create virtual account'};
      }
    } catch (e) {
      if (kDebugMode) {
        print('Exception while creating virtual account: $e');
      }
      return {'success': false, 'message': 'Network connection failed'};
    }
  }

  static Future<Map<String, dynamic>?> getVirtualCards(String token) async {
    try {
      if (kDebugMode) {
        print('Getting virtual cards');
        print('API URL: $baseUrl/virtual-cards');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/virtual-cards'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (kDebugMode) {
        print('Get virtual cards response status: ${response.statusCode}');
        print('Get virtual cards response body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': 'Failed to get virtual cards'};
      }
    } catch (e) {
      if (kDebugMode) {
        print('Exception while getting virtual cards: $e');
      }
      return {'success': false, 'message': 'Network connection failed'};
    }
  }

  static Future<Map<String, dynamic>?> createVirtualCard(String token, dynamic design) async {
    try {
      if (kDebugMode) {
        print('Creating virtual card');
        print('API URL: $baseUrl/virtual-cards');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/virtual-cards'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'design': design.toJson(),
        }),
      );

      if (kDebugMode) {
        print('Create virtual card response status: ${response.statusCode}');
        print('Create virtual card response body: ${response.body}');
      }

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': 'Failed to create virtual card'};
      }
    } catch (e) {
      if (kDebugMode) {
        print('Exception while creating virtual card: $e');
      }
      return {'success': false, 'message': 'Network connection failed'};
    }
  }

  static Future<Map<String, dynamic>?> fundVirtualAccount(String token, double amount) async {
    try {
      if (kDebugMode) {
        print('Funding virtual account');
        print('API URL: $baseUrl/virtual-account/fund');
        print('Amount: $amount');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/virtual-account/fund'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'amount': amount,
        }),
      );

      if (kDebugMode) {
        print('Fund virtual account response status: ${response.statusCode}');
        print('Fund virtual account response body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': 'Failed to fund virtual account'};
      }
    } catch (e) {
      if (kDebugMode) {
        print('Exception while funding virtual account: $e');
      }
      return {'success': false, 'message': 'Network connection failed'};
    }
  }
} 