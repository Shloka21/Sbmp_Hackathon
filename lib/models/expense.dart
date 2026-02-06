/// Expense model for money tracking
class Expense {
  final String id;
  final String category;
  final double amount;
  final String? note;
  final DateTime date;
  final bool isIncome;

  Expense({
    required this.id,
    required this.category,
    required this.amount,
    this.note,
    required this.date,
    this.isIncome = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'category': category,
    'amount': amount,
    'note': note,
    'date': date.toIso8601String(),
    'isIncome': isIncome,
  };

  factory Expense.fromJson(Map<String, dynamic> json) => Expense(
    id: json['id'],
    category: json['category'],
    amount: json['amount'].toDouble(),
    note: json['note'],
    date: DateTime.parse(json['date']),
    isIncome: json['isIncome'] ?? false,
  );
}

/// Expense categories with icons
class ExpenseCategory {
  static const List<Map<String, dynamic>> categories = [
    {'id': 'food', 'name': 'Food', 'nameHi': 'खाना', 'icon': '🍽️', 'color': 0xFFE74C3C},
    {'id': 'transport', 'name': 'Transport', 'nameHi': 'यात्रा', 'icon': '🚌', 'color': 0xFF3498DB},
    {'id': 'education', 'name': 'Education', 'nameHi': 'शिक्षा', 'icon': '📚', 'color': 0xFF9B59B6},
    {'id': 'health', 'name': 'Health', 'nameHi': 'स्वास्थ्य', 'icon': '🏥', 'color': 0xFF2ECC71},
    {'id': 'shopping', 'name': 'Shopping', 'nameHi': 'खरीदारी', 'icon': '🛒', 'color': 0xFFF1C40F},
    {'id': 'bills', 'name': 'Bills', 'nameHi': 'बिल', 'icon': '💡', 'color': 0xFFE67E22},
    {'id': 'entertainment', 'name': 'Fun', 'nameHi': 'मनोरंजन', 'icon': '🎬', 'color': 0xFF1ABC9C},
    {'id': 'other', 'name': 'Other', 'nameHi': 'अन्य', 'icon': '📦', 'color': 0xFF95A5A6},
  ];

  static const List<Map<String, dynamic>> incomeCategories = [
    {'id': 'salary', 'name': 'Salary', 'nameHi': 'वेतन', 'icon': '💵', 'color': 0xFF2ECC71},
    {'id': 'business', 'name': 'Business', 'nameHi': 'व्यापार', 'icon': '💼', 'color': 0xFF3498DB},
    {'id': 'farming', 'name': 'Farming', 'nameHi': 'खेती', 'icon': '🌾', 'color': 0xFFF1C40F},
    {'id': 'other', 'name': 'Other', 'nameHi': 'अन्य', 'icon': '💰', 'color': 0xFF9B59B6},
  ];
}

/// Savings goal model
class SavingsGoal {
  final String id;
  final String title;
  final double targetAmount;
  final double currentAmount;
  final DateTime targetDate;
  final String? icon;
  final DateTime createdAt;

  SavingsGoal({
    required this.id,
    required this.title,
    required this.targetAmount,
    this.currentAmount = 0,
    required this.targetDate,
    this.icon,
    required this.createdAt,
  });

  double get progress => targetAmount > 0 ? (currentAmount / targetAmount).clamp(0, 1) : 0;
  
  int get daysRemaining => targetDate.difference(DateTime.now()).inDays;

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'targetAmount': targetAmount,
    'currentAmount': currentAmount,
    'targetDate': targetDate.toIso8601String(),
    'icon': icon,
    'createdAt': createdAt.toIso8601String(),
  };

  factory SavingsGoal.fromJson(Map<String, dynamic> json) => SavingsGoal(
    id: json['id'],
    title: json['title'],
    targetAmount: json['targetAmount'].toDouble(),
    currentAmount: json['currentAmount']?.toDouble() ?? 0,
    targetDate: DateTime.parse(json['targetDate']),
    icon: json['icon'],
    createdAt: DateTime.parse(json['createdAt']),
  );
}
