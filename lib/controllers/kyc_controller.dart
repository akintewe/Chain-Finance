import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import '../utils/colors.dart';
import '../utils/loader.dart';
import '../routes/routes.dart';

class KYCController extends GetxController {
  var kycStatus = 'unknown'.obs;
  var isLoading = false.obs;
  var hasShownKYCDialog = false.obs;
  
  // File selection variables
  var identificationCardFront = Rx<File?>(null);
  var identificationCardBack = Rx<File?>(null);
  var utilityBill = Rx<File?>(null);
  
  // Error messages
  var frontCardError = ''.obs;
  var backCardError = ''.obs;
  var utilityBillError = ''.obs;
  
  // Navigation state
  var shouldNavigateToSuccess = false.obs;
  var successMessage = ''.obs;
  var successKycStatus = ''.obs;

  @override
  void onInit() {
    super.onInit();
    checkKYCStatus();
  }

  Future<void> checkKYCStatus() async {
    isLoading.value = true;
    try {
      final response = await ApiService.getUserProfile();
      
      if (response != null && response['status'] == true) {
        final userData = response['data'];
        final kyc = userData['kyc'];
        
        if (kyc == null) {
          kycStatus.value = 'not_submitted';
          // Show KYC dialog if not shown before
          if (!hasShownKYCDialog.value) {
            await Future.delayed(const Duration(seconds: 1));
            showKYCDialog();
          }
        } else {
          kycStatus.value = kyc['status'] ?? 'unknown';
        }
      } else {
        kycStatus.value = 'error';
      }
    } catch (e) {
      print('Error checking KYC status: $e');
      kycStatus.value = 'error';
    } finally {
      isLoading.value = false;
    }
  }

  void showKYCDialog() {
    hasShownKYCDialog.value = true;
    
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Complete KYC Verification',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: const Text(
          'To ensure the security of your account and comply with regulations, please complete your KYC (Know Your Customer) verification by uploading your identification documents.',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 16,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: const Text(
              'Complete Later',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              navigateToKYCScreen();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Complete Now',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  void navigateToKYCScreen() {
    Get.toNamed('/kyc-screen');
  }

  Future<void> pickFile(String type) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1920,
        maxHeight: 1080,
      );
      
