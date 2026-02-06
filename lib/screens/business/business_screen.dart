import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../providers/user_provider.dart';

/// Business Screen - Small business starter kit
class BusinessScreen extends StatelessWidget {
  const BusinessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final isHindi = userProvider.language == 'hi';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isHindi ? '🏪 व्यापार शुरू करें' : '🏪 Start Business'),
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Column(
              children: [
                const Text('💼', style: TextStyle(fontSize: 64)),
                const SizedBox(height: 16),
                Text(
                  isHindi ? 'अपना व्यापार शुरू करें!' : 'Start Your Business!',
                  style: AppTypography.headlineMedium.copyWith(
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  isHindi 
                      ? 'हम आपकी हर कदम पर मदद करेंगे' 
                      : 'We\'ll help you every step of the way',
                  style: AppTypography.bodyMedium.copyWith(
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: AppSpacing.xl),
          
          Text(
            isHindi ? '🎯 व्यापार आइडियाज' : '🎯 Business Ideas',
            style: AppTypography.headlineSmall,
          ),
          const SizedBox(height: 16),
          
          // Business ideas
          ..._getBusinessIdeas(isHindi).map((idea) {
            return _BusinessIdeaCard(
              icon: idea['icon']!,
              title: idea['title']!,
              investment: idea['investment']!,
              profit: idea['profit']!,
              onTap: () => _showBusinessDetail(context, idea, isHindi),
            );
          }),
          
          const SizedBox(height: AppSpacing.xl),
          
          // Tools section
          Text(
            isHindi ? '🛠️ व्यापार टूल्स' : '🛠️ Business Tools',
            style: AppTypography.headlineSmall,
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _ToolCard(
                  icon: '🧮',
                  title: isHindi ? 'लागत\nकैलकुलेटर' : 'Cost\nCalculator',
                  onTap: () {},
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ToolCard(
                  icon: '📊',
                  title: isHindi ? 'प्रॉफिट\nट्रैकर' : 'Profit\nTracker',
                  onTap: () {},
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ToolCard(
                  icon: '💰',
                  title: isHindi ? 'लोन\nखोजें' : 'Find\nLoans',
                  onTap: () => context.push('/schemes'),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppSpacing.xl),
          
          // Ask AI
          GestureDetector(
            onTap: () => context.push('/ai-chat'),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Text('🐻', style: TextStyle(fontSize: 40)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isHindi ? 'साथी से पूछें' : 'Ask Sathi',
                          style: AppTypography.titleLarge,
                        ),
                        Text(
                          isHindi 
                              ? 'व्यापार संबंधी कोई भी सवाल पूछें!' 
                              : 'Ask any business-related question!',
                          style: AppTypography.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  List<Map<String, String>> _getBusinessIdeas(bool isHindi) {
    return [
      {
        'icon': '🥬',
        'title': isHindi ? 'सब्जी/फल की दुकान' : 'Vegetable/Fruit Shop',
        'investment': isHindi ? '₹5,000 - ₹20,000' : '₹5,000 - ₹20,000',
        'profit': isHindi ? '₹300-500/दिन' : '₹300-500/day',
        'description': isHindi 
            ? 'गांव या मोहल्ले में ताजी सब्जी-फल बेचें' 
            : 'Sell fresh vegetables and fruits in your area',
      },
      {
        'icon': '🧵',
        'title': isHindi ? 'सिलाई/टेलरिंग' : 'Tailoring Business',
        'investment': isHindi ? '₹10,000 - ₹30,000' : '₹10,000 - ₹30,000',
        'profit': isHindi ? '₹6,000-15,000/महीना' : '₹6,000-15,000/month',
        'description': isHindi 
            ? 'कपड़े सिलने का व्यापार घर से शुरू करें' 
            : 'Start a tailoring business from home',
      },
      {
        'icon': '📱',
        'title': isHindi ? 'मोबाइल रिचार्ज/सर्विस' : 'Mobile Recharge Shop',
        'investment': isHindi ? '₹3,000 - ₹10,000' : '₹3,000 - ₹10,000',
        'profit': isHindi ? '₹200-400/दिन' : '₹200-400/day',
        'description': isHindi 
            ? 'रिचार्ज, बिल पेमेंट, और छोटी सर्विसेज' 
            : 'Recharge, bill payments, and small services',
      },
      {
        'icon': '🍵',
        'title': isHindi ? 'चाय/नाश्ता स्टॉल' : 'Tea/Snacks Stall',
        'investment': isHindi ? '₹3,000 - ₹15,000' : '₹3,000 - ₹15,000',
        'profit': isHindi ? '₹400-800/दिन' : '₹400-800/day',
        'description': isHindi 
            ? 'भीड़-भाड़ वाली जगह पर चाय-नाश्ता बेचें' 
            : 'Sell tea and snacks in busy areas',
      },
      {
        'icon': '🐄',
        'title': isHindi ? 'दूध का व्यापार' : 'Dairy/Milk Business',
        'investment': isHindi ? '₹20,000 - ₹50,000' : '₹20,000 - ₹50,000',
        'profit': isHindi ? '₹8,000-20,000/महीना' : '₹8,000-20,000/month',
        'description': isHindi 
            ? 'दूध और दूध से बने प्रोडक्ट्स बेचें' 
            : 'Sell milk and dairy products',
      },
    ];
  }

  void _showBusinessDetail(
    BuildContext context,
    Map<String, String> idea,
    bool isHindi,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  Center(
                    child: Text(idea['icon']!, style: const TextStyle(fontSize: 80)),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    idea['title']!,
                    style: AppTypography.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  _DetailRow(
                    icon: Icons.attach_money,
                    label: isHindi ? 'शुरुआती लागत' : 'Starting Investment',
                    value: idea['investment']!,
                  ),
                  _DetailRow(
                    icon: Icons.trending_up,
                    label: isHindi ? 'संभावित कमाई' : 'Expected Profit',
                    value: idea['profit']!,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    idea['description']!,
                    style: AppTypography.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      context.push('/ai-chat');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      isHindi ? '🐻 साथी से पूरी जानकारी लें' : '🐻 Get Full Details from Sathi',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
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

class _BusinessIdeaCard extends StatelessWidget {
  final String icon;
  final String title;
  final String investment;
  final String profit;
  final VoidCallback onTap;

  const _BusinessIdeaCard({
    required this.icon,
    required this.title,
    required this.investment,
    required this.profit,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(icon, style: const TextStyle(fontSize: 28)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTypography.titleMedium),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.attach_money, size: 14, color: AppColors.textLight),
                      Text(' $investment', style: AppTypography.bodySmall),
                      const SizedBox(width: 12),
                      Icon(Icons.trending_up, size: 14, color: AppColors.success),
                      Text(' $profit', style: AppTypography.bodySmall.copyWith(
                        color: AppColors.success,
                      )),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.textLight),
          ],
        ),
      ),
    );
  }
}

class _ToolCard extends StatelessWidget {
  final String icon;
  final String title;
  final VoidCallback onTap;

  const _ToolCard({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 8),
            Text(
              title,
              style: AppTypography.labelLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label, style: AppTypography.bodyMedium),
          ),
          Text(value, style: AppTypography.titleMedium),
        ],
      ),
    );
  }
}
