import 'package:nexa_prime/controllers/wallet_controller.dart';
import 'package:nexa_prime/routes/routes.dart';
import 'package:nexa_prime/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'views/onboarding/onboarding.dart';
import 'controllers/auth_controller.dart';
import 'controllers/notification_controller.dart';
import 'controllers/price_alert_controller.dart';
import 'package:nexa_prime/utils/loader.dart';
import 'package:nexa_prime/services/onesignal_service.dart';
import 'dart:math';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize OneSignal
  await OneSignalService.initialize();

  // Initialize Get controllers
  Get.put(AuthController());
  Get.put(WalletController());
  Get.put(NotificationController());
  Get.put(PriceAlertController());
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Nexa Prime',
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.background,
        fontFamily: 'Poppins',
        useMaterial3: true,
        colorScheme: ColorScheme.dark(
          background: AppColors.background,
          surface: AppColors.surface,
          primary: AppColors.primary,
          secondary: AppColors.secondary,
        ),
      ),
      getPages: Routes.routes,
      home: FutureBuilder(
        future: _checkLoginStatus(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Show a loading screen while checking auth status
            return Scaffold(
              backgroundColor: AppColors.background,
              body: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
            );
          }
          
          // Navigate to the appropriate screen based on auth status
          return const OnboardingScreen();
        },
      ),
    );
  }
  
  Future<bool> _checkLoginStatus() async {
    final authController = Get.find<AuthController>();
    final isLoggedIn = await authController.isUserLoggedIn();
    
    if (isLoggedIn) {
      print('User is already logged in, redirecting to dashboard...');
      
      // Send OneSignal player ID to backend for already logged in users
      OneSignalService.sendPlayerIdToBackend();
      
      // Add a small delay to ensure proper navigation
      await Future.delayed(const Duration(milliseconds: 100));
      Get.offAllNamed(Routes.dashboard);
      return true;
    }
    
    print('No valid token found, showing onboarding screen');
    return false;
  }
}
