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
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Padding(
              padding: EdgeInsets.all(constraints.maxWidth * 0.05), // Responsive padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo
                  SizedBox(
                    height: constraints.maxHeight * 0.06,
                    width: constraints.maxHeight * 0.06,
                    child: Image.asset('assets/images/WhatsApp_Image_2024-10-27_at_3.41.28_PM-removebg-preview.png'),
                  ),
                  
                  SizedBox(height: constraints.maxHeight * 0.02),
                  
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
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              // Image
                              SizedBox(
                                height: constraints.maxHeight * 0.5,
                                child: Image.asset(
                                  contents[index].image,
                                  fit: BoxFit.contain,
                                ),
                              ),
                              
                              SizedBox(height: constraints.maxHeight * 0.02),
                              
                              // Text
                              Container(
                                alignment: Alignment.centerLeft,
                                child: RichText(
                                  textAlign: TextAlign.left,
                                  text: TextSpan(
                                    style: AppTextStyles.heading2.copyWith(
                                      fontSize: constraints.maxWidth * 0.055,
                                    ),
                                    children: [
                                      TextSpan(text: contents[index].mainText),
                                      TextSpan(
                                        text: contents[index].gradientText,
                                        style: AppTextStyles.heading2.copyWith(
                                          fontSize: constraints.maxWidth * 0.055,
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
                   SizedBox(height: constraints.maxHeight * 0.02),
                  // Page indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      contents.length,
                      (index) => Container(
                        margin: EdgeInsets.symmetric(horizontal: constraints.maxWidth * 0.01),
                        height: constraints.maxHeight * 0.01,
                        width: currentIndex == index ? constraints.maxWidth * 0.06 : constraints.maxWidth * 0.02,
                        decoration: BoxDecoration(
                          gradient: currentIndex == index ? AppColors.primaryGradient : null,
                          color: currentIndex == index ? null : AppColors.textSecondary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  
                  SizedBox(height: constraints.maxHeight * 0.03),
                  
                  // Buttons row
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: constraints.maxHeight * 0.06,
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
                      ),
                      SizedBox(width: constraints.maxWidth * 0.04),
                      Expanded(
                        child: SizedBox(
                          height: constraints.maxHeight * 0.06,
                          child: Container(
                            decoration: AppButtonStyles.outlinedButtonDecoration,
                            child: OutlinedButton(
                              style: AppButtonStyles.outlinedButton,
                              onPressed: () => Routes.navigateToSignin(),
                              child: ShaderMask(
                                shaderCallback: (Rect bounds) => AppColors.primaryGradient.createShader(bounds),
                                child: Text(
                                  'Sign In',
                                  style: AppTextStyles.button.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: constraints.maxHeight * 0.02),
                  
                  // Login text
                  Center(
                    child: GestureDetector(
                      onTap: () => Routes.navigateToSignin(),
                      child: RichText(
                        text: TextSpan(
                          style: AppTextStyles.body.copyWith(
                            fontSize: constraints.maxWidth * 0.035,
                          ),
                          children: [
                            const TextSpan(
                              text: 'If you already have an account, you can ',
                            ),
                            TextSpan(
                              text: 'Login Here',
                              style: AppTextStyles.body.copyWith(
                                fontSize: constraints.maxWidth * 0.035,
                                color: AppColors.gradient,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  SizedBox(height: constraints.maxHeight * 0.02),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}