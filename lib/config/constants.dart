/// App Constants - Configuration, Languages, Features

/// Supported Languages with native names and codes
class AppLanguages {
  static const List<Map<String, String>> all = [
    {'code': 'en', 'name': 'English', 'native': 'English', 'emoji': '🇬🇧'},
    {'code': 'hi', 'name': 'Hindi', 'native': 'हिंदी', 'emoji': '🇮🇳'},
    {'code': 'ta', 'name': 'Tamil', 'native': 'தமிழ்', 'emoji': '🏛️'},
    {'code': 'te', 'name': 'Telugu', 'native': 'తెలుగు', 'emoji': '🎭'},
    {'code': 'mr', 'name': 'Marathi', 'native': 'मराठी', 'emoji': '🏔️'},
    {'code': 'gu', 'name': 'Gujarati', 'native': 'ગુજરાતી', 'emoji': '🦁'},
    {'code': 'pa', 'name': 'Punjabi', 'native': 'ਪੰਜਾਬੀ', 'emoji': '🌾'},
    {'code': 'bn', 'name': 'Bengali', 'native': 'বাংলা', 'emoji': '🐅'},
    {'code': 'od', 'name': 'Odia', 'native': 'ଓଡ଼ିଆ', 'emoji': '🛕'},
    {'code': 'ml', 'name': 'Malayalam', 'native': 'മലയാളം', 'emoji': '🥥'},
    {'code': 'kn', 'name': 'Kannada', 'native': 'ಕನ್ನಡ', 'emoji': '🏯'},
    {'code': 'as', 'name': 'Assamese', 'native': 'অসমীয়া', 'emoji': '🦏'},
  ];
  
  static Map<String, String>? getByCode(String code) {
    try {
      return all.firstWhere((l) => l['code'] == code);
    } catch (_) {
      return all.first;
    }
  }
}

/// User occupation options
class AppOccupations {
  static List<Map<String, String>> getAll(bool isHindi) {
    return [
      {
        'id': 'farmer',
        'name': isHindi ? 'किसान' : 'Farmer',
        'emoji': '🌾',
      },
      {
        'id': 'daily_worker',
        'name': isHindi ? 'दैनिक मज़दूर' : 'Daily Worker',
        'emoji': '👷',
      },
      {
        'id': 'small_business',
        'name': isHindi ? 'छोटा व्यापारी' : 'Small Business',
        'emoji': '🏪',
      },
      {
        'id': 'homemaker',
        'name': isHindi ? 'गृहिणी' : 'Homemaker',
        'emoji': '🏠',
      },
      {
        'id': 'student',
        'name': isHindi ? 'छात्र' : 'Student',
        'emoji': '📚',
      },
      {
        'id': 'artisan',
        'name': isHindi ? 'कारीगर' : 'Artisan',
        'emoji': '🎨',
      },
      {
        'id': 'driver',
        'name': isHindi ? 'ड्राइवर' : 'Driver',
        'emoji': '🚗',
      },
      {
        'id': 'tailor',
        'name': isHindi ? 'दर्जी' : 'Tailor',
        'emoji': '🧵',
      },
      {
        'id': 'shopkeeper',
        'name': isHindi ? 'दुकानदार' : 'Shopkeeper',
        'emoji': '🛒',
      },
      {
        'id': 'teacher',
        'name': isHindi ? 'शिक्षक' : 'Teacher',
        'emoji': '👨‍🏫',
      },
      {
        'id': 'retired',
        'name': isHindi ? 'सेवानिवृत्त' : 'Retired',
        'emoji': '🧓',
      },
      {
        'id': 'other',
        'name': isHindi ? 'अन्य' : 'Other',
        'emoji': '👤',
      },
    ];
  }
}

/// Income ranges
class AppIncomeRanges {
  static List<Map<String, String>> getAll(bool isHindi) {
    return [
      {
        'id': 'below_5000',
        'name': isHindi ? '₹5,000 से कम' : 'Below ₹5,000',
        'emoji': '💵',
      },
      {
        'id': '5000_10000',
        'name': '₹5,000 - ₹10,000',
        'emoji': '💵',
      },
      {
        'id': '10000_20000',
        'name': '₹10,000 - ₹20,000',
        'emoji': '💰',
      },
      {
        'id': '20000_50000',
        'name': '₹20,000 - ₹50,000',
        'emoji': '💰',
      },
      {
        'id': 'above_50000',
        'name': isHindi ? '₹50,000 से अधिक' : 'Above ₹50,000',
        'emoji': '💎',
      },
      {
        'id': 'irregular',
        'name': isHindi ? 'अनियमित आय' : 'Irregular Income',
        'emoji': '📊',
      },
    ];
  }
}

