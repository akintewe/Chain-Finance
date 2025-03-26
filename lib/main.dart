import 'package:nexa_prime/controllers/wallet_controller.dart';
import 'package:nexa_prime/routes/routes.dart';
import 'package:nexa_prime/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'views/onboarding/onboarding.dart';
import 'controllers/auth_controller.dart';

void main() {
  // Initialize Get controllers
  Get.put(AuthController());
   Get.put(WalletController());
  
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
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        useMaterial3: true,
      ),
      getPages: Routes.routes,
      home: const OnboardingScreen(),
    );
  }
}
