import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../providers/user_provider.dart';

/// Language Selection Screen with 12 Indian languages
class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> 
    with SingleTickerProviderStateMixin {
  String? _selectedLanguage;
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _selectLanguage(String code) {
    setState(() => _selectedLanguage = code);
  }

  void _continue() {
    if (_selectedLanguage == null) return;
    
    final userProvider = context.read<UserProvider>();
    userProvider.setLanguage(_selectedLanguage!);
    
    context.go('/profile-setup');
  }

  @override
  Widget build(BuildContext context) {
    final isHindi = _selectedLanguage == 'hi';
    
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                
                // Header with mascot
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text('🐻', style: TextStyle(fontSize: 40)),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Choose Your Language',
                        style: AppTypography.headlineMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'अपनी भाषा चुनें',
                        style: AppTypography.titleMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Language grid
                Expanded(
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 0.95,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: AppLanguages.all.length,
                    itemBuilder: (context, index) {
                      final lang = AppLanguages.all[index];
                      final isSelected = _selectedLanguage == lang['code'];
                      
                      return GestureDetector(
                        onTap: () => _selectLanguage(lang['code']!),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: isSelected 
                                ? AppColors.primary 
                                : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected 
                                  ? AppColors.primary 
                                  : Colors.grey.shade200,
                              width: 2,
                            ),
                            boxShadow: isSelected ? [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ] : null,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                lang['emoji']!,
                                style: const TextStyle(fontSize: 24),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                lang['native']!,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected 
                                      ? Colors.white 
                                      : AppColors.textPrimary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                lang['name']!,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isSelected 
                                      ? Colors.white70 
                                      : AppColors.textLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Continue button
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _selectedLanguage != null ? _continue : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey.shade300,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _selectedLanguage == 'hi' ? 'आगे बढ़ें' : 'Continue',
                          style: AppTypography.buttonText,
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward, size: 20),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Voice hint
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.volume_up, 
                         size: 16, 
                         color: AppColors.textLight),
                    const SizedBox(width: 8),
                    Text(
                      'Voice support available',
                      style: AppTypography.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
