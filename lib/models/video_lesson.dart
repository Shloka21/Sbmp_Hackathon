/// Video Lesson Model with Multilingual Audio Support
class VideoLesson {
  final String id;
  final String categoryId;
  final String videoPath;
  final Map<String, String> audioTracks; // language code -> audio path
  final Map<String, String> subtitles;   // language code -> srt path
  final Map<String, String> titles;      // language code -> title
  final Map<String, String> descriptions;
  final int durationSeconds;
  final int xpReward;
  final String thumbnail;

  const VideoLesson({
    required this.id,
    required this.categoryId,
    required this.videoPath,
    required this.audioTracks,
    required this.subtitles,
    required this.titles,
    required this.descriptions,
    required this.durationSeconds,
    required this.xpReward,
    required this.thumbnail,
  });

  /// Get title for language
  String getTitle(String langCode) => titles[langCode] ?? titles['en'] ?? '';

  /// Get description for language
  String getDescription(String langCode) => descriptions[langCode] ?? descriptions['en'] ?? '';

  /// Get audio track for language (returns null if not available)
  String? getAudioTrack(String langCode) => audioTracks[langCode];

  /// Get subtitles for language
  String? getSubtitles(String langCode) => subtitles[langCode];

  /// Check if language is supported
  bool supportsLanguage(String langCode) => audioTracks.containsKey(langCode);

  factory VideoLesson.fromJson(Map<String, dynamic> json) => VideoLesson(
        id: json['id'],
        categoryId: json['categoryId'],
        videoPath: json['videoPath'],
        audioTracks: Map<String, String>.from(json['audioTracks'] ?? {}),
        subtitles: Map<String, String>.from(json['subtitles'] ?? {}),
        titles: Map<String, String>.from(json['titles'] ?? {}),
        descriptions: Map<String, String>.from(json['descriptions'] ?? {}),
        durationSeconds: json['durationSeconds'] ?? 0,
        xpReward: json['xpReward'] ?? 10,
        thumbnail: json['thumbnail'] ?? '',
      );
}

/// Supported Indian Languages (6 languages)
class SupportedLanguages {
  static const Map<String, String> all = {
    'en': 'English',
    'hi': 'हिंदी',
    'mr': 'मराठी',
    'te': 'తెలుగు',
    'kn': 'ಕನ್ನಡ',
    'bn': 'বাংলা',
  };

  /// Get language name
  static String getName(String code) => all[code] ?? code;

  /// Get TTS voice name for Edge-TTS
  static String getTTSVoice(String code) {
    const voices = {
      'en': 'en-IN-NeerjaNeural',
      'hi': 'hi-IN-SwaraNeural',
      'mr': 'mr-IN-AarohiNeural',
      'te': 'te-IN-ShrutiNeural',
      'kn': 'kn-IN-SapnaNeural',
      'bn': 'bn-IN-TanishaaNeural',
    };
    return voices[code] ?? voices['hi']!;
  }
}

