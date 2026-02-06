import 'dart:math';
import 'package:flutter/material.dart';

/// Badge Celebration Widget - Full screen animated celebration
class BadgeCelebration extends StatefulWidget {
  final String badgeName;
  final String badgeNameHi;
  final String badgeEmoji;
  final String description;
  final String descriptionHi;
  final bool isHindi;
  final VoidCallback onDismiss;

  const BadgeCelebration({
    super.key,
    required this.badgeName,
    required this.badgeNameHi,
    required this.badgeEmoji,
    required this.description,
    required this.descriptionHi,
    required this.isHindi,
    required this.onDismiss,
  });

  @override
  State<BadgeCelebration> createState() => _BadgeCelebrationState();
}

class _BadgeCelebrationState extends State<BadgeCelebration>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _rotateController;
  late AnimationController _confettiController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;

  final List<_ConfettiParticle> _confetti = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    
    // Badge scale animation
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );
    
    // Badge rotation animation
    _rotateController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _rotateAnimation = Tween<double>(begin: 0.0, end: 2 * 3.14159).animate(
      CurvedAnimation(parent: _rotateController, curve: Curves.easeOutCubic),
    );
    
    // Confetti animation
    _confettiController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..addListener(() {
      setState(() {
        for (var particle in _confetti) {
          particle.update();
        }
      });
    });
    
    // Generate confetti particles
    _generateConfetti();
    
    // Start animations
    _scaleController.forward();
    _rotateController.forward();
    _confettiController.repeat();
  }

  void _generateConfetti() {
    final colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.yellow,
      Colors.purple,
      Colors.orange,
      Colors.pink,
      Colors.cyan,
    ];
    
    for (int i = 0; i < 50; i++) {
      _confetti.add(_ConfettiParticle(
        x: _random.nextDouble() * 400,
        y: -_random.nextDouble() * 200,
        color: colors[_random.nextInt(colors.length)],
        size: _random.nextDouble() * 8 + 4,
        velocity: _random.nextDouble() * 2 + 1,
        random: _random,
      ));
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _rotateController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black87,
      child: Stack(
        children: [
          // Confetti
          ...List.generate(_confetti.length, (index) {
            final particle = _confetti[index];
            return Positioned(
              left: particle.x,
              top: particle.y,
              child: Container(
                width: particle.size,
                height: particle.size,
                decoration: BoxDecoration(
                  color: particle.color,
                  borderRadius: BorderRadius.circular(particle.size / 2),
                ),
              ),
            );
          }),
          
          // Main content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Title
                Text(
                  widget.isHindi ? '🎉 नया बैज मिला!' : '🎉 New Badge Unlocked!',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 40),
                
                // Animated badge
                AnimatedBuilder(
                  animation: Listenable.merge([_scaleController, _rotateController]),
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Transform.rotate(
                        angle: _rotateAnimation.value,
                        child: Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              colors: [
                                Colors.amber.shade300,
                                Colors.amber.shade600,
                                Colors.amber.shade900,
                              ],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.amber.withOpacity(0.5),
                                blurRadius: 30,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              widget.badgeEmoji,
                              style: const TextStyle(fontSize: 64),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 30),
                
                // Badge name
                Text(
                  widget.isHindi ? widget.badgeNameHi : widget.badgeName,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                
                // Description
                Text(
                  widget.isHindi ? widget.descriptionHi : widget.description,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.8),
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 60),
                
                // Continue button
                ElevatedButton(
                  onPressed: widget.onDismiss,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    widget.isHindi ? 'आगे बढ़ें' : 'Continue',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfettiParticle {
  double x;
  double y;
  final Color color;
  final double size;
  final double velocity;
  final Random random;
  double horizontalDrift = 0;

  _ConfettiParticle({
    required this.x,
    required this.y,
    required this.color,
    required this.size,
    required this.velocity,
    required this.random,
  }) {
    horizontalDrift = (random.nextDouble() - 0.5) * 2;
  }

  void update() {
    y += velocity * 3;
    x += horizontalDrift;
    
    // Reset if off screen
    if (y > 800) {
      y = -20;
      x = random.nextDouble() * 400;
    }
  }
}

/// Show badge celebration overlay
void showBadgeCelebration(
  BuildContext context, {
  required String badgeName,
  required String badgeNameHi,
  required String badgeEmoji,
  required String description,
  required String descriptionHi,
  required bool isHindi,
}) {
  Navigator.of(context).push(
    PageRouteBuilder(
      opaque: false,
      pageBuilder: (context, animation, secondaryAnimation) {
        return FadeTransition(
          opacity: animation,
          child: BadgeCelebration(
            badgeName: badgeName,
            badgeNameHi: badgeNameHi,
            badgeEmoji: badgeEmoji,
            description: description,
            descriptionHi: descriptionHi,
            isHindi: isHindi,
            onDismiss: () => Navigator.of(context).pop(),
          ),
        );
      },
    ),
  );
}
