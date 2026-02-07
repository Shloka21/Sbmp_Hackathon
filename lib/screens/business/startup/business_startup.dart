import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../config/theme.dart';
import '../../../providers/user_provider.dart';
import 'helpers.dart';
import 'business_management.dart';

/// Business Selection Screen - Choose a business type to start
class BusinessSelectionScreen extends StatelessWidget {
  const BusinessSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final isHindi = userProvider.language == 'hi';
    final businesses = BusinessStorageHelper.getBusinessTemplates();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isHindi ? '🚀 व्यापार चुनें' : '🚀 Choose Your Business'),
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                const Text('💼', style: TextStyle(fontSize: 48)),
                const SizedBox(height: 12),
                Text(
                  isHindi ? 'अपने सपनों का व्यापार चुनें!' : 'Pick Your Dream Business!',
                  style: AppTypography.headlineSmall.copyWith(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  isHindi 
                      ? 'हम आपका मार्गदर्शन करेंगे और एक पूर्ण योजना बनाएंगे'
                      : 'We\'ll guide you through and create a complete plan',
                  style: AppTypography.bodyMedium.copyWith(color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          
          // Business grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.85,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: businesses.length,
              itemBuilder: (context, index) {
                final business = businesses[index];
                return _BusinessCard(
                  business: business,
                  isHindi: isHindi,
                  onTap: () async {
                    await HapticFeedback.lightImpact();
                    if (!context.mounted) return;
                    Navigator.of(context).push(
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            BusinessSetupWizard(businessId: business['id']),
                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                          return FadeTransition(opacity: animation, child: child);
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _BusinessCard extends StatelessWidget {
  final Map<String, dynamic> business;
  final bool isHindi;
  final VoidCallback onTap;

  const _BusinessCard({
    required this.business,
    required this.isHindi,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Center(
                child: Text(
                  business['icon'],
                  style: const TextStyle(fontSize: 32),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                isHindi ? business['name_hi'] : business['name'],
                style: AppTypography.titleMedium,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '₹${business['min_investment']} - ₹${business['max_investment']}',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.success,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.trending_up, size: 14, color: AppColors.success),
                const SizedBox(width: 4),
                Text(
                  '₹${business['daily_profit']}/${isHindi ? 'दिन' : 'day'}',
                  style: AppTypography.bodySmall.copyWith(fontSize: 11),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Business Setup Wizard - Multi-step form for business planning
class BusinessSetupWizard extends StatefulWidget {
  final int businessId;

  const BusinessSetupWizard({super.key, required this.businessId});

  @override
  State<BusinessSetupWizard> createState() => _BusinessSetupWizardState();
}

class _BusinessSetupWizardState extends State<BusinessSetupWizard> {
  int _currentStep = 0;
  final int _totalSteps = 5;

  // Step 1 - Location
  String? _selectedLocation;
  final List<String> _locationOptions = [
    'Village Road',
    'Town Market',
    'City Main Road',
    'Home-based',
  ];
  final List<String> _locationOptionsHi = [
    'गांव की सड़क',
    'कस्बे का बाजार',
    'शहर की मुख्य सड़क',
    'घर से',
  ];

  // Step 2 - Shop Size
  String _shopSize = 'Small (10x10)';
  final List<String> _shopSizeOptions = ['Small (10x10)', 'Medium (15x15)', 'Large (20x20)'];
  final List<String> _shopSizeOptionsHi = ['छोटा (10x10)', 'मध्यम (15x15)', 'बड़ा (20x20)'];

  // Step 3 - Ownership
  String? _ownershipType;
  final List<String> _ownershipOptions = ['Rent', 'Own', 'Lease'];
  final List<String> _ownershipOptionsHi = ['किराया', 'खुद का', 'लीज'];

  // Step 4 - Costs
  double _rentDeposit = 5000;
  double _furnitureCost = 10000;
  double _stockCost = 15000;
  double _licenseCost = 2000;

  // Step 5 - Funding
  String? _selectedLoan;
  final List<Map<String, String>> _loanOptions = [
    {'name': 'Mudra Loan', 'amount': '₹50,000 - ₹10 Lakh'},
    {'name': 'PM SVANidhi', 'amount': '₹10,000 - ₹50,000'},
    {'name': 'Self-Funded', 'amount': 'No loan needed'},
  ];

  Map<String, dynamic>? _businessTemplate;

  @override
  void initState() {
    super.initState();
    _businessTemplate = BusinessStorageHelper.getBusinessTemplate(widget.businessId);
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final isHindi = userProvider.language == 'hi';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_businessTemplate != null 
            ? (isHindi ? _businessTemplate!['name_hi'] : _businessTemplate!['name'])
            : (isHindi ? 'व्यापार सेटअप' : 'Business Setup')),
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Progress indicator
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isHindi ? 'चरण ${_currentStep + 1} / $_totalSteps' : 'Step ${_currentStep + 1} of $_totalSteps',
                      style: AppTypography.titleMedium,
                    ),
                    Text(
                      '${((_currentStep + 1) / _totalSteps * 100).toInt()}%',
                      style: AppTypography.titleMedium.copyWith(color: AppColors.primary),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: (_currentStep + 1) / _totalSteps,
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ),

          // Step content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: _buildCurrentStep(isHindi),
            ),
          ),

          // Navigation buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              children: [
                if (_currentStep > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setState(() => _currentStep--),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(isHindi ? '⬅️ पीछे' : '⬅️ Back'),
                    ),
                  ),
                if (_currentStep > 0) const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _canProceed() ? _handleNext : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      _currentStep == _totalSteps - 1
                          ? (isHindi ? '✅ योजना बनाएं' : '✅ Create Plan')
                          : (isHindi ? 'आगे ➡️' : 'Next ➡️'),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStep(bool isHindi) {
    switch (_currentStep) {
      case 0:
        return _buildLocationStep(isHindi);
      case 1:
        return _buildShopSizeStep(isHindi);
      case 2:
        return _buildOwnershipStep(isHindi);
      case 3:
        return _buildCostsStep(isHindi);
      case 4:
        return _buildFundingStep(isHindi);
      default:
        return const SizedBox();
    }
  }

  Widget _buildLocationStep(bool isHindi) {
    final options = isHindi ? _locationOptionsHi : _locationOptions;
    return _buildStepContainer(
      icon: '📍',
      title: isHindi ? 'अपना स्थान चुनें' : 'Choose Your Location',
      subtitle: isHindi ? 'व्यापार कहां होगा?' : 'Where will business be located?',
      child: Column(
        children: List.generate(options.length, (index) {
          final option = options[index];
          final isSelected = _selectedLocation == _locationOptions[index];
          return _buildOptionTile(
            title: option,
            isSelected: isSelected,
            onTap: () => setState(() => _selectedLocation = _locationOptions[index]),
          );
        }),
      ),
    );
  }

  Widget _buildShopSizeStep(bool isHindi) {
    final options = isHindi ? _shopSizeOptionsHi : _shopSizeOptions;
    return _buildStepContainer(
      icon: '📐',
      title: isHindi ? 'दुकान का आकार' : 'Shop Size',
      subtitle: isHindi ? 'आपको कितनी जगह चाहिए?' : 'How much space do you need?',
      child: Column(
        children: List.generate(options.length, (index) {
          final option = options[index];
          final isSelected = _shopSize == _shopSizeOptions[index];
          return _buildOptionTile(
            title: option,
            isSelected: isSelected,
            onTap: () => setState(() => _shopSize = _shopSizeOptions[index]),
          );
        }),
      ),
    );
  }

  Widget _buildOwnershipStep(bool isHindi) {
    final options = isHindi ? _ownershipOptionsHi : _ownershipOptions;
    return _buildStepContainer(
      icon: '🏠',
      title: isHindi ? 'स्वामित्व का प्रकार' : 'Ownership Type',
      subtitle: isHindi ? 'आप जगह कैसे लेंगे?' : 'How will you get the space?',
      child: Column(
        children: List.generate(options.length, (index) {
          final option = options[index];
          final isSelected = _ownershipType == _ownershipOptions[index];
          return _buildOptionTile(
            title: option,
            isSelected: isSelected,
            onTap: () => setState(() => _ownershipType = _ownershipOptions[index]),
          );
        }),
      ),
    );
  }

  Widget _buildCostsStep(bool isHindi) {
    return _buildStepContainer(
      icon: '💰',
      title: isHindi ? 'अनुमानित लागत' : 'Estimated Costs',
      subtitle: isHindi ? 'स्लाइडर से अपनी लागत सेट करें' : 'Set your costs using sliders',
      child: Column(
        children: [
          _buildCostSlider(
            label: isHindi ? 'किराया/जमा' : 'Rent/Deposit',
            value: _rentDeposit,
            min: 0,
            max: 50000,
            onChanged: (v) => setState(() => _rentDeposit = v),
          ),
          _buildCostSlider(
            label: isHindi ? 'फर्नीचर/सेटअप' : 'Furniture/Setup',
            value: _furnitureCost,
            min: 0,
            max: 50000,
            onChanged: (v) => setState(() => _furnitureCost = v),
          ),
          _buildCostSlider(
            label: isHindi ? 'प्रारंभिक स्टॉक' : 'Initial Stock',
            value: _stockCost,
            min: 0,
            max: 100000,
            onChanged: (v) => setState(() => _stockCost = v),
          ),
          _buildCostSlider(
            label: isHindi ? 'लाइसेंस/परमिट' : 'License/Permits',
            value: _licenseCost,
            min: 0,
            max: 10000,
            onChanged: (v) => setState(() => _licenseCost = v),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isHindi ? 'कुल अनुमानित लागत:' : 'Total Estimated Cost:',
                  style: AppTypography.titleMedium,
                ),
                Text(
                  '₹${(_rentDeposit + _furnitureCost + _stockCost + _licenseCost).toStringAsFixed(0)}',
                  style: AppTypography.headlineSmall.copyWith(color: AppColors.primary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCostSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: AppTypography.bodyMedium),
              Text('₹${value.toStringAsFixed(0)}', style: AppTypography.titleMedium),
            ],
          ),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: ((max - min) / 1000).toInt(),
            activeColor: AppColors.primary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildFundingStep(bool isHindi) {
    return _buildStepContainer(
      icon: '🏦',
      title: isHindi ? 'फंडिंग का स्रोत' : 'Funding Source',
      subtitle: isHindi ? 'आप पैसे कैसे जुटाएंगे?' : 'How will you fund your business?',
      child: Column(
        children: _loanOptions.map((loan) {
          final isSelected = _selectedLoan == loan['name'];
          return _buildOptionTile(
            title: loan['name']!,
            subtitle: loan['amount'],
            isSelected: isSelected,
            onTap: () => setState(() => _selectedLoan = loan['name']),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStepContainer({
    required String icon,
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Column(
            children: [
              Text(icon, style: const TextStyle(fontSize: 48)),
              const SizedBox(height: 12),
              Text(title, style: AppTypography.headlineSmall, textAlign: TextAlign.center),
              const SizedBox(height: 4),
              Text(subtitle, style: AppTypography.bodyMedium, textAlign: TextAlign.center),
            ],
          ),
        ),
        const SizedBox(height: 24),
        child,
      ],
    );
  }

  Widget _buildOptionTile({
    required String title,
    String? subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade200,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.titleMedium.copyWith(
                      color: isSelected ? AppColors.primary : AppColors.textPrimary,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(subtitle, style: AppTypography.bodySmall),
                  ],
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: AppColors.primary, size: 24),
          ],
        ),
      ),
    );
  }

  bool _canProceed() {
    switch (_currentStep) {
      case 0:
        return _selectedLocation != null;
      case 1:
        return _shopSize.isNotEmpty;
      case 2:
        return _ownershipType != null;
      case 3:
        return true; // Costs always have values
      case 4:
        return _selectedLoan != null;
      default:
        return false;
    }
  }

  void _handleNext() async {
    if (_currentStep < _totalSteps - 1) {
      setState(() => _currentStep++);
    } else {
      await _finishSetup();
    }
  }

  Future<void> _finishSetup() async {
    final totalStartup = _rentDeposit + _furnitureCost + _stockCost + _licenseCost;
    final estimatedProfit = totalStartup * 0.35;

    final plan = {
      'business_id': widget.businessId,
      'shop_size': _shopSize == 'Small (10x10)' ? 100.0 : (_shopSize == 'Medium (15x15)' ? 225.0 : 400.0),
      'rent_type': _ownershipType ?? 'Rent',
      'location_type': _selectedLocation ?? 'Village Road',
      'rent_deposit': _rentDeposit,
      'furniture_cost': _furnitureCost,
      'stock_cost': _stockCost,
      'license_cost': _licenseCost,
      'loan_option': _selectedLoan,
      'startup_cost': totalStartup,
      'expected_profit': estimatedProfit,
    };

    int newId = await BusinessStorageHelper.saveBusinessPlan(plan);

    final planWithId = Map<String, dynamic>.from(plan);
    planWithId['id'] = newId;

    if (_businessTemplate != null) {
      planWithId['season_rainy'] = _businessTemplate!['season_rainy'];
      planWithId['season_festival'] = _businessTemplate!['season_festival'];
      planWithId['season_wedding'] = _businessTemplate!['season_wedding'];
      planWithId['business_name'] = _businessTemplate!['name'];
      planWithId['business_name_hi'] = _businessTemplate!['name_hi'];
      planWithId['business_icon'] = _businessTemplate!['icon'];
    }

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => BusinessPlanResultScreen(businessPlan: planWithId),
      ),
    );
  }
}
