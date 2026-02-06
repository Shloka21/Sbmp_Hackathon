/// Learning lesson model
class Lesson {
  final String id;
  final String categoryId;
  final String title;
  final String titleHi;
  final String description;
  final String descriptionHi;
  final List<LessonStep> steps;
  final int durationMinutes;
  final int xpReward;
  final String difficulty;
  final String icon;

  Lesson({
    required this.id,
    required this.categoryId,
    required this.title,
    required this.titleHi,
    required this.description,
    required this.descriptionHi,
    required this.steps,
    required this.durationMinutes,
    required this.xpReward,
    required this.difficulty,
    required this.icon,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) => Lesson(
    id: json['id'],
    categoryId: json['categoryId'],
    title: json['title'],
    titleHi: json['titleHi'],
    description: json['description'],
    descriptionHi: json['descriptionHi'],
    steps: (json['steps'] as List).map((s) => LessonStep.fromJson(s)).toList(),
    durationMinutes: json['durationMinutes'],
    xpReward: json['xpReward'],
    difficulty: json['difficulty'],
    icon: json['icon'],
  );
}

class LessonStep {
  final String type; // text, image, quiz, interactive
  final String content;
  final String contentHi;
  final Map<String, dynamic>? data;

  LessonStep({
    required this.type,
    required this.content,
    required this.contentHi,
    this.data,
  });

  factory LessonStep.fromJson(Map<String, dynamic> json) => LessonStep(
    type: json['type'],
    content: json['content'],
    contentHi: json['contentHi'],
    data: json['data'],
  );
}

/// Learning categories
class LearningCategory {
  static const List<Map<String, dynamic>> categories = [
    {
      'id': 'savings',
      'title': 'Savings',
      'titleHi': 'बचत',
      'icon': '💰',
      'color': 0xFF2ECC71,
      'description': 'Learn how to save money wisely',
      'descriptionHi': 'समझदारी से पैसे बचाना सीखें',
    },
    {
      'id': 'banking',
      'title': 'Banking',
      'titleHi': 'बैंकिंग',
      'icon': '🏦',
      'color': 0xFF3498DB,
      'description': 'Understand banks and accounts',
      'descriptionHi': 'बैंक और खातों को समझें',
    },
    {
      'id': 'credit',
      'title': 'Credit & Loans',
      'titleHi': 'लोन',
      'icon': '💳',
      'color': 0xFFE74C3C,
      'description': 'Learn about borrowing wisely',
      'descriptionHi': 'समझदारी से उधार लेना सीखें',
    },
    {
      'id': 'investment',
      'title': 'Investment',
      'titleHi': 'निवेश',
      'icon': '📈',
      'color': 0xFF9B59B6,
      'description': 'Grow your money over time',
      'descriptionHi': 'समय के साथ पैसे बढ़ाएं',
    },
    {
      'id': 'business',
      'title': 'Business Basics',
      'titleHi': 'व्यापार',
      'icon': '🏪',
      'color': 0xFFF1C40F,
      'description': 'Start and run a small business',
      'descriptionHi': 'छोटा व्यापार शुरू करें',
    },
    {
      'id': 'digital',
      'title': 'Digital Money',
      'titleHi': 'डिजिटल पैसा',
      'icon': '📱',
      'color': 0xFF1ABC9C,
      'description': 'UPI, wallets, and online payments',
      'descriptionHi': 'UPI, वॉलेट और ऑनलाइन भुगतान',
    },
  ];
}
