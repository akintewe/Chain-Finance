import 'package:chain_finance/utils/colors.dart';
import 'package:chain_finance/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ReceiveQRScreen extends StatelessWidget {
  final Map<String, dynamic> token;

  const ReceiveQRScreen({super.key, required this.token});

  void _copyToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: token['address']));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Address copied to clipboard',
          style: AppTextStyles.body.copyWith(color: AppColors.text),
        ),
        backgroundColor: AppColors.surface,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.text),
          onPressed: () => Get.back(),
        ),
        title: Text('Receive ${token['symbol']}', style: AppTextStyles.button),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Alert message
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.secondary.withOpacity(0.5),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: AppColors.secondary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Only receive tokens through Binance Smart Chain Network',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.text,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // Token Info
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  token['icon'],
                  width: 40,
                  height: 40,
                ),
                const SizedBox(width: 12),
                Text(
                  token['name'],
                  style: AppTextStyles.heading2.copyWith(fontSize: 24),
                ),
              ],
            ),
            
            const SizedBox(height: 40),
            
            // QR Code
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: ShaderMask(
                shaderCallback: (Rect bounds) {
                  return LinearGradient(
                    colors: [
                      AppColors.secondary,
                      AppColors.primary,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds);
                },
                child: QrImageView(
                  data: token['address'],
                  version: QrVersions.auto,
                  size: 200,
                  eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: Colors.white,
                  ),
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: Colors.white,
                  ),
                  backgroundColor: AppColors.surface,
                ),
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Address
            Text(
              'Wallet Address',
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      token['address'],
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.text,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.copy,
                      color: AppColors.secondary,
                    ),
                    onPressed: () => _copyToClipboard(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 