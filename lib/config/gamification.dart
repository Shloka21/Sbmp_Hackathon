/// Gamification Configuration - XP, Badges, Levels

/// Badge definitions with icons and thresholds
class Badge {
  final String id;
  final String name;
  final String nameHi;
  final String description;
  final String descriptionHi;
  final String emoji;
  final int xpRequired;
  final BadgeCategory category;
  
  const Badge({
    required this.id,
    required this.name,
    required this.nameHi,
    required this.description,
    required this.descriptionHi,
    required this.emoji,
    required this.xpRequired,
    required this.category,
  });
}

enum BadgeCategory {
  learning,
  saving,
  streak,
  schemes,
  business,
  special,
}

/// All available badges
class AppBadges {
  static const List<Badge> all = [
    // Learning Badges
    Badge(
      id: 'first_lesson',
      name: 'First Step',
      nameHi: 'पहला कदम',
      description: 'Complete your first lesson',
      descriptionHi: 'अपना पहला पाठ पूरा करें',
      emoji: '🎓',
      xpRequired: 10,
      category: BadgeCategory.learning,
    ),
    Badge(
      id: 'knowledge_seeker',
      name: 'Knowledge Seeker',
      nameHi: 'ज्ञान खोजी',
      description: 'Complete 5 lessons',
      descriptionHi: '5 पाठ पूरे करें',
      emoji: '📚',
      xpRequired: 100,
      category: BadgeCategory.learning,
    ),
    Badge(
      id: 'money_master',
      name: 'Money Master',
      nameHi: 'पैसों का मास्टर',
      description: 'Complete all money lessons',
      descriptionHi: 'सभी पैसों के पाठ पूरे करें',
      emoji: '💰',
      xpRequired: 500,
      category: BadgeCategory.learning,
    ),
    
    // Saving Badges
    Badge(
      id: 'first_save',
      name: 'Saver Star',
      nameHi: 'बचत सितारा',
      description: 'Set your first savings goal',
      descriptionHi: 'अपना पहला बचत लक्ष्य बनाएं',
      emoji: '⭐',
      xpRequired: 20,
      category: BadgeCategory.saving,
    ),
    Badge(
      id: 'goal_achiever',
      name: 'Goal Achiever',
      nameHi: 'लक्ष्य विजेता',
      description: 'Complete a savings goal',
      descriptionHi: 'एक बचत लक्ष्य पूरा करें',
      emoji: '🏆',
      xpRequired: 200,
      category: BadgeCategory.saving,
    ),
    Badge(
      id: 'super_saver',
      name: 'Super Saver',
      nameHi: 'महा बचतकर्ता',
      description: 'Save ₹10,000 total',
      descriptionHi: '₹10,000 की कुल बचत करें',
      emoji: '💎',
      xpRequired: 1000,
      category: BadgeCategory.saving,
    ),
    
    // Streak Badges
    Badge(
      id: 'streak_3',
      name: 'Getting Started',
      nameHi: 'शुरुआत',
      description: '3 day streak',
      descriptionHi: '3 दिन की स्ट्रीक',
      emoji: '🔥',
      xpRequired: 30,
      category: BadgeCategory.streak,
    ),
    Badge(
      id: 'streak_7',
      name: 'Week Warrior',
      nameHi: 'हफ्ते का योद्धा',
      description: '7 day streak',
      descriptionHi: '7 दिन की स्ट्रीक',
      emoji: '💪',
      xpRequired: 100,
      category: BadgeCategory.streak,
    ),
    Badge(
      id: 'streak_30',
      name: 'Monthly Champion',
      nameHi: 'महीने का चैंपियन',
      description: '30 day streak',
      descriptionHi: '30 दिन की स्ट्रीक',
      emoji: '👑',
      xpRequired: 500,
      category: BadgeCategory.streak,
    ),
    
    // Scheme Badges
    Badge(
      id: 'scheme_explorer',
      name: 'Scheme Explorer',
      nameHi: 'योजना खोजी',
      description: 'View 5 government schemes',
      descriptionHi: '5 सरकारी योजनाएं देखें',
      emoji: '🔍',
      xpRequired: 50,
      category: BadgeCategory.schemes,
    ),
    Badge(
      id: 'scheme_master',
      name: 'Scheme Master',
      nameHi: 'योजना मास्टर',
      description: 'Complete eligibility check',
      descriptionHi: 'पात्रता जांच पूरी करें',
      emoji: '📋',
      xpRequired: 150,
      category: BadgeCategory.schemes,
    ),
    
    // Business Badges
    Badge(
      id: 'entrepreneur',
      name: 'Entrepreneur',
      nameHi: 'उद्यमी',
      description: 'Explore business ideas',
      descriptionHi: 'व्यापार आइडियाज देखें',
      emoji: '🚀',
      xpRequired: 75,
      category: BadgeCategory.business,
    ),
    
    // Special Badges
    Badge(
      id: 'sathi_friend',
      name: 'Sathi\'s Friend',
      nameHi: 'साथी का दोस्त',
      description: 'Chat with Sathi 10 times',
      descriptionHi: 'साथी से 10 बार बात करें',
      emoji: '🐻',
      xpRequired: 100,
      category: BadgeCategory.special,
    ),
    Badge(
      id: 'financial_guru',
      name: 'Financial Guru',
      nameHi: 'वित्तीय गुरु',
      description: 'Reach Level 10',
      descriptionHi: 'लेवल 10 तक पहुंचें',
      emoji: '🧙',
      xpRequired: 2000,
      category: BadgeCategory.special,
    ),
  ];
  
