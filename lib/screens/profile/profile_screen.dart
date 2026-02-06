import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../config/gamification.dart';
import '../../providers/user_provider.dart';

/// Profile Screen with badges, settings, and activity
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final isHindi = userProvider.language == 'hi';
    final level = Levels.getLevelForXP(userProvider.xp);
    final levelTitle = Levels.getLevelTitle(level, isHindi);
    final earnedBadges = userProvider.earnedBadges;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Profile header
          SliverAppBar(
            expandedHeight: 280,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.primaryDark,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => context.pop(),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings, color: Colors.white),
                onPressed: () => _showSettings(context, isHindi),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      // Avatar
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            userProvider.userName.isNotEmpty 
                                ? userProvider.userName[0].toUpperCase() 
                                : '👤',
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Name
                      Text(
                        userProvider.userName.isNotEmpty 
                            ? userProvider.userName 
                            : (isHindi ? 'उपयोगकर्ता' : 'User'),
                        style: AppTypography.headlineMedium.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      
                      // Level badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '⭐ ${isHindi ? 'लेवल' : 'Level'} $level',
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '• $levelTitle',
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Stats cards
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats row
                  Row(
                    children: [
                      _buildStatCard(
                        '💰',
                        '${userProvider.xp}',
                        isHindi ? 'कुल XP' : 'Total XP',
                      ),
                      const SizedBox(width: 12),
                      _buildStatCard(
                        '🔥',
                        '${userProvider.streak}',
                        isHindi ? 'दिन स्ट्रीक' : 'Day Streak',
                      ),
                      const SizedBox(width: 12),
                      _buildStatCard(
                        '🏆',
                        '${earnedBadges.length}',
                        isHindi ? 'बैज' : 'Badges',
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Badges section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isHindi ? '🏅 मेरे बैज' : '🏅 My Badges',
                        style: AppTypography.headlineSmall,
                      ),
                      TextButton(
                        onPressed: () => _showAllBadges(context, isHindi),
                        child: Text(
                          isHindi ? 'सभी देखें' : 'See All',
                          style: TextStyle(color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // Badges grid
                  _buildBadgesGrid(earnedBadges, isHindi),
                  
                  const SizedBox(height: 24),
                  
                  // Profile info section
                  Text(
                    isHindi ? '👤 प्रोफाइल जानकारी' : '👤 Profile Info',
                    style: AppTypography.headlineSmall,
                  ),
                  const SizedBox(height: 12),
                  
                  _buildInfoCard([
                    _buildInfoRow(
                      Icons.person,
                      isHindi ? 'नाम' : 'Name',
                      userProvider.userName.isEmpty 
                          ? (isHindi ? 'सेट नहीं' : 'Not set') 
                          : userProvider.userName,
                    ),
                    _buildInfoRow(
                      Icons.work,
                      isHindi ? 'व्यवसाय' : 'Occupation',
                      userProvider.occupation ?? (isHindi ? 'सेट नहीं' : 'Not set'),
                    ),
                    _buildInfoRow(
                      Icons.attach_money,
                      isHindi ? 'आय' : 'Income',
                      userProvider.incomeRange ?? (isHindi ? 'सेट नहीं' : 'Not set'),
                    ),
                    _buildInfoRow(
                      Icons.language,
                      isHindi ? 'भाषा' : 'Language',
                      AppLanguages.getByCode(userProvider.language)?['native'] ?? 'English',
                    ),
                  ]),
                  
                  const SizedBox(height: 24),
                  
                  // Settings section
                  Text(
                    isHindi ? '⚙️ सेटिंग्स' : '⚙️ Settings',
                    style: AppTypography.headlineSmall,
                  ),
                  const SizedBox(height: 12),
                  
                  _buildSettingsCard(context, isHindi, userProvider),
                  
                  const SizedBox(height: 24),
                  
                  // Logout button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton.icon(
                      onPressed: () => _confirmLogout(context, isHindi),
                      icon: Icon(Icons.logout, color: AppColors.error),
                      label: Text(
                        isHindi ? 'लॉग आउट' : 'Log Out',
                        style: TextStyle(color: AppColors.error),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.error),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // App version
                  Center(
                    child: Text(
                      'Sathi v1.0.0',
                      style: AppTypography.bodySmall,
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String emoji, String value, String label) {
    return Expanded(
      child: Container(
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
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 8),
            Text(
              value,
              style: AppTypography.headlineSmall,
            ),
            Text(
              label,
              style: AppTypography.bodySmall.copyWith(fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadgesGrid(List<String> earnedBadges, bool isHindi) {
    if (earnedBadges.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Column(
            children: [
              const Text('🎯', style: TextStyle(fontSize: 40)),
              const SizedBox(height: 12),
              Text(
                isHindi 
                    ? 'अभी तक कोई बैज नहीं मिला'
                    : 'No badges earned yet',
                style: AppTypography.bodyMedium,
              ),
              const SizedBox(height: 4),
              Text(
                isHindi 
                    ? 'सीखना शुरू करें और बैज कमाएं!'
                    : 'Start learning to earn badges!',
                style: AppTypography.bodySmall,
              ),
            ],
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 0.85,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: earnedBadges.length > 8 ? 8 : earnedBadges.length,
      itemBuilder: (context, index) {
        final badge = AppBadges.getById(earnedBadges[index]);
        if (badge == null) return const SizedBox();
        
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.amber.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(badge.emoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(height: 4),
              Text(
                isHindi ? badge.nameHi : badge.name,
                style: const TextStyle(fontSize: 9),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTypography.bodySmall),
                Text(value, style: AppTypography.titleMedium),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: AppColors.textLight),
        ],
      ),
    );
  }

  Widget _buildSettingsCard(BuildContext context, bool isHindi, UserProvider userProvider) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Biometric toggle
          _buildSettingsTile(
            Icons.fingerprint,
            isHindi ? 'बायोमेट्रिक लॉगिन' : 'Biometric Login',
            isHindi ? 'फिंगरप्रिंट या फेस आईडी' : 'Fingerprint or Face ID',
            trailing: Switch(
              value: userProvider.biometricEnabled,
              onChanged: (value) {
                userProvider.setBiometricEnabled(value);
              },
              activeColor: AppColors.primary,
            ),
          ),
          const Divider(height: 1),
          
          // Notifications toggle
          _buildSettingsTile(
            Icons.notifications,
            isHindi ? 'नोटिफिकेशन' : 'Notifications',
            isHindi ? 'दैनिक रिमाइंडर' : 'Daily reminders',
            trailing: Switch(
              value: userProvider.notificationsEnabled,
              onChanged: (value) {
                userProvider.setNotificationsEnabled(value);
              },
              activeColor: AppColors.primary,
            ),
          ),
          const Divider(height: 1),
          
          // Language
          _buildSettingsTile(
            Icons.language,
            isHindi ? 'भाषा बदलें' : 'Change Language',
            AppLanguages.getByCode(userProvider.language)?['native'] ?? 'English',
            onTap: () => context.go('/language'),
          ),
          const Divider(height: 1),
          
          // Help
          _buildSettingsTile(
            Icons.help_outline,
            isHindi ? 'मदद और सहायता' : 'Help & Support',
            isHindi ? 'FAQs, संपर्क करें' : 'FAQs, Contact us',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(IconData icon, String title, String subtitle, {Widget? trailing, VoidCallback? onTap}) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(title, style: AppTypography.titleMedium),
      subtitle: Text(subtitle, style: AppTypography.bodySmall),
      trailing: trailing ?? Icon(Icons.chevron_right, color: AppColors.textLight),
      onTap: onTap,
    );
  }

  void _showSettings(BuildContext context, bool isHindi) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isHindi ? 'सेटिंग्स नीचे स्क्रॉल करें' : 'Scroll down for settings'),
      ),
    );
  }

  void _showAllBadges(BuildContext context, bool isHindi) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                isHindi ? '🏅 सभी बैज' : '🏅 All Badges',
                style: AppTypography.headlineMedium,
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 0.8,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: AppBadges.all.length,
                itemBuilder: (context, index) {
                  final badge = AppBadges.all[index];
                  final userProvider = context.read<UserProvider>();
                  final isEarned = userProvider.earnedBadges.contains(badge.id);
                  
                  return Container(
                    decoration: BoxDecoration(
                      color: isEarned ? Colors.white : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(16),
                      border: isEarned ? Border.all(color: Colors.amber, width: 2) : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Opacity(
                          opacity: isEarned ? 1.0 : 0.3,
                          child: Text(badge.emoji, style: const TextStyle(fontSize: 36)),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isHindi ? badge.nameHi : badge.name,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isEarned ? AppColors.textPrimary : AppColors.textLight,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (isEarned)
                          const Text('✅', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context, bool isHindi) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isHindi ? 'लॉग आउट' : 'Log Out'),
        content: Text(
          isHindi 
              ? 'क्या आप सचमुच लॉग आउट करना चाहते हैं?'
              : 'Are you sure you want to log out?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(isHindi ? 'रद्द करें' : 'Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              final userProvider = context.read<UserProvider>();
              userProvider.logout();
              context.go('/auth');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: Text(
              isHindi ? 'लॉग आउट' : 'Log Out',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
