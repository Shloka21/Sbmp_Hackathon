import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../config/theme.dart';
import '../../../providers/user_provider.dart';

/// Profit Tracker Screen for calculating business profits
class ProfitTrackerScreen extends StatefulWidget {
  const ProfitTrackerScreen({super.key});

  @override
  State<ProfitTrackerScreen> createState() => _ProfitTrackerScreenState();
}

class _ProfitTrackerScreenState extends State<ProfitTrackerScreen> {
  final _revenueController = TextEditingController();
  final _costsController = TextEditingController();

  double get revenue => double.tryParse(_revenueController.text) ?? 0;
  double get costs => double.tryParse(_costsController.text) ?? 0;
  double get profit => revenue - costs;
  double get margin => revenue > 0 ? (profit / revenue * 100) : 0;

  @override
  void dispose() {
    _revenueController.dispose();
    _costsController.dispose();
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
        title: Text(isHindi ? '📊 प्रॉफिट ट्रैकर' : '📊 Profit Tracker'),
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
                const Text('📈', style: TextStyle(fontSize: 48)),
                const SizedBox(height: 12),
                Text(
                  isHindi ? 'अपना मुनाफा जानें' : 'Calculate Your Profit',
                  style: AppTypography.titleLarge.copyWith(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Revenue input
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('💵', style: TextStyle(fontSize: 28)),
                    const SizedBox(width: 12),
                    Text(
                      isHindi ? 'कुल बिक्री/आय' : 'Total Revenue/Sales',
                      style: AppTypography.titleMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _revenueController,
                  keyboardType: TextInputType.number,
                  style: AppTypography.headlineMedium.copyWith(color: AppColors.success),
                  decoration: InputDecoration(
                    prefixText: '₹ ',
                    hintText: '0',
                    filled: true,
                    fillColor: AppColors.success.withOpacity(0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Costs input
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('💸', style: TextStyle(fontSize: 28)),
                    const SizedBox(width: 12),
                    Text(
                      isHindi ? 'कुल खर्च/लागत' : 'Total Costs/Expenses',
                      style: AppTypography.titleMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _costsController,
                  keyboardType: TextInputType.number,
                  style: AppTypography.headlineMedium.copyWith(color: AppColors.error),
                  decoration: InputDecoration(
                    prefixText: '₹ ',
                    hintText: '0',
                    filled: true,
                    fillColor: AppColors.error.withOpacity(0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Results
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: profit >= 0 ? AppColors.success.withOpacity(0.1) : AppColors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: profit >= 0 ? AppColors.success : AppColors.error,
                width: 2,
              ),
            ),
            child: Column(
              children: [
                Text(
                  profit >= 0 
                      ? (isHindi ? '🎉 शुद्ध लाभ' : '🎉 Net Profit')
                      : (isHindi ? '😟 शुद्ध हानि' : '😟 Net Loss'),
                  style: AppTypography.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  currencyFormat.format(profit.abs()),
                  style: AppTypography.headlineLarge.copyWith(
                    color: profit >= 0 ? AppColors.success : AppColors.error,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isHindi 
                        ? 'प्रॉफिट मार्जिन: ${margin.toStringAsFixed(1)}%' 
                        : 'Profit Margin: ${margin.toStringAsFixed(1)}%',
                    style: AppTypography.titleMedium.copyWith(
                      color: profit >= 0 ? AppColors.success : AppColors.error,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Margin insights
          if (revenue > 0)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  const Text('💡', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      margin < 10 
                          ? (isHindi ? 'मार्जिन कम है। खर्च कम करें या दाम बढ़ाएं।' : 'Low margin. Reduce costs or increase prices.')
                          : margin < 20 
                              ? (isHindi ? 'ठीक मार्जिन। और बेहतर हो सकता है।' : 'Decent margin. Room for improvement.')
                              : (isHindi ? 'बहुत अच्छा मार्जिन! 👏' : 'Great profit margin! 👏'),
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
}
