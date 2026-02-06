import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../providers/user_provider.dart';
import '../../services/auth_service.dart';

/// Splash Screen with smart auth routing
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _controller.forward();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final userProvider = context.read<UserProvider>();
    await userProvider.initialize();
    await _authService.init();

    if (!mounted) return;

    // Check auth status
    final isRegistered = await _authService.isRegistered();
    final needsFullAuth = await _authService.needsFullAuth();
    final localAuthEnabled = await _authService.isLocalAuthEnabled();

    if (!isRegistered) {
      // New user - go to phone auth
      context.go('/auth');
    } else if (needsFullAuth) {
      // Session expired (> 7 days) - require OTP again
      context.go('/auth');
    } else if (localAuthEnabled) {
      // Always require PIN/Biometric on cold start if enabled
      context.go('/verify-pin');
    } else if (userProvider.isOnboardingComplete || userProvider.isLoggedIn) {
      // Recent activity, authenticated - go home
      await _authService.updateLastActivity();
      context.go('/home');
    } else {
      // Need to complete onboarding
      context.go('/language');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.darkGradient,
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo/Mascot
                      Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(35),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            '🐻',
                            style: TextStyle(fontSize: 70),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      // App Name
                      Text(
                        'Sathi',
                        style: AppTypography.displayLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your Financial Friend',
                        style: AppTypography.titleLarge.copyWith(
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Hindi tagline
                      Text(
                        'आपका वित्तीय साथी',
                        style: AppTypography.titleMedium.copyWith(
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(height: 48),
                      // Loading indicator
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
