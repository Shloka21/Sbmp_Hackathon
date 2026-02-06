import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../config/theme.dart';
import '../../providers/user_provider.dart';
import '../../providers/money_provider.dart';

/// Budget Planner Screen with 50-30-20 rule
class BudgetPlannerScreen extends StatefulWidget {
  const BudgetPlannerScreen({super.key});

  @override
  State<BudgetPlannerScreen> createState() => _BudgetPlannerScreenState();
}

class _BudgetPlannerScreenState extends State<BudgetPlannerScreen> {
  final _incomeController = TextEditingController();
  
  // Default 50-30-20 allocation
  double _needsPercentage = 50;
  double _wantsPercentage = 30;
  double _savingsPercentage = 20;

  double get income => double.tryParse(_incomeController.text) ?? 0;
  double get needsAmount => income * _needsPercentage / 100;
  double get wantsAmount => income * _wantsPercentage / 100;
  double get savingsAmount => income * _savingsPercentage / 100;

  @override
  void dispose() {
    _incomeController.dispose();
    super.dispose();
  }

  void _adjustPercentages(String category, double newValue) {
    setState(() {
      final remaining = 100 - newValue;
      
      if (category == 'needs') {
        _needsPercentage = newValue;
        // Distribute remaining between wants and savings proportionally
        final ratio = _wantsPercentage / (_wantsPercentage + _savingsPercentage);
        _wantsPercentage = (remaining * ratio).clamp(0, 100);
        _savingsPercentage = remaining - _wantsPercentage;
      } else if (category == 'wants') {
        _wantsPercentage = newValue;
        final ratio = _needsPercentage / (_needsPercentage + _savingsPercentage);
        _needsPercentage = (remaining * ratio).clamp(0, 100);
        _savingsPercentage = remaining - _needsPercentage;
      } else {
        _savingsPercentage = newValue;
        final ratio = _needsPercentage / (_needsPercentage + _wantsPercentage);
        _needsPercentage = (remaining * ratio).clamp(0, 100);
        _wantsPercentage = remaining - _needsPercentage;
      }
    });
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
        title: Text(isHindi ? '💰 बजट प्लानर' : '💰 Budget Planner'),
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
                const Text('📊', style: TextStyle(fontSize: 48)),
                const SizedBox(height: 12),
                Text(
                  isHindi ? '50-30-20 नियम' : '50-30-20 Rule',
                  style: AppTypography.titleLarge.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  isHindi 
                      ? 'ज़रूरतें • इच्छाएं • बचत' 
                      : 'Needs • Wants • Savings',
                  style: AppTypography.bodyMedium.copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Income input
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isHindi ? '💵 आपकी मासिक आय' : '💵 Your Monthly Income',
                  style: AppTypography.titleMedium,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _incomeController,
                  keyboardType: TextInputType.number,
                  style: AppTypography.headlineMedium,
                  decoration: InputDecoration(
                    prefixText: '₹ ',
                    hintText: '25,000',
                    filled: true,
                    fillColor: AppColors.background,
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
          
          // Pie chart
          if (income > 0) ...[
            Container(
              height: 200,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: PieChart(
                      PieChartData(
                        sections: [
                          PieChartSectionData(
                            value: _needsPercentage,
                            title: '${_needsPercentage.toInt()}%',
                            color: Colors.blue,
                            radius: 60,
                            titleStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          PieChartSectionData(
                            value: _wantsPercentage,
                            title: '${_wantsPercentage.toInt()}%',
                            color: Colors.orange,
                            radius: 60,
                            titleStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          PieChartSectionData(
                            value: _savingsPercentage,
                            title: '${_savingsPercentage.toInt()}%',
                            color: Colors.green,
                            radius: 60,
                            titleStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                        centerSpaceRadius: 30,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _legendItem(Colors.blue, isHindi ? 'ज़रूरतें' : 'Needs'),
                      const SizedBox(height: 8),
                      _legendItem(Colors.orange, isHindi ? 'इच्छाएं' : 'Wants'),
                      const SizedBox(height: 8),
                      _legendItem(Colors.green, isHindi ? 'बचत' : 'Savings'),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
          ],
          
          // Allocation sliders
          _buildAllocationCard(
            icon: '🏠',
            title: isHindi ? 'ज़रूरतें (50%)' : 'Needs (50%)',
            subtitle: isHindi ? 'किराया, खाना, बिजली, दवाई' : 'Rent, food, utilities, medicine',
            amount: currencyFormat.format(needsAmount),
            percentage: _needsPercentage,
            color: Colors.blue,
            onChanged: (v) => _adjustPercentages('needs', v),
          ),
          
          _buildAllocationCard(
            icon: '🎬',
            title: isHindi ? 'इच्छाएं (30%)' : 'Wants (30%)',
            subtitle: isHindi ? 'मूवी, शॉपिंग, रेस्टोरेंट' : 'Movies, shopping, dining out',
            amount: currencyFormat.format(wantsAmount),
            percentage: _wantsPercentage,
            color: Colors.orange,
            onChanged: (v) => _adjustPercentages('wants', v),
          ),
          
          _buildAllocationCard(
            icon: '🐷',
            title: isHindi ? 'बचत (20%)' : 'Savings (20%)',
            subtitle: isHindi ? 'इमरजेंसी, लक्ष्य, निवेश' : 'Emergency, goals, investment',
            amount: currencyFormat.format(savingsAmount),
            percentage: _savingsPercentage,
            color: Colors.green,
            onChanged: (v) => _adjustPercentages('savings', v),
          ),
          
          const SizedBox(height: 24),
          
          // Tip
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.purple.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.purple.shade200),
            ),
            child: Row(
              children: [
                const Text('💡', style: TextStyle(fontSize: 24)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isHindi 
                        ? 'यह एक सुझाव है। अपनी ज़रूरत के हिसाब से बदलें!' 
                        : 'This is a suggestion. Customize based on your needs!',
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

  Widget _legendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(label, style: AppTypography.bodySmall),
      ],
    );
  }

  Widget _buildAllocationCard({
    required String icon,
    required String title,
    required String subtitle,
    required String amount,
    required double percentage,
    required Color color,
    required ValueChanged<double> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTypography.titleMedium),
                    Text(subtitle, style: AppTypography.bodySmall),
                  ],
                ),
              ),
              Text(
                amount,
                style: AppTypography.titleLarge.copyWith(color: color),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: color,
              inactiveTrackColor: color.withOpacity(0.2),
              thumbColor: color,
            ),
            child: Slider(
              value: percentage,
              min: 0,
              max: 80,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
