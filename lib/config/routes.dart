import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../screens/splash/splash_screen.dart';
import '../screens/auth/auth_screen.dart';
import '../screens/auth/local_auth_screen.dart';
import '../screens/onboarding/language_screen.dart';
import '../screens/onboarding/profile_setup_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/learning/learning_screen.dart';
import '../screens/learning/lesson_detail_screen.dart';
import '../screens/schemes/schemes_screen.dart';
import '../screens/money/money_screen.dart';
import '../screens/ai_chat/ai_chat_screen.dart';
import '../screens/business/business_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/news/news_screen.dart';
import '../screens/info/trust_screen.dart';
import '../screens/game/village_game_screen.dart';
import '../screens/learning/video_lesson_screen.dart';

/// App Router Configuration
class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      // Splash Screen
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      
      // Auth - Phone OTP
      GoRoute(
        path: '/auth',
        name: 'auth',
        builder: (context, state) => const AuthScreen(),
      ),
      
      // PIN Setup
      GoRoute(
        path: '/setup-pin',
        name: 'setup-pin',
        builder: (context, state) => const LocalAuthScreen(isSetup: true),
      ),
      
      // PIN Verify
      GoRoute(
        path: '/verify-pin',
        name: 'verify-pin',
        builder: (context, state) => const LocalAuthScreen(isSetup: false),
      ),
      
      // Onboarding - Language Selection
      GoRoute(
        path: '/language',
        name: 'language',
        builder: (context, state) => const LanguageScreen(),
      ),
      
      // Onboarding - Profile Setup
      GoRoute(
        path: '/profile-setup',
        name: 'profile-setup',
        builder: (context, state) => const ProfileSetupScreen(),
      ),
      
      // Home Dashboard
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      
      // Learning Module
      GoRoute(
        path: '/learning',
        name: 'learning',
        builder: (context, state) => const LearningScreen(),
      ),
      
      // Lesson Detail
      GoRoute(
        path: '/lesson/:lessonId',
        name: 'lesson',
        builder: (context, state) {
          final lessonId = state.pathParameters['lessonId'] ?? '';
          return LessonDetailScreen(lessonId: lessonId);
        },
      ),
      
      // Government Schemes
      GoRoute(
        path: '/schemes',
        name: 'schemes',
        builder: (context, state) => const SchemesScreen(),
      ),
      
      // Money Management
      GoRoute(
        path: '/money',
        name: 'money',
        builder: (context, state) => const MoneyScreen(),
      ),
      
      // AI Chat (Sathi)
      GoRoute(
        path: '/ai-chat',
        name: 'ai-chat',
        builder: (context, state) => const AiChatScreen(),
      ),
      
      // Business Ideas
      GoRoute(
        path: '/business',
        name: 'business',
        builder: (context, state) => const BusinessScreen(),
      ),
      
      // Profile & Settings
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      
      // News Screen
      GoRoute(
        path: '/news',
        name: 'news',
        builder: (context, state) => const NewsScreen(),
      ),
      
      // Trust/Privacy Screen
      GoRoute(
        path: '/trust',
        name: 'trust',
        builder: (context, state) => const TrustScreen(),
      ),
      
      // Sathi Village Game
      GoRoute(
        path: '/game',
        name: 'game',
        builder: (context, state) => const VillageGameScreen(),
      ),
      
      // Video Lesson
      GoRoute(
        path: '/video-lesson/:lessonId',
        name: 'video-lesson',
        builder: (context, state) {
          final lessonId = state.pathParameters['lessonId'] ?? '';
          return VideoLessonScreen(lessonId: lessonId);
        },
      ),
    ],
  );
}
