import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../../utils/text_styles.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Privacy Policy',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildSection('Effective Date: 4/16/2025', isHeader: true),
              const SizedBox(height: 16),
              _buildCompanyInfo(),
              const SizedBox(height: 24),
              _buildIntro(),
              const SizedBox(height: 24),
              _buildSection('1. Information We Collect', isHeader: true),
              _buildParagraph(
                'To comply with Anti-Money Laundering (AML) and Know Your Customer (KYC) regulations and provide our services securely, we may collect and process the following information:',
              ),
              _buildBulletPoints([
                'Identity Information: Full name, date of birth, nationality, government-issued ID (e.g., passport, driver\'s license), selfie or biometric verification.',
                'Contact Information: Email address, residential address, and phone number.',
                'Financial & Transactional Data: Wallet addresses, transaction history, and blockchain activity related to our services.',
                'Technical Data: IP address, device information, and usage logs (automatically collected for security and fraud prevention).',
              ]),
              const SizedBox(height: 24),
              _buildSection('2. How We Use Your Information', isHeader: true),
              _buildParagraph('We use your information for the following purposes:'),
              _buildBulletPoints([
                'To verify your identity and comply with AML/KYC regulations.',
                'To process crypto transactions and provide support.',
                'To monitor and prevent fraud, suspicious activity, and abuse.',
                'To communicate updates, alerts, and service-related notices.',
                'To comply with legal obligations under applicable laws and regulations.',
              ]),
              const SizedBox(height: 24),
              _buildSection('3. Legal Basis for Processing', isHeader: true),
              _buildParagraph('We process your personal data under the following legal grounds:'),
              _buildBulletPoints([
                'Compliance with legal obligations (e.g., AML/KYC laws).',
                'Performance of a contract (to provide our services to you).',
                'Legitimate interests (e.g., fraud prevention and service improvement).',
              ]),
              const SizedBox(height: 24),
              _buildSection('4. Data Storage and Security', isHeader: true),
              _buildParagraph(
                'We store your data in a secure cloud-based infrastructure with access restricted to authorized personnel only. We implement industry-standard technical and organizational measures to protect your information from unauthorized access, loss, misuse, or alteration.',
              ),
              const SizedBox(height: 24),
              _buildSection('5. Data Retention', isHeader: true),
              _buildParagraph(
                'We retain personal data as long as necessary for regulatory compliance (including AML/KYC requirements), to provide our services, or to resolve disputes. Once no longer needed, data is securely deleted or anonymized.',
              ),
              const SizedBox(height: 24),
              _buildSection('6. International Data Transfers', isHeader: true),
              _buildParagraph(
                'As a global service provider, your information may be processed in countries outside your jurisdiction. In such cases, we ensure that adequate safeguards are in place, consistent with applicable data protection laws.',
              ),
              const SizedBox(height: 24),
              _buildSection('7. Sharing of Information', isHeader: true),
              _buildParagraph('We do not sell your personal data. We may share data only with:'),
              _buildBulletPoints([
                'Regulators or law enforcement, when legally required.',
                'Identity verification or AML screening partners (if applicable in the future).',
                'Legal or financial advisors, in connection with regulatory audits or compliance.',
              ]),
              const SizedBox(height: 24),
              _buildSection('8. Your Rights', isHeader: true),
              _buildParagraph('Depending on your jurisdiction, you may have the right to:'),
              _buildBulletPoints([
                'Access and review your personal information.',
                'Request correction or deletion of your data (subject to legal obligations).',
                'Object to or restrict certain types of processing.',
                'File a complaint with a relevant data protection authority.',
              ]),
              _buildParagraph(
                'To exercise your rights, contact us at: inquiries@nexaprime.org',
                isHighlighted: true,
              ),
              const SizedBox(height: 24),
              _buildSection('9. Children\'s Privacy', isHeader: true),
              _buildParagraph(
                'Our services are not intended for individuals under the age of 18. We do not knowingly collect personal information from children.',
              ),
              const SizedBox(height: 24),
              _buildSection('10. Changes to This Policy', isHeader: true),
              _buildParagraph(
                'We may update this Privacy Policy periodically. We will notify you of significant changes by posting an updated version on our website and updating the effective date at the top of this page.',
              ),
              const SizedBox(height: 24),
              _buildSection('11. Contact Us', isHeader: true),
              _buildParagraph('For any questions or concerns regarding this Privacy Policy or our data handling practices, contact:'),
              const SizedBox(height: 16),
              _buildContactInfo(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.privacy_tip_outlined,
              color: AppColors.primary,
              size: 30,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Privacy Policy',
            style: AppTextStyles.heading.copyWith(fontSize: 24),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCompanyInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nexa Prime',
            style: AppTextStyles.body2.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '3044 Breckenridge Lane\nLouisville, KY 40220\nUnited States',
            style: AppTextStyles.body.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntro() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        'Your privacy is important to us. This Privacy Policy describes how We collect, use, store and protect your personal information when you use our services to send and receive cryptocurrency globally.',
        style: AppTextStyles.body.copyWith(
          color: AppColors.textSecondary,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildSection(String title, {bool isHeader = false}) {
    return Text(
      title,
      style: AppTextStyles.body2.copyWith(
        fontWeight: FontWeight.w600,
        fontSize: isHeader ? 18 : 16,
        color: isHeader ? AppColors.primary : Colors.white,
      ),
    );
  }

  Widget _buildParagraph(String text, {bool isHighlighted = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: AppTextStyles.body.copyWith(
          color: isHighlighted ? AppColors.primary : AppColors.textSecondary,
          height: 1.5,
          fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildBulletPoints(List<String> points) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: points.map((point) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '• ',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Expanded(
                  child: Text(
                    point,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildContactInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.email_outlined,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Email:',
                style: AppTextStyles.body2.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'inquiries@nexaprime.org',
            style: AppTextStyles.body.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Mailing Address:',
                style: AppTextStyles.body2.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Nexa Prime\n3044 Breckenridge Lane\nLouisville, KY 40220\nUSA',
            style: AppTextStyles.body.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
} 