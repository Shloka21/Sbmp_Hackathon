import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../config/gamification.dart';
import '../../models/scheme.dart';
import '../../providers/user_provider.dart';

/// Government Schemes Screen with filters and eligibility checker
class SchemesScreen extends StatefulWidget {
  const SchemesScreen({super.key});

  @override
  State<SchemesScreen> createState() => _SchemesScreenState();
}

class _SchemesScreenState extends State<SchemesScreen> {
  String _selectedCategory = 'all';

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final isHindi = userProvider.language == 'hi';
    final categories = SchemeCategories.getAll(isHindi);
    final schemes = GovernmentSchemes.getByCategory(_selectedCategory);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isHindi ? 'सरकारी योजनाएं' : 'Government Schemes'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.check_circle_outline),
            onPressed: () => _showEligibilityChecker(context, isHindi),
            tooltip: isHindi ? 'पात्रता जांचें' : 'Check Eligibility',
          ),
        ],
      ),
      body: Column(
        children: [
          // Category filter
          Container(
            color: AppColors.primary,
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
            child: SizedBox(
              height: 44,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  final isSelected = _selectedCategory == cat['id'];
                  
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(cat['emoji']!, style: const TextStyle(fontSize: 14)),
                          const SizedBox(width: 4),
                          Text(cat['name']!),
                        ],
                      ),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() => _selectedCategory = cat['id']!);
                      },
                      selectedColor: Colors.white,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      labelStyle: TextStyle(
                        color: isSelected ? AppColors.primary : Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Personalized recommendation banner
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Text('👤', style: TextStyle(fontSize: 32)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isHindi ? 'आपके लिए योजनाएं' : 'Schemes for You',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        isHindi 
                            ? 'अपनी पात्रता जांचें और आवेदन करें'
                            : 'Check eligibility and apply',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _showEligibilityChecker(context, isHindi),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: Text(isHindi ? 'जांचें' : 'Check'),
                ),
              ],
            ),
          ),

          // Schemes list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: schemes.length,
              itemBuilder: (context, index) {
                final scheme = schemes[index];
                return _buildSchemeCard(scheme, isHindi);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSchemeCard(Scheme scheme, bool isHindi) {
    return GestureDetector(
      onTap: () => _showSchemeDetails(context, scheme, isHindi),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(scheme.emoji, style: const TextStyle(fontSize: 28)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isHindi ? scheme.nameHi : scheme.name,
                    style: AppTypography.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isHindi ? scheme.descriptionHi : scheme.description,
                    style: AppTypography.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      _buildBadge(
                        isHindi ? scheme.benefitsHi.first : scheme.benefits.first,
                        Icons.check_circle,
                        AppColors.success,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppColors.textLight,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text.length > 25 ? '${text.substring(0, 25)}...' : text,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showSchemeDetails(BuildContext context, Scheme scheme, bool isHindi) {
    final userProvider = context.read<UserProvider>();
    userProvider.addXP(XPRewards.viewScheme);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                
                // Content
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(20),
                    children: [
                      // Header
                      Row(
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Center(
                              child: Text(scheme.emoji, style: const TextStyle(fontSize: 32)),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isHindi ? scheme.nameHi : scheme.name,
                                  style: AppTypography.headlineSmall,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  isHindi ? scheme.descriptionHi : scheme.description,
                                  style: AppTypography.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Benefits
                      _buildSection(
                        isHindi ? '✅ लाभ' : '✅ Benefits',
                        isHindi ? scheme.benefitsHi : scheme.benefits,
                      ),
                      
                      // Eligibility
                      _buildSection(
                        isHindi ? '📋 पात्रता' : '📋 Eligibility',
                        isHindi ? scheme.eligibilityHi : scheme.eligibility,
                      ),
                      
                      // Documents
                      _buildSection(
                        isHindi ? '📎 आवश्यक दस्तावेज़' : '📎 Required Documents',
                        isHindi ? scheme.documentsHi : scheme.documents,
                        isChecklist: true,
                      ),
                      
                      // How to Apply
                      _buildSection(
                        isHindi ? '🚀 कैसे आवेदन करें' : '🚀 How to Apply',
                        isHindi ? scheme.howToApplyHi : scheme.howToApply,
                        isNumbered: true,
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Apply button
                      SizedBox(
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  isHindi 
                                      ? 'नज़दीकी CSC केंद्र में आवेदन करें'
                                      : 'Apply at nearest CSC center'
                                ),
                                backgroundColor: AppColors.primary,
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            isHindi ? 'आवेदन करें' : 'Apply Now',
                            style: AppTypography.buttonText,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSection(String title, List<String> items, {bool isChecklist = false, bool isNumbered = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTypography.titleLarge),
        const SizedBox(height: 12),
        ...items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isChecklist)
                  Container(
                    width: 20,
                    height: 20,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.primary),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  )
                else if (isNumbered)
                  Container(
                    width: 24,
                    height: 24,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.only(right: 8, top: 6),
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                Expanded(
                  child: Text(item, style: AppTypography.bodyMedium),
                ),
              ],
            ),
          );
        }).toList(),
        const SizedBox(height: 16),
      ],
    );
  }

  void _showEligibilityChecker(BuildContext context, bool isHindi) {
    final userProvider = context.read<UserProvider>();
    userProvider.addXP(XPRewards.completeEligibility);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    isHindi ? '🔍 पात्रता जांचें' : '🔍 Check Eligibility',
                    style: AppTypography.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isHindi 
                        ? 'अपने बारे में बताएं और पात्र योजनाएं देखें'
                        : 'Tell us about yourself to see eligible schemes',
                    style: AppTypography.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _buildEligibilityOption(
                    '🌾',
                    isHindi ? 'मैं किसान हूं' : 'I am a Farmer',
                    () => _showMatchedSchemes(context, 'farmer', isHindi),
                  ),
                  _buildEligibilityOption(
                    '👩',
                    isHindi ? 'मैं महिला हूं' : 'I am a Woman',
                    () => _showMatchedSchemes(context, 'women', isHindi),
                  ),
                  _buildEligibilityOption(
                    '🎓',
                    isHindi ? 'मैं छात्र हूं' : 'I am a Student',
                    () => _showMatchedSchemes(context, 'student', isHindi),
                  ),
                  _buildEligibilityOption(
                    '👷',
                    isHindi ? 'मैं दैनिक कर्मचारी हूं' : 'I am a Daily Worker',
                    () => _showMatchedSchemes(context, 'worker', isHindi),
                  ),
                  _buildEligibilityOption(
                    '💼',
                    isHindi ? 'मैं व्यापार करना चाहता हूं' : 'I want to start Business',
                    () => _showMatchedSchemes(context, 'business', isHindi),
                  ),
                  _buildEligibilityOption(
                    '🏠',
                    isHindi ? 'मुझे घर बनाना है' : 'I need Housing',
                    () => _showMatchedSchemes(context, 'all', isHindi),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEligibilityOption(String emoji, String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 16),
            Expanded(
              child: Text(text, style: AppTypography.titleMedium),
            ),
            Icon(Icons.chevron_right, color: AppColors.textLight),
          ],
        ),
      ),
    );
  }

  void _showMatchedSchemes(BuildContext context, String category, bool isHindi) {
    Navigator.pop(context);
    setState(() => _selectedCategory = category);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isHindi 
              ? 'आपके लिए ${GovernmentSchemes.getByCategory(category).length} योजनाएं मिलीं!'
              : 'Found ${GovernmentSchemes.getByCategory(category).length} schemes for you!'
        ),
        backgroundColor: AppColors.success,
      ),
    );
  }
}
