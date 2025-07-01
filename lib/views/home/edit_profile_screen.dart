import 'dart:io';
import 'package:nexa_prime/controllers/auth_controller.dart';
import 'package:nexa_prime/utils/colors.dart';
import 'package:nexa_prime/utils/custom_textfield.dart';
import 'package:nexa_prime/utils/text_styles.dart';
import 'package:nexa_prime/utils/button_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:permission_handler/permission_handler.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> with SingleTickerProviderStateMixin {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final AuthController authController = Get.find();
  final RxBool _isLoading = false.obs;
  final ImagePicker _picker = ImagePicker();
  final Rx<File?> _imageFile = Rx<File?>(null);
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    loadUserData();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_animationController);
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    nameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  void loadUserData() async {
    final userData = await authController.getUserData();
    nameController.text = userData['name'] ?? '';
    emailController.text = userData['email'] ?? '';
  }

  Future<void> _requestPermissions() async {
    await [
      Permission.camera,
      Permission.photos,
    ].request();
  }

  Future<void> _showImagePickerOptions() async {
    await _requestPermissions();
    
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Profile Picture',
              style: AppTextStyles.heading2.copyWith(fontSize: 20),
            ),
            const SizedBox(height: 24),
            
            // Camera Option
            _buildImageOption(
              icon: Icons.camera_alt,
              title: 'Take Photo',
              subtitle: 'Use camera to take a new picture',
              onTap: () {
                Get.back();
                _pickImageFromCamera();
              },
            ),
            
            const SizedBox(height: 16),
            
            // Gallery Option
            _buildImageOption(
              icon: Icons.photo_library,
              title: 'Choose from Gallery',
              subtitle: 'Select from your photo library',
              onTap: () {
                Get.back();
                _pickImageFromGallery();
              },
            ),
            
            if (_imageFile.value != null) ...[
              const SizedBox(height: 16),
              
              // Remove Photo Option
              _buildImageOption(
                icon: Icons.delete,
                title: 'Remove Photo',
                subtitle: 'Remove current profile picture',
                onTap: () {
                  Get.back();
                  _removeImage();
                },
                isDestructive: true,
              ),
            ],
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildImageOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDestructive 
                ? Colors.red.withOpacity(0.2)
                : AppColors.primary.withOpacity(0.1),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDestructive 
                    ? Colors.red.withOpacity(0.1)
                    : AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isDestructive ? Colors.red : AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.body2.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDestructive ? Colors.red : AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1000,
        maxHeight: 1000,
      );
      
      if (image != null) {
        await _cropImage(image.path);
      }
    } catch (e) {
      _showErrorSnackbar('Failed to take photo: ${e.toString()}');
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1000,
        maxHeight: 1000,
      );
      
      if (image != null) {
        await _cropImage(image.path);
      }
    } catch (e) {
      _showErrorSnackbar('Failed to pick image: ${e.toString()}');
    }
  }

  Future<void> _cropImage(String imagePath) async {
    try {
      final CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: imagePath,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1), // Square crop
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Edit Profile Picture',
            toolbarColor: AppColors.primary,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
            backgroundColor: AppColors.background,
            activeControlsWidgetColor: AppColors.primary,
            statusBarColor: AppColors.primary,
            cropGridColor: AppColors.primary.withOpacity(0.5),
            cropFrameColor: AppColors.primary,
            dimmedLayerColor: Colors.black.withOpacity(0.8),
          ),
          IOSUiSettings(
            title: 'Edit Profile Picture',
            aspectRatioLockEnabled: true,
            resetAspectRatioEnabled: false,
            aspectRatioPickerButtonHidden: true,
            rotateButtonsHidden: false,
            rotateClockwiseButtonHidden: true,
            hidesNavigationBar: false,
            minimumAspectRatio: 1.0,
            rectX: 1.0,
            rectY: 1.0,
            rectWidth: 1.0,
            rectHeight: 1.0,
          ),
        ],
      );
      
      if (croppedFile != null) {
        _imageFile.value = File(croppedFile.path);
        Get.snackbar(
          'Success',
          'Profile picture updated successfully',
          backgroundColor: AppColors.primary.withOpacity(0.1),
          colorText: AppColors.primary,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
        );
      }
    } catch (e) {
      _showErrorSnackbar('Failed to edit image: ${e.toString()}');
    }
  }

  void _removeImage() {
    _imageFile.value = null;
    Get.snackbar(
      'Removed',
      'Profile picture removed',
      backgroundColor: AppColors.textSecondary.withOpacity(0.1),
      colorText: AppColors.textSecondary,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }

  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'Error',
      message,
      backgroundColor: Colors.red.withOpacity(0.1),
      colorText: Colors.red,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
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
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('Edit Profile', style: AppTextStyles.body2),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
              // Profile Image Section - Now Blank by Default
              GestureDetector(
                onTap: _showImagePickerOptions,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Obx(() => Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.surface,
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.2),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: _imageFile.value != null
                          ? ClipOval(
                              child: Image.file(
                                _imageFile.value!,
                                fit: BoxFit.cover,
                                width: 120,
                                height: 120,
                              ),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                                Icon(
                                  Icons.add_a_photo,
                                  size: 32,
                                  color: AppColors.textSecondary,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Add Photo',
                                  style: AppTextStyles.body.copyWith(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                    )),
                    
                    // Camera/Edit Icon
                    Positioned(
                      bottom: 0,
                      right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                      shape: BoxShape.circle,
                          border: Border.all(color: AppColors.background, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          _imageFile.value != null ? Icons.edit : Icons.camera_alt,
                      color: Colors.white,
                          size: 18,
                    ),
                  ),
                ),
              ],
            ),
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
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
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
      ),
    );
  }

  void _updateProfile() async {
    if (nameController.text.trim().isEmpty) {
      _showErrorSnackbar('Please enter your full name');
      return;
    }
    
    if (emailController.text.trim().isEmpty) {
      _showErrorSnackbar('Please enter your email address');
      return;
    }

    try {
      _isLoading.value = true;
      await authController.updateProfile(
        nameController.text.trim(),
        _imageFile.value,
      );
      
      Get.snackbar(
        'Success',
        'Profile updated successfully',
        backgroundColor: AppColors.primary.withOpacity(0.1),
        colorText: AppColors.primary,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } catch (e) {
      _showErrorSnackbar('Failed to update profile: ${e.toString()}');
    } finally {
      _isLoading.value = false;
    }
  }
} 