import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../config/theme.dart';
import '../../../providers/user_provider.dart';

/// Cost Calculator Screen for small business planning
class CostCalculatorScreen extends StatefulWidget {
  const CostCalculatorScreen({super.key});

  @override
  State<CostCalculatorScreen> createState() => _CostCalculatorScreenState();
}

class _CostCalculatorScreenState extends State<CostCalculatorScreen> {
  final _rentController = TextEditingController();
  final _materialsController = TextEditingController();
  final _laborController = TextEditingController();
  final _marketingController = TextEditingController();
  final _otherController = TextEditingController();

  double get totalCost {
    final rent = double.tryParse(_rentController.text) ?? 0;
    final materials = double.tryParse(_materialsController.text) ?? 0;
    final labor = double.tryParse(_laborController.text) ?? 0;
    final marketing = double.tryParse(_marketingController.text) ?? 0;
    final other = double.tryParse(_otherController.text) ?? 0;
    return rent + materials + labor + marketing + other;
  }

  @override
  void dispose() {
    _rentController.dispose();
    _materialsController.dispose();
    _laborController.dispose();
    _marketingController.dispose();
    _otherController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final isHindi = userProvider.language == 'hi';
    final currencyFormat = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isHindi ? '🧮 लागत कैलकुलेटर' : '🧮 Cost Calculator'),
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Text('💰', style: TextStyle(fontSize: 48)),
                const SizedBox(height: 12),
                Text(
                  isHindi ? 'अपनी व्यापार लागत जानें' : 'Calculate Your Business Costs',
                  style: AppTypography.titleLarge.copyWith(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Cost inputs
          _buildCostInput(
            icon: '🏠',
            label: isHindi ? 'किराया (महीना)' : 'Rent (per month)',
            controller: _rentController,
          ),
          _buildCostInput(
            icon: '📦',
            label: isHindi ? 'सामग्री/माल' : 'Materials/Goods',
            controller: _materialsController,
          ),
          _buildCostInput(
            icon: '👷',
            label: isHindi ? 'मजदूरी/वेतन' : 'Labor/Wages',
            controller: _laborController,
          ),
          _buildCostInput(
            icon: '📢',
            label: isHindi ? 'मार्केटिंग/विज्ञापन' : 'Marketing/Ads',
            controller: _marketingController,
          ),
          _buildCostInput(
            icon: '📋',
            label: isHindi ? 'अन्य खर्च' : 'Other Expenses',
            controller: _otherController,
          ),
          
          const SizedBox(height: 24),
          
          // Total
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primary, width: 2),
            ),
            child: Column(
              children: [
                Text(
                  isHindi ? 'कुल मासिक लागत' : 'Total Monthly Cost',
                  style: AppTypography.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  currencyFormat.format(totalCost),
                  style: AppTypography.headlineLarge.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  isHindi 
                      ? 'रोज़ाना: ${currencyFormat.format(totalCost / 30)}' 
                      : 'Daily: ${currencyFormat.format(totalCost / 30)}',
                  style: AppTypography.bodyMedium,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Tip
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber.shade200),
            ),
            child: Row(
              children: [
                const Text('💡', style: TextStyle(fontSize: 24)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isHindi 
                        ? 'टिप: हर दिन इतना कमाना होगा बस खर्च निकालने के लिए!' 
                        : 'Tip: This is how much you need to earn daily just to cover costs!',
                    style: AppTypography.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCostInput({
    required String icon,
    required String label,
    required TextEditingController controller,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label, style: AppTypography.titleMedium),
          ),
          SizedBox(
            width: 100,
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.right,
              decoration: const InputDecoration(
                prefixText: '₹ ',
                hintText: '0',
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
        ],
      ),
    );
  }
}
