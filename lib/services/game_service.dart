import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/game/game_player.dart';
import '../models/game/building.dart';
import '../models/game/game_event.dart';

/// Game Service for Sathi Village
/// Handles game logic, persistence, and daily mechanics
class GameService extends ChangeNotifier {
  GamePlayer? _player;
  int _lastPlayedDay = 0;
  bool _hasEventToday = false;
  GameEvent? _todayEvent;

  GamePlayer? get player => _player;
  bool get hasPlayer => _player != null;
  bool get hasEventToday => _hasEventToday;
  GameEvent? get todayEvent => _todayEvent;

  /// Initialize or load existing game
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final savedData = prefs.getString('sathi_village_player');

    if (savedData != null) {
      try {
        _player = GamePlayer.fromJson(jsonDecode(savedData));
        _lastPlayedDay = prefs.getInt('sathi_village_last_day') ?? 0;
      } catch (e) {
        debugPrint('Error loading game: $e');
        _player = GamePlayer.newPlayer();
      }
    } else {
      _player = GamePlayer.newPlayer();
    }

    _checkDailyReset();
    notifyListeners();
  }

  /// Check if we need to process a new day
  void _checkDailyReset() {
    final today = DateTime.now().day;
    if (_lastPlayedDay != today && _player != null) {
      _processNewDay();
      _lastPlayedDay = today;
      _saveGame();
    }
  }

  /// Process new day mechanics
  void _processNewDay() {
    if (_player == null) return;

    // Increment day
    _player!.dayNumber++;

    // Collect income from all buildings
    int dailyIncome = 0;
    _player!.buildingLevels.forEach((buildingId, level) {
      final building = Buildings.getById(buildingId);
      if (building != null) {
        dailyIncome += building.incomeAtLevel(level);
      }
    });
    _player!.earn(dailyIncome);

    // Calculate bank interest (daily, simplified)
    if (_player!.bankBalance > 0) {
      final interest = (_player!.bankBalance * 0.001).round(); // 0.1% daily (~36% annual for simplicity)
      _player!.bankBalance += interest;
    }

    // Maybe show an event (40% chance)
    final shouldShowEvent = DateTime.now().millisecondsSinceEpoch % 10 < 4;
    if (shouldShowEvent) {
      _todayEvent = GameEvents.getRandomEvent(
        _player!.buildingLevels.keys.toSet(),
      );
      _hasEventToday = _todayEvent != null;
    } else {
      _hasEventToday = false;
      _todayEvent = null;
    }

    // Award daily XP
    _player!.addXP(10);

    notifyListeners();
  }

  /// Process a player's choice for an event
  Future<String> processEventChoice(EventChoice choice, bool isHindi) async {
    if (_player == null) return '';

    // Apply coin change
    if (choice.coinChange != 0) {
      if (choice.coinChange > 0) {
        _player!.earn(choice.coinChange);
      } else {
        _player!.spend(-choice.coinChange);
      }
    }

    // Handle debt if choice takes debt
    if (choice.takesDept) {
      _player!.debt += 550; // Example: 500 loan + 50 interest
    }

    // Award XP
    final leveledUp = _player!.addXP(choice.xpReward);

    // Clear today's event
    _hasEventToday = false;
    _todayEvent = null;

    // Check for badge awards
    _checkBadges();

    await _saveGame();
    notifyListeners();

    // Return consequence and advice
    String result = choice.getConsequence(isHindi);
    result += '\n\n🐻 ${choice.getAdvice(isHindi)}';
    if (leveledUp) {
      result += isHindi
          ? '\n\n🎉 बधाई! आप लेवल ${_player!.level} पर पहुंच गए!'
          : '\n\n🎉 Congratulations! You reached Level ${_player!.level}!';
    }

    return result;
  }

  /// Check and award badges
  void _checkBadges() {
    if (_player == null) return;

    // Savings Champion - ₹1000 in bank
    if (_player!.bankBalance >= 1000 && !_player!.badges.contains('savings_champion')) {
      _player!.awardBadge('savings_champion');
    }

    // Debt Free - no debt
    if (_player!.debt == 0 && _player!.badges.contains('first_loan') && !_player!.badges.contains('debt_free')) {
      _player!.awardBadge('debt_free');
    }

    // Scheme Explorer - has govt office
    if (_player!.hasBuilding('govt') && !_player!.badges.contains('scheme_explorer')) {
      _player!.awardBadge('scheme_explorer');
    }

    // Super Farmer - farm level 3+
    if (_player!.getBuildingLevel('farm') >= 3 && !_player!.badges.contains('super_farmer')) {
      _player!.awardBadge('super_farmer');
    }
  }

  /// Build or upgrade a building
  Future<bool> buildOrUpgrade(Building building) async {
    if (_player == null) return false;

    final currentLevel = _player!.getBuildingLevel(building.id);
    final cost = building.upgradeCost(currentLevel);

    // Check if player can afford and meets level requirement
    if (!_player!.canAfford(cost)) return false;
    if (_player!.level < building.unlockLevel) return false;

    _player!.spend(cost);
    _player!.buildOrUpgrade(building.id);
    _player!.addXP(50);

    _checkBadges();
    await _saveGame();
    notifyListeners();

    return true;
  }

  /// Deposit money to bank
  Future<void> depositToBank(int amount) async {
    if (_player == null) return;
    _player!.deposit(amount);
    await _saveGame();
    notifyListeners();
  }

  /// Withdraw from bank
  Future<void> withdrawFromBank(int amount) async {
    if (_player == null) return;
    _player!.withdraw(amount);
    await _saveGame();
    notifyListeners();
  }

  /// Skip today's event
  void skipEvent() {
    _hasEventToday = false;
    _todayEvent = null;
    notifyListeners();
  }

  /// Get daily income from all buildings
  int get dailyIncome {
    if (_player == null) return 0;
    int income = 0;
    _player!.buildingLevels.forEach((buildingId, level) {
      final building = Buildings.getById(buildingId);
      if (building != null) {
        income += building.incomeAtLevel(level);
      }
    });
    return income;
  }

  /// Save game to storage
  Future<void> _saveGame() async {
    if (_player == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('sathi_village_player', jsonEncode(_player!.toJson()));
    await prefs.setInt('sathi_village_last_day', _lastPlayedDay);
  }

  /// Reset game (for testing)
  Future<void> resetGame() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('sathi_village_player');
    await prefs.remove('sathi_village_last_day');
    _player = GamePlayer.newPlayer();
    _lastPlayedDay = 0;
    _hasEventToday = false;
    _todayEvent = null;
    notifyListeners();
  }
}
