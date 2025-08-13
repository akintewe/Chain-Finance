import 'package:nexa_prime/views/auth/otp_verification_screen.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../routes/routes.dart';
import '../utils/loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import '../services/onesignal_service.dart';
import 'kyc_controller.dart';
import 'wallet_controller.dart';
import 'notification_controller.dart';
import 'price_alert_controller.dart';
import '../services/api_service.dart';

class AuthController extends GetxController {
  static AuthController get instance => Get.find();
  
  final baseUrl = 'https://chdevapi.com.ng/api';
  final _isLoading = false.obs;
  final _token = ''.obs;
  final _isLoggedOut = false.obs; // Track logout state
  final _profileImageUrl = ''.obs; // Reactive profile image URL
  final storage = const FlutterSecureStorage();
  
  bool get isLoading => _isLoading.value;
  String get token => _token.value;
  bool get isLoggedOut => _isLoggedOut.value;
  String get profileImageUrl => _profileImageUrl.value;
  
  @override
  void onInit() async {
    super.onInit();
    // Initialize token from storage when controller is created
    await initializeToken();
    print('AuthController initialized');
  }
  
  Future<void> initializeToken() async {
    try {
      // Check if user has logged out (check both reactive and persistent storage)
      final isLoggedOutFromStorage = await storage.read(key: 'is_logged_out');
      if (_isLoggedOut.value || isLoggedOutFromStorage == 'true') {
        print('User has logged out, skipping token initialization');
        _token.value = '';
        _isLoggedOut.value = true; // Ensure reactive flag is also set
        return;
      }
      
    final storedToken = await storage.read(key: 'token');
      print('Initializing token - Stored token: ${storedToken != null ? 'Present' : 'Missing'}');
      
      if (storedToken != null && storedToken.isNotEmpty) {
      _token.value = storedToken;
        print('Token loaded from storage: ${storedToken.substring(0, 10)}...');
        
        // Load profile image automatically when token is restored
        await loadProfileImage();
      } else {
        _token.value = '';
        print('No token found in storage');
      }
    } catch (e) {
      print('Error initializing token: $e');
      _token.value = '';
    }
  }
  
  Future<bool> isUserLoggedIn() async {
    // Check both reactive token and stored token
    final storedToken = await getStoredToken();
    final reactiveToken = _token.value;
    
    print('Auth check - Stored token: ${storedToken != null ? 'Present' : 'Missing'}');
    print('Auth check - Reactive token: ${reactiveToken.isNotEmpty ? 'Present' : 'Missing'}');
    
    // Check if user has logged out
    final isLoggedOutFromStorage = await storage.read(key: 'is_logged_out');
    if (isLoggedOutFromStorage == 'true') {
      print('User has logged out, not logged in');
      return false;
    }
    
    // If we have a stored token, consider user logged in (even if reactive token is empty during hot reload)
    if (storedToken != null && storedToken.isNotEmpty) {
      // If reactive token is empty but we have stored token, restore it
      if (reactiveToken.isEmpty) {
        print('Restoring token from storage during hot reload');
        _token.value = storedToken;
      }
      
      final isLoggedIn = _token.value.isNotEmpty;
      print('Auth check - Is logged in: $isLoggedIn');
      return isLoggedIn;
    }
    
    print('No stored token found, user not logged in');
    return false;
  }

