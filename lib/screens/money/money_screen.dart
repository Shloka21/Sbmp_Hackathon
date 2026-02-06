import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../config/theme.dart';
import '../../models/expense.dart';
import '../../providers/user_provider.dart';
import '../../providers/money_provider.dart';
import '../../widgets/common/widgets.dart';

/// Money Management Screen - Track expenses, income, and savings goals
class MoneyScreen extends StatefulWidget {
  const MoneyScreen({super.key});

  @override
  State<MoneyScreen> createState() => _MoneyScreenState();
}

class _MoneyScreenState extends State<MoneyScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Initialize money provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MoneyProvider>().initialize();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final isHindi = userProvider.language == 'hi';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isHindi ? '💰 पैसा प्रबंधन' : '💰 Money Manager'),
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primaryAccent,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: [
            Tab(text: isHindi ? 'खर्च' : 'Expenses'),
            Tab(text: isHindi ? 'विश्लेषण' : 'Analytics'),
            Tab(text: isHindi ? 'लक्ष्य' : 'Goals'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _ExpensesTab(isHindi: isHindi),
          _AnalyticsTab(isHindi: isHindi),
          _GoalsTab(isHindi: isHindi),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddExpenseDialog(context, isHindi),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add),
        label: Text(isHindi ? 'जोड़ें' : 'Add'),
      ),
    );
  }

  void _showAddExpenseDialog(BuildContext context, bool isHindi) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddExpenseSheet(isHindi: isHindi),
    );
  }
}

class _ExpensesTab extends StatelessWidget {
  final bool isHindi;

  const _ExpensesTab({required this.isHindi});

  @override
  Widget build(BuildContext context) {
    final moneyProvider = context.watch<MoneyProvider>();
    final currencyFormat = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        // Summary cards
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                title: isHindi ? 'आय' : 'Income',
                amount: currencyFormat.format(moneyProvider.totalIncomeThisMonth),
                icon: Icons.arrow_downward,
                color: AppColors.success,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SummaryCard(
                title: isHindi ? 'खर्च' : 'Expenses',
                amount: currencyFormat.format(moneyProvider.totalExpensesThisMonth),
                icon: Icons.arrow_upward,
                color: AppColors.error,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        // Balance card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: Row(
            children: [
              const Text('💵', style: TextStyle(fontSize: 40)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isHindi ? 'इस महीने बचत' : 'Balance This Month',
                      style: AppTypography.bodyMedium.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                    Text(
                      currencyFormat.format(moneyProvider.balanceThisMonth),
                      style: AppTypography.headlineLarge.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: AppSpacing.xl),
        
        // Recent transactions
        Text(
          isHindi ? 'हाल के लेनदेन' : 'Recent Transactions',
          style: AppTypography.headlineSmall,
        ),
        const SizedBox(height: 16),
        
        if (moneyProvider.expenses.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  const Text('📝', style: TextStyle(fontSize: 64)),
                  const SizedBox(height: 16),
                  Text(
                    isHindi 
                        ? 'कोई लेनदेन नहीं\n+ बटन दबाकर जोड़ें' 
                        : 'No transactions yet\nTap + to add one',
                    style: AppTypography.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          )
        else
          ...moneyProvider.getRecentTransactions().map((expense) {
            final category = expense.isIncome
                ? ExpenseCategory.incomeCategories.firstWhere(
                    (c) => c['id'] == expense.category,
                    orElse: () => ExpenseCategory.incomeCategories.last,
                  )
                : ExpenseCategory.categories.firstWhere(
                    (c) => c['id'] == expense.category,
                    orElse: () => ExpenseCategory.categories.last,
                  );
            
            return _TransactionCard(
              icon: category['icon'],
              title: isHindi ? category['nameHi'] : category['name'],
              note: expense.note,
              amount: expense.amount,
              isIncome: expense.isIncome,
              date: expense.date,
            );
          }),
      ],
    );
  }
}

class _AnalyticsTab extends StatelessWidget {
  final bool isHindi;

  const _AnalyticsTab({required this.isHindi});

  @override
  Widget build(BuildContext context) {
    final moneyProvider = context.watch<MoneyProvider>();
    final categoryData = moneyProvider.expensesByCategory;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Text(
          isHindi ? 'खर्च विश्लेषण' : 'Expense Analysis',
          style: AppTypography.headlineSmall,
        ),
        const SizedBox(height: 8),
        Text(
          isHindi ? 'इस महीने का खर्च' : 'This month\'s spending',
          style: AppTypography.bodyMedium,
        ),
        const SizedBox(height: AppSpacing.xl),
        
        if (categoryData.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  const Text('📊', style: TextStyle(fontSize: 64)),
                  const SizedBox(height: 16),
                  Text(
                    isHindi 
                        ? 'डेटा अभी उपलब्ध नहीं है' 
                        : 'No data available yet',
                    style: AppTypography.bodyLarge,
                  ),
                ],
              ),
            ),
          )
        else
          Container(
            height: 250,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: PieChart(
              PieChartData(
                sections: categoryData.entries.map((entry) {
                  final category = ExpenseCategory.categories.firstWhere(
                    (c) => c['id'] == entry.key,
                    orElse: () => ExpenseCategory.categories.last,
                  );
                  return PieChartSectionData(
                    value: entry.value,
                    title: '${category['icon']}\n₹${entry.value.toInt()}',
                    color: Color(category['color']),
                    radius: 80,
                    titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  );
                }).toList(),
                centerSpaceRadius: 40,
              ),
            ),
          ),
        
