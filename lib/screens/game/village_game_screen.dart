import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../models/game/building.dart';
import '../../models/game/game_event.dart';
import '../../providers/user_provider.dart';
import '../../services/game_service.dart';

/// Sathi Village - Main Game Screen
class VillageGameScreen extends StatefulWidget {
  const VillageGameScreen({super.key});

  @override
  State<VillageGameScreen> createState() => _VillageGameScreenState();
}

class _VillageGameScreenState extends State<VillageGameScreen> with TickerProviderStateMixin {
  late AnimationController _bounceController;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    // Initialize game
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GameService>().init();
    });
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gameService = context.watch<GameService>();
    final userProvider = context.watch<UserProvider>();
    final isHindi = userProvider.language == 'hi';
    final player = gameService.player;

    if (player == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1), // Warm cream
      appBar: _buildAppBar(isHindi, player.coins, player.dayNumber),
      body: Column(
        children: [
          // Status Bar
          _buildStatusBar(player, isHindi),

          // Village Grid
          Expanded(
            child: _buildVillageGrid(gameService, isHindi),
          ),

          // Sathi Guide
          _buildSathiGuide(isHindi, gameService),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isHindi, int coins, int day) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
          ),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
      ),
      title: Row(
        children: [
          const Text('🏘️', style: TextStyle(fontSize: 24)),
          const SizedBox(width: 8),
          Text(
            isHindi ? 'साथी गाँव' : 'Sathi Village',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      actions: [
        // Coins
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              const Text('🪙', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 4),
              Text(
                '$coins',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        // Day
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          margin: const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              const Text('📅', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 4),
              Text(
                isHindi ? 'दिन $day' : 'Day $day',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBar(player, bool isHindi) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            emoji: '⭐',
            label: isHindi ? 'लेवल' : 'Level',
            value: '${player.level}',
            color: Colors.amber,
          ),
          _buildStatItem(
            emoji: '✨',
            label: 'XP',
            value: '${player.xp}/${player.xpForNextLevel}',
            color: Colors.purple,
          ),
          _buildStatItem(
            emoji: '🏦',
            label: isHindi ? 'बैंक' : 'Bank',
            value: '₹${player.bankBalance}',
            color: Colors.blue,
          ),
          if (player.debt > 0)
            _buildStatItem(
              emoji: '💳',
              label: isHindi ? 'कर्ज' : 'Debt',
              value: '₹${player.debt}',
              color: Colors.red,
            ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String emoji,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
            fontSize: 14,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildVillageGrid(GameService gameService, bool isHindi) {
    final player = gameService.player!;
    final availableBuildings = Buildings.availableAt(player.level);

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: availableBuildings.length,
      itemBuilder: (context, index) {
        final building = availableBuildings[index];
        final level = player.getBuildingLevel(building.id);
        final isOwned = level > 0;

        return _buildBuildingCard(
          building: building,
          level: level,
          isOwned: isOwned,
          isHindi: isHindi,
          onTap: () => _showBuildingSheet(building, level, isHindi, gameService),
        );
      },
    );
  }

  Widget _buildBuildingCard({
    required Building building,
    required int level,
    required bool isOwned,
    required bool isHindi,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isOwned ? Colors.white : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isOwned ? const Color(0xFF4CAF50) : Colors.grey.shade300,
            width: isOwned ? 2 : 1,
          ),
          boxShadow: isOwned
              ? [
                  BoxShadow(
                    color: const Color(0xFF4CAF50).withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Building Emoji
            Text(
              building.emoji,
              style: TextStyle(
                fontSize: 40,
                color: isOwned ? null : Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            // Building Name
            Text(
              building.getName(isHindi),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: isOwned ? Colors.black87 : Colors.grey,
              ),
            ),
            // Level Badge
            if (isOwned)
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  isHindi ? 'लेवल $level' : 'Lv.$level',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            else
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '🔒 ₹${building.baseCost}',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showBuildingSheet(
    Building building,
    int currentLevel,
    bool isHindi,
    GameService gameService,
  ) {
    final player = gameService.player!;
    final isOwned = currentLevel > 0;
    final upgradeCost = building.upgradeCost(currentLevel);
    final canAfford = player.canAfford(upgradeCost);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            // Building Header
            Row(
              children: [
                Text(building.emoji, style: const TextStyle(fontSize: 48)),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        building.getName(isHindi),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (isOwned)
                        Text(
                          isHindi ? 'लेवल $currentLevel' : 'Level $currentLevel',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Description
            Text(
              building.getDescription(isHindi),
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),

            // Financial Lesson
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Row(
                children: [
                  const Text('💡', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      building.getLesson(isHindi),
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Income Info
            if (building.dailyIncome > 0)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('📈', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 8),
                    Text(
                      isHindi
                          ? 'रोज की कमाई: ₹${building.incomeAtLevel(isOwned ? currentLevel : 1)}'
                          : 'Daily Income: ₹${building.incomeAtLevel(isOwned ? currentLevel : 1)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 20),

            // Action Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: canAfford
                    ? () async {
                        HapticFeedback.mediumImpact();
                        final success = await gameService.buildOrUpgrade(building);
                        if (success && mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                isHindi
                                    ? '🎉 ${building.getName(isHindi)} ${isOwned ? 'अपग्रेड' : 'बन गया'}!'
                                    : '🎉 ${building.getName(isHindi)} ${isOwned ? 'upgraded' : 'built'}!',
                              ),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  isOwned
                      ? (isHindi ? 'अपग्रेड करें (₹$upgradeCost)' : 'Upgrade (₹$upgradeCost)')
                      : (isHindi ? 'बनाएं (₹$upgradeCost)' : 'Build (₹$upgradeCost)'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSathiGuide(bool isHindi, GameService gameService) {
    // If there's an event, show it
    if (gameService.hasEventToday && gameService.todayEvent != null) {
      return _buildEventCard(gameService.todayEvent!, isHindi, gameService);
    }

    // Otherwise show Sathi tip
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          ScaleTransition(
            scale: Tween<double>(begin: 0.9, end: 1.1).animate(_bounceController),
            child: const Text('🐻', style: TextStyle(fontSize: 32)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isHindi
                  ? 'नमस्ते! इमारतें बनाकर अपना गाँव बढ़ाओ और पैसों की समझ सीखो!'
                  : 'Hello! Build your village and learn about money!',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(GameEvent event, bool isHindi, GameService gameService) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.shade200, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Event Header
          Row(
            children: [
              Text(event.emoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  event.getTitle(isHindi),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: () {
                  gameService.skipEvent();
                },
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Description
          Text(
            event.getDescription(isHindi),
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),

          // Choices
          ...event.choices.map((choice) {
            // Check if choice requires a building
            if (choice.requiresBuilding != null &&
                !gameService.player!.hasBuilding(choice.requiresBuilding!)) {
              return const SizedBox.shrink();
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () async {
                    HapticFeedback.mediumImpact();
                    final result = await gameService.processEventChoice(choice, isHindi);

                    if (mounted) {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          title: Text(
                            choice.coinChange >= 0 ? '✅' : '📢',
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 40),
                          ),
                          content: Text(
                            result,
                            textAlign: TextAlign.center,
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(isHindi ? 'ठीक है' : 'OK'),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    choice.getText(isHindi),
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
