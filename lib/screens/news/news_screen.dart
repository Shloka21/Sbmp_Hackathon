import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../services/news_service.dart';
import '../../providers/user_provider.dart';

/// News Screen - Financial news and tips
class NewsScreen extends StatelessWidget {
  const NewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final isHindi = userProvider.language == 'hi';
    final news = NewsService.getNews(userProvider.language);
    final importantNews = news.where((n) => n.isImportant).toList();
    final otherNews = news.where((n) => !n.isImportant).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isHindi ? 'वित्तीय समाचार' : 'Financial News'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Important news section
          if (importantNews.isNotEmpty) ...[
            Text(
              isHindi ? '⚡ महत्वपूर्ण खबरें' : '⚡ Important News',
              style: AppTypography.headlineSmall,
            ),
            const SizedBox(height: 12),
            ...importantNews.map((item) => _buildImportantNewsCard(item, isHindi)),
            const SizedBox(height: 24),
          ],

          // Latest news section
          Text(
            isHindi ? '📰 ताज़ा खबरें' : '📰 Latest News',
            style: AppTypography.headlineSmall,
          ),
          const SizedBox(height: 12),
          ...otherNews.map((item) => _buildNewsCard(item, isHindi)),
          
          const SizedBox(height: 24),
          
          // Disclaimer
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.textLight, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isHindi 
                        ? 'यह शैक्षिक उद्देश्यों के लिए है। निवेश से पहले विशेषज्ञ से सलाह लें।'
                        : 'This is for educational purposes. Consult an expert before investing.',
                    style: AppTypography.bodySmall,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImportantNewsCard(NewsItem item, bool isHindi) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primaryDark,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(item.imageEmoji, style: const TextStyle(fontSize: 36)),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isHindi ? 'महत्वपूर्ण' : 'Important',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              item.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              item.summary,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              item.getTimeAgo(isHindi),
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewsCard(NewsItem item, bool isHindi) {
    return Container(
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
              color: AppColors.background,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(item.imageEmoji, style: const TextStyle(fontSize: 28)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: AppTypography.titleMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  item.summary,
                  style: AppTypography.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _getCategoryName(item.category, isHindi),
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      item.getTimeAgo(isHindi),
                      style: AppTypography.bodySmall.copyWith(fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getCategoryName(String category, bool isHindi) {
    final categories = {
      'schemes': isHindi ? 'योजनाएं' : 'Schemes',
      'banking': isHindi ? 'बैंकिंग' : 'Banking',
      'market': isHindi ? 'बाज़ार' : 'Market',
    };
    return categories[category] ?? category;
  }
}
