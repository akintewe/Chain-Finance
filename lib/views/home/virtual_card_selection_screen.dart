import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nexa_prime/controllers/virtual_account_controller.dart';
import 'package:nexa_prime/utils/colors.dart';
import 'package:nexa_prime/utils/text_styles.dart';
import 'package:nexa_prime/utils/responsive_helper.dart';

class VirtualCardSelectionScreen extends StatefulWidget {
  const VirtualCardSelectionScreen({super.key});

  @override
  State<VirtualCardSelectionScreen> createState() => _VirtualCardSelectionScreenState();
}

class _VirtualCardSelectionScreenState extends State<VirtualCardSelectionScreen> {
  late VirtualAccountController controller;
  late PageController _pageController;
  int _currentIndex = 0;

  // Beautiful card designs matching your app's theme
  final List<Map<String, dynamic>> cardDesigns = [
    {
      'name': 'Platinum Black',
      'colors': [Color(0xFF141E30), Color(0xFF243B55)],
      'icon': Icons.auto_awesome,
      'pattern': 'geometric',
      'hasMetalChip': true,
    },
    {
      'name': 'Rose Gold',
      'colors': [Color(0xFFED4264), Color(0xFFFFEDBC)],
      'icon': Icons.diamond,
      'pattern': 'diamonds',
      'hasMetalChip': true,
    },
    {
      'name': 'Ocean Blue',
      'colors': [Color(0xFF2E3192), Color(0xFF1BFFFF)],
      'icon': Icons.water,
      'pattern': 'waves',
      'hasMetalChip': true,
    },
    {
      'name': 'Purple Elite',
      'colors': [Color(0xFF360033), Color(0xFF0B8793)],
      'icon': Icons.stars,
      'pattern': 'stars',
      'hasMetalChip': true,
    },
    {
      'name': 'Emerald Luxury',
      'colors': [Color(0xFF134E5E), Color(0xFF71B280)],
      'icon': Icons.park,
      'pattern': 'leaves',
      'hasMetalChip': true,
    },
    {
      'name': 'Royal Gold',
      'colors': [Color(0xFFBF953F), Color(0xFFFCF6BA), Color(0xFFB38728), Color(0xFFFBF5B7), Color(0xFFAA771C)],
      'icon': Icons.workspace_premium,
      'pattern': 'luxury',
      'hasMetalChip': true,
    },
    {
      'name': 'Cosmic Purple',
      'colors': [Color(0xFF5F2C82), Color(0xFF49A09D)],
      'icon': Icons.nights_stay,
      'pattern': 'cosmic',
      'hasMetalChip': true,
    },
    {
      'name': 'Midnight Navy',
      'colors': [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
      'icon': Icons.dark_mode,
      'pattern': 'mesh',
      'hasMetalChip': true,
    },
    {
      'name': 'Sunset Premium',
      'colors': [Color(0xFFFF512F), Color(0xFFF09819)],
      'icon': Icons.wb_twilight,
      'pattern': 'rays',
      'hasMetalChip': true,
    },
    {
      'name': 'Deep Ocean',
      'colors': [Color(0xFF005C97), Color(0xFF363795)],
      'icon': Icons.waves,
      'pattern': 'ripples',
      'hasMetalChip': true,
    },
    {
      'name': 'Carbon Fiber',
      'colors': [Color(0xFF1C1C1C), Color(0xFF383838)],
      'icon': Icons.texture,
      'pattern': 'carbon',
      'hasMetalChip': true,
    },
    {
      'name': 'Ruby Red',
      'colors': [Color(0xFF8E0E00), Color(0xFF1F1C18)],
      'icon': Icons.favorite,
      'pattern': 'diamonds',
      'hasMetalChip': true,
    },
  ];

  @override
  void initState() {
    super.initState();
    // Initialize controller with error handling
    try {
      controller = Get.find<VirtualAccountController>();
    } catch (e) {
      controller = Get.put(VirtualAccountController());
    }
    
    _pageController = PageController(viewportFraction: 0.85);
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Choose Card Design',
          style: AppTextStyles.heading2.copyWith(
            color: AppColors.text,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.text),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: ResponsiveHelper.getResponsiveAllPadding(context, all: 20.0),
        child: Column(
          children: [
            Text(
              'Select your preferred card design',
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemCount: cardDesigns.length,
                itemBuilder: (context, index) {
                  final design = cardDesigns[index];
                  final isSelected = index == _currentIndex;
                  
                  return AnimatedScale(
                    scale: isSelected ? 1.0 : 0.9,
                    duration: const Duration(milliseconds: 300),
                    child: AnimatedOpacity(
                      opacity: isSelected ? 1.0 : 0.5,
                      duration: const Duration(milliseconds: 300),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 20),
                        child: _buildCard(design, isSelected),
                      ),
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
                cardDesigns.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentIndex == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    gradient: _currentIndex == index
                        ? AppColors.primaryGradient
                        : null,
                    color: _currentIndex == index
                        ? null
                        : AppColors.textSecondary.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            // Select button
            SizedBox(
              width: double.infinity,
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate back or to virtual account screen
                    Get.back();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Select This Design',
                    style: AppTextStyles.body2.copyWith(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(Map<String, dynamic> design, bool isSelected) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: (design['colors'][0] as Color).withOpacity(isSelected ? 0.4 : 0.2),
            blurRadius: isSelected ? 30 : 15,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          height: 220,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: design['colors'] as List<Color>,
            ),
          ),
          child: Stack(
            children: [
              // Decorative pattern based on card type
              ..._buildCardPattern(design['pattern']),
              // Card content
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Card name badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            design['name'],
                            style: AppTextStyles.body.copyWith(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        // App Logo
                        Container(
                          width: 60,
                          height: 60,
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.asset(
                              'assets/images/app_logo.jpeg',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Premium Metal Chip
                        Container(
                          width: 55,
                          height: 40,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFFFFD700),
                                Color(0xFFDAA520),
                                Color(0xFFB8860B),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              // Chip grid pattern
                              Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: List.generate(
                                        4,
                                        (i) => Container(
                                          width: 8,
                                          height: 1.5,
                                          margin: EdgeInsets.symmetric(horizontal: 0.5),
                                          decoration: BoxDecoration(
                                            color: Color(0xFF8B7355).withOpacity(0.6),
                                            borderRadius: BorderRadius.circular(1),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: List.generate(
                                        4,
                                        (i) => Container(
                                          width: 8,
                                          height: 1.5,
                                          margin: EdgeInsets.symmetric(horizontal: 0.5),
                                          decoration: BoxDecoration(
                                            color: Color(0xFF8B7355).withOpacity(0.6),
                                            borderRadius: BorderRadius.circular(1),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: List.generate(
                                        4,
                                        (i) => Container(
                                          width: 8,
                                          height: 1.5,
                                          margin: EdgeInsets.symmetric(horizontal: 0.5),
                                          decoration: BoxDecoration(
                                            color: Color(0xFF8B7355).withOpacity(0.6),
                                            borderRadius: BorderRadius.circular(1),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Contactless payment icon
                        Row(
                          children: [
                            Icon(
                              Icons.wifi,
                              color: Colors.white.withOpacity(0.9),
                              size: 28,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Card number
                        Text(
                          '**** **** **** 1234',
                          style: AppTextStyles.heading2.copyWith(
                            color: Colors.white,
                            fontSize: 20,
                            letterSpacing: 3,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'CARD HOLDER',
                                  style: AppTextStyles.body.copyWith(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 9,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'YOUR NAME',
                                  style: AppTextStyles.body.copyWith(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'EXPIRES',
                                  style: AppTextStyles.body.copyWith(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 9,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '12/28',
                                  style: AppTextStyles.body.copyWith(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                            // Mastercard logo
                            Row(
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                Transform.translate(
                                  offset: const Offset(-8, 0),
                                  child: Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: Colors.amber.shade600,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Build decorative patterns based on card design
  List<Widget> _buildCardPattern(String pattern) {
    switch (pattern) {
      case 'geometric':
        return [
          Positioned(
            top: -30,
            right: -30,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white.withOpacity(0.15), width: 2),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            right: 30,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white.withOpacity(0.15), width: 2),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ];
      
      case 'diamonds':
        return List.generate(8, (index) {
          return Positioned(
            top: (index % 4) * 50.0,
            left: (index ~/ 4) * 100.0 + 50,
            child: Transform.rotate(
              angle: 0.785,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white.withOpacity(0.1), width: 1.5),
                ),
              ),
            ),
          );
        });

      case 'waves':
        return [
          Positioned(
            bottom: -20,
            left: -40,
            right: -40,
            child: CustomPaint(
              size: Size(400, 100),
              painter: WavePainter(),
            ),
          ),
        ];

      case 'stars':
        return List.generate(15, (index) {
          final random = index * 37;
          return Positioned(
            top: (random % 200).toDouble(),
            left: ((random * 3) % 350).toDouble(),
            child: Icon(
              Icons.star,
              color: Colors.white.withOpacity(0.15),
              size: 12 + (random % 3) * 4,
            ),
          );
        });

      case 'leaves':
        return List.generate(6, (index) {
          return Positioned(
            top: (index * 35.0) - 20,
            right: (index % 2) * 80.0 - 30,
            child: Icon(
              Icons.eco,
              color: Colors.white.withOpacity(0.12),
              size: 45,
            ),
          );
        });

      case 'luxury':
        return [
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.white.withOpacity(0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -40,
            left: -40,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.white.withOpacity(0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ];

      case 'cosmic':
        return List.generate(20, (index) {
          final random = index * 29;
          return Positioned(
            top: (random % 200).toDouble(),
            left: ((random * 5) % 350).toDouble(),
            child: Container(
              width: 2 + (random % 2),
              height: 2 + (random % 2),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.6),
                shape: BoxShape.circle,
              ),
            ),
          );
        });

      case 'mesh':
        return List.generate(5, (i) {
          return Positioned(
            top: i * 40.0,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(8, (j) {
                return Container(
                  width: 3,
                  height: 3,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                );
              }),
            ),
          );
        });

      case 'rays':
        return [
          Positioned.fill(
            child: CustomPaint(
              painter: RaysPainter(),
            ),
          ),
        ];

      case 'ripples':
        return List.generate(3, (index) {
          return Positioned(
            bottom: -50 - (index * 30),
            right: -50 - (index * 30),
            child: Container(
              width: 150 + (index * 60),
              height: 150 + (index * 60),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.1 - index * 0.03),
                  width: 2,
                ),
              ),
            ),
          );
        });

      case 'carbon':
        return [
          Positioned.fill(
            child: CustomPaint(
              painter: CarbonFiberPainter(),
            ),
          ),
        ];

      default:
        return [
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            left: -30,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
        ];
    }
  }
}

// Custom painter for wave pattern
class WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final path = Path();
    for (int i = 0; i < 3; i++) {
      path.reset();
      path.moveTo(0, size.height / 2 + i * 15);
      
      for (double x = 0; x < size.width; x += 20) {
        path.quadraticBezierTo(
          x + 10, size.height / 2 + i * 15 - 10,
          x + 20, size.height / 2 + i * 15,
        );
      }
      
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Custom painter for rays pattern
class RaysPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..style = PaintingStyle.fill;

    final center = Offset(size.width * 0.8, -20);
    
    for (int i = 0; i < 12; i++) {
      final path = Path();
      final angle = (i * 30.0) * (3.14159 / 180);
      
      path.moveTo(center.dx, center.dy);
      path.lineTo(
        center.dx + 300 * cos(angle),
        center.dy + 300 * sin(angle),
      );
      path.lineTo(
        center.dx + 300 * cos(angle + 0.1),
        center.dy + 300 * sin(angle + 0.1),
      );
      path.close();
      
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Custom painter for carbon fiber pattern
class CarbonFiberPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Draw diagonal lines for carbon fiber effect
    for (double i = -size.height; i < size.width; i += 10) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        paint,
      );
    }
    
    for (double i = 0; i < size.width + size.height; i += 10) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i - size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
