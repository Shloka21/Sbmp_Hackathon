import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../config/gamification.dart';
import '../../providers/user_provider.dart';
import '../../services/news_service.dart';
import '../../widgets/game/game_dashboard_widget.dart';

/// Home Dashboard with visual elements and news widget
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _welcomeController;
  late Animation<double> _welcomeAnimation;

  @override
  void initState() {
    super.initState();
    _welcomeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _welcomeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _welcomeController, curve: Curves.easeOut),
    );
    _welcomeController.forward();
    
    // Award daily login XP
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = context.read<UserProvider>();
      userProvider.addXP(XPRewards.dailyLogin);
    });
  }

  @override
  void dispose() {
    _welcomeController.dispose();
    super.dispose();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    final userProvider = context.read<UserProvider>();
    final isHindi = userProvider.language == 'hi';
    
    if (hour < 12) {
      return isHindi ? 'सुप्रभात' : 'Good Morning';
    } else if (hour < 17) {
      return isHindi ? 'नमस्कार' : 'Good Afternoon';
    } else {
      return isHindi ? 'शुभ संध्या' : 'Good Evening';
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final isHindi = userProvider.language == 'hi';
    final features = DashboardFeatures.getAll(isHindi);
    final news = NewsService.getNews(userProvider.language);
    
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // App bar with gradient
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.primaryDark,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: FadeTransition(
                      opacity: _welcomeAnimation,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${_getGreeting()} 👋',
                                    style: AppTypography.bodyLarge.copyWith(
                                      color: Colors.white70,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    userProvider.userName.isNotEmpty 
                                        ? userProvider.userName 
                                        : (isHindi ? 'दोस्त' : 'Friend'),
                                    style: AppTypography.headlineMedium.copyWith(
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              GestureDetector(
                                onTap: () => context.push('/profile'),
                                child: Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Center(
                                    child: Text(
                                      userProvider.userName.isNotEmpty 
                                          ? userProvider.userName[0].toUpperCase() 
                                          : '👤',
                                      style: const TextStyle(
                                        fontSize: 24,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          // Level and XP bar
                          _buildLevelBar(userProvider, isHindi),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Main content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Confidence Meter
                  _buildConfidenceMeter(userProvider, isHindi),
                  const SizedBox(height: 24),
                  
                  // Daily tip card
                _buildDailyTipCard(isHindi),
                const SizedBox(height: 24),
                
                // Sathi Village Game Widget
                GameDashboardWidget(isHindi: isHindi),
                const SizedBox(height: 24),
                  
                  // Feature grid
                  Text(
                    isHindi ? '🎯 क्या करना है?' : '🎯 What would you like to do?',
                    style: AppTypography.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 0.85,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: features.length,
                    itemBuilder: (context, index) {
                      final feature = features[index];
                      return _buildFeatureCard(feature);
                    },
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // News section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isHindi ? '📰 ताज़ा खबरें' : '📰 Latest News',
                        style: AppTypography.headlineSmall,
                      ),
                      TextButton(
                        onPressed: () => context.push('/news'),
                        child: Text(
                          isHindi ? 'सभी देखें' : 'See All',
                          style: TextStyle(color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // News cards
                  SizedBox(
                    height: 140,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: news.take(4).length,
                      itemBuilder: (context, index) {
                        final item = news[index];
                        return _buildNewsCard(item, isHindi);
                      },
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Quick action - Ask Sathi
                  _buildAskSathiCard(isHindi),
                  
                  const SizedBox(height: 100), // Bottom padding for nav
                ],
              ),
            ),
          ),
        ],
      ),
      
      // Bottom navigation
      bottomNavigationBar: _buildBottomNav(isHindi),
    );
  }

  Widget _buildLevelBar(UserProvider userProvider, bool isHindi) {
    final level = Levels.getLevelForXP(userProvider.xp);
    final progress = Levels.progressToNextLevel(userProvider.xp);
    final title = Levels.getLevelTitle(level, isHindi);
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.amber,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                '$level',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${userProvider.xp} XP',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Streak flame
          if (userProvider.streak > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Text('🔥', style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 2),
                  Text(
                    '${userProvider.streak}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildConfidenceMeter(UserProvider userProvider, bool isHindi) {
    final progress = ConfidenceMeter.getProgress(userProvider.xp);
    final level = ConfidenceMeter.getLevel(userProvider.xp, isHindi);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text('💪', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 8),
                  Text(
                    isHindi ? 'आत्मविश्वास मीटर' : 'Confidence Meter',
                    style: AppTypography.titleMedium,
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  level,
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Stack(
            children: [
              Container(
                height: 20,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              FractionallySizedBox(
                widthFactor: progress,
                child: Container(
                  height: 20,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary,
                        AppColors.primaryLight,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            isHindi 
                ? 'सीखते रहें और अपना आत्मविश्वास बढ़ाएं!'
                : 'Keep learning to boost your financial confidence!',
            style: AppTypography.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildDailyTipCard(bool isHindi) {
    final tip = DailyTips.getToday(isHindi);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.9),
            AppColors.primaryDark,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Center(
              child: Text('💡', style: TextStyle(fontSize: 24)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isHindi ? 'आज की टिप' : 'Today\'s Tip',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tip.replaceFirst('💡 ', '').replaceFirst('💡 Tip: ', ''),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(Map<String, dynamic> feature) {
    return GestureDetector(
      onTap: () => context.push(feature['route']),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Color(feature['color']).withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Color(feature['color']).withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  feature['emoji'],
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              feature['name'],
              style: AppTypography.labelLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewsCard(NewsItem item, bool isHindi) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(item.imageEmoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 8),
              if (item.isImportant)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    isHindi ? 'महत्वपूर्ण' : 'Important',
                    style: TextStyle(
                      color: AppColors.error,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            item.title,
            style: AppTypography.titleMedium.copyWith(fontSize: 13),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          Text(
            item.getTimeAgo(isHindi),
            style: AppTypography.bodySmall.copyWith(fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildAskSathiCard(bool isHindi) {
    return GestureDetector(
      onTap: () => context.push('/ai-chat'),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primary.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Text('🐻', style: TextStyle(fontSize: 32)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isHindi ? 'साथी से पूछें' : 'Ask Sathi',
                    style: AppTypography.titleLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isHindi 
                        ? 'वित्त संबंधी कोई भी सवाल पूछें!'
                        : 'Ask any financial question!',
                    style: AppTypography.bodyMedium,
                  ),
                ],
              ),
            ),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_forward,
                color: Colors.white,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav(bool isHindi) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home, isHindi ? 'होम' : 'Home', true, () {}),
              _buildNavItem(Icons.school, isHindi ? 'सीखें' : 'Learn', false, 
                  () => context.push('/learning')),
              _buildNavItem(Icons.account_balance, isHindi ? 'पैसे' : 'Money', false,
                  () => context.push('/money')),
              _buildNavItem(Icons.smart_toy, isHindi ? 'साथी' : 'Sathi', false,
                  () => context.push('/ai-chat')),
              _buildNavItem(Icons.person, isHindi ? 'प्रोफाइल' : 'Profile', false,
                  () => context.push('/profile')),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? AppColors.primary : AppColors.textLight,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isActive ? AppColors.primary : AppColors.textLight,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