/// Video lessons data for all 6 categories with dubbed audio
class VideoLessonsData {
  static const List<Map<String, dynamic>> lessons = [
    // SAVINGS
    {
      'id': 'savings_intro',
      'categoryId': 'savings',
      'videoPath': 'assets/lessons/savings/savings_intro.mp4',
      'audioTracks': {
        'en': 'assets/lessons/savings/intro_en.mp3',
        'hi': 'assets/lessons/savings/intro_hi.mp3',
        'mr': 'assets/lessons/savings/intro_mr.mp3',
        'te': 'assets/lessons/savings/intro_te.mp3',
        'kn': 'assets/lessons/savings/intro_kn.mp3',
        'bn': 'assets/lessons/savings/intro_bn.mp3',
      },
      'subtitles': <String, String>{},
      'titles': {
        'en': 'Checking & Savings Explained',
        'hi': 'चेकिंग और बचत खाते',
        'mr': 'चेकिंग आणि बचत खाती',
        'te': 'చెకింగ్ మరియు సేవింగ్స్',
        'kn': 'ಚೆಕಿಂಗ್ ಮತ್ತು ಉಳಿತಾಯ',
        'bn': 'চেকিং ও সেভিংস',
      },
      'descriptions': {
        'en': 'Learn about checking and savings accounts',
        'hi': 'चेकिंग और बचत खातों के बारे में जानें',
      },
      'durationSeconds': 45,
      'xpReward': 50,
      'thumbnail': '',
    },
    // BANKING
    {
      'id': 'banking_intro',
      'categoryId': 'banking',
      'videoPath': 'assets/lessons/banking/banking_intro.mp4',
      'audioTracks': {
        'en': 'assets/lessons/banking/intro_en.mp3',
        'hi': 'assets/lessons/banking/intro_hi.mp3',
        'mr': 'assets/lessons/banking/intro_mr.mp3',
        'te': 'assets/lessons/banking/intro_te.mp3',
        'kn': 'assets/lessons/banking/intro_kn.mp3',
        'bn': 'assets/lessons/banking/intro_bn.mp3',
      },
      'subtitles': <String, String>{},
      'titles': {
        'en': 'How to Open a Bank Account',
        'hi': 'बैंक खाता कैसे खोलें',
        'mr': 'बँक खाते कसे उघडावे',
        'te': 'బ్యాంక్ ఖాతా ఎలా తెరవాలి',
        'kn': 'ಬ್ಯಾಂಕ್ ಖಾತೆ ತೆರೆಯುವುದು',
        'bn': 'ব্যাংক অ্যাকাউন্ট খোলা',
      },
      'descriptions': {
        'en': 'Step by step guide to opening your first bank account',
        'hi': 'अपना पहला बैंक खाता खोलने की पूरी जानकारी',
      },
      'durationSeconds': 50,
      'xpReward': 50,
      'thumbnail': '',
    },
    // CREDIT
    {
      'id': 'credit_intro',
      'categoryId': 'credit',
      'videoPath': 'assets/lessons/credit/credit_intro.mp4',
      'audioTracks': {
        'en': 'assets/lessons/credit/intro_en.mp3',
        'hi': 'assets/lessons/credit/intro_hi.mp3',
        'mr': 'assets/lessons/credit/intro_mr.mp3',
        'te': 'assets/lessons/credit/intro_te.mp3',
        'kn': 'assets/lessons/credit/intro_kn.mp3',
        'bn': 'assets/lessons/credit/intro_bn.mp3',
      },
      'subtitles': <String, String>{},
      'titles': {
        'en': 'Understanding Loans & Credit',
        'hi': 'लोन और क्रेडिट समझें',
        'mr': 'कर्ज आणि क्रेडिट समजून घ्या',
        'te': 'రుణాలు మరియు క్రెడిట్',
        'kn': 'ಸಾಲ ಮತ್ತು ಕ್ರೆಡಿಟ್',
        'bn': 'ঋণ ও ক্রেডিট',
      },
      'descriptions': {
        'en': 'Learn how loans and credit work',
        'hi': 'जानें कि लोन और क्रेडिट कैसे काम करते हैं',
      },
      'durationSeconds': 50,
      'xpReward': 50,
      'thumbnail': '',
    },
    // INVESTMENT
    {
      'id': 'investment_intro',
      'categoryId': 'investment',
      'videoPath': 'assets/lessons/investment/investment_intro.mp4',
      'audioTracks': {
        'en': 'assets/lessons/investment/intro_en.mp3',
        'hi': 'assets/lessons/investment/intro_hi.mp3',
        'mr': 'assets/lessons/investment/intro_mr.mp3',
        'te': 'assets/lessons/investment/intro_te.mp3',
        'kn': 'assets/lessons/investment/intro_kn.mp3',
        'bn': 'assets/lessons/investment/intro_bn.mp3',
      },
      'subtitles': <String, String>{},
      'titles': {
        'en': 'Investment Basics',
        'hi': 'निवेश की मूल बातें',
        'mr': 'गुंतवणुकीची मूलभूत माहिती',
        'te': 'పెట్టుబడి ప్రాథమిక అంశాలు',
        'kn': 'ಹೂಡಿಕೆಯ ಮೂಲಭೂತ ಅಂಶಗಳು',
        'bn': 'বিনিয়োগের মূল বিষয়',
      },
      'descriptions': {
        'en': 'Start your investment journey',
        'hi': 'अपनी निवेश यात्रा शुरू करें',
      },
      'durationSeconds': 55,
      'xpReward': 60,
      'thumbnail': '',
    },
    // BUSINESS
    {
      'id': 'business_intro',
      'categoryId': 'business',
      'videoPath': 'assets/lessons/business/business_intro.mp4',
      'audioTracks': {
        'en': 'assets/lessons/business/intro_en.mp3',
        'hi': 'assets/lessons/business/intro_hi.mp3',
        'mr': 'assets/lessons/business/intro_mr.mp3',
        'te': 'assets/lessons/business/intro_te.mp3',
        'kn': 'assets/lessons/business/intro_kn.mp3',
        'bn': 'assets/lessons/business/intro_bn.mp3',
      },
      'subtitles': <String, String>{},
      'titles': {
        'en': 'Starting a Small Business',
        'hi': 'छोटा व्यापार शुरू करें',
        'mr': 'लहान व्यवसाय सुरू करणे',
        'te': 'చిన్న వ్యాపారం ప్రారంభించడం',
        'kn': 'ಸಣ್ಣ ವ್ಯಾಪಾರ ಪ್ರಾರಂಭಿಸುವುದು',
        'bn': 'ছোট ব্যবসা শুরু করা',
      },
      'descriptions': {
        'en': 'Learn how to start and run a small business',
        'hi': 'छोटा व्यापार शुरू करना और चलाना सीखें',
      },
      'durationSeconds': 50,
      'xpReward': 60,
      'thumbnail': '',
    },
    // DIGITAL
    {
      'id': 'digital_intro',
      'categoryId': 'digital',
      'videoPath': 'assets/lessons/digital/digital_intro.mp4',
      'audioTracks': {
        'en': 'assets/lessons/digital/intro_en.mp3',
        'hi': 'assets/lessons/digital/intro_hi.mp3',
        'mr': 'assets/lessons/digital/intro_mr.mp3',
        'te': 'assets/lessons/digital/intro_te.mp3',
        'kn': 'assets/lessons/digital/intro_kn.mp3',
        'bn': 'assets/lessons/digital/intro_bn.mp3',
      },
      'subtitles': <String, String>{},
      'titles': {
        'en': 'Digital Payments & UPI',
        'hi': 'डिजिटल भुगतान और UPI',
        'mr': 'डिजिटल पेमेंट आणि UPI',
        'te': 'డిజిటల్ చెల్లింపులు & UPI',
        'kn': 'ಡಿಜಿಟಲ್ ಪಾವತಿಗಳು & UPI',
        'bn': 'ডিজিটাল পেমেন্ট ও UPI',
      },
      'descriptions': {
        'en': 'Learn to use UPI and digital payments safely',
        'hi': 'UPI और डिजिटल भुगतान सुरक्षित रूप से करना सीखें',
      },
      'durationSeconds': 45,
      'xpReward': 50,
      'thumbnail': '',
    },
  ];

  /// Get all lessons
  static List<VideoLesson> getAll() =>
      lessons.map((json) => VideoLesson.fromJson(json)).toList();

  /// Get lessons by category
  static List<VideoLesson> getByCategory(String categoryId) =>
      getAll().where((l) => l.categoryId == categoryId).toList();

  /// Get lesson by ID
  static VideoLesson? getById(String id) {
    try {
      return getAll().firstWhere((l) => l.id == id);
    } catch (_) {
      return null;
    }
  }
}
