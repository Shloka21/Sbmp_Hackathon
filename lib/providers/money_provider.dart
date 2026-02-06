import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../models/expense.dart';

/// Money Provider for managing expenses, income, and savings goals
class MoneyProvider extends ChangeNotifier {
  List<Expense> _expenses = [];
  List<SavingsGoal> _goals = [];
  bool _isLoading = true;

  // Getters
  List<Expense> get expenses => _expenses;
  List<SavingsGoal> get goals => _goals;
  bool get isLoading => _isLoading;

  // Computed values
  double get totalExpensesThisMonth {
    final now = DateTime.now();
    return _expenses
        .where((e) => 
            !e.isIncome && 
            e.date.month == now.month && 
            e.date.year == now.year)
        .fold(0, (sum, e) => sum + e.amount);
  }

  double get totalIncomeThisMonth {
    final now = DateTime.now();
    return _expenses
        .where((e) => 
            e.isIncome && 
            e.date.month == now.month && 
            e.date.year == now.year)
        .fold(0, (sum, e) => sum + e.amount);
  }

  double get balanceThisMonth => totalIncomeThisMonth - totalExpensesThisMonth;

  Map<String, double> get expensesByCategory {
    final now = DateTime.now();
    final monthExpenses = _expenses.where((e) => 
        !e.isIncome && 
        e.date.month == now.month && 
        e.date.year == now.year);
    
    final categories = <String, double>{};
    for (var expense in monthExpenses) {
      categories[expense.category] = 
          (categories[expense.category] ?? 0) + expense.amount;
    }
    return categories;
  }

  /// Initialize data from storage
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load expenses
      final expensesJson = prefs.getString('expenses');
      if (expensesJson != null) {
        final List<dynamic> decoded = json.decode(expensesJson);
        _expenses = decoded.map((e) => Expense.fromJson(e)).toList();
      }
      
      // Load goals
      final goalsJson = prefs.getString('savings_goals');
      if (goalsJson != null) {
        final List<dynamic> decoded = json.decode(goalsJson);
        _goals = decoded.map((g) => SavingsGoal.fromJson(g)).toList();
      }
    } catch (e) {
      debugPrint('Error loading money data: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Add expense
  Future<void> addExpense(Expense expense) async {
    _expenses.add(expense);
    notifyListeners();
    await _saveExpenses();
  }

  /// Delete expense
  Future<void> deleteExpense(String id) async {
    _expenses.removeWhere((e) => e.id == id);
    notifyListeners();
    await _saveExpenses();
  }

  /// Add savings goal
  Future<void> addGoal(SavingsGoal goal) async {
    _goals.add(goal);
    notifyListeners();
    await _saveGoals();
  }

  /// Update goal progress
  Future<void> updateGoalProgress(String goalId, double amount) async {
    final index = _goals.indexWhere((g) => g.id == goalId);
    if (index != -1) {
      final goal = _goals[index];
      _goals[index] = SavingsGoal(
        id: goal.id,
        title: goal.title,
        targetAmount: goal.targetAmount,
        currentAmount: goal.currentAmount + amount,
        targetDate: goal.targetDate,
        icon: goal.icon,
        createdAt: goal.createdAt,
      );
      notifyListeners();
      await _saveGoals();
    }
  }

  /// Delete goal
  Future<void> deleteGoal(String id) async {
    _goals.removeWhere((g) => g.id == id);
    notifyListeners();
    await _saveGoals();
  }

  /// Get recent transactions
  List<Expense> getRecentTransactions({int limit = 10}) {
    final sorted = [..._expenses]..sort((a, b) => b.date.compareTo(a.date));
    return sorted.take(limit).toList();
  }

  // Private methods
  Future<void> _saveExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'expenses', 
      json.encode(_expenses.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> _saveGoals() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'savings_goals', 
      json.encode(_goals.map((g) => g.toJson()).toList()),
    );
  }
}
