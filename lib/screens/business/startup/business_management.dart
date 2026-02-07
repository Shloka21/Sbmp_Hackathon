import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../config/theme.dart';
import '../../../providers/user_provider.dart';
import 'helpers.dart';

/// Business Plan Result Screen - Shows the complete business plan with insights
class BusinessPlanResultScreen extends StatefulWidget {
  final Map<String, dynamic> businessPlan;

  const BusinessPlanResultScreen({super.key, required this.businessPlan});

  @override
  State<BusinessPlanResultScreen> createState() => _BusinessPlanResultScreenState();
}

class _BusinessPlanResultScreenState extends State<BusinessPlanResultScreen> {
  List<Map<String, dynamic>> _checklist = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadChecklist();
  }

  Future<void> _loadChecklist() async {
    final planId = widget.businessPlan['id'] as int? ?? 0;
    final items = await BusinessStorageHelper.getChecklistItems(planId);
    setState(() {
      _checklist = items;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final isHindi = userProvider.language == 'hi';
    final plan = widget.businessPlan;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isHindi ? '📊 आपकी व्यापार योजना' : '📊 Your Business Plan'),
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Business header card
                  _buildHeaderCard(plan, isHindi),
                  const SizedBox(height: 20),

                  // Risk alerts
                  _buildRiskAlertsCard(plan, isHindi),
                  const SizedBox(height: 20),

                  // Profit simulation
                  _buildProfitSimulationCard(plan, isHindi),
                  const SizedBox(height: 20),

                  // Investment breakdown
                  _buildInvestmentBreakdownCard(plan, isHindi),
                  const SizedBox(height: 20),

                  // Season impact
                  _buildSeasonImpactCard(plan, isHindi),
                  const SizedBox(height: 20),

                  // Launch checklist
                  _buildLaunchChecklistCard(isHindi),
                  const SizedBox(height: 20),

                  // Action buttons
                  _buildActionButtons(plan, isHindi),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildHeaderCard(Map<String, dynamic> plan, bool isHindi) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            plan['business_icon'] ?? '💼',
            style: const TextStyle(fontSize: 48),
          ),
          const SizedBox(height: 12),
          Text(
            isHindi ? (plan['business_name_hi'] ?? plan['business_name'] ?? 'व्यवसाय') : (plan['business_name'] ?? 'Business'),
            style: AppTypography.headlineMedium.copyWith(color: Colors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatBadge(
                icon: '📍',
                label: isHindi ? 'स्थान' : 'Location',
                value: plan['location_type'] ?? 'N/A',
              ),
              _buildStatBadge(
                icon: '📐',
                label: isHindi ? 'आकार' : 'Size',
                value: '${(plan['shop_size'] ?? 100).toInt()} sq ft',
              ),
              _buildStatBadge(
                icon: '🏠',
                label: isHindi ? 'प्रकार' : 'Type',
                value: plan['rent_type'] ?? 'N/A',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatBadge({required String icon, required String label, required String value}) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildRiskAlertsCard(Map<String, dynamic> plan, bool isHindi) {
    final startupCost = (plan['startup_cost'] ?? 0).toDouble();
    List<Map<String, dynamic>> alerts = [];

    if (startupCost > 50000) {
      alerts.add({
        'icon': '⚠️',
        'color': Colors.orange,
        'title': isHindi ? 'उच्च निवेश' : 'High Investment',
        'message': isHindi 
            ? 'शुरुआत छोटे निवेश से करें और धीरे-धीरे बढ़ाएं'
            : 'Consider starting smaller and expanding gradually',
      });
    }

    if (plan['loan_option'] != 'Self-Funded') {
      alerts.add({
        'icon': '💳',
        'color': Colors.blue,
        'title': isHindi ? 'लोन लिया है' : 'Loan Taken',
        'message': isHindi 
            ? 'EMI समय पर भरें, नहीं तो जुर्माना लगेगा'
            : 'Pay EMI on time to avoid penalties',
      });
    }

    if (plan['location_type'] == 'City Main Road') {
      alerts.add({
        'icon': '🏙️',
        'color': Colors.purple,
        'title': isHindi ? 'उच्च किराया क्षेत्र' : 'High Rent Area',
        'message': isHindi
            ? 'शहर में किराया ज्यादा है, मार्जिन पर ध्यान दें'
            : 'City locations have higher rent, focus on margins',
      });
    }

    if (alerts.isEmpty) {
      alerts.add({
        'icon': '✅',
        'color': Colors.green,
        'title': isHindi ? 'सब कुछ ठीक है!' : 'All Good!',
        'message': isHindi
            ? 'आपकी योजना संतुलित दिखती है'
            : 'Your plan looks balanced',
      });
    }

    return _buildSectionCard(
      title: isHindi ? '⚠️ जोखिम चेतावनी' : '⚠️ Risk Alerts',
      child: Column(
        children: alerts.map((alert) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: (alert['color'] as Color).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: (alert['color'] as Color).withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Text(alert['icon'], style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(alert['title'], style: AppTypography.titleMedium),
                    Text(alert['message'], style: AppTypography.bodySmall),
                  ],
                ),
              ),
            ],
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildProfitSimulationCard(Map<String, dynamic> plan, bool isHindi) {
    final startupCost = (plan['startup_cost'] ?? 0).toDouble();
    final expectedProfit = (plan['expected_profit'] ?? startupCost * 0.35).toDouble();
    final monthlyProfit = expectedProfit / 12;

    return _buildSectionCard(
      title: isHindi ? '📈 लाभ अनुमान' : '📈 Profit Simulation',
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildProfitBox(
                label: isHindi ? 'कुल निवेश' : 'Total Investment',
                value: '₹${startupCost.toStringAsFixed(0)}',
                color: Colors.red.shade400,
              ),
              _buildProfitBox(
                label: isHindi ? 'वार्षिक लाभ' : 'Yearly Profit',
                value: '₹${expectedProfit.toStringAsFixed(0)}',
                color: Colors.green.shade400,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('💰', style: TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
                Column(
                  children: [
                    Text(
                      isHindi ? 'अनुमानित मासिक लाभ' : 'Estimated Monthly Profit',
                      style: AppTypography.bodyMedium,
                    ),
                    Text(
                      '₹${monthlyProfit.toStringAsFixed(0)}',
                      style: AppTypography.headlineSmall.copyWith(color: AppColors.success),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            isHindi
                ? '* यह अनुमान है, वास्तविक लाभ अलग हो सकता है'
                : '* This is an estimate, actual profit may vary',
            style: AppTypography.bodySmall.copyWith(fontStyle: FontStyle.italic),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProfitBox({required String label, required String value, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(label, style: AppTypography.bodySmall),
          const SizedBox(height: 4),
          Text(value, style: AppTypography.titleLarge.copyWith(color: color)),
        ],
      ),
    );
  }

  Widget _buildInvestmentBreakdownCard(Map<String, dynamic> plan, bool isHindi) {
    final rent = (plan['rent_deposit'] ?? 0).toDouble();
    final furniture = (plan['furniture_cost'] ?? 0).toDouble();
    final stock = (plan['stock_cost'] ?? 0).toDouble();
    final license = (plan['license_cost'] ?? 0).toDouble();
    final total = rent + furniture + stock + license;

    if (total == 0) {
      return const SizedBox.shrink();
    }

    return _buildSectionCard(
      title: isHindi ? '💼 निवेश विवरण' : '💼 Investment Breakdown',
      child: SizedBox(
        height: 200,
        child: PieChart(
          PieChartData(
            sectionsSpace: 2,
            centerSpaceRadius: 40,
            sections: [
              PieChartSectionData(
                value: rent,
                title: '${(rent / total * 100).toInt()}%',
                color: Colors.blue,
                radius: 60,
                titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
              ),
              PieChartSectionData(
                value: furniture,
                title: '${(furniture / total * 100).toInt()}%',
                color: Colors.orange,
                radius: 60,
                titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
              ),
              PieChartSectionData(
                value: stock,
                title: '${(stock / total * 100).toInt()}%',
                color: Colors.green,
                radius: 60,
                titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
              ),
              PieChartSectionData(
                value: license,
                title: '${(license / total * 100).toInt()}%',
                color: Colors.purple,
                radius: 60,
                titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSeasonImpactCard(Map<String, dynamic> plan, bool isHindi) {
    final rainy = (plan['season_rainy'] ?? 1.0).toDouble();
    final festival = (plan['season_festival'] ?? 1.0).toDouble();
    final wedding = (plan['season_wedding'] ?? 1.0).toDouble();

    return _buildSectionCard(
      title: isHindi ? '🌦️ मौसम का प्रभाव' : '🌦️ Season Impact',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildSeasonIndicator('🌧️', isHindi ? 'बारिश' : 'Rainy', rainy),
          _buildSeasonIndicator('🎉', isHindi ? 'त्योहार' : 'Festival', festival),
          _buildSeasonIndicator('💒', isHindi ? 'शादी' : 'Wedding', wedding),
        ],
      ),
    );
  }

  Widget _buildSeasonIndicator(String emoji, String label, double factor) {
    final isPositive = factor >= 1.0;
    final percentage = ((factor - 1) * 100).toInt();
    final displayText = percentage >= 0 ? '+$percentage%' : '$percentage%';

    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 28)),
        const SizedBox(height: 4),
        Text(label, style: AppTypography.bodySmall),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isPositive ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            displayText,
            style: TextStyle(
              color: isPositive ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLaunchChecklistCard(bool isHindi) {
    final completedCount = _checklist.where((item) => item['is_completed'] == 1).length;
    final totalCount = _checklist.length;
    final progress = totalCount > 0 ? completedCount / totalCount : 0.0;

    return _buildSectionCard(
      title: isHindi ? '✅ लॉन्च चेकलिस्ट' : '✅ Launch Checklist',
      child: Column(
        children: [
          // Progress header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$completedCount / $totalCount ${isHindi ? 'पूर्ण' : 'completed'}',
                        style: AppTypography.titleMedium,
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.success),
                          minHeight: 8,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: AppTypography.headlineSmall.copyWith(color: AppColors.primary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Checklist items
          ...List.generate(_checklist.length, (index) {
            final item = _checklist[index];
            final isCompleted = item['is_completed'] == 1;
            return GestureDetector(
              onTap: () => _toggleChecklistItem(index),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isCompleted ? AppColors.success.withOpacity(0.1) : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isCompleted ? AppColors.success : Colors.grey.shade200,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isCompleted ? Icons.check_circle : Icons.circle_outlined,
                      color: isCompleted ? AppColors.success : Colors.grey,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        isHindi ? (item['title_hi'] ?? item['title']) : item['title'],
                        style: TextStyle(
                          decoration: isCompleted ? TextDecoration.lineThrough : null,
                          color: isCompleted ? Colors.grey : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Future<void> _toggleChecklistItem(int index) async {
    final planId = widget.businessPlan['id'] as int? ?? 0;
    final currentValue = _checklist[index]['is_completed'] == 1;
    await BusinessStorageHelper.updateChecklistItem(planId, index, !currentValue);
    await _loadChecklist();
  }

  Widget _buildActionButtons(Map<String, dynamic> plan, bool isHindi) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () {
            final incomplete = _checklist.where((t) => t['is_completed'] == 0).toList();

            if (incomplete.isNotEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(isHindi
                      ? 'रुकिए! 🛑\nपहले चेकलिस्ट पूरी करें!'
                      : 'Wait! 🛑\nComplete the checklist first!'),
                  backgroundColor: Colors.orange,
                  duration: const Duration(seconds: 3),
                ),
              );
              return;
            }

            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (_) => DailyTrackingScreen(planId: plan['id'] ?? 0),
              ),
              (route) => false,
            );
          },
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(56),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: Text(
            isHindi ? '🚀 दैनिक ट्रैकिंग शुरू करें' : '🚀 Start Daily Tracking',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: Text(isHindi ? '🏠 होम पर जाएं' : '🏠 Go to Home'),
        ),
      ],
    );
  }

  Widget _buildSectionCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.titleLarge),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

/// Daily Tracking Screen - Track daily business operations
class DailyTrackingScreen extends StatefulWidget {
  final int planId;

  const DailyTrackingScreen({super.key, required this.planId});

  @override
  State<DailyTrackingScreen> createState() => _DailyTrackingScreenState();
}

class _DailyTrackingScreenState extends State<DailyTrackingScreen> {
  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final isHindi = userProvider.language == 'hi';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isHindi ? '📊 दैनिक ट्रैकिंग' : '📊 Daily Tracking'),
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🎉', style: TextStyle(fontSize: 80)),
              const SizedBox(height: 24),
              Text(
                isHindi ? 'बधाई हो!' : 'Congratulations!',
                style: AppTypography.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                isHindi
                    ? 'आपका व्यवसाय अब लॉन्च के लिए तैयार है!\n\nदैनिक ट्रैकिंग फीचर जल्द आ रहा है।'
                    : 'Your business is now ready to launch!\n\nDaily tracking feature coming soon.',
                style: AppTypography.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Icon(Icons.lightbulb_outline, size: 40, color: AppColors.primary),
                    const SizedBox(height: 12),
                    Text(
                      isHindi ? 'अगले कदम:' : 'Next Steps:',
                      style: AppTypography.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isHindi
                          ? '1. अपनी दुकान/व्यवसाय स्थापित करें\n2. ग्राहकों को आकर्षित करें\n3. दैनिक आय-व्यय का रिकॉर्ड रखें'
                          : '1. Set up your shop/business\n2. Attract customers\n3. Keep daily income-expense records',
                      style: AppTypography.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(200, 50),
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(isHindi ? '🏠 होम पर जाएं' : '🏠 Go to Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
