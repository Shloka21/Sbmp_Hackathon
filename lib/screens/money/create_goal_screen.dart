import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../config/theme.dart';
import '../../models/expense.dart';
import '../../providers/money_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/common/widgets.dart';

class CreateGoalScreen extends StatefulWidget {
  const CreateGoalScreen({super.key});

  @override
  State<CreateGoalScreen> createState() => _CreateGoalScreenState();
}

class _CreateGoalScreenState extends State<CreateGoalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _monthsController = TextEditingController();

  String _selectedCategory = 'other';
  bool _reminderEnabled = false;
  double _monthlySavings = 0;

  final Map<String, String> _categories = {
    'education': '🎓 Education',
    'vehicle': '🛵 Vehicle',
    'home': '🏠 Home',
    'emergency': '🆘 Emergency',
    'travel': '✈️ Travel',
    'gadget': '📱 Gadget',
    'wedding': '💍 Wedding',
    'other': '🎯 Other',
  };
  
  final Map<String, String> _categoriesHi = {
    'education': '🎓 शिक्षा',
    'vehicle': '🛵 गाड़ी',
    'home': '🏠 घर',
    'emergency': '🆘 इमरजेंसी',
    'travel': '✈️ यात्रा',
    'gadget': '📱 गैजेट',
    'wedding': '💍 शादी',
    'other': '🎯 अन्य',
  };

  @override
  void initState() {
    super.initState();
    _amountController.addListener(_calculateMonthly);
    _monthsController.addListener(_calculateMonthly);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _monthsController.dispose();
    super.dispose();
  }

  void _calculateMonthly() {
    final amount = double.tryParse(_amountController.text) ?? 0;
    final months = double.tryParse(_monthsController.text) ?? 0;
    
    setState(() {
      if (amount > 0 && months > 0) {
        _monthlySavings = amount / months;
      } else {
        _monthlySavings = 0;
      }
    });
  }

  void _saveGoal() {
    if (!_formKey.currentState!.validate()) return;

    final title = _titleController.text.trim();
    final amount = double.parse(_amountController.text);
    final months = int.parse(_monthsController.text);
    final targetDate = DateTime.now().add(Duration(days: months * 30));

    final newGoal = SavingsGoal(
      id: const Uuid().v4(),
      title: title,
      targetAmount: amount,
      targetDate: targetDate,
      category: _selectedCategory,
      reminderEnabled: _reminderEnabled,
      createdAt: DateTime.now(),
      icon: _categories[_selectedCategory]!.split(' ')[0], // Extract emoji
    );

    context.read<MoneyProvider>().addGoal(newGoal);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Savings Goal Created Successfully! 🎉'),
        backgroundColor: AppColors.success,
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final isHindi = userProvider.language == 'hi';
    final categories = isHindi ? _categoriesHi : _categories;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isHindi ? 'नया लक्ष्य बनाएं' : 'Create New Goal'),
        backgroundColor: AppColors.primaryDark,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            // Header Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Text('🎯', style: TextStyle(fontSize: 48)),
                  const SizedBox(height: 12),
                  Text(
                    isHindi 
                        ? 'अपने सपने पूरे करें!' 
                        : 'Achieve Your Dreams!',
                    style: AppTypography.headlineSmall.copyWith(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isHindi 
                        ? 'बचत लक्ष्य बनाएं और ट्रैक करें' 
                        : 'Set a goal and track your savings',
                    style: AppTypography.bodyMedium.copyWith(color: Colors.white70),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),

            // Goal Name
            Text(
              isHindi ? 'लक्ष्य का नाम' : 'Goal Name',
              style: AppTypography.labelLarge,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: isHindi ? 'जैसे: नई बाइक' : 'e.g., New Bike',
                prefixIcon: const Icon(Icons.edit),
              ),
              validator: (v) => v!.isEmpty ? (isHindi ? 'नाम लिखें' : 'Enter name') : null,
            ),

            const SizedBox(height: 16),

            // Category
            Text(
              isHindi ? 'श्रेणी' : 'Category',
              style: AppTypography.labelLarge,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedCategory,
                  isExpanded: true,
                  items: categories.entries.map((e) {
                    return DropdownMenuItem(
                      value: e.key,
                      child: Text(e.value),
                    );
                  }).toList(),
                  onChanged: (v) => setState(() => _selectedCategory = v!),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Target Amount
            Text(
              isHindi ? 'कुल राशि (₹)' : 'Target Amount (₹)',
              style: AppTypography.labelLarge,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                prefixText: '₹ ',
                prefixIcon: Icon(Icons.currency_rupee),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return isHindi ? 'राशि लिखें' : 'Enter amount';
                if (double.tryParse(v) == null || double.parse(v) <= 0) return isHindi ? 'सही राशि लिखें' : 'Invalid amount';
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Time Period
            Text(
              isHindi ? 'समय (महीने)' : 'Time Period (months)',
              style: AppTypography.labelLarge,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _monthsController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.calendar_month),
                suffixText: 'months',
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return isHindi ? 'समय लिखें' : 'Enter months';
                if (int.tryParse(v) == null || int.parse(v) <= 0) return isHindi ? 'सही समय लिखें' : 'Invalid duration';
                return null;
              },
            ),

            const SizedBox(height: 24),

            // Visual Calculator
            if (_monthlySavings > 0)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Text(
                      isHindi ? 'आपको हर महीने बचाना होगा:' : 'You need to save monthly:',
                      style: AppTypography.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '₹${_monthlySavings.toStringAsFixed(0)}',
                      style: AppTypography.headlineMedium.copyWith(color: AppColors.primary),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 24),

            // Reminders Toggle
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                isHindi ? 'रिमाइंडर सेट करें' : 'Set Reminders',
                style: AppTypography.titleMedium,
              ),
              subtitle: Text(
                isHindi ? 'हम आपको हर महीने याद दिलाएंगे' : 'We will remind you monthly',
                style: AppTypography.bodySmall,
              ),
              value: _reminderEnabled,
              onChanged: (v) => setState(() => _reminderEnabled = v),
              activeColor: AppColors.primary,
            ),

            const SizedBox(height: 32),

            // Create Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveGoal,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  isHindi ? 'लक्ष्य बनाएं' : 'Create Goal',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