  static Badge? getById(String id) {
    try {
      return all.firstWhere((b) => b.id == id);
    } catch (_) {
      return null;
    }
  }
}

/// XP rewards for different actions
class XPRewards {
  static const int completeLesson = 25;
  static const int completeQuiz = 15;
  static const int correctAnswer = 5;
  static const int setSavingsGoal = 20;
  static const int completeSavingsGoal = 100;
  static const int addExpense = 5;
  static const int viewScheme = 5;
  static const int completeEligibility = 30;
  static const int chatWithSathi = 10;
  static const int dailyLogin = 15;
  static const int shareApp = 50;
  static const int viewBusinessIdea = 10;
}

/// Level thresholds
class Levels {
  static int getLevelForXP(int xp) {
    if (xp < 50) return 1;
    if (xp < 150) return 2;
    if (xp < 300) return 3;
    if (xp < 500) return 4;
    if (xp < 750) return 5;
    if (xp < 1100) return 6;
    if (xp < 1500) return 7;
    if (xp < 2000) return 8;
    if (xp < 2600) return 9;
    if (xp < 3300) return 10;
    return 10 + ((xp - 3300) ~/ 1000);
  }
  
  static int xpForLevel(int level) {
    switch (level) {
      case 1: return 0;
      case 2: return 50;
      case 3: return 150;
      case 4: return 300;
      case 5: return 500;
      case 6: return 750;
      case 7: return 1100;
      case 8: return 1500;
      case 9: return 2000;
      case 10: return 2600;
      default: return 3300 + (level - 10) * 1000;
    }
  }
  
  static int xpToNextLevel(int currentXP) {
    final currentLevel = getLevelForXP(currentXP);
    final nextLevelXP = xpForLevel(currentLevel + 1);
    return nextLevelXP - currentXP;
  }
  
  static double progressToNextLevel(int currentXP) {
    final currentLevel = getLevelForXP(currentXP);
    final thisLevelXP = xpForLevel(currentLevel);
    final nextLevelXP = xpForLevel(currentLevel + 1);
    return (currentXP - thisLevelXP) / (nextLevelXP - thisLevelXP);
  }
  
  static String getLevelTitle(int level, bool isHindi) {
    if (isHindi) {
      if (level <= 2) return 'नया सीखने वाला';
      if (level <= 4) return 'होशियार छात्र';
      if (level <= 6) return 'पैसों का समझदार';
      if (level <= 8) return 'बचत विशेषज्ञ';
      if (level <= 10) return 'वित्तीय गुरु';
      return 'धन मास्टर';
    } else {
      if (level <= 2) return 'Beginner';
      if (level <= 4) return 'Smart Learner';
      if (level <= 6) return 'Money Wise';
      if (level <= 8) return 'Savings Expert';
      if (level <= 10) return 'Financial Guru';
      return 'Money Master';
    }
  }
}

/// Confidence Meter levels
class ConfidenceMeter {
  static String getLevel(int xp, bool isHindi) {
    final percentage = (xp / 3000).clamp(0.0, 1.0);
    if (isHindi) {
      if (percentage < 0.2) return 'शुरुआती';
      if (percentage < 0.4) return 'सीख रहे हैं';
      if (percentage < 0.6) return 'समझदार';
      if (percentage < 0.8) return 'आत्मविश्वासी';
      return 'विशेषज्ञ';
    } else {
      if (percentage < 0.2) return 'Beginner';
      if (percentage < 0.4) return 'Learning';
      if (percentage < 0.6) return 'Confident';
      if (percentage < 0.8) return 'Skilled';
      return 'Expert';
    }
  }
  
  static double getProgress(int xp) {
    return (xp / 3000).clamp(0.0, 1.0);
  }
}
