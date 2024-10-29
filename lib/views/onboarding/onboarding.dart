import 'package:chain_finance/controllers/onboardingcontent.dart';
import 'package:chain_finance/routes/routes.dart';
import 'package:chain_finance/utils/button_style.dart';
import 'package:chain_finance/views/auth/signupScreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/text_styles.dart';
import '../../utils/colors.dart';



class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final List<OnboardingContent> contents = [
    OnboardingContent(
      image: 'assets/icons/49.png',
      mainText: 'Safeguard your\nfinances the best way\nwith ',
      gradientText: 'Chain Finance.',
    ),
    OnboardingContent(
      image: 'assets/icons/Property 1=2.png', 
      mainText: 'Send and receive\nmoney in real-time\nwith ',
      gradientText: 'Chain Finance.',
    ),
    OnboardingContent(
      image: 'assets/icons/Property 1=50.png',
      mainText: 'Trade securely\nanywhere, anytime\nwith ',
      gradientText: 'Chain Finance.',
    ),
  ];

  int currentIndex = 0;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startAutoPlay();
  }

  void _startAutoPlay() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        if (currentIndex < contents.length - 1) {
          currentIndex++;
        } else {
          currentIndex = 0;
        }
        _pageController.animateToPage(
          currentIndex,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
        _startAutoPlay();
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: SizedBox(
              height: MediaQuery.of(context).size.height - 48,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo
                  SizedBox(
                    height: 50,
                    width: 50,
                    child: Image.asset('assets/images/WhatsApp_Image_2024-10-27_at_3.41.28_PM-removebg-preview.png'),
                  ),
                  
                  const Spacer(flex: 1),
                  
                  // Animated content
                  Expanded(
                    flex: 5,
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() {
                          currentIndex = index;
                        });
                      },
                      itemCount: contents.length,
                      itemBuilder: (context, index) {
                        return AnimatedOpacity(
                          duration: const Duration(milliseconds: 500),
                          opacity: currentIndex == index ? 1.0 : 0.0,
                          child: Column(
                            children: [
                              // Image
                              SizedBox(
                               
                                width: Get.width * 0.9,
                                child: Image.asset(
                                  contents[index].image,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              
                            
                              
                              // Text
                              Container(
                                alignment: Alignment.centerLeft,
                                child: RichText(
                                  textAlign: TextAlign.left,
                                  text: TextSpan(
                                    style: AppTextStyles.heading2,
                                    children: [
                                      TextSpan(
                                        text: contents[index].mainText,
                                      ),
                                      TextSpan(
                                        text: contents[index].gradientText,
                                        style: AppTextStyles.heading2.copyWith(
                                          foreground: Paint()..shader = AppColors.primaryGradient.createShader(
                                            const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Page indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      contents.length,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 8,
                        width: currentIndex == index ? 24 : 8,
                        decoration: BoxDecoration(
                          gradient: currentIndex == index ? AppColors.primaryGradient : null,
                          color: currentIndex == index ? null : AppColors.textSecondary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  
                  SizedBox(height: Get.height * 0.02),
                  
                  // Buttons row
                  Row(
                    children: [
                     
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ElevatedButton(
                            style: AppButtonStyles.primaryButton,
                           onPressed: () => Routes.navigateToSignup(),
                            child: Text('Sign Up', style: AppTextStyles.button),
                          ),
                        ),
                      ),
                      
                      const SizedBox(width: 16),
                      
                      // Sign In button
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: OutlinedButton(
                            style: AppButtonStyles.outlinedButton,
                         onPressed: () => Routes.navigateToSignin(),
                            child: Text(
                              'Sign In',
                              style: AppTextStyles.button.copyWith(
                                color: AppColors.secondary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Login text
                  Center(
                    child: GestureDetector(
                      onTap: () => Routes.navigateToSignin(),
                      child: RichText(
                        text: TextSpan(
                          style: AppTextStyles.body,
                          children: [
                            const TextSpan(
                              text: 'If you already have an account, you can ',
                            ),
                            TextSpan(
                              text: 'Login Here',
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.secondary,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}