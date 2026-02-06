import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../models/user.dart';
import '../../providers/user_provider.dart';
import '../../widgets/common/widgets.dart';

/// Profile Setup Screen
class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _nameController = TextEditingController();
  String? _selectedOccupation;
  String? _selectedIncome;
  int _currentStep = 0;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _completeSetup() async {
    if (_nameController.text.isEmpty ||
        _selectedOccupation == null ||
        _selectedIncome == null) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final userProvider = context.read<UserProvider>();
    
    final user = UserProfile(
      id: const Uuid().v4(),
      name: _nameController.text.trim(),
      language: userProvider.language,
      occupation: _selectedOccupation!,
      incomeRange: _selectedIncome!,
      createdAt: DateTime.now(),
    );

    await userProvider.saveUser(user);
    await userProvider.completeOnboarding();

    if (mounted) {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final isHindi = userProvider.language == 'hi';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      if (_currentStep > 0) {
                        setState(() => _currentStep--);
                      } else {
                        context.go('/language');
                      }
                    },
                    icon: const Icon(Icons.arrow_back),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (index) {
                        return Container(
                          width: 60,
                          height: 6,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: index <= _currentStep
                                ? AppColors.primary
                                : AppColors.primary.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _buildCurrentStep(isHindi),
                ),
              ),
            ),
            
            // Bottom button
            Padding(
              padding: const EdgeInsets.all(20),
              child: PrimaryButton(
                text: _currentStep < 2 
                    ? (isHindi ? 'आगे बढ़ें' : 'Continue')
                    : (isHindi ? 'शुरू करें!' : 'Get Started!'),
                isLoading: _isLoading,
                onPressed: _canProceed() ? _onContinue : () {},
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStep(bool isHindi) {
    switch (_currentStep) {
      case 0:
        return _buildNameStep(isHindi);
      case 1:
        return _buildOccupationStep(isHindi);
      case 2:
        return _buildIncomeStep(isHindi);
      default:
        return const SizedBox();
    }
  }

  Widget _buildNameStep(bool isHindi) {
    return Column(
      key: const ValueKey('name'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Center(
          child: Text('👋', style: TextStyle(fontSize: 80)),
        ),
        const SizedBox(height: 32),
        Text(
          isHindi ? 'आपका नाम क्या है?' : 'What\'s your name?',
          style: AppTypography.headlineLarge,
        ),
        const SizedBox(height: 8),
        Text(
          isHindi ? 'हम आपको इसी नाम से बुलाएंगे' : 'We\'ll call you by this name',
          style: AppTypography.bodyMedium,
        ),
        const SizedBox(height: 32),
        TextField(
          controller: _nameController,
          textCapitalization: TextCapitalization.words,
          style: AppTypography.titleLarge,
          decoration: InputDecoration(
            hintText: isHindi ? 'अपना नाम लिखें' : 'Enter your name',
            prefixIcon: const Icon(Icons.person_outline),
          ),
          onChanged: (value) => setState(() {}),
        ),
      ],
    );
  }

  Widget _buildOccupationStep(bool isHindi) {
    final occupations = AppOccupations.getAll(isHindi);
    
    return Column(
      key: const ValueKey('occupation'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Center(
          child: Text('💼', style: TextStyle(fontSize: 80)),
        ),
        const SizedBox(height: 32),
        Text(
          isHindi ? 'आप क्या काम करते हैं?' : 'What do you do?',
          style: AppTypography.headlineLarge,
        ),
        const SizedBox(height: 8),
        Text(
          isHindi 
              ? 'इससे हम आपके लिए सही सुझाव दे पाएंगे' 
              : 'This helps us give you relevant advice',
          style: AppTypography.bodyMedium,
        ),
        const SizedBox(height: 32),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: occupations.map((occ) {
            final isSelected = _selectedOccupation == occ['id'];
            return GestureDetector(
              onTap: () => setState(() => _selectedOccupation = occ['id']),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : Colors.grey.shade300,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(occ['emoji']!, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 8),
                    Text(
                      occ['name']!,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildIncomeStep(bool isHindi) {
    final incomeRanges = AppIncomeRanges.getAll(isHindi);
    
    return Column(
      key: const ValueKey('income'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Center(
          child: Text('💰', style: TextStyle(fontSize: 80)),
        ),
        const SizedBox(height: 32),
        Text(
          isHindi ? 'आपकी मासिक आय कितनी है?' : 'What\'s your monthly income?',
          style: AppTypography.headlineLarge,
        ),
        const SizedBox(height: 8),
        Text(
          isHindi 
              ? 'यह जानकारी सुरक्षित रहेगी' 
              : 'Your information stays private',
          style: AppTypography.bodyMedium,
        ),
        const SizedBox(height: 32),
        ...incomeRanges.map((income) {
          final isSelected = _selectedIncome == income['id'];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GestureDetector(
              onTap: () => setState(() => _selectedIncome = income['id']),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : Colors.grey.shade300,
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    Text(income['emoji']!, style: const TextStyle(fontSize: 24)),
                    const SizedBox(width: 12),
                    Text(
                      income['name']!,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    if (isSelected)
                      const Icon(
                        Icons.check_circle,
                        color: Colors.white,
                      ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  bool _canProceed() {
    switch (_currentStep) {
      case 0:
        return _nameController.text.trim().isNotEmpty;
      case 1:
        return _selectedOccupation != null;
      case 2:
        return _selectedIncome != null;
      default:
        return false;
    }
  }

  void _onContinue() {
    if (_currentStep < 2) {
      setState(() => _currentStep++);
    } else {
      _completeSetup();
    }
  }
}
