import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter/foundation.dart';

/// AI Service for Sathi AI - the financial assistant
class AiService {
  GenerativeModel? _model;
  ChatSession? _chat;
  
  // Initialize with API key
  void initialize(String apiKey) {
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
      systemInstruction: Content.text(_systemPrompt),
    );
    _chat = _model!.startChat(history: []);
  }

  // Check if initialized
  bool get isInitialized => _model != null;

  // System prompt for Sathi AI
  static const String _systemPrompt = '''
You are "Sathi" (साथी), a friendly financial assistant for rural and first-time learners in India. Your role is to help users with:

1. **Financial Literacy**: Explain savings, banking, loans, investments in simple terms
2. **Government Schemes**: Help find and apply for relevant schemes (PM-KISAN, Mudra, Sukanya Samriddhi, etc.)
3. **Money Management**: Help budget, track expenses, set savings goals
4. **Small Business**: Guide on starting and managing small businesses

**Communication Style**:
- Use simple, friendly language (avoid complex financial jargon)
- Be encouraging and supportive
- Give practical, actionable advice
- Use examples relevant to rural India (farming, small shops, daily wages)
- When user speaks in Hindi, respond in Hindi
- Use emojis to make responses friendly

**For Goal Setting**:
When a user sets a financial goal, break it down into:
1. Required monthly/weekly savings
2. Relevant government schemes that can help
3. Action steps (what to do this week)
4. Tips to achieve the goal
5. Potential income boosters

**Example responses**:
- If user wants to save ₹50,000: Calculate daily/weekly savings needed, suggest appropriate accounts, recommend relevant schemes
- If user asks about loans: Explain in simple terms, recommend government loan schemes first
- If user wants to start business: Ask about skills/interests, suggest local business ideas

Always be:
- Empathetic to financial stress
- Clear about any risks
- Encouraging about small progress
- Focused on practical steps
''';

  /// Send a message and get response
  Future<String> sendMessage(String message, {String language = 'en'}) async {
    if (_chat == null) {
      return language == 'hi' 
          ? 'मुझे पहले API key से सेट करें।'
          : 'Please set up the API key first.';
    }

    try {
      final prompt = language == 'hi' 
          ? 'User message (respond in Hindi): $message'
          : message;
          
      final response = await _chat!.sendMessage(Content.text(prompt));
      return response.text ?? 'Sorry, I could not generate a response.';
    } catch (e) {
      debugPrint('AI Error: $e');
      return language == 'hi'
          ? '❌ कुछ गड़बड़ हुई। कृपया दोबारा कोशिश करें।'
          : '❌ Something went wrong. Please try again.';
    }
  }

  /// Generate a financial plan for a goal
  Future<Map<String, dynamic>> generateGoalPlan({
    required String goal,
    required String userOccupation,
    required String incomeRange,
    String language = 'en',
  }) async {
    if (_chat == null) {
      return {'error': 'AI not initialized'};
    }

    try {
      final prompt = '''
Create a detailed financial plan for this user:

**Goal**: $goal
**Occupation**: $userOccupation
**Income Range**: $incomeRange

Respond in JSON format with these fields:
{
  "goalAmount": <number>,
  "timeframeDays": <number>,
  "dailySavings": <number>,
  "weeklySavings": <number>,
  "monthlySavings": <number>,
  "relevantSchemes": ["scheme1", "scheme2"],
  "weeklyTasks": [
    {"week": 1, "tasks": ["task1", "task2"]},
    {"week": 2, "tasks": ["task1", "task2"]}
  ],
  "tips": ["tip1", "tip2"],
  "incomeBoosterIdeas": ["idea1", "idea2"],
  "summary": "Brief encouraging summary"
}
''';

      final response = await _model!.generateContent([Content.text(prompt)]);
      final text = response.text ?? '{}';
      
      // Try to parse JSON from response
      final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(text);
      if (jsonMatch != null) {
        return {'success': true, 'plan': jsonMatch.group(0)};
      }
      return {'error': 'Could not parse response'};
    } catch (e) {
      debugPrint('Goal Plan Error: $e');
      return {'error': e.toString()};
    }
  }

  /// Get personalized tip based on user profile
  Future<String> getPersonalizedTip({
    required String occupation,
    required String language,
  }) async {
    if (_model == null) {
      return '';
    }

    try {
      final prompt = language == 'hi'
          ? 'एक छोटी, व्यावहारिक पैसे बचाने की टिप दें जो $occupation के लिए उपयोगी हो। सिर्फ 1-2 वाक्य।'
          : 'Give one short, practical money saving tip relevant for a $occupation. Just 1-2 sentences.';

      final response = await _model!.generateContent([Content.text(prompt)]);
      return response.text ?? '';
    } catch (e) {
      return '';
    }
  }

  /// Get offline response (fallback)
  String getOfflineResponse(String message, {String language = 'en'}) {
    final lowerMessage = message.toLowerCase();
    
    if (lowerMessage.contains('save') || lowerMessage.contains('बचत')) {
      return language == 'hi'
          ? '💰 बचत की टिप:\n\n1. हर दिन कम से कम ₹20 बचाएं\n2. एक डिब्बे में रखें या परिवार को दें\n3. हर हफ्ते गिनें\n\n🔔 इंटरनेट आने पर मैं आपको पूरी योजना बनाने में मदद करूंगा!'
          : '💰 Savings Tip:\n\n1. Save at least ₹20 daily\n2. Keep in a box or give to family\n3. Count every week\n\n🔔 When internet is available, I\'ll help you create a complete plan!';
    }
    
    if (lowerMessage.contains('loan') || lowerMessage.contains('ऋण') || lowerMessage.contains('लोन')) {
      return language == 'hi'
          ? '💳 ऋण की जानकारी:\n\nPM Mudra योजना देखें:\n• शिशु: ₹50,000 तक\n• किशोर: ₹5 लाख तक\n• कोई गारंटी नहीं चाहिए\n\n🏦 अपने नजदीकी बैंक में जाएं।'
          : '💳 Loan Info:\n\nCheck PM Mudra Yojana:\n• Shishu: Up to ₹50,000\n• Kishore: Up to ₹5 lakh\n• No collateral needed\n\n🏦 Visit your nearest bank.';
    }
    
    return language == 'hi'
        ? '🤖 मैं अभी ऑफलाइन मोड में हूं।\n\nआप ये कर सकते हैं:\n• खर्चे track करें\n• योजनाएं देखें\n• सीखने के lessons पढ़ें\n\n📶 इंटरनेट आने पर मैं आपकी पूरी मदद करूंगा!'
        : '🤖 I\'m currently offline.\n\nYou can:\n• Track your expenses\n• Browse schemes\n• Read learning lessons\n\n📶 When connected, I\'ll help you fully!';
  }

  /// Clear chat history
  void clearHistory() {
    if (_model != null) {
      _chat = _model!.startChat(history: []);
    }
  }
}
