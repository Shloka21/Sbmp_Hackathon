/// Building Model for Sathi Village
class Building {
  final String id;
  final String name;
  final String nameHi;
  final String emoji;
  final int baseCost;
  final int dailyIncome;
  final int unlockLevel;
  final String description;
  final String descriptionHi;
  final String financialLesson;
  final String financialLessonHi;

  const Building({
    required this.id,
    required this.name,
    required this.nameHi,
    required this.emoji,
    required this.baseCost,
    required this.dailyIncome,
    required this.unlockLevel,
    required this.description,
    required this.descriptionHi,
    required this.financialLesson,
    required this.financialLessonHi,
  });

  /// Get localized name
  String getName(bool isHindi) => isHindi ? nameHi : name;

  /// Get localized description
  String getDescription(bool isHindi) => isHindi ? descriptionHi : description;

  /// Get localized lesson
  String getLesson(bool isHindi) => isHindi ? financialLessonHi : financialLesson;

  /// Cost to upgrade to next level
  int upgradeCost(int currentLevel) => baseCost * (currentLevel + 1);

  /// Income at a specific level
  int incomeAtLevel(int level) => dailyIncome * level;
}

/// Static building definitions
class Buildings {
  static const List<Building> all = [
    Building(
      id: 'bank',
      name: 'Bank',
      nameHi: 'बैंक',
      emoji: '🏦',
      baseCost: 0,
      dailyIncome: 0,
      unlockLevel: 1,
      description: 'Save money and earn interest',
      descriptionHi: 'पैसे बचाएं और ब्याज कमाएं',
      financialLesson: 'Banks keep your money safe and pay you interest for saving',
      financialLessonHi: 'बैंक आपके पैसे सुरक्षित रखता है और बचत पर ब्याज देता है',
    ),
    Building(
      id: 'farm',
      name: 'Farm',
      nameHi: 'खेत',
      emoji: '🌾',
      baseCost: 100,
      dailyIncome: 50,
      unlockLevel: 1,
      description: 'Grow crops to earn daily income',
      descriptionHi: 'फसल उगाकर रोज कमाई करें',
      financialLesson: 'Regular income needs planning and patience',
      financialLessonHi: 'नियमित आय के लिए योजना और धैर्य चाहिए',
    ),
    Building(
      id: 'shop',
      name: 'Shop',
      nameHi: 'दुकान',
      emoji: '🏪',
      baseCost: 200,
      dailyIncome: 75,
      unlockLevel: 2,
      description: 'Run a shop to earn profits',
      descriptionHi: 'दुकान चलाकर मुनाफा कमाएं',
      financialLesson: 'Profit = Selling Price - Cost Price. Keep track of both!',
      financialLessonHi: 'मुनाफा = बिक्री मूल्य - लागत। दोनों का हिसाब रखें!',
    ),
    Building(
      id: 'govt',
      name: 'Govt Office',
      nameHi: 'सरकारी दफ्तर',
      emoji: '🏛️',
      baseCost: 300,
      dailyIncome: 25,
      unlockLevel: 3,
      description: 'Access government schemes',
      descriptionHi: 'सरकारी योजनाओं का लाभ उठाएं',
      financialLesson: 'Many govt schemes can help you save money and get benefits',
      financialLessonHi: 'कई सरकारी योजनाएं पैसे बचाने और लाभ पाने में मदद करती हैं',
    ),
    Building(
      id: 'loan',
      name: 'Loan Office',
      nameHi: 'लोन ऑफिस',
      emoji: '💰',
      baseCost: 400,
      dailyIncome: 0,
      unlockLevel: 4,
      description: 'Take loans for emergencies',
      descriptionHi: 'जरूरत में लोन लें',
      financialLesson: 'Loans have interest. Borrow only what you can repay!',
      financialLessonHi: 'लोन पर ब्याज लगता है। उतना ही उधार लें जितना चुका सकें!',
    ),
    Building(
      id: 'hospital',
      name: 'Hospital',
      nameHi: 'अस्पताल',
      emoji: '🏥',
      baseCost: 500,
      dailyIncome: 0,
      unlockLevel: 5,
      description: 'Health insurance protection',
      descriptionHi: 'स्वास्थ्य बीमा सुरक्षा',
      financialLesson: 'Health insurance saves you from big medical bills',
      financialLessonHi: 'स्वास्थ्य बीमा बड़े मेडिकल खर्च से बचाता है',
    ),
    Building(
      id: 'school',
      name: 'School',
      nameHi: 'स्कूल',
      emoji: '🎓',
      baseCost: 600,
      dailyIncome: 100,
      unlockLevel: 6,
      description: 'Invest in education',
      descriptionHi: 'शिक्षा में निवेश करें',
      financialLesson: 'Education is the best investment for your future',
      financialLessonHi: 'शिक्षा आपके भविष्य के लिए सबसे अच्छा निवेश है',
    ),
  ];

  /// Get building by ID
  static Building? getById(String id) {
    try {
      return all.firstWhere((b) => b.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Get buildings available at a level
  static List<Building> availableAt(int level) {
    return all.where((b) => b.unlockLevel <= level).toList();
  }
}
