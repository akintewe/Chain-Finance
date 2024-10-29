import 'package:chain_finance/utils/custom_page_route.dart';
import 'package:chain_finance/views/auth/signinScreen.dart';
import 'package:chain_finance/views/auth/signupScreen.dart';

import 'package:get/get.dart';


class Routes {
  static const String signup = '/signup';
  static const String signin = '/signin';

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
  ];

  static void navigateToSignup() {
    Get.toNamed(signup);
  }

  static void navigateToSignin() {
    Get.toNamed(signin);
  }
}