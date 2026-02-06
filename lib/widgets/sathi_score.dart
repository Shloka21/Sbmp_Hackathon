import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../config/theme.dart';

/// Sathi Score - Financial Health Score Widget
class SathiScoreWidget extends StatelessWidget {
  final int score; // 0-100
  final int change; // positive or negative change
  final List<ScoreFactor> factors;
  final VoidCallback? onTap;

  const SathiScoreWidget({
    super.key,
    required this.score,
    this.change = 0,
    this.factors = const [],
    this.onTap,
  });

  Color get _scoreColor {
    if (score >= 80) return Colors.green;
    if (score >= 60) return AppColors.primary;
    if (score >= 40) return Colors.orange;
    return Colors.red;
  }

  String get _scoreLabel {
    if (score >= 80) return 'Excellent';
    if (score >= 60) return 'Good';
    if (score >= 40) return 'Fair';
    return 'Needs Work';
  }

  String get _emoji {
    if (score >= 80) return '🌟';
    if (score >= 60) return '😊';
    if (score >= 40) return '🙂';
    return '💪';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              _scoreColor.withValues(alpha: 0.1),
              _scoreColor.withValues(alpha: 0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: _scoreColor.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Text('$_emoji Sathi Score', style: AppTypography.titleMedium),
                const Spacer(),
                if (change != 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: change > 0 ? Colors.green : Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${change > 0 ? '+' : ''}$change',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 120,
              height: 120,
              child: CustomPaint(
                painter: _ScoreRingPainter(
                  score: score,
                  color: _scoreColor,
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$score',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: _scoreColor,
                        ),
                      ),
                      Text(
                        _scoreLabel,
                        style: TextStyle(
                          fontSize: 12,
                          color: _scoreColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (factors.isNotEmpty) ...[
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 12),
              ...factors.take(3).map((factor) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(
                      factor.completed ? Icons.check_circle : Icons.circle_outlined,
                      size: 18,
                      color: factor.completed ? Colors.green : Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        factor.label,
                        style: TextStyle(
                          fontSize: 13,
                          color: factor.completed 
                              ? AppColors.textPrimary 
                              : Colors.grey,
                          decoration: factor.completed 
                              ? null 
                              : TextDecoration.lineThrough,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
              const SizedBox(height: 4),
              Text(
                'Tap for details',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ScoreRingPainter extends CustomPainter {
  final int score;
  final Color color;

  _ScoreRingPainter({required this.score, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;
    
    // Background ring
    final bgPaint = Paint()
      ..color = Colors.grey.shade200
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;
    
    canvas.drawCircle(center, radius, bgPaint);
    
    // Score ring
    final scorePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;
    
    final sweepAngle = (score / 100) * 2 * math.pi;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      scorePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class ScoreFactor {
  final String label;
  final bool completed;

  const ScoreFactor({required this.label, required this.completed});
}

/// Calculate Sathi Score based on user activity
class SathiScoreCalculator {
  static int calculateScore({
    required int totalXp,
    required int streakDays,
    required int badgesEarned,
    required int schemesExplored,
    required bool hasEmergencyFund,
    required bool tracksExpenses,
  }) {
    int score = 20; // Base score
    
    // XP contribution (max 20 points)
    score += (totalXp / 100).clamp(0, 20).toInt();
    
    // Streak contribution (max 15 points)
    score += (streakDays * 2).clamp(0, 15);
    
    // Badges contribution (max 15 points)
    score += (badgesEarned * 3).clamp(0, 15);
    
    // Schemes explored (max 10 points)
    score += (schemesExplored * 2).clamp(0, 10);
    
    // Emergency fund (10 points)
    if (hasEmergencyFund) score += 10;
    
    // Expense tracking (10 points)
    if (tracksExpenses) score += 10;
    
    return score.clamp(0, 100);
  }

  static List<ScoreFactor> getFactors({
    required int streakDays,
    required bool hasEmergencyFund,
    required bool tracksExpenses,
    required int lessonsCompleted,
  }) {
    return [
      ScoreFactor(
        label: 'Regular expense tracking',
        completed: tracksExpenses,
      ),
      ScoreFactor(
        label: 'Emergency savings started',
        completed: hasEmergencyFund,
      ),
      ScoreFactor(
        label: '7+ day learning streak',
        completed: streakDays >= 7,
      ),
      ScoreFactor(
        label: 'Completed 5+ lessons',
        completed: lessonsCompleted >= 5,
      ),
    ];
  }
}

/// Compact score display for home screen
class SathiScoreCompact extends StatelessWidget {
  final int score;
  final VoidCallback? onTap;

  const SathiScoreCompact({
    super.key,
    required this.score,
    this.onTap,
  });

  Color get _scoreColor {
    if (score >= 80) return Colors.green;
    if (score >= 60) return AppColors.primary;
    if (score >= 40) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: _scoreColor.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _scoreColor.withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '🎯',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(width: 6),
            Text(
              '$score',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _scoreColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