  // Register User
  Future<void> registerUser({
    required String name,
    required String email,
    required String username,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      print('Starting registration process...');
      print('Email: $email');
      print('Username: $username');
      
      Loader.show();
      _isLoading.value = true;
      print('Loader shown, making API request...');
      
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'username': username,
          'password': password,
          'password_confirmation': passwordConfirmation,
        }),
      );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      
        final data = jsonDecode(response.body);
      print('Decoded data: $data');
      
      if (response.statusCode == 200 && data['status'] == true) {
        print('Registration successful!');
        Get.snackbar('Success', 'Registration successful');
        print('Navigating to email verification...');
        Routes.navigateToEmailVerification(email);
      } else {
        print('Registration failed with status: ${data['status']}');
        print('Error message: ${data['message']}');
        // Handle error response
        _isLoading.value = false;
        Loader.hide();
        print('Loader dismissed due to error');
        Get.snackbar(
          'Error',
          data['message'] ?? 'Registration failed',
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.red,
        );
      }
    } catch (e) {
      print('Exception occurred during registration: $e');
      _isLoading.value = false;
      Loader.hide();
      print('Loader dismissed due to exception');
      Get.snackbar(
        'Error',
        'An error occurred. Please try again.',
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    }
  }

  // Verify OTP
  Future<void> verifyOTP(String otp) async {
    try {
      Loader.show();
      _isLoading.value = true;
      
      final response = await http.post(
        Uri.parse('$baseUrl/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'otp': otp}),
      );

      if (response.statusCode == 200) {
          _isLoading.value = false;
      Loader.hide();
        Get.snackbar('Success', 'OTP verified successfully');
        // Get.to(() => NewPasswordScreen());
      } else {
          _isLoading.value = false;
      Loader.hide();
        Get.snackbar('Error', jsonDecode(response.body)['message'] ?? 'Invalid OTP');
        throw jsonDecode(response.body)['message'] ?? 'Invalid OTP';
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      _isLoading.value = false;
      Loader.hide();
    }
  }

  // Login User
  Future<void> login({
    required String email,
    required String password,
  }) async {
    try {
      print('Starting login process...');
      print('Email: $email');
      Loader.show();
      _isLoading.value = true;
      
      print('Making HTTP request to: $baseUrl/login');
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      final data = jsonDecode(response.body);
      print('Decoded data: $data');
      
      if (response.statusCode == 200 && data['status'] == true) {
        print('Login successful, storing token...');
        _token.value = data['data']['token'];
        print('Token stored: ${_token.value}');
        
        // Clear logout flag since user is logging in
        await clearLogoutFlag();
        
        // Store the login password securely for later verification (gate to sensitive screens)
        try {
          await storage.write(key: 'login_password', value: password);
        } catch (e) {
          print('Warning: failed to persist login password for gating: $e');
        }
        
        print('Storing user data...');
        await _storeUserData(data['data']);
        print('User data stored successfully');
        
        Get.snackbar(
          'Success', 
          data['message'] ?? 'Login successful',
          backgroundColor: Colors.green.withOpacity(0.1),
          colorText: Colors.green,
        );
        print('Navigating to dashboard...');
        Routes.navigateToDashboard();
        
        // Send OneSignal player ID to backend after successful login
        OneSignalService.sendPlayerIdToBackend();
        
        // Check KYC status after successful login
        await _checkKYCStatus();
        
        // Load profile image after successful login
        await loadProfileImage();
      } else if (response.statusCode == 401) {
        print('Authentication failed: ${data['message']}');
        _isLoading.value = false;
        Loader.hide();
        Get.snackbar(
          'Error', 
          data['message'] ?? 'Invalid credentials',
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.red,
        );
      } else {
        print('Other error: ${data['message']}');
        _isLoading.value = false;
        Loader.hide();
        Get.snackbar(
          'Error', 
          data['message'] ?? 'Login failed',
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.red,
        );
      }
    } catch (e) {
      print('Exception occurred during login: $e');
      Get.snackbar(
        'Error', 
        'An error occurred. Please try again.',
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    } finally {
      print('Login process completed');
      _isLoading.value = false;
      Loader.hide();
    }
  }

  // Logout User
  Future<void> logout() async {
    try {
      _isLoading.value = true;
      
      // Call logout API
      final response = await http.post(
        Uri.parse('$baseUrl/logout'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_token.value}',
        },
      );

      if (response.statusCode == 200) {
        // Set logout flag
        _isLoggedOut.value = true;
        
        // Clear all cached data
        await _clearAllCachedData();
        
        // Force clear token to ensure it's completely removed
        await forceClearToken();
        
        // Navigate first, then show snackbar to avoid context issues
        Get.offAllNamed(Routes.signin);
        
        // Show snackbar after navigation
        Future.delayed(const Duration(milliseconds: 100), () {
          if (Get.isSnackbarOpen) Get.back();
          Get.snackbar('Success', 'Logout successful');
        });
      } else {
        throw jsonDecode(response.body)['message'] ?? 'Logout failed';
      }
    } catch (e) {
      // Set logout flag even if API call fails
      _isLoggedOut.value = true;
      
      // Even if API call fails, clear local data
      await _clearAllCachedData();
      
      // Force clear token to ensure it's completely removed
      await forceClearToken();
      
      // Navigate first, then show snackbar to avoid context issues
      Get.offAllNamed(Routes.signin);
      
      // Show snackbar after navigation
      Future.delayed(const Duration(milliseconds: 100), () {
        if (Get.isSnackbarOpen) Get.back();
        Get.snackbar('Error', e.toString());
      });
    } finally {
      _isLoading.value = false;
    }
  }

  // Clear all cached data
  Future<void> _clearAllCachedData() async {
    try {
      print('Starting to clear all cached data...');
      
      // Clear secure storage
      await storage.deleteAll();
      print('Secure storage cleared');
      
      // Verify storage is cleared
      final remainingToken = await storage.read(key: 'token');
      print('Remaining token in storage: ${remainingToken != null ? 'Present' : 'None'}');
      
      // Clear shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      print('Shared preferences cleared');
      
      // Clear HTTP cache (if any)
      await _clearHttpCache();
      
      // Clear all GetX controllers
      _clearAllControllers();
      
      // Clear OneSignal data
      await _clearOneSignalData();
      
      // Reset auth controller state
      resetState();
      
      // Force clear token from memory
      _token.value = '';
      print('Reactive token cleared: ${_token.value.isEmpty ? 'Empty' : 'Still has value'}');
      
      print('All cached data cleared successfully');
    } catch (e) {
      print('Error clearing cached data: $e');
    }
  }

  // Clear HTTP cache
  Future<void> _clearHttpCache() async {
    try {
      // Clear any HTTP client cache
      // This is a placeholder for future HTTP cache clearing if needed
      print('HTTP cache cleared');
    } catch (e) {
      print('Error clearing HTTP cache: $e');
    }
  }

  // Clear all GetX controllers
  void _clearAllControllers() {
    try {
      // Remove all registered controllers
      if (Get.isRegistered<KYCController>()) {
        Get.delete<KYCController>();
      }
      
      // Reset main controllers state (don't delete them as they're needed for app functionality)
      if (Get.isRegistered<WalletController>()) {
        Get.find<WalletController>().resetState();
      }
      
      if (Get.isRegistered<NotificationController>()) {
        Get.find<NotificationController>().resetState();
      }
      
      if (Get.isRegistered<PriceAlertController>()) {
        Get.find<PriceAlertController>().resetState();
      }
      
      print('All controllers cleared and reset');
    } catch (e) {
      print('Error clearing controllers: $e');
    }
  }

  // Clear OneSignal data
  Future<void> _clearOneSignalData() async {
    try {
      // Remove external user ID from OneSignal
      await OneSignalService.removeExternalUserId();
      
      // Clear OneSignal tags
      await OneSignalService.removeTags([
        'user_type',
        'app_version',
        'preferred_currency',
        'transaction_updates',
        'price_alerts',
        'security_alerts',
        'news_updates',
      ]);
      
      print('OneSignal data cleared');
    } catch (e) {
      print('Error clearing OneSignal data: $e');
    }
  }

  Future<void> verifyEmailOTP(String otp, String email) async {
    try {
      Loader.show();
      _isLoading.value = true;
      
      final response = await http.post(
        Uri.parse('$baseUrl/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'otp': otp
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == true) {
          _isLoading.value = false;
      Loader.hide();
        Get.snackbar(
          'Success', 
          data['message'] ?? 'Email verified successfully. Please sign in.',
          backgroundColor: Colors.green.withOpacity(0.1),
          colorText: Colors.green,
        );
        // After successful email verification, take user back to Sign In screen
        Get.offAllNamed(Routes.signin);
      } else {
          _isLoading.value = false;
      Loader.hide();
        Get.snackbar(
          'Error',
          data['message'] ?? 'Invalid OTP',
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.red,
        );
      }
    } catch (e) {
        _isLoading.value = false;
      Loader.hide();
      Get.snackbar(
        'Error',
        'An error occurred. Please try again.',
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    } finally {
      _isLoading.value = false;
      Loader.hide();
    }
  }

  Future<void> createPasscode(String passcode, String email) async {
    try {
      print('Running createPasscode');
      Loader.show();
      _isLoading.value = true;
      
      final response = await http.post(
        Uri.parse('$baseUrl/set-transaction-pin'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'transaction_pin': passcode,
        }),
      );

      if (response.statusCode == 200) {
        Get.snackbar('Success', 'Transaction PIN set successfully');
        Get.offAllNamed(Routes.signin);
      } else {
        throw jsonDecode(response.body)['message'] ?? 'Failed to set transaction PIN';
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      _isLoading.value = false;
      Loader.hide();
    }
  }

  // Set Transaction PIN for currently logged-in user from Settings screen
  Future<void> setTransactionPinForCurrentUser(String passcode) async {
    try {
      print('Running setTransactionPinForCurrentUser');
      Loader.show();
      _isLoading.value = true;

      final userData = await getUserData();
      final email = userData['email'];

      if (email == null || email.isEmpty) {
        throw 'Unable to determine user email. Please sign in again.';
      }

      final response = await http.post(
        Uri.parse('$baseUrl/set-transaction-pin'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'transaction_pin': passcode,
        }),
      );

      if (response.statusCode == 200) {
        _isLoading.value = false;
        Loader.hide();
        Get.back();
        Get.snackbar(
          'Success',
          'Transaction PIN set successfully',
          backgroundColor: Colors.green.withOpacity(0.1),
          colorText: Colors.green,
        );
      } else if (response.statusCode == 400) {
        _isLoading.value = false;
        Loader.hide();
        final data = jsonDecode(response.body);
        Get.snackbar(
          'Error',
          data['message'] ?? 'Bad request',
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.red,
        );
      } else {
        _isLoading.value = false;
        Loader.hide();
        Get.snackbar(
          'Error',
          'Failed to set Transaction PIN',
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.red,
        );
      }
    } catch (e) {
      _isLoading.value = false;
      Loader.hide();
      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    } finally {
      _isLoading.value = false;
      Loader.hide();
    }
  }

  Future<void> resendEmailVerification() async {
    try {
      _isLoading.value = true;
      
      final response = await http.post(
        Uri.parse('$baseUrl/resend-email-verification'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        Get.snackbar('Success', 'Verification code resent successfully');
      } else {
        throw jsonDecode(response.body)['message'] ?? 'Failed to resend verification code';
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      _isLoading.value = false;
    }
  }

  // Check KYC status after login
  Future<void> _checkKYCStatus() async {
    try {
      // Initialize KYC controller if not already done
      if (!Get.isRegistered<KYCController>()) {
        Get.put(KYCController());
      }
      
      // The KYC controller will automatically check status and show dialog if needed
      final kycController = Get.find<KYCController>();
      await kycController.checkKYCStatus();
    } catch (e) {
      print('Error checking KYC status: $e');
    }
  }

  Future<void> resendOTP(String email) async {
    print('Running resendOTP');
    print(email);
    try {
      Loader.show();
      _isLoading.value = true;
      
      final response = await http.post(
        Uri.parse('$baseUrl/resend-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        _isLoading.value = false;
      Loader.hide();
        print(data);
        Get.snackbar(
          'Success', 
          'OTP sent successfully',
          backgroundColor: Colors.green.withOpacity(0.1),
          colorText: Colors.green,
        );
      } else if (response.statusCode == 400) {
        _isLoading.value = false;
      Loader.hide();
        print(data);
        Get.snackbar(
          'Error',
          data['message'] ?? 'Bad request',
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.red,
        );
      } else {
        _isLoading.value = false;
      Loader.hide();
        print(data);
        Get.snackbar(
          'Error',
          'Failed to send OTP',
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.red,
        );
      }
    } catch (e) {
      _isLoading.value = false;
      Loader.hide();
      Get.snackbar(
        'Error',
        'An error occurred. Please try again.',
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    } finally {
      _isLoading.value = false;
      Loader.hide();
    }
  }

  Future<void> _storeUserData(Map<String, dynamic> userData) async {
    await storage.write(key: 'token', value: userData['token']);
    await storage.write(key: 'user_id', value: userData['user']['id'].toString());
    await storage.write(key: 'name', value: userData['user']['name']);
    await storage.write(key: 'email', value: userData['user']['email']);
    await storage.write(key: 'username', value: userData['user']['username']);
    await storage.write(key: 'uuid', value: userData['user']['uuid']);
  }

  Future<String?> getStoredToken() async {
    return await storage.read(key: 'token');
  }

  Future<Map<String, String?>> getUserData() async {
    return {
      'id': await storage.read(key: 'user_id'),
      'name': await storage.read(key: 'name'),
      'email': await storage.read(key: 'email'),
      'username': await storage.read(key: 'username'),
      'uuid': await storage.read(key: 'uuid'),
    };
  }

  // Retrieve stored login password (secured by platform keystore via FlutterSecureStorage)
  Future<String?> getStoredLoginPassword() async {
    try {
      return await storage.read(key: 'login_password');
    } catch (e) {
      print('Error reading stored login password: $e');
      return null;
    }
  }

  // Reset auth controller state
  void resetState() {
    _isLoading.value = false;
    _token.value = '';
    _isLoggedOut.value = false; // Reset logout flag
    print('Auth controller state reset - Token cleared');
  }
  
  // Clear logout flag from persistent storage
  Future<void> clearLogoutFlag() async {
    try {
      await storage.delete(key: 'is_logged_out');
      _isLoggedOut.value = false;
      print('Logout flag cleared from persistent storage');
    } catch (e) {
      print('Error clearing logout flag: $e');
    }
  }
  
  // Force clear token from storage and memory
  Future<void> forceClearToken() async {
    try {
      print('Force clearing token...');
      
      // Set logout flag in persistent storage
      _isLoggedOut.value = true;
      await storage.write(key: 'is_logged_out', value: 'true');
      print('Logout flag set in persistent storage');
      
      // Clear token from secure storage
      await storage.delete(key: 'token');
      print('Token deleted from secure storage');
      
      // Clear reactive token
      _token.value = '';
      print('Reactive token cleared');
      
      // Also clear all user data
      await storage.delete(key: 'user_id');
      await storage.delete(key: 'name');
      await storage.delete(key: 'email');
      await storage.delete(key: 'username');
      await storage.delete(key: 'uuid');
      await storage.delete(key: 'login_password');
      print('All user data cleared from storage');
      
      // Verify token is cleared
      final remainingToken = await storage.read(key: 'token');
      print('Force clear - Remaining token: ${remainingToken != null ? 'Present' : 'None'}');
      print('Force clear - Reactive token: ${_token.value.isEmpty ? 'Empty' : 'Still has value'}');
      
      // Double-check by reading all keys
      final allKeys = await storage.readAll();
      print('Force clear - Remaining keys in storage: ${allKeys.keys}');
    } catch (e) {
      print('Error force clearing token: $e');
    }
  }

  Future<void> forgotPassword(String email) async {
    try {
      Loader.show();
      _isLoading.value = true;
      
      final response = await http.post(
        Uri.parse('$baseUrl/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        _isLoading.value = false;
        Loader.hide();
        Get.snackbar(
          'Success', 
          'OTP sent to your email',
          backgroundColor: Colors.green.withOpacity(0.1),
          colorText: Colors.green,
        );
        Get.to(() => OTPVerificationScreen(), arguments: email);
      } else {
        _isLoading.value = false;
        Loader.hide();
        Get.snackbar(
          'Error',
          data['message'] ?? 'Failed to send OTP',
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.red,
        );
      }
    } catch (e) {
      _isLoading.value = false;
      Loader.hide();
      Get.snackbar('Error', e.toString());
    }
  }

  Future<void> resetPassword(String email, String otp, String password, String passwordConfirmation) async {
    try {
      Loader.show();
      _isLoading.value = true;
      
      final response = await http.post(
        Uri.parse('$baseUrl/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'otp': otp,
          'password': password,
          'password_confirmation': passwordConfirmation
        }),
      );

      if (response.statusCode == 200) {
        _isLoading.value = false;
        Loader.hide();
        Get.snackbar(
          'Success', 
          'Password reset successfully',
          backgroundColor: Colors.green.withOpacity(0.1),
          colorText: Colors.green,
        );
        Get.offAllNamed(Routes.signin);
      } else {
        _isLoading.value = false;
        Loader.hide();
        Get.snackbar(
          'Error',
          jsonDecode(response.body)['message'] ?? 'Failed to reset password',
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.red,
        );
      }
    } catch (e) {
      _isLoading.value = false;
      Loader.hide();
      Get.snackbar('Error', e.toString());
    }
  }

  Future<void> updateProfile(String name, [File? imageFile]) async {
    try {
      _isLoading.value = true;
      
      if (imageFile != null) {
        // Upload profile image using API service
        final result = await ApiService.uploadProfileImage(imageFile);
        
        if (result != null && result['error'] == null) {
          // Update profile image URL from response
          if (result['data'] != null && result['data']['profile_image_url'] != null) {
            _profileImageUrl.value = result['data']['profile_image_url'];
            print('Profile image URL updated: ${_profileImageUrl.value}');
          }
          
          Get.back();
          Get.snackbar(
            'Success',
            'Profile image updated successfully',
            backgroundColor: Colors.green.withOpacity(0.1),
            colorText: Colors.green,
          );
        } else {
          throw result?['message'] ?? 'Failed to upload profile image';
        }
      } else {
        // If no image, just update name
        final response = await http.post(
          Uri.parse('$baseUrl/update-profile'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $_token'
          },
          body: jsonEncode({
            'name': name,
          }),
        );

        if (response.statusCode == 200) {
          Get.back();
          Get.snackbar(
            'Success',
            'Profile updated successfully',
            backgroundColor: Colors.green.withOpacity(0.1),
            colorText: Colors.green,
          );
        } else {
          throw jsonDecode(response.body)['message'] ?? 'Failed to update profile';
        }
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      _isLoading.value = false;
    }
  }

  // Get user profile data
  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user-profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final profileData = data['data'];
        
        // Update profile image URL if available
        if (profileData != null && profileData['profile_image_url'] != null) {
          _profileImageUrl.value = profileData['profile_image_url'];
        }
        
        return profileData;
      } else if (response.statusCode == 500) {
        // Handle 500 error - show session expired dialog
        print('Session expired - showing session expired dialog');
        showSessionExpiredDialog();
        return null;
      } else {
        print('Failed to get user profile: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }

  // Show session expired dialog (not dismissible)
  void showSessionExpiredDialog() {
    Get.dialog(
      WillPopScope(
        onWillPop: () async => false, // Prevent back button from dismissing
        child: Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.red,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Title
                const Text(
                  'Session Expired',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                
                // Message
                const Text(
                  'Your session has expired. Please log in again to continue.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Logout button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Logout and navigate to login
                      logout();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Logout',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false, // Prevent tapping outside to dismiss
    );
  }

  // Load profile image on app start
  Future<void> loadProfileImage() async {
    try {
      final profileData = await getUserProfile();
      if (profileData != null && profileData['profile_image_url'] != null) {
        _profileImageUrl.value = profileData['profile_image_url'];
        print('Profile image loaded: ${_profileImageUrl.value}');
      }
    } catch (e) {
      print('Error loading profile image: $e');
    }
  }

  // Refresh profile image (useful for hot reload or when returning to app)
  Future<void> refreshProfileImage() async {
    try {
      print('Refreshing profile image...');
      await loadProfileImage();
    } catch (e) {
      print('Error refreshing profile image: $e');
    }
  }
} 