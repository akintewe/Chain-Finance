import 'dart:io';
import 'package:nexa_prime/controllers/auth_controller.dart';
import 'package:nexa_prime/utils/colors.dart';
import 'package:nexa_prime/utils/custom_textfield.dart';
import 'package:nexa_prime/utils/text_styles.dart';
import 'package:nexa_prime/utils/button_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final AuthController authController = Get.find();
  final RxBool _isLoading = false.obs;
  final ImagePicker _picker = ImagePicker();
  final Rx<File?> _imageFile = Rx<File?>(null);

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  void loadUserData() async {
    final userData = await authController.getUserData();
    nameController.text = userData['name'] ?? '';
    emailController.text = userData['email'] ?? '';
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 50,
      );
      if (image != null) {
        _imageFile.value = File(image.path);
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick image',
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.text),
          onPressed: () => Get.back(),
        ),
        title: Text('Edit Profile', style: AppTextStyles.button),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile Image Section
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                Obx(() => CircleAvatar(
                  radius: 60,
                  backgroundImage: _imageFile.value != null
                      ? FileImage(_imageFile.value!) as ImageProvider
                      : const AssetImage('assets/icons/Photo by Brooke Cagle.png'),
                )),
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.background, width: 2),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Form Fields
            CustomTextField(
              label: 'Full Name',
              controller: nameController,
              hintText: 'Enter your full name',
            ),
            const SizedBox(height: 16),

            CustomTextField(
              label: 'Email Address',
              controller: emailController,
              hintText: 'Enter your email address',
            
            ),
            const SizedBox(height: 32),

            // Save Button
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Obx(() => ElevatedButton(
                style: AppButtonStyles.primaryButton,
                onPressed: _isLoading.value ? null : () => _updateProfile(),
                child: _isLoading.value
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text('Save Changes', style: AppTextStyles.button),
              )),
            ),
          ],
        ),
      ),
    );
  }

  void _updateProfile() async {
    try {
      _isLoading.value = true;
      await authController.updateProfile(
        nameController.text,
        _imageFile.value,
      );
    } finally {
      _isLoading.value = false;
    }
  }
} 