/// Game Player Model for Sathi Village
class GamePlayer {
  String id;
  String name;
  int coins;
  int bankBalance;
  int debt;
  int xp;
  int level;
  int dayNumber;
  List<String> badges;
  Map<String, int> buildingLevels;

  GamePlayer({
    required this.id,
    this.name = 'Player',
    this.coins = 500,
    this.bankBalance = 0,
    this.debt = 0,
    this.xp = 0,
    this.level = 1,
    this.dayNumber = 1,
    List<String>? badges,
    Map<String, int>? buildingLevels,
  })  : badges = badges ?? [],
        buildingLevels = buildingLevels ?? {};

  /// Calculate total net worth
  int get netWorth => coins + bankBalance - debt;

  /// Check if player can afford something
  bool canAfford(int amount) => coins >= amount;

  /// Spend coins
  void spend(int amount) {
    if (canAfford(amount)) {
      coins -= amount;
    }
  }

  /// Earn coins
  void earn(int amount) {
    coins += amount;
  }

  /// Deposit to bank
  void deposit(int amount) {
    if (canAfford(amount)) {
      coins -= amount;
      bankBalance += amount;
    }
  }

  /// Withdraw from bank
  void withdraw(int amount) {
    if (bankBalance >= amount) {
      bankBalance -= amount;
      coins += amount;
    }
  }

  /// Take a loan
  void takeLoan(int amount) {
    coins += amount;
    debt += amount;
  }

  /// Pay off debt
  void payDebt(int amount) {
    if (canAfford(amount) && debt > 0) {
      final payment = amount > debt ? debt : amount;
      coins -= payment;
      debt -= payment;
    }
  }

  /// Add XP and check for level up
  bool addXP(int amount) {
    xp += amount;
    final newLevel = _calculateLevel();
    if (newLevel > level) {
      level = newLevel;
      return true; // Leveled up
    }
    return false;
  }

  int _calculateLevel() {
    if (xp >= 3500) return 6;
    if (xp >= 2000) return 5;
    if (xp >= 1000) return 4;
    if (xp >= 500) return 3;
    if (xp >= 200) return 2;
    return 1;
  }

  /// XP needed for next level
  int get xpForNextLevel {
    switch (level) {
      case 1: return 200;
      case 2: return 500;
      case 3: return 1000;
      case 4: return 2000;
      case 5: return 3500;
      default: return 5000;
    }
  }

  /// Check if player has a building
  bool hasBuilding(String buildingId) => buildingLevels.containsKey(buildingId);

  /// Get building level
  int getBuildingLevel(String buildingId) => buildingLevels[buildingId] ?? 0;

  /// Build or upgrade a building
  void buildOrUpgrade(String buildingId) {
    buildingLevels[buildingId] = (buildingLevels[buildingId] ?? 0) + 1;
  }

  /// Award a badge
  void awardBadge(String badgeId) {
    if (!badges.contains(badgeId)) {
      badges.add(badgeId);
    }
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'coins': coins,
        'bankBalance': bankBalance,
        'debt': debt,
        'xp': xp,
        'level': level,
        'dayNumber': dayNumber,
        'badges': badges,
        'buildingLevels': buildingLevels,
      };

  /// Create from JSON
  factory GamePlayer.fromJson(Map<String, dynamic> json) => GamePlayer(
        id: json['id'] ?? 'player_1',
        name: json['name'] ?? 'Player',
        coins: json['coins'] ?? 500,
        bankBalance: json['bankBalance'] ?? 0,
        debt: json['debt'] ?? 0,
        xp: json['xp'] ?? 0,
        level: json['level'] ?? 1,
        dayNumber: json['dayNumber'] ?? 1,
        badges: List<String>.from(json['badges'] ?? []),
        buildingLevels: Map<String, int>.from(json['buildingLevels'] ?? {}),
      );

  /// Create a new player
  factory GamePlayer.newPlayer() => GamePlayer(
        id: 'player_${DateTime.now().millisecondsSinceEpoch}',
        coins: 500,
        buildingLevels: {'bank': 1}, // Start with a basic bank
      );
}