        const SizedBox(height: AppSpacing.xl),
        
        // Category breakdown
        Text(
          isHindi ? 'श्रेणी के अनुसार' : 'By Category',
          style: AppTypography.titleLarge,
        ),
        const SizedBox(height: 16),
        
        ...categoryData.entries.map((entry) {
          final category = ExpenseCategory.categories.firstWhere(
            (c) => c['id'] == entry.key,
            orElse: () => ExpenseCategory.categories.last,
          );
          final total = categoryData.values.fold(0.0, (a, b) => a + b);
          final percentage = total > 0 ? (entry.value / total * 100) : 0;
          
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Text(category['icon'], style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isHindi ? category['nameHi'] : category['name'],
                        style: AppTypography.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: percentage / 100,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(category['color']),
                          ),
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₹${entry.value.toInt()}',
                      style: AppTypography.titleMedium,
                    ),
                    Text(
                      '${percentage.toStringAsFixed(0)}%',
                      style: AppTypography.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class _GoalsTab extends StatelessWidget {
  final bool isHindi;

  const _GoalsTab({required this.isHindi});

  @override
  Widget build(BuildContext context) {
    final moneyProvider = context.watch<MoneyProvider>();

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Text(
          isHindi ? '🎯 बचत लक्ष्य' : '🎯 Savings Goals',
          style: AppTypography.headlineSmall,
        ),
        const SizedBox(height: 16),
        
        if (moneyProvider.goals.isEmpty)
          GestureDetector(
            onTap: () => _showAddGoalDialog(context, isHindi),
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.3),
                  width: 2,
                  style: BorderStyle.solid,
                ),
              ),
              child: Column(
                children: [
                  const Text('🎯', style: TextStyle(fontSize: 64)),
                  const SizedBox(height: 16),
                  Text(
                    isHindi 
                        ? 'अपना पहला लक्ष्य बनाएं!' 
                        : 'Create your first goal!',
                    style: AppTypography.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isHindi 
                        ? 'टैप करें' 
                        : 'Tap to add',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ...moneyProvider.goals.map((goal) {
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(goal.icon ?? '🎯', style: const TextStyle(fontSize: 32)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(goal.title, style: AppTypography.titleLarge),
                            Text(
                              '${goal.daysRemaining} ${isHindi ? 'दिन बाकी' : 'days left'}',
                              style: AppTypography.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: goal.progress,
                      backgroundColor: AppColors.background,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                      minHeight: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '₹${goal.currentAmount.toInt()}',
                        style: AppTypography.titleMedium.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      Text(
                        '₹${goal.targetAmount.toInt()}',
                        style: AppTypography.titleMedium,
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }

  void _showAddGoalDialog(BuildContext context, bool isHindi) {
    // Simple goal dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isHindi ? 'नया लक्ष्य' : 'New Goal'),
        content: Text(isHindi 
            ? 'Sathi AI से बात करें और अपना लक्ष्य बताएं!' 
            : 'Talk to Sathi AI to set your goal!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(isHindi ? 'ठीक है' : 'OK'),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String amount;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.amount,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.bodySmall),
                Text(
                  amount,
                  style: AppTypography.titleLarge.copyWith(color: color),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  final String icon;
  final String title;
  final String? note;
  final double amount;
  final bool isIncome;
  final DateTime date;

  const _TransactionCard({
    required this.icon,
    required this.title,
    this.note,
    required this.amount,
    required this.isIncome,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.titleMedium),
                if (note != null && note!.isNotEmpty)
                  Text(
                    note!,
                    style: AppTypography.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isIncome ? '+' : '-'}₹${amount.toInt()}',
                style: AppTypography.titleMedium.copyWith(
                  color: isIncome ? AppColors.success : AppColors.error,
                ),
              ),
              Text(
                DateFormat('dd MMM').format(date),
                style: AppTypography.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AddExpenseSheet extends StatefulWidget {
  final bool isHindi;

  const _AddExpenseSheet({required this.isHindi});

  @override
  State<_AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends State<_AddExpenseSheet> {
  bool _isIncome = false;
  String? _selectedCategory;
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = _isIncome 
        ? ExpenseCategory.incomeCategories 
        : ExpenseCategory.categories;

    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Toggle income/expense
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _isIncome = false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: !_isIncome ? AppColors.error : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          widget.isHindi ? '💸 खर्च' : '💸 Expense',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: !_isIncome ? Colors.white : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _isIncome = true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _isIncome ? AppColors.success : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          widget.isHindi ? '💰 आय' : '💰 Income',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: _isIncome ? Colors.white : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Amount
            Text(
              widget.isHindi ? 'राशि' : 'Amount',
              style: AppTypography.labelLarge,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              style: AppTypography.headlineMedium,
              decoration: InputDecoration(
                prefixText: '₹ ',
                hintText: '0',
                filled: true,
                fillColor: AppColors.background,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Category
            Text(
              widget.isHindi ? 'श्रेणी' : 'Category',
              style: AppTypography.labelLarge,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: categories.map((cat) {
                final isSelected = _selectedCategory == cat['id'];
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = cat['id']),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? Color(cat['color']) 
                          : AppColors.background,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(cat['icon'], style: const TextStyle(fontSize: 16)),
                        const SizedBox(width: 6),
                        Text(
                          widget.isHindi ? cat['nameHi'] : cat['name'],
                          style: TextStyle(
                            color: isSelected ? Colors.white : AppColors.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            
            const SizedBox(height: 24),
            
            // Note
            Text(
              widget.isHindi ? 'नोट (वैकल्पिक)' : 'Note (optional)',
              style: AppTypography.labelLarge,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _noteController,
              decoration: InputDecoration(
                hintText: widget.isHindi ? 'विवरण लिखें...' : 'Add details...',
                filled: true,
                fillColor: AppColors.background,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Save button
            PrimaryButton(
              text: widget.isHindi ? 'सहेजें' : 'Save',
              onPressed: _saveExpense,
            ),
          ],
        ),
      ),
    );
  }

  void _saveExpense() {
    if (_amountController.text.isEmpty || _selectedCategory == null) {
      return;
    }

    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) return;

    final expense = Expense(
      id: const Uuid().v4(),
      category: _selectedCategory!,
      amount: amount,
      note: _noteController.text.isEmpty ? null : _noteController.text,
      date: DateTime.now(),
      isIncome: _isIncome,
    );

    context.read<MoneyProvider>().addExpense(expense);
    Navigator.pop(context);
  }
}