/// Dashboard quick features
class DashboardFeatures {
  static List<Map<String, dynamic>> getAll(bool isHindi) {
    return [
      {
        'id': 'learn',
        'route': '/learning',
        'name': isHindi ? 'सीखें' : 'Learn',
        'emoji': '📚',
        'color': 0xFF2196F3,
        'description': isHindi ? 'वित्तीय ज्ञान' : 'Financial Knowledge',
      },
      {
        'id': 'save',
        'route': '/money',
        'name': isHindi ? 'बचाएं' : 'Save',
        'emoji': '💰',
        'color': 0xFF4CAF50,
        'description': isHindi ? 'पैसे बचाएं' : 'Save Money',
      },
      {
        'id': 'schemes',
        'route': '/schemes',
        'name': isHindi ? 'योजनाएं' : 'Schemes',
        'emoji': '🏛️',
        'color': 0xFF9C27B0,
        'description': isHindi ? 'सरकारी मदद' : 'Govt Help',
      },
      {
        'id': 'business',
        'route': '/business',
        'name': isHindi ? 'व्यापार' : 'Business',
        'emoji': '🚀',
        'color': 0xFFFF9800,
        'description': isHindi ? 'व्यापार शुरू करें' : 'Start Business',
      },
      {
        'id': 'sathi',
        'route': '/ai-chat',
        'name': isHindi ? 'साथी से पूछें' : 'Ask Sathi',
        'emoji': '🐻',
        'color': 0xFF1A8D4F,
        'description': isHindi ? 'AI मदद' : 'AI Help',
      },
      {
        'id': 'news',
        'route': '/news',
        'name': isHindi ? 'समाचार' : 'News',
        'emoji': '📰',
        'color': 0xFF607D8B,
        'description': isHindi ? 'वित्तीय खबरें' : 'Financial News',
      },
    ];
  }
}

/// Scheme categories for filtering
class SchemeCategories {
  static List<Map<String, dynamic>> getAll(bool isHindi) {
    return [
      {
        'id': 'all',
        'name': isHindi ? 'सभी' : 'All',
        'emoji': '📋',
      },
      {
        'id': 'farmer',
        'name': isHindi ? 'किसान' : 'Farmer',
        'emoji': '🌾',
      },
      {
        'id': 'women',
        'name': isHindi ? 'महिला' : 'Women',
        'emoji': '👩',
      },
      {
        'id': 'student',
        'name': isHindi ? 'छात्र' : 'Student',
        'emoji': '🎓',
      },
      {
        'id': 'business',
        'name': isHindi ? 'व्यापारी' : 'Business',
        'emoji': '💼',
      },
      {
        'id': 'senior',
        'name': isHindi ? 'वरिष्ठ नागरिक' : 'Senior',
        'emoji': '🧓',
      },
      {
        'id': 'worker',
        'name': isHindi ? 'कर्मचारी' : 'Worker',
        'emoji': '👷',
      },
    ];
  }
}

/// Money Map visual icons
class MoneyMapIcons {
  static const String savings = '🌾'; // Grain sack for savings
  static const String assets = '🚜'; // Tractor for assets
  static const String income = '💵'; // Cash for income
  static const String expense = '🛒'; // Shopping for expenses
  static const String investment = '📈'; // Growth for investments
  static const String loan = '🏦'; // Bank for loans
  static const String emergency = '🛡️'; // Shield for emergency fund
  static const String goal = '🎯'; // Target for goals
}

/// Daily tips database
class DailyTips {
  static List<String> getAll(bool isHindi) {
    if (isHindi) {
      return [
        '💡 हर महीने कमाई का 20% बचाएं!',
        '💡 इमरजेंसी फंड में 3 महीने का खर्च रखें',
        '💡 बड़ी खरीदारी से पहले 24 घंटे सोचें',
        '💡 ऊंचे ब्याज वाले कर्ज पहले चुकाएं',
        '💡 हर खर्च को लिखकर ट्रैक करें',
        '💡 सरकारी योजनाओं का फायदा उठाएं',
        '💡 बच्चों को पैसों का महत्व सिखाएं',
        '💡 जीरो बिल का लक्ष्य रखें',
        '💡 खर्च करने से पहले बचत करें',
        '💡 छोटी बचत बड़ी बन जाती है!',
      ];
    }
    return [
      '💡 Save at least 20% of your income every month!',
      '💡 Keep 3 months\' expenses in emergency fund',
      '💡 Wait 24 hours before big purchases',
      '💡 Pay off high-interest debts first',
      '💡 Track every expense by writing it down',
      '💡 Make use of government schemes',
      '💡 Teach children the value of money',
      '💡 Aim for zero unnecessary bills',
      '💡 Save first, spend later',
      '💡 Small savings add up to big amounts!',
    ];
  }
  
  static String getToday(bool isHindi) {
    final tips = getAll(isHindi);
    return tips[DateTime.now().day % tips.length];
  }
}
