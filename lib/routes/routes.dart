import '../utils/custom_page_route.dart';
import '../views/auth/signinScreen.dart';
import '../views/auth/signupScreen.dart';
import '../views/dashboard/dashboard_screen.dart';
import '../views/auth/email_verification_screen.dart';
import '../views/auth/create_passcode_screen.dart';
import '../views/home/set_transaction_pin_screen.dart';
import '../views/home/notification_settings_screen.dart';
import '../views/home/kyc_screen.dart';
import '../views/home/kyc_success_screen.dart';
import '../views/home/kyc_status_screen.dart';
import '../views/home/privacy_policy_screen.dart';

import 'package:get/get.dart';


class Routes {
  static const String signup = '/signup';
  static const String signin = '/signin';
  static const String dashboard = '/dashboard';
  static const String emailVerification = '/email-verification';
  static const String createPasscode = '/create-passcode';
  static const String setTransactionPin = '/set-transaction-pin';
  static const String notificationSettings = '/notification-settings';
  static const String kycScreen = '/kyc-screen';
  static const String kycSuccess = '/kyc-success';
  static const String kycStatus = '/kyc-status';
  static const String privacyPolicy = '/privacy-policy';

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
    GetPage(
      name: setTransactionPin,
      page: () => SetTransactionPinScreen(),
      customTransition: CustomPageRoute(),
      transitionDuration: const Duration(milliseconds: 400),
    ),
    GetPage(
      name: notificationSettings,
      page: () => const NotificationSettingsScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: kycScreen,
      page: () => const KYCScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: kycSuccess,
      page: () => const KYCSuccessScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: kycStatus,
      page: () => const KYCStatusScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: privacyPolicy,
      page: () => const PrivacyPolicyScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
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