      if (image != null) {
        File file = File(image.path);
        
        // Validate file exists and has content
        if (!await file.exists()) {
          Get.snackbar(
            'Error',
            'Selected file not found. Please try again.',
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
            margin: const EdgeInsets.all(16),
          );
          return;
        }
        
        final fileSize = await file.length();
        if (fileSize == 0) {
          Get.snackbar(
            'Error',
            'Selected file is empty. Please choose a valid image.',
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
            margin: const EdgeInsets.all(16),
          );
          return;
        }
        
        // Check file size (max 10MB)
        if (fileSize > 10 * 1024 * 1024) {
          Get.snackbar(
            'Error',
            'File size too large. Please choose an image smaller than 10MB.',
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
            margin: const EdgeInsets.all(16),
          );
          return;
        }
        
        print('Selected file for $type: ${file.path}, size: $fileSize bytes');
        
        // Clear previous errors
        clearErrors();
        
        switch (type) {
          case 'front':
            identificationCardFront.value = file;
            break;
          case 'back':
            identificationCardBack.value = file;
            break;
          case 'utility':
            utilityBill.value = file;
            break;
        }
      }
    } catch (e) {
      print('Error picking file: $e');
      Get.snackbar(
        'Error',
        'Failed to pick image. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    }
  }

  void clearErrors() {
    frontCardError.value = '';
    backCardError.value = '';
    utilityBillError.value = '';
  }

  bool validateFiles() {
    bool isValid = true;
    
    if (identificationCardFront.value == null) {
      frontCardError.value = 'Please select front side of ID card';
      isValid = false;
    }
    
    if (identificationCardBack.value == null) {
      backCardError.value = 'Please select back side of ID card';
      isValid = false;
    }
    
    if (utilityBill.value == null) {
      utilityBillError.value = 'Please select utility bill';
      isValid = false;
    }
    
    return isValid;
  }

  Future<void> submitKYC() async {
    if (!validateFiles()) {
      return;
    }

    // Additional validation before submission
    try {
      if (!await identificationCardFront.value!.exists()) {
        frontCardError.value = 'Front card file not found';
        return;
      }
      if (!await identificationCardBack.value!.exists()) {
        backCardError.value = 'Back card file not found';
        return;
      }
      if (!await utilityBill.value!.exists()) {
        utilityBillError.value = 'Utility bill file not found';
        return;
      }
      
      print('Submitting KYC with files:');
      print('Front: ${identificationCardFront.value!.path}');
      print('Back: ${identificationCardBack.value!.path}');
      print('Utility: ${utilityBill.value!.path}');
    } catch (e) {
      print('Error validating files: $e');
      Get.snackbar(
        'Error',
        'Error validating files. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    Loader.show();
    try {
      print('Starting KYC submission...');
      final response = await ApiService.submitKYC(
        identificationCardFront: identificationCardFront.value!,
        identificationCardBack: identificationCardBack.value!,
        utilityBill: utilityBill.value!,
      );

      print('KYC submission completed, processing response...');

      // Handle new API response structure
      if (response != null && response['data'] != null && response['data']['kyc_status'] != null) {
        try {
          print('Processing successful response...');
          kycStatus.value = response['data']['kyc_status'];
        
          // Hide loader first
          Loader.hide();
          
          print('Setting up navigation state...');
          
          // Navigate directly to success screen
          try {
            final message = response['data']['message'] ?? 'Your documents have been submitted successfully and are pending review.';
            final status = response['data']['kyc_status'] ?? 'pending';
            
            print('Navigating directly to success screen...');
            print('Message: $message');
            print('Status: $status');
            
            // Wait a bit for the loader to fully close
            await Future.delayed(const Duration(milliseconds: 300));
            
            // Navigate directly to success screen
            Get.offAllNamed(Routes.kycSuccess, arguments: {
              'message': message,
              'kyc_status': status,
            });
            
            print('Direct navigation to success screen completed');
          } catch (e) {
            print('Error with direct navigation: $e');
            // Fallback to snackbar
        Get.snackbar(
              'Success',
              response['data']['message'] ?? 'Your documents have been submitted successfully and are pending review.',
              backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
              duration: const Duration(seconds: 5),
        );
          }
        } catch (e) {
          print('Error setting up navigation state: $e');
          print('Error stack trace: ${StackTrace.current}');
          Loader.hide();
        }
      } else if (response != null && response['error'] != null) {
        String errorMessage = response['message'] ?? 'Failed to submit KYC documents';
        
        if (response['error'] == 'validation_error' && response['errors'] != null) {
          final errors = response['errors'];
          if (errors['identification_card_front'] != null) {
            frontCardError.value = errors['identification_card_front'][0];
          }
          if (errors['identification_card_back'] != null) {
            backCardError.value = errors['identification_card_back'][0];
          }
          if (errors['utility_bill'] != null) {
            utilityBillError.value = errors['utility_bill'][0];
          }
        } else if (response['error'] == 'file_error') {
          Get.snackbar(
            'File Error',
            errorMessage,
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
            margin: const EdgeInsets.all(16),
          );
        } else {
          Get.snackbar(
            'Error',
            errorMessage,
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
            margin: const EdgeInsets.all(16),
          );
        }
      }
    } catch (e) {
      print('Error submitting KYC: $e');
      print('Error stack trace: ${StackTrace.current}');
      Loader.hide();
      Get.snackbar(
        'Error',
        'Failed to submit KYC documents. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    } finally {
      Loader.hide();
    }
  }

  void resetKYCDialog() {
    hasShownKYCDialog.value = false;
  }
} 