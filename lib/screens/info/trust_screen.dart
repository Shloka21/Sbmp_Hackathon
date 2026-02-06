import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../config/theme.dart';

/// Trust Information Screen - Why Trust Sathi?
class TrustScreen extends StatelessWidget {
  const TrustScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Why Trust Sathi?',
          style: AppTypography.titleLarge.copyWith(color: AppColors.textPrimary),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Hero section
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(25),
              ),
              child: const Center(
                child: Text('🐻', style: TextStyle(fontSize: 50)),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Sathi is Your Safe Space',
              style: AppTypography.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'आपकी जानकारी सुरक्षित है!',
              style: AppTypography.titleMedium.copyWith(
                color: AppColors.primary,
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Trust points
            _TrustCard(
              icon: Icons.lock_outline,
              color: Colors.blue,
              title: 'Your Data Stays on Your Phone',
              hindiTitle: 'आपका Data Phone में ही रहता है',
              description: 'We use local storage. Your financial information never leaves your device.',
            ),
            
            _TrustCard(
              icon: Icons.money_off,
              color: Colors.green,
              title: 'We Do NOT Take Your Money',
              hindiTitle: 'हम आपके पैसे नहीं लेते',
              description: 'Sathi is a learning app. We don\'t access your bank accounts or UPI.',
            ),
            
            _TrustCard(
              icon: Icons.shield_outlined,
              color: Colors.orange,
              title: 'No Bank Password Ever',
              hindiTitle: 'Bank Password कभी नहीं मांगते',
              description: 'We never ask for your banking credentials, OTP, or card details.',
            ),
            
            _TrustCard(
              icon: Icons.wifi_off,
              color: Colors.purple,
              title: 'Works Offline',
              hindiTitle: 'बिना Internet भी चलता है',
              description: 'Most features work without internet. Your data stays private.',
            ),
            
            _TrustCard(
              icon: Icons.verified_user_outlined,
              color: Colors.teal,
              title: 'Educational Purpose',
              hindiTitle: 'सिर्फ सीखने के लिए',
              description: 'We help you learn about money. We don\'t provide actual financial services.',
            ),
            
            const SizedBox(height: 24),
            
            // Scam warning
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.warning_amber, color: Colors.red.shade700),
                      const SizedBox(width: 8),
                      Text(
                        'Scam Warning',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '🚨 Sathi will NEVER:\n'
                    '• Ask for your OTP\n'
                    '• Ask for money or fees\n'
                    '• Call you for "verification"\n'
                    '• Ask for bank passwords\n\n'
                    'If someone claims to be from Sathi and asks for these, it\'s a SCAM!',
                    style: TextStyle(
                      color: Colors.red.shade900,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Contact
            Text(
              'Questions? Contact us:',
              style: AppTypography.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'support@sathi.app',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _TrustCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String hindiTitle;
  final String description;

  const _TrustCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.hindiTitle,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  hindiTitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
