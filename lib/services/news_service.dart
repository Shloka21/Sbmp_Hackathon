import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// News Service - Financial news from NewsData.io API
class NewsService {
  static const String _apiKey = 'pub_63848f14fb72a4f59827b41405b23b9a3';
  static const String _baseUrl = 'https://newsdata.io/api/1/news';

  /// Fetch live financial news from API
  static Future<List<NewsItem>> fetchNews(String language) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl?apikey=$_apiKey&country=in&category=business&language=${language == 'hi' ? 'hi' : 'en'}'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List? ?? [];
        
        return results.take(10).map((item) {
          return NewsItem(
            id: item['article_id'] ?? '',
            title: item['title'] ?? '',
            summary: item['description'] ?? item['content'] ?? '',
            category: 'business',
            imageUrl: item['image_url'],
            imageEmoji: _getCategoryEmoji(item['category'] as List?),
            date: DateTime.tryParse(item['pubDate'] ?? '') ?? DateTime.now(),
            isImportant: false,
            sourceUrl: item['link'],
          );
        }).toList();
      }
    } catch (e) {
      debugPrint('News API error: $e');
    }
    
    // Return mock data if API fails
    return getMockNews(language);
  }

  static String _getCategoryEmoji(List? categories) {
    if (categories == null || categories.isEmpty) return '📰';
    final cat = categories.first.toString().toLowerCase();
    if (cat.contains('business')) return '💼';
    if (cat.contains('economy')) return '📈';
    if (cat.contains('politics')) return '🏛️';
    if (cat.contains('technology')) return '💻';
    return '📰';
  }

  /// Get news synchronously (uses mock data)
  static List<NewsItem> getNews(String language) {
    return getMockNews(language);
  }

  /// Get mock financial news (fallback)
  static List<NewsItem> getMockNews(String language) {
    final isHindi = language == 'hi';
    
    return [
      NewsItem(
        id: '1',
        title: isHindi ? 'पीएम किसान की 16वीं किस्त जल्द' : 'PM-KISAN 16th Installment Coming Soon',
        summary: isHindi 
            ? 'सरकार जल्द ही किसानों के खातों में ₹2,000 भेजेगी'
            : 'Government to transfer ₹2,000 to farmers\' accounts soon',
        category: 'schemes',
        imageEmoji: '🌾',
        date: DateTime.now().subtract(const Duration(hours: 2)),
        isImportant: true,
      ),
      NewsItem(
        id: '2',
        title: isHindi ? 'जन धन खातों पर मिलेगा ₹10,000 ओवरड्राफ्ट' : 'Jan Dhan Accounts to Get ₹10,000 Overdraft',
        summary: isHindi 
            ? 'जीरो बैलेंस खातों पर भी मिलेगी यह सुविधा'
            : 'Zero balance accounts will also get this facility',
        category: 'banking',
        imageEmoji: '🏦',
        date: DateTime.now().subtract(const Duration(hours: 5)),
        isImportant: false,
      ),
      NewsItem(
        id: '3',
        title: isHindi ? 'सोने की कीमतों में गिरावट' : 'Gold Prices Drop',
        summary: isHindi 
            ? 'आज सोना ₹500 प्रति 10 ग्राम सस्ता हुआ'
            : 'Gold became cheaper by ₹500 per 10 grams today',
        category: 'market',
        imageEmoji: '💰',
        date: DateTime.now().subtract(const Duration(hours: 8)),
        isImportant: false,
      ),
      NewsItem(
        id: '4',
        title: isHindi ? 'मुद्रा लोन की सीमा बढ़ी' : 'Mudra Loan Limit Increased',
        summary: isHindi 
            ? 'अब ₹20 लाख तक का लोन बिना गारंटी के मिलेगा'
            : 'Now get up to ₹20 lakh loan without guarantee',
        category: 'schemes',
        imageEmoji: '💼',
        date: DateTime.now().subtract(const Duration(days: 1)),
        isImportant: true,
      ),
      NewsItem(
        id: '5',
        title: isHindi ? 'बचत खाते पर SBI का ब्याज बढ़ा' : 'SBI Increases Savings Account Interest',
        summary: isHindi 
            ? 'अब 2.75% से बढ़कर 3% ब्याज मिलेगा'
            : 'Interest rate increased from 2.75% to 3%',
        category: 'banking',
        imageEmoji: '📈',
        date: DateTime.now().subtract(const Duration(days: 1)),
        isImportant: false,
      ),
      NewsItem(
        id: '6',
        title: isHindi ? 'महिलाओं के लिए नई स्कीम' : 'New Scheme for Women',
        summary: isHindi 
            ? 'लखपति दीदी योजना में मिलेगी ₹1 लाख की मदद'
            : 'Lakhpati Didi scheme offers ₹1 lakh assistance',
        category: 'schemes',
        imageEmoji: '👩',
        date: DateTime.now().subtract(const Duration(days: 2)),
        isImportant: true,
      ),
    ];
  }

  /// Get news by category
  static List<NewsItem> getNewsByCategory(String category, String language) {
    return getMockNews(language).where((n) => n.category == category).toList();
  }

  /// Get important news
  static List<NewsItem> getImportantNews(String language) {
    return getMockNews(language).where((n) => n.isImportant).toList();
  }
}

class NewsItem {
  final String id;
  final String title;
  final String summary;
  final String category;
  final String? imageUrl;
  final String imageEmoji;
  final DateTime date;
  final bool isImportant;
  final String? sourceUrl;

  NewsItem({
    required this.id,
    required this.title,
    required this.summary,
    required this.category,
    this.imageUrl,
    required this.imageEmoji,
    required this.date,
    this.isImportant = false,
    this.sourceUrl,
  });

  String getTimeAgo(bool isHindi) {
    final diff = DateTime.now().difference(date);
    if (diff.inHours < 1) {
      return isHindi ? 'अभी' : 'Just now';
    } else if (diff.inHours < 24) {
      return isHindi ? '${diff.inHours} घंटे पहले' : '${diff.inHours}h ago';
    } else {
      return isHindi ? '${diff.inDays} दिन पहले' : '${diff.inDays}d ago';
    }
  }
}
