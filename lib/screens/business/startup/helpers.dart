import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Oscar Helper - Shows smart suggestions and messages via SnackBar
class OscarHelper extends ChangeNotifier {
  /// Show a message to the user via SnackBar
  void showMessage(String message, {BuildContext? context}) {
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF1A8D4F),
          duration: const Duration(seconds: 4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  /// Show a smart suggestion overlay
  void showSuggestion(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Text('🐻', style: TextStyle(fontSize: 28)),
            const SizedBox(width: 8),
            Expanded(child: Text(title, style: const TextStyle(fontSize: 18))),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }
}

/// Business Storage Helper - SharedPreferences-based storage for business plans
class BusinessStorageHelper {
  static const String _businessPlansKey = 'business_plans';
  static const String _checklistKey = 'business_checklist';

  /// Get all business templates (static data)
  static List<Map<String, dynamic>> getBusinessTemplates() {
    return [
      {
        'id': 1,
        'name': 'Vegetable/Fruit Shop',
        'name_hi': 'सब्जी/फल की दुकान',
        'icon': '🥬',
        'min_investment': 5000,
        'max_investment': 20000,
        'daily_profit': '300-500',
        'season_rainy': 0.8,
        'season_festival': 1.3,
        'season_wedding': 1.1,
        'description': 'Sell fresh vegetables and fruits in your local area',
        'description_hi': 'अपने क्षेत्र में ताज़ी सब्जियां और फल बेचें',
      },
      {
        'id': 2,
        'name': 'Tailoring Business',
        'name_hi': 'सिलाई/टेलरिंग',
        'icon': '🧵',
        'min_investment': 10000,
        'max_investment': 30000,
        'daily_profit': '200-500',
        'season_rainy': 0.9,
        'season_festival': 1.5,
        'season_wedding': 1.8,
        'description': 'Start a tailoring business from home',
        'description_hi': 'घर से सिलाई का व्यवसाय शुरू करें',
      },
      {
        'id': 3,
        'name': 'Mobile Recharge Shop',
        'name_hi': 'मोबाइल रिचार्ज शॉप',
        'icon': '📱',
        'min_investment': 3000,
        'max_investment': 10000,
        'daily_profit': '200-400',
        'season_rainy': 1.0,
        'season_festival': 1.1,
        'season_wedding': 1.0,
        'description': 'Recharge, bill payments, and small services',
        'description_hi': 'रिचार्ज, बिल भुगतान और छोटी सेवाएं',
      },
      {
        'id': 4,
        'name': 'Tea/Snacks Stall',
        'name_hi': 'चाय/नाश्ता स्टॉल',
        'icon': '🍵',
        'min_investment': 3000,
        'max_investment': 15000,
        'daily_profit': '400-800',
        'season_rainy': 0.7,
        'season_festival': 1.2,
        'season_wedding': 1.0,
        'description': 'Sell tea and snacks in busy areas',
        'description_hi': 'भीड़-भाड़ वाले इलाकों में चाय और नाश्ता बेचें',
      },
      {
        'id': 5,
        'name': 'Dairy/Milk Business',
        'name_hi': 'दूध का व्यापार',
        'icon': '🐄',
        'min_investment': 20000,
        'max_investment': 50000,
        'daily_profit': '250-650',
        'season_rainy': 0.9,
        'season_festival': 1.2,
        'season_wedding': 1.1,
        'description': 'Sell milk and dairy products',
        'description_hi': 'दूध और डेयरी उत्पाद बेचें',
      },
      {
        'id': 6,
        'name': 'Grocery Store',
        'name_hi': 'किराना दुकान',
        'icon': '🏪',
        'min_investment': 30000,
        'max_investment': 100000,
        'daily_profit': '500-1500',
        'season_rainy': 1.0,
        'season_festival': 1.3,
        'season_wedding': 1.1,
        'description': 'Open a general store with daily essentials',
        'description_hi': 'दैनिक जरूरतों की सामान्य दुकान खोलें',
      },
    ];
  }

  /// Get a specific business template by ID
  static Map<String, dynamic>? getBusinessTemplate(int businessId) {
    final templates = getBusinessTemplates();
    try {
      return templates.firstWhere((t) => t['id'] == businessId);
    } catch (e) {
      return null;
    }
  }

  /// Save a business plan
  static Future<int> saveBusinessPlan(Map<String, dynamic> plan) async {
    final prefs = await SharedPreferences.getInstance();
    final plansJson = prefs.getString(_businessPlansKey);
    List<Map<String, dynamic>> plans = [];
    
    if (plansJson != null) {
      final decoded = json.decode(plansJson) as List;
      plans = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
    }
    
    // Generate new ID
    int newId = 1;
    if (plans.isNotEmpty) {
      newId = plans.map((p) => p['id'] as int? ?? 0).reduce((a, b) => a > b ? a : b) + 1;
    }
    
    plan['id'] = newId;
    plan['created_at'] = DateTime.now().toIso8601String();
    plans.add(plan);
    
    await prefs.setString(_businessPlansKey, json.encode(plans));
    return newId;
  }

  /// Get all saved business plans
  static Future<List<Map<String, dynamic>>> getBusinessPlans() async {
    final prefs = await SharedPreferences.getInstance();
    final plansJson = prefs.getString(_businessPlansKey);
    
    if (plansJson == null) return [];
    
    final decoded = json.decode(plansJson) as List;
    return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  /// Save checklist items for a business plan
  static Future<void> saveChecklistItems(int planId, List<Map<String, dynamic>> items) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '${_checklistKey}_$planId';
    await prefs.setString(key, json.encode(items));
  }

  /// Get checklist items for a business plan
  static Future<List<Map<String, dynamic>>> getChecklistItems(int planId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '${_checklistKey}_$planId';
    final itemsJson = prefs.getString(key);
    
    if (itemsJson == null) {
      // Return default checklist items
      return _getDefaultChecklist();
    }
    
    final decoded = json.decode(itemsJson) as List;
    return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  /// Update a single checklist item
  static Future<void> updateChecklistItem(int planId, int itemIndex, bool isCompleted) async {
    final items = await getChecklistItems(planId);
    if (itemIndex >= 0 && itemIndex < items.length) {
      items[itemIndex]['is_completed'] = isCompleted ? 1 : 0;
      await saveChecklistItems(planId, items);
    }
  }

  static List<Map<String, dynamic>> _getDefaultChecklist() {
    return [
      {'title': 'Register your business', 'title_hi': 'अपना व्यवसाय पंजीकृत करें', 'is_completed': 0},
      {'title': 'Open a business bank account', 'title_hi': 'व्यवसाय बैंक खाता खोलें', 'is_completed': 0},
      {'title': 'Get necessary licenses', 'title_hi': 'आवश्यक लाइसेंस प्राप्त करें', 'is_completed': 0},
      {'title': 'Set up your shop/location', 'title_hi': 'अपनी दुकान/स्थान सेट करें', 'is_completed': 0},
      {'title': 'Purchase initial inventory', 'title_hi': 'प्रारंभिक इन्वेंटरी खरीदें', 'is_completed': 0},
      {'title': 'Create pricing list', 'title_hi': 'मूल्य सूची बनाएं', 'is_completed': 0},
    ];
  }
}
