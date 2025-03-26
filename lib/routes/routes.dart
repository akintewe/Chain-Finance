import 'package:nexa_prime/utils/custom_page_route.dart';
import 'package:nexa_prime/views/auth/signinScreen.dart';
import 'package:nexa_prime/views/auth/signupScreen.dart';
import 'package:nexa_prime/views/dashboard/dashboard_screen.dart';
import 'package:nexa_prime/views/auth/email_verification_screen.dart';
import 'package:nexa_prime/views/auth/create_passcode_screen.dart';

import 'package:get/get.dart';


class Routes {
  static const String signup = '/signup';
  static const String signin = '/signin';
  static const String dashboard = '/dashboard';
  static const String emailVerification = '/email-verification';
  static const String createPasscode = '/create-passcode';

  static final routes = [
    GetPage(
      name: signup,
      page: () => SignUpScreen(),
      customTransition: CustomPageRoute(),
      transitionDuration: const Duration(milliseconds: 400),
    ),
    GetPage(
      name: signin,
      page: () => SignInScreen(),
      customTransition: CustomPageRoute(),
      transitionDuration: const Duration(milliseconds: 400),
    ),
    GetPage(
      name: dashboard,
      page: () => const DashboardScreen(),
      customTransition: CustomPageRoute(),
      transitionDuration: const Duration(milliseconds: 400),
    ),
    GetPage(
      name: emailVerification,
      page: () =>  EmailVerificationScreen(email: Get.arguments),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: createPasscode,
      page: () => CreatePasscodeScreen(),
      customTransition: CustomPageRoute(),
      transitionDuration: const Duration(milliseconds: 400),
    ),
  ];

  static void navigateToSignup() {
    Get.toNamed(signup);
  }

  static void navigateToSignin() {
    Get.toNamed(signin);
  }

  static void navigateToDashboard() {
    Get.offAllNamed(dashboard);
  }

  static void navigateToEmailVerification(String email) {
    Get.toNamed(emailVerification, arguments: email);
  }
}