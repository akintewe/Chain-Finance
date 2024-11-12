import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../routes/routes.dart';
import '../utils/loader.dart';

class AuthController extends GetxController {
  static AuthController get instance => Get.find();
  
  final baseUrl = 'https://chainfinance.com.ng/api';
  final _isLoading = false.obs;
  final _token = ''.obs;
  
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
        Get.toNamed(Routes.emailVerification);
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
        Get.snackbar('Success', 'OTP verified successfully');
        Get.toNamed(Routes.signin);
      } else {
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
      _isLoading.value = true;
      
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _token.value = data['token']; // Assuming the token is returned
        Get.snackbar('Success', 'Login successful');
        Get.offAllNamed(Routes.dashboard);
      } else {
        throw jsonDecode(response.body)['message'] ?? 'Invalid credentials';
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      _isLoading.value = false;
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

  Future<void> verifyEmailOTP(String otp) async {
    try {
      _isLoading.value = true;
      
      final response = await http.post(
        Uri.parse('$baseUrl/verify-email'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'otp': otp}),
      );

      if (response.statusCode == 200) {
        Get.snackbar('Success', 'Email verified successfully');
        Get.toNamed(Routes.createPasscode);
      } else {
        throw jsonDecode(response.body)['message'] ?? 'Invalid OTP';
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> createPasscode(String passcode) async {
    try {
      Loader.show();
      _isLoading.value = true;
      
      final response = await http.post(
        Uri.parse('$baseUrl/create-passcode'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'passcode': passcode}),
      );

      if (response.statusCode == 200) {
        Get.snackbar('Success', 'Passcode created successfully');
        Get.offAllNamed(Routes.signin);
      } else {
        throw jsonDecode(response.body)['message'] ?? 'Failed to create passcode';
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      _isLoading.value = false;
      Loader.hide();
    }
  }
} 