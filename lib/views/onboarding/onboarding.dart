import 'package:nexa_prime/controllers/onboardingcontent.dart';
import 'package:nexa_prime/routes/routes.dart';
import 'package:nexa_prime/utils/button_style.dart';
import 'package:nexa_prime/views/auth/signupScreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/text_styles.dart';
import '../../utils/colors.dart';
import '../../utils/responsive_helper.dart';
import 'dart:math' as math;

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> with SingleTickerProviderStateMixin {
  final List<OnboardingContent> contents = [
    OnboardingContent(
      image: 'assets/images/WhatsApp Image 2025-03-25 at 10.07.55 AM.jpeg',
      mainText: 'Cryptocurrency\n always at\nyour fingertips\n in its  ',
      gradientText: 'Finest',
    ),
    OnboardingContent(
      image: 'assets/images/WhatsApp Image 2025-03-25 at 10.07.55 AM.jpeg', 
      mainText: 'Send and receive\nmoney in real-time\nwith ',
      gradientText: 'Nexa Prime.',
    ),
    OnboardingContent(
      image: 'assets/images/WhatsApp Image 2025-03-25 at 10.07.55 AM.jpeg',
      mainText: 'Trade securely\nanywhere, anytime\nwith ',
      gradientText: 'Nexa Prime.',
    ),
  ];

  int currentIndex = 0;
  late final PageController _pageController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late bool isTablet;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

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
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Initialize isTablet based on screen width
            isTablet = ResponsiveHelper.isTablet(context);

            return Stack(
              children: [
                // Background gradient
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.background,
                          AppColors.background.withOpacity(0.8),
                        ],
                      ),
                    ),
                  ),
                ),
                
                // Animated background circles
                ...List.generate(3, (index) {
                  return Positioned(
                    left: constraints.maxWidth * (0.2 + index * 0.3),
                    top: constraints.maxHeight * (0.1 + index * 0.2),
                    child: Container(
                      width: constraints.maxWidth * 0.4,
                      height: constraints.maxWidth * 0.4,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary.withOpacity(0.1),
                            AppColors.secondary.withOpacity(0.05),
                          ],
                        ),
                      ),
                    ),
                  );
                }),

                // Main content
                Padding(
                  padding: ResponsiveHelper.getResponsiveAllPadding(context, all: constraints.maxWidth * 0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                      // Logo with animation
                      AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _scaleAnimation.value,
                            child: Container(
                    height: isTablet ? constraints.maxHeight * 0.05 : constraints.maxHeight * 0.06,
                    width: isTablet ? constraints.maxHeight * 0.05 : constraints.maxHeight * 0.06,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: AppColors.primaryGradient,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(0.3),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: Image.asset(
                                  'assets/images/WhatsApp Image 2025-03-25 at 10.07.55 AM.jpeg',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          );
                        },
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
                              _animationController.reset();
                              _animationController.forward();
                        });
                      },
                      itemCount: contents.length,
                      itemBuilder: (context, index) {
                        return AnimatedOpacity(
                          duration: const Duration(milliseconds: 500),
                          opacity: currentIndex == index ? 1.0 : 0.0,
                          child: Column(
                            mainAxisAlignment: isTablet ? MainAxisAlignment.center : MainAxisAlignment.end,
                            children: [
                                  // Image with animation
                                  AnimatedBuilder(
                                    animation: _animationController,
                                    builder: (context, child) {
                                      return Transform.scale(
                                        scale: _scaleAnimation.value,
                                        child: Container(
                                height: isTablet ? constraints.maxHeight * 0.35 : constraints.maxHeight * 0.5,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(30),
                                            boxShadow: [
                                              BoxShadow(
                                                color: AppColors.primary.withOpacity(0.2),
                                                blurRadius: 30,
                                                offset: const Offset(0, 20),
                                              ),
                                            ],
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(30),
                                child: Image.asset(
                                  contents[index].image,
                                              fit: BoxFit.cover,
                                            ),
                                ),
                                        ),
                                      );
                                    },
                              ),

                              SizedBox(height: isTablet ? constraints.maxHeight * 0.015 : constraints.maxHeight * 0.02),
                              
                                  // Text with animation
                                  AnimatedBuilder(
                                    animation: _animationController,
                                    builder: (context, child) {
                                      return Transform.translate(
                                        offset: Offset(0, 20 * (1 - _fadeAnimation.value)),
                                        child: Opacity(
                                          opacity: _fadeAnimation.value,
                                          child: Container(
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
                                        ),
                                      );
                                    },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                   SizedBox(height: isTablet ? constraints.maxHeight * 0.015 : constraints.maxHeight * 0.02),
                      
                      // Page indicators with animation
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      contents.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                        margin: EdgeInsets.symmetric(horizontal: constraints.maxWidth * 0.01),
                        height: constraints.maxHeight * 0.01,
                        width: currentIndex == index ? constraints.maxWidth * 0.06 : constraints.maxWidth * 0.02,
                        decoration: BoxDecoration(
                          gradient: currentIndex == index ? AppColors.primaryGradient : null,
                              color: currentIndex == index ? null : AppColors.textSecondary.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: isTablet ? constraints.maxHeight * 0.025 : constraints.maxHeight * 0.03),
                  
                      // Buttons row with animation
                      AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, 20 * (1 - _fadeAnimation.value)),
                            child: Opacity(
                              opacity: _fadeAnimation.value,
                              child: Row(
                    children: [
                      Expanded(
                                    child: Container(
                          height: isTablet ? constraints.maxHeight * 0.05 : constraints.maxHeight * 0.06,
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                                        borderRadius: BorderRadius.circular(15),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.primary.withOpacity(0.3),
                                            blurRadius: 15,
                                            offset: const Offset(0, 5),
                                          ),
                                        ],
                            ),
                            child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.transparent,
                                          shadowColor: Colors.transparent,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(15),
                                          ),
                                        ),
                              onPressed: () => Routes.navigateToSignup(),
                              child: Text('Sign Up', style: AppTextStyles.button),
                          ),
                        ),
                      ),
                      SizedBox(width: constraints.maxWidth * 0.04),
                      Expanded(
                                    child: Container(
                          height: isTablet ? constraints.maxHeight * 0.05 : constraints.maxHeight * 0.06,
                                      decoration: BoxDecoration(
                                        color: AppColors.surface,
                                        borderRadius: BorderRadius.circular(15),
                                        border: Border.all(
                                          color: AppColors.primary.withOpacity(0.2),
                                        ),
                                      ),
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.transparent,
                                          shadowColor: Colors.transparent,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(15),
                                          ),
                                        ),
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
                                ],
                        ),
                      ),
                          );
                        },
                  ),
                  
                  SizedBox(height: constraints.maxHeight * 0.02),
                  
                      // Login text with animation
                      AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, 20 * (1 - _fadeAnimation.value)),
                            child: Opacity(
                              opacity: _fadeAnimation.value,
                              child: Center(
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
                            ),
                          );
                        },
                  ),
                  
                  SizedBox(height: constraints.maxHeight * 0.02),
                ],
              ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}