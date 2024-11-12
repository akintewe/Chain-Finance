import 'package:chain_finance/routes/routes.dart';
import 'package:chain_finance/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'views/onboarding/onboarding.dart';
import 'controllers/auth_controller.dart';

void main() {
  // Initialize Get controllers
  Get.put(AuthController());
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Chain Finance',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        useMaterial3: true,
      ),
      getPages: Routes.routes,
      home: const OnboardingScreen(),
    );
  }
}
