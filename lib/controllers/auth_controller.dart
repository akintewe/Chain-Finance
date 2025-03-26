import 'package:nexa_prime/views/auth/otp_verification_screen.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../routes/routes.dart';
import '../utils/loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:io';

class AuthController extends GetxController {
  static AuthController get instance => Get.find();
  
  final baseUrl = 'https://chdevapi.com.ng/api';
  final _isLoading = false.obs;
  final _token = ''.obs;
  final storage = const FlutterSecureStorage();
  
  bool get isLoading => _isLoading.value;
  String get token => _token.value;

  // Register User
  Future<void> registerUser({
    required String name,
    required String email,
    required String username,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      Loader.show();
      _isLoading.value = true;
      
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

      if (response.statusCode == 200) {
        print(response.body);
        final data = jsonDecode(response.body);
        Get.snackbar('Success', 'Registration successful');
        Routes.navigateToEmailVerification(email);
      } else {
        print(response.body);
        throw jsonDecode(response.body)['message'] ?? 'Registration failed';
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      _isLoading.value = false;
      Loader.hide();
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
      
      final response = await http.post(
        Uri.parse('$baseUrl/logout'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_token.value}',
        },
      );

      if (response.statusCode == 200) {
        await storage.deleteAll();
        _token.value = '';
        Get.snackbar('Success', 'Logout successful');
        Get.offAllNamed(Routes.signin);
      } else {
        throw jsonDecode(response.body)['message'] ?? 'Logout failed';
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      _isLoading.value = false;
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
          data['message'] ?? 'Email verified successfully',
          backgroundColor: Colors.green.withOpacity(0.1),
          colorText: Colors.green,
        );
        Get.toNamed(Routes.createPasscode, arguments: email);
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
        // Create multipart request
        var request = http.MultipartRequest(
          'POST',
          Uri.parse('$baseUrl/update-profile'),
        );

        // Add authorization header
        request.headers.addAll({
          'Authorization': 'Bearer $_token',
        });

        // Add text fields
        request.fields['name'] = name;

        // Add file
        request.files.add(
          await http.MultipartFile.fromPath(
            'profile_image',
            imageFile.path,
          ),
        );

        // Send request
        final response = await request.send();
        final responseData = await response.stream.bytesToString();

        if (response.statusCode == 200) {
          Get.back();
          Get.snackbar(
            'Success',
            'Profile updated successfully',
            backgroundColor: Colors.green.withOpacity(0.1),
            colorText: Colors.green,
          );
        } else {
          throw jsonDecode(responseData)['message'] ?? 'Failed to update profile';
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
} 