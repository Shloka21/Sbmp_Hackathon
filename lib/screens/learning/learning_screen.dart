import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../models/lesson.dart';
import '../../data/lesson_data.dart';
import '../../providers/user_provider.dart';

/// Learning Screen - Categories and lessons
class LearningScreen extends StatelessWidget {
  const LearningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final isHindi = userProvider.language == 'hi';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isHindi ? '📚 सीखें' : '📚 Learn'),
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          // Header
          Text(
            isHindi ? 'वित्तीय शिक्षा' : 'Financial Education',
            style: AppTypography.headlineLarge,
          ),
          const SizedBox(height: 8),
          Text(
            isHindi 
                ? 'छोटे-छोटे lessons से पैसों को समझें!' 
                : 'Learn about money through bite-sized lessons!',
            style: AppTypography.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.xl),
          
          // Categories
          ...LearningCategory.categories.map((category) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _CategoryCard(
                title: isHindi ? category['titleHi'] : category['title'],
                description: isHindi 
                    ? category['descriptionHi'] 
                    : category['description'],
                icon: category['icon'],
                color: Color(category['color']),
                onTap: () {
                  // Navigate to category lessons
                  _showCategoryLessons(context, category, isHindi);
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  void _showCategoryLessons(
    BuildContext context, 
    Map<String, dynamic> category,
    bool isHindi,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Color(category['color']).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(
                          category['icon'],
                          style: const TextStyle(fontSize: 28),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isHindi ? category['titleHi'] : category['title'],
                            style: AppTypography.headlineSmall,
                          ),
                          Text(
                            isHindi 
                                ? category['descriptionHi'] 
                                : category['description'],
                            style: AppTypography.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(),
              // Lessons list from LessonData
              Expanded(
                child: Builder(
                  builder: (context) {
                    final lessons = LessonData.getLessonsForCategory(category['id']);
                    final lessonIds = LessonData.getLessonIdsForCategory(category['id']);
                    final userProvider = context.watch<UserProvider>();
                    
                    return ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      itemCount: lessons.length,
                      itemBuilder: (context, index) {
                        final lesson = lessons[index];
                        final lessonId = lesson['id'] as String;
                        final isCompleted = userProvider.isLessonCompleted(lessonId);
                        final isUnlocked = userProvider.isLessonUnlocked(
                          category['id'], 
                          index, 
                          lessonIds,
                        );
                        
                        return _LessonCard(
                          lessonNumber: index + 1,
                          title: isHindi 
                              ? lesson['titleHi'] as String
                              : lesson['title'] as String,
                          icon: lesson['icon'] as String,
                          xp: lesson['xpReward'] as int,
                          isCompleted: isCompleted,
                          isLocked: !isUnlocked,
                          onTap: isUnlocked ? () {
                            HapticFeedback.lightImpact();
                            context.pop();
                            context.push('/lesson/$lessonId');
                          } : null,
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getSampleLessonTitle(String categoryId, int index, bool isHindi) {
    final titles = {
      'savings': isHindi 
          ? ['बचत क्या है?', 'रोज़ बचत कैसे करें', 'बचत के फायदे', 'बचत खाता खोलें', 'बचत लक्ष्य बनाएं']
          : ['What is Savings?', 'Daily Savings Tips', 'Benefits of Saving', 'Open a Savings Account', 'Set Savings Goals'],
      'banking': isHindi
          ? ['बैंक क्या है?', 'खाता कैसे खोलें', 'ATM कैसे use करें', 'Mobile Banking', 'सुरक्षित Banking']
          : ['What is a Bank?', 'How to Open Account', 'Using ATM', 'Mobile Banking', 'Safe Banking'],
      'credit': isHindi
          ? ['लोन क्या है?', 'Interest को समझें', 'अच्छा vs बुरा कर्ज', 'लोन कैसे लें', 'EMI Calculator']
          : ['What is a Loan?', 'Understanding Interest', 'Good vs Bad Debt', 'How to Get Loans', 'EMI Calculator'],
    };
    
    return titles[categoryId]?[index] ?? (isHindi ? 'पाठ ${index + 1}' : 'Lesson ${index + 1}');
  }

  String _getVideoTitle(String categoryId, bool isHindi) {
    final titles = {
      'savings': isHindi ? 'बचत खाता समझें' : 'Checking & Savings',
      'banking': isHindi ? 'बैंक खाता खोलें' : 'How to Open Account',
      'credit': isHindi ? 'लोन और क्रेडिट' : 'Loans & Credit',
      'investment': isHindi ? 'निवेश की शुरुआत' : 'Investment Basics',
      'business': isHindi ? 'व्यापार शुरू करें' : 'Start a Business',
      'digital': isHindi ? 'डिजिटल भुगतान' : 'Digital Payments',
    };
    return titles[categoryId] ?? (isHindi ? 'वीडियो पाठ' : 'Video Lesson');
  }
}

class _CategoryCard extends StatelessWidget {
  final String title;
  final String description;
  final String icon;
  final Color color;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(icon, style: const TextStyle(fontSize: 32)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTypography.titleLarge),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: AppTypography.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: color,
              size: 28,
            ),
          ],
        ),
      ),
    );
  }
}

class _LessonCard extends StatelessWidget {
  final int lessonNumber;
  final String title;
  final String icon;
  final int xp;
  final bool isCompleted;
  final bool isLocked;
  final VoidCallback? onTap;

  const _LessonCard({
    required this.lessonNumber,
    required this.title,
    required this.icon,
    required this.xp,
    required this.isCompleted,
    required this.isLocked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: isLocked ? 0.5 : 1.0,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isLocked ? Colors.grey.shade100 : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: isCompleted
                ? Border.all(color: AppColors.success, width: 2)
                : null,
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isLocked
                      ? Colors.grey.shade300
                      : isCompleted
                          ? AppColors.success
                          : AppColors.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: isLocked
                      ? Icon(Icons.lock, color: Colors.grey.shade600, size: 24)
                      : isCompleted
                          ? const Icon(Icons.check, color: Colors.white)
                          : Text(
                              icon,
                              style: const TextStyle(fontSize: 24),
                            ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.titleMedium.copyWith(
                        color: isLocked ? Colors.grey : null,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Text('⭐', style: TextStyle(fontSize: 12)),
                        Text(
                          ' $xp XP',
                          style: AppTypography.bodySmall.copyWith(
                            color: isLocked ? Colors.grey : null,
                          ),
                        ),
                        if (isCompleted) ...[
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.success.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '✓ Done',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.success,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                        if (isLocked) ...[
                          const SizedBox(width: 12),
                          Text(
                            '🔒 Complete previous',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                isLocked 
                    ? Icons.lock_outline
                    : isCompleted 
                        ? Icons.replay 
                        : Icons.play_circle_outline,
                color: isLocked ? Colors.grey : AppColors.primary,
                size: 32,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Video Lesson Card with distinct video styling
class _VideoLessonCard extends StatelessWidget {
  final String title;
  final String description;
  final int xp;
  final VoidCallback onTap;

  const _VideoLessonCard({
    required this.title,
    required this.description,
    required this.xp,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.primaryDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Video Icon
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Icon(
                    Icons.videocam,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 14,
                          color: Colors.white70,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          description,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text('⭐', style: TextStyle(fontSize: 12)),
                        Text(
                          ' $xp XP',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.play_circle_filled,
                color: Colors.white,
                size: 40,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
