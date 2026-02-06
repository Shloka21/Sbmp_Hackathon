/// User Profile Model
class UserProfile {
  final String id;
  final String name;
  final String language;
  final String occupation;
  final String incomeRange;
  final String? state;
  final int? age;
  final DateTime createdAt;
  final int level;
  final int xp;
  final List<String> badges;
  final int streak;

  UserProfile({
    required this.id,
    required this.name,
    required this.language,
    required this.occupation,
    required this.incomeRange,
    this.state,
    this.age,
    required this.createdAt,
    this.level = 1,
    this.xp = 0,
    this.badges = const [],
    this.streak = 0,
  });

  UserProfile copyWith({
    String? id,
    String? name,
    String? language,
    String? occupation,
    String? incomeRange,
    String? state,
    int? age,
    DateTime? createdAt,
    int? level,
    int? xp,
    List<String>? badges,
    int? streak,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      language: language ?? this.language,
      occupation: occupation ?? this.occupation,
      incomeRange: incomeRange ?? this.incomeRange,
      state: state ?? this.state,
      age: age ?? this.age,
      createdAt: createdAt ?? this.createdAt,
      level: level ?? this.level,
      xp: xp ?? this.xp,
      badges: badges ?? this.badges,
      streak: streak ?? this.streak,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'language': language,
    'occupation': occupation,
    'incomeRange': incomeRange,
    'state': state,
    'age': age,
    'createdAt': createdAt.toIso8601String(),
    'level': level,
    'xp': xp,
    'badges': badges,
    'streak': streak,
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    id: json['id'],
    name: json['name'],
    language: json['language'],
    occupation: json['occupation'],
    incomeRange: json['incomeRange'],
    state: json['state'],
    age: json['age'],
    createdAt: DateTime.parse(json['createdAt']),
    level: json['level'] ?? 1,
    xp: json['xp'] ?? 0,
    badges: List<String>.from(json['badges'] ?? []),
    streak: json['streak'] ?? 0,
  );
}
