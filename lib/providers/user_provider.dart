import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../models/user.dart';

/// User Provider with gamification support
class UserProvider extends ChangeNotifier {
  UserProfile? _user;
  String _language = 'en';
  bool _isOnboardingComplete = false;
  bool _isLoading = true;
  
  // Gamification
  int _xp = 0;
  int _streak = 0;
  List<String> _earnedBadges = [];
  
  // Lesson progress
  Set<String> _completedLessons = {};
  
  // Settings
  bool _biometricEnabled = false;
  bool _notificationsEnabled = true;

  // Quick accessors
  String get language => _language;
  bool get isOnboardingComplete => _isOnboardingComplete;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _user != null;
  UserProfile? get user => _user;
  
  // User info helpers
  String get userName => _user?.name ?? '';
  String? get occupation => _user?.occupation;
  String? get incomeRange => _user?.incomeRange;
  
  // Gamification getters
  int get xp => _xp;
  int get streak => _streak;
  List<String> get earnedBadges => _earnedBadges;
  Set<String> get completedLessons => _completedLessons;
  
  // Settings getters
  bool get biometricEnabled => _biometricEnabled;
  bool get notificationsEnabled => _notificationsEnabled;

  /// Initialize from storage
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      
      _language = prefs.getString('language') ?? 'en';
      _isOnboardingComplete = prefs.getBool('onboarding_complete') ?? false;
      _xp = prefs.getInt('user_xp') ?? 0;
      _streak = prefs.getInt('user_streak') ?? 0;
      _biometricEnabled = prefs.getBool('biometric_enabled') ?? false;
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      
      final badgesJson = prefs.getString('earned_badges');
      if (badgesJson != null) {
        _earnedBadges = List<String>.from(json.decode(badgesJson));
      }
      
      // Load completed lessons
      final lessonsJson = prefs.getString('completed_lessons');
      if (lessonsJson != null) {
        _completedLessons = Set<String>.from(json.decode(lessonsJson));
      }
      
      final userJson = prefs.getString('user_profile');
      if (userJson != null) {
        _user = UserProfile.fromJson(json.decode(userJson));
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Set language
  Future<void> setLanguage(String code) async {
    _language = code;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', code);
  }

  /// Complete onboarding
  Future<void> completeOnboarding() async {
    _isOnboardingComplete = true;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);
  }

  /// Save user profile
  Future<void> saveUser(UserProfile user) async {
    _user = user;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_profile', json.encode(user.toJson()));
  }

  /// Add XP
  Future<void> addXP(int amount) async {
    _xp += amount;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_xp', _xp);
    
    // Check for badge unlocks
    _checkBadgeUnlocks();
  }

  /// Update streak
  Future<void> updateStreak() async {
    _streak++;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_streak', _streak);
    
    // Streak badges
    if (_streak == 3) await addBadge('streak_3');
    if (_streak == 7) await addBadge('streak_7');
    if (_streak == 30) await addBadge('streak_30');
  }

  /// Add badge
  Future<void> addBadge(String badgeId) async {
    if (_earnedBadges.contains(badgeId)) return;
    
    _earnedBadges.add(badgeId);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('earned_badges', json.encode(_earnedBadges));
  }

  /// Mark a lesson as completed
  Future<void> markLessonComplete(String lessonId, int xpReward) async {
    if (_completedLessons.contains(lessonId)) return;
    
    _completedLessons.add(lessonId);
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('completed_lessons', json.encode(_completedLessons.toList()));
    
    // Award XP
    await addXP(xpReward);
    
    // Check for lesson completion badges
    if (_completedLessons.length == 1) await addBadge('first_lesson');
    if (_completedLessons.length >= 5) await addBadge('five_lessons');
    if (_completedLessons.length >= 10) await addBadge('ten_lessons');
  }

  /// Check if a lesson is completed
  bool isLessonCompleted(String lessonId) {
    return _completedLessons.contains(lessonId);
  }

  /// Check if a lesson is unlocked (first lesson always unlocked, others need previous completed)
  bool isLessonUnlocked(String categoryId, int lessonIndex, List<String> categoryLessonIds) {
    if (lessonIndex == 0) return true; // First lesson always unlocked
    
    // Check if previous lesson in this category is completed
    if (lessonIndex > 0 && lessonIndex < categoryLessonIds.length) {
      final previousLessonId = categoryLessonIds[lessonIndex - 1];
      return _completedLessons.contains(previousLessonId);
    }
    return false;
  }

  /// Get completed lessons count for a category
  int getCompletedCountForCategory(String categoryId, List<String> categoryLessonIds) {
    return categoryLessonIds.where((id) => _completedLessons.contains(id)).length;
  }

  /// Check for automatic badge unlocks
  void _checkBadgeUnlocks() {
    if (_xp >= 10 && !_earnedBadges.contains('first_lesson')) {
      addBadge('first_lesson');
    }
    if (_xp >= 100 && !_earnedBadges.contains('knowledge_seeker')) {
      addBadge('knowledge_seeker');
    }
    if (_xp >= 500 && !_earnedBadges.contains('money_master')) {
      addBadge('money_master');
    }
    if (_xp >= 2000 && !_earnedBadges.contains('financial_guru')) {
      addBadge('financial_guru');
    }
  }

  /// Settings
  Future<void> setBiometricEnabled(bool enabled) async {
    _biometricEnabled = enabled;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('biometric_enabled', enabled);
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    _notificationsEnabled = enabled;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', enabled);
  }

  /// Get localized text
  String getText(String en, String hi) {
    return _language == 'hi' ? hi : en;
  }

  /// Logout
  Future<void> logout() async {
    _user = null;
    _isOnboardingComplete = false;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_profile');
    await prefs.remove('onboarding_complete');
    // Keep XP and badges
  }
}
