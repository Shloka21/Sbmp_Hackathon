import 'package:flutter/foundation.dart';

/// Comprehensive Offline AI Brain for Sathi
/// Rule-based responses when no internet is available
class OfflineAiBrain {
  /// Get a contextual offline response based on user intent
  static String getResponse({
    required String message,
    required String language,
    String? userOccupation,
  }) {
    final intent = _detectIntent(message.toLowerCase());
    // Auto-detect Hindi if message contains Devanagari characters (0x0900-0x097F)
    final hasDevanagari = message.codeUnits.any((c) => c >= 0x0900 && c <= 0x097F);
    final isHindi = language == 'hi' || hasDevanagari;
    
    switch (intent) {
      case UserIntent.savings:
        return _getSavingsResponse(isHindi, userOccupation);
      case UserIntent.loan:
        return _getLoanResponse(isHindi, userOccupation);
      case UserIntent.scheme:
        return _getSchemeResponse(isHindi, userOccupation);
      case UserIntent.business:
        return _getBusinessResponse(isHindi, userOccupation);
      case UserIntent.budget:
        return _getBudgetResponse(isHindi);
      case UserIntent.investment:
        return _getInvestmentResponse(isHindi);
      case UserIntent.insurance:
        return _getInsuranceResponse(isHindi);
      case UserIntent.emergency:
        return _getEmergencyResponse(isHindi);
      case UserIntent.scamAlert:
        return _getScamAlertResponse(isHindi);
      case UserIntent.greeting:
        return _getGreetingResponse(isHindi);
      case UserIntent.thanks:
        return _getThanksResponse(isHindi);
      case UserIntent.unknown:
      default:
        return _getDefaultResponse(isHindi);
    }
  }

  /// Detect user intent from message
  static UserIntent _detectIntent(String message) {
    // Greeting patterns
    if (_matchesAny(message, ['hello', 'hi', 'namaste', 'नमस्ते', 'हाय', 'कैसे हो', 'how are'])) {
      return UserIntent.greeting;
    }
    
    // Thanks patterns
    if (_matchesAny(message, ['thank', 'धन्यवाद', 'शुक्रिया', 'thanks'])) {
      return UserIntent.thanks;
    }
    
    // Savings patterns
    if (_matchesAny(message, ['save', 'saving', 'बचत', 'बचाना', 'पैसा जमा', 'bachao', 'bachat'])) {
      return UserIntent.savings;
    }
    
    // Loan patterns
    if (_matchesAny(message, ['loan', 'ऋण', 'लोन', 'उधार', 'कर्ज', 'udhar', 'karj'])) {
      return UserIntent.loan;
    }
    
    // Scheme patterns
    if (_matchesAny(message, ['scheme', 'yojana', 'योजना', 'government', 'सरकारी', 'pm', 'प्रधानमंत्री'])) {
      return UserIntent.scheme;
    }
    
    // Business patterns
    if (_matchesAny(message, ['business', 'व्यापार', 'व्यवसाय', 'दुकान', 'कमाई', 'earn', 'start', 'शुरू'])) {
      return UserIntent.business;
    }
    
    // Budget patterns
    if (_matchesAny(message, ['budget', 'खर्च', 'expense', 'track', 'बजट', 'kharcha'])) {
      return UserIntent.budget;
    }
    
    // Investment patterns
    if (_matchesAny(message, ['invest', 'निवेश', 'fd', 'mutual', 'share', 'stock', 'gold', 'सोना'])) {
      return UserIntent.investment;
    }
    
    // Insurance patterns
    if (_matchesAny(message, ['insurance', 'बीमा', 'lic', 'health', 'life', 'jeevan'])) {
      return UserIntent.insurance;
    }
    
    // Emergency patterns
    if (_matchesAny(message, ['emergency', 'इमरजेंसी', 'urgent', 'help', 'मदद', 'problem', 'परेशान'])) {
      return UserIntent.emergency;
    }
    
    // Scam patterns
    if (_matchesAny(message, ['scam', 'fraud', 'धोखा', 'fake', 'otp', 'लूट'])) {
      return UserIntent.scamAlert;
    }
    
    return UserIntent.unknown;
  }

  static bool _matchesAny(String message, List<String> patterns) {
    return patterns.any((pattern) => message.contains(pattern));
  }

  // ==================== RESPONSE GENERATORS ====================

  static String _getSavingsResponse(bool isHindi, String? occupation) {
    if (isHindi) {
      return '''💰 **बचत की टिप्स:**

1. **50-30-20 नियम** अपनाएं:
   • 50% जरूरी खर्च (खाना, किराया)
   • 30% चाहत (मनोरंजन)
   • 20% बचत (हमेशा पहले बचाएं!)

2. **छोटी बचत बड़ी बनती है:**
   • रोज ₹50 = महीने में ₹1,500
   • रोज ₹100 = साल में ₹36,500!

3. **बचत कहां रखें:**
   • Post Office Savings (सुरक्षित)
   • Jan Dhan Account (मुफ्त)
   • Sukanya Samriddhi (बेटियों के लिए)

📱 खर्च track करने के लिए Money section देखें!

🔔 इंटरनेट आने पर मैं आपको पूरी योजना बनाकर दूंगा!''';
    }
    
    return '''💰 **Savings Tips:**

1. **Follow 50-30-20 Rule:**
   • 50% for needs (food, rent)
   • 30% for wants (entertainment)
   • 20% for savings (save first!)

2. **Small savings grow big:**
   • ₹50/day = ₹1,500/month
   • ₹100/day = ₹36,500/year!

3. **Where to save:**
   • Post Office Savings (safe)
   • Jan Dhan Account (free)
   • Sukanya Samriddhi (for daughters)

📱 Track expenses in Money section!

🔔 When online, I'll create a detailed plan for you!''';
  }

  static String _getLoanResponse(bool isHindi, String? occupation) {
    if (isHindi) {
      return '''💳 **ऋण की जानकारी:**

**सरकारी योजनाएं (सबसे अच्छी):**

1. **PM Mudra Loan:**
   • शिशु: ₹50,000 तक
   • किशोर: ₹5 लाख तक
   • तरुण: ₹10 लाख तक
   • 🎯 कोई गारंटी नहीं!

2. **Kisan Credit Card:**
   • किसानों के लिए
   • कम ब्याज दर
   • 4% ब्याज सब्सिडी

3. **PM SVANidhi:**
   • Street vendors के लिए
   • ₹10,000 से शुरू
   • समय पर चुकाने पर इनाम

⚠️ **सावधान:**
• OTP कभी share न करें
• "Processing fee" का झांसा
• सिर्फ बैंक से लोन लें

🏦 नजदीकी बैंक जाएं और पूछें!''';
    }
    
    return '''💳 **Loan Information:**

**Government Schemes (Best Options):**

1. **PM Mudra Loan:**
   • Shishu: Up to ₹50,000
   • Kishore: Up to ₹5 lakh
   • Tarun: Up to ₹10 lakh
   • 🎯 No collateral needed!

2. **Kisan Credit Card:**
   • For farmers
   • Low interest rate
   • 4% interest subsidy

3. **PM SVANidhi:**
   • For street vendors
   • Starts from ₹10,000
   • Rewards for timely repayment

⚠️ **Be Careful:**
• Never share OTP
• Beware of "processing fees"
• Only take loans from banks

🏦 Visit your nearest bank to apply!''';
  }

  static String _getSchemeResponse(bool isHindi, String? occupation) {
    if (isHindi) {
      return '''🏛️ **आपके लिए सरकारी योजनाएं:**

**पैसों की मदद:**
• **PM-KISAN:** ₹6,000/साल (किसानों को)
• **PM Awas:** घर बनाने में मदद
• **Ujjwala:** मुफ्त गैस कनेक्शन

**महिलाओं के लिए:**
• **Lakhpati Didi:** व्यापार training
• **Sukanya Samriddhi:** बेटियों की पढ़ाई

**युवाओं के लिए:**
• **PM Mudra:** व्यापार शुरू करें
• **Skill India:** मुफ्त training

**बुजुर्गों के लिए:**
• **PM-SYM:** ₹3,000/महीना पेंशन

📋 Schemes section में पूरी list देखें!

🔔 Profile में अपनी जानकारी भरें, मैं matching योजनाएं दिखाऊंगा!''';
    }
    
    return '''🏛️ **Government Schemes for You:**

**Financial Help:**
• **PM-KISAN:** ₹6,000/year (farmers)
• **PM Awas:** Housing assistance
• **Ujjwala:** Free gas connection

**For Women:**
• **Lakhpati Didi:** Business training
• **Sukanya Samriddhi:** Daughter's education

**For Youth:**
• **PM Mudra:** Start your business
• **Skill India:** Free training

**For Elderly:**
• **PM-SYM:** ₹3,000/month pension

📋 Check Schemes section for full list!

🔔 Fill your profile, I'll show matching schemes!''';
  }

  static String _getBusinessResponse(bool isHindi, String? occupation) {
    if (isHindi) {
      return '''🏪 **व्यापार शुरू करें:**

**कम पूंजी में शुरू करें:**

1. **टिफिन सर्विस** (₹15,000)
   • घर से शुरू करें
   • Office areas में supply
   • ₹15-20k/महीना कमाई

2. **Mobile Recharge/Bill Payment**
   • ₹5,000 में शुरू
   • Commission based
   • कहीं भी कर सकते हैं

3. **सब्जी/फल की दुकान**
   • ₹10,000 में शुरू
   • रोज cash in hand

4. **Tailoring (सिलाई)**
   • ₹15,000 में machine + training
   • घर बैठे काम

**Loan के लिए:**
• PM Mudra से ₹50,000 बिना guarantee
• Interest सिर्फ 7-8%

📊 Business section में पूरी guide देखें!''';
    }
    
    return '''🏪 **Start Your Business:**

**Low Investment Ideas:**

1. **Tiffin Service** (₹15,000)
   • Start from home
   • Supply to office areas
   • Earn ₹15-20k/month

2. **Mobile Recharge/Bill Payment**
   • Start with ₹5,000
   • Commission based
   • Work from anywhere

3. **Vegetable/Fruit Shop**
   • Start with ₹10,000
   • Daily cash flow

4. **Tailoring**
   • ₹15,000 for machine + training
   • Work from home

**For Loan:**
• PM Mudra gives ₹50,000 without guarantee
• Interest only 7-8%

📊 Check Business section for full guide!''';
  }

  static String _getBudgetResponse(bool isHindi) {
    if (isHindi) {
      return '''📊 **खर्च Track करें:**

**50-30-20 Method:**
• 50% = जरूरी (खाना, बिल, दवाई)
• 30% = चाहत (बाहर खाना, shopping)
• 20% = बचत (सबसे पहले!)

**कैसे Track करें:**
1. रोज खर्च लिखें (5 मिनट)
2. Category बनाएं (खाना, travel, etc.)
3. हफ्ते में total देखें
4. जहां ज्यादा खर्च है, वहां कम करें

**Festival Planning:**
• Diwali/होली से 3 महीने पहले बचत शुरू
• रोज ₹50 = त्योहार में ₹4,500!

📱 Money section में Voice से खर्च जोड़ें!
बस बोलें: "सब्जी पर 200 खर्च किए"''';
    }
    
    return '''📊 **Track Your Expenses:**

**50-30-20 Method:**
• 50% = Needs (food, bills, medicine)
• 30% = Wants (eating out, shopping)
• 20% = Savings (always first!)

**How to Track:**
1. Write expenses daily (5 mins)
2. Create categories (food, travel, etc.)
3. Check weekly total
4. Cut down where you spend more

**Festival Planning:**
• Start saving 3 months before Diwali/Holi
• ₹50/day = ₹4,500 for festival!

📱 Add expenses by voice in Money section!
Just say: "Spent 200 on vegetables"''';
  }

  static String _getInvestmentResponse(bool isHindi) {
    if (isHindi) {
      return '''📈 **निवेश की जानकारी:**

**शुरुआती के लिए सुरक्षित:**

1. **Fixed Deposit (FD)**
   • Bank में safe
   • 6-7% return
   • 1 साल से 5 साल

2. **Post Office Schemes**
   • सरकारी guarantee
   • RD: ₹100/महीने से शुरू
   • NSC: Tax benefit भी

3. **PPF (Public Provident Fund)**
   • 15 साल का
   • Tax free returns
   • ₹500/साल से शुरू

4. **Gold (सोना)**
   • Sovereign Gold Bond लें
   • Physical से सुरक्षित
   • कोई making charge नहीं

⚠️ Share market में पहले सीखें, फिर invest करें!

🔔 इंटरनेट पर detailed जानकारी दूंगा!''';
    }
    
    return '''📈 **Investment Information:**

**Safe for Beginners:**

1. **Fixed Deposit (FD)**
   • Safe in bank
   • 6-7% return
   • 1 year to 5 years

2. **Post Office Schemes**
   • Government guaranteed
   • RD: Start from ₹100/month
   • NSC: Tax benefits too

3. **PPF**
   • 15 years tenure
   • Tax free returns
   • Start from ₹500/year

4. **Gold**
   • Buy Sovereign Gold Bond
   • Safer than physical
   • No making charges

⚠️ Learn before investing in shares!

🔔 I'll give detailed info when online!''';
  }

  static String _getInsuranceResponse(bool isHindi) {
    if (isHindi) {
      return '''🛡️ **बीमा की जानकारी:**

**जरूरी बीमा:**

1. **Health Insurance (स्वास्थ्य बीमा)**
   • PM-JAY: ₹5 लाख मुफ्त (गरीब परिवार)
   • Private: ₹300-500/महीना
   • Hospital का बड़ा खर्च बच जाता है

2. **Life Insurance (जीवन बीमा)**
   • PM Jeevan Jyoti: ₹436/साल
   • ₹2 लाख का cover
   • परिवार की सुरक्षा

3. **PM Suraksha Bima**
   • सिर्फ ₹20/साल
   • Accident cover
   • ₹2 लाख तक

**क्यों जरूरी है?**
• अचानक बीमारी में खर्च बच जाता है
• परिवार सुरक्षित रहता है
• बचत टूटने से बचती है

📋 नजदीकी bank या post office में apply करें!''';
    }
    
    return '''🛡️ **Insurance Information:**

**Essential Insurance:**

1. **Health Insurance**
   • PM-JAY: ₹5 lakh free (for poor)
   • Private: ₹300-500/month
   • Saves from big hospital bills

2. **Life Insurance**
   • PM Jeevan Jyoti: ₹436/year
   • ₹2 lakh cover
   • Protects family

3. **PM Suraksha Bima**
   • Only ₹20/year
   • Accident cover
   • Up to ₹2 lakh

**Why Important?**
• Saves from sudden illness costs
• Keeps family secure
• Protects your savings

📋 Apply at nearest bank or post office!''';
  }

  static String _getEmergencyResponse(bool isHindi) {
    if (isHindi) {
      return '''🆘 **इमरजेंसी में मदद:**

**अभी करें:**

1. **शांत रहें** - सब ठीक होगा
2. **परिवार से बात करें** - अकेले न रहें

**पैसों की तंगी में:**
• पहले जरूरी खर्च लिखें
• कौन सा खर्च टाल सकते हैं?
• किसी विश्वसनीय से उधार (ब्याज नहीं)

**कर्ज में फंसे हैं?**
• एक-एक करके चुकाएं
• सबसे छोटा पहले
• नया कर्ज न लें

**तुरंत मदद:**
• 📞 181 - Women Helpline
• 📞 1800-180-1551 - Banking help
• 📞 14431 - Kisan Call Center

**याद रखें:**
💪 मुश्किल वक्त गुजर जाता है
🌟 छोटे-छोटे कदम उठाएं
🤝 मदद मांगना कमजोरी नहीं है

मैं Sathi आपके साथ हूं! 🐻''';
    }
    
    return '''🆘 **Emergency Help:**

**Do This Now:**

1. **Stay calm** - Things will be okay
2. **Talk to family** - Don't be alone

**Money crisis?**
• List essential expenses first
• What can you postpone?
• Borrow from trusted ones (no interest)

**Stuck in debt?**
• Pay one by one
• Smallest debt first
• Don't take new debt

**Immediate Help:**
• 📞 181 - Women Helpline
• 📞 1800-180-1551 - Banking help
• 📞 14431 - Kisan Call Center

**Remember:**
💪 Tough times will pass
🌟 Take small steps
🤝 Asking for help is not weakness

I'm Sathi, always with you! 🐻''';
  }

  static String _getScamAlertResponse(bool isHindi) {
    if (isHindi) {
      return '''🚨 **धोखे से बचें!**

**ये कभी न करें:**

❌ **OTP share न करें**
   किसी को भी नहीं - बैंक भी नहीं मांगता!

❌ **Unknown links न खोलें**
   WhatsApp/SMS पर आए lottery links

❌ **Processing fee न दें**
   असली loan में पहले fee नहीं लगती

❌ **Card details न बताएं**
   Phone पर CVV/PIN कोई नहीं मांगता

**असली vs नकली की पहचान:**
• सरकारी website: .gov.in होता है
• बैंक कभी OTP नहीं मांगता
• Job में पहले पैसे नहीं लगते

**धोखा हो गया?**
• तुरंत बैंक call करें
• 📞 1930 - Cyber Crime Helpline
• Police में report करें

🛡️ सावधान रहें, सुरक्षित रहें!''';
    }
    
    return '''🚨 **Avoid Scams!**

**Never Do This:**

❌ **Don't share OTP**
   Not to anyone - banks don't ask!

❌ **Don't open unknown links**
   Lottery links on WhatsApp/SMS

❌ **Don't pay processing fees**
   Real loans don't charge upfront

❌ **Don't share card details**
   No one asks CVV/PIN on phone

**Real vs Fake:**
• Government sites: end in .gov.in
• Banks never ask for OTP
• Jobs don't need money first

**Got scammed?**
• Call bank immediately
• 📞 1930 - Cyber Crime Helpline
• Report to police

🛡️ Stay alert, stay safe!''';
  }

  static String _getGreetingResponse(bool isHindi) {
    if (isHindi) {
      return '''🐻 **नमस्ते! मैं साथी हूं!**

आपका financial साथी! 

मैं अभी offline mode में हूं, लेकिन फिर भी आपकी मदद कर सकता हूं:

• 💰 **बचत की टिप्स** - "बचत" बोलें
• 💳 **लोन की जानकारी** - "लोन" बोलें  
• 🏛️ **सरकारी योजनाएं** - "योजना" बोलें
• 🏪 **व्यापार ideas** - "व्यापार" बोलें
• 📊 **खर्च track करें** - "बजट" बोलें

या कुछ भी पूछें, मैं मदद करने की कोशिश करूंगा!

📶 इंटरनेट आने पर और भी smart हो जाऊंगा! 😊''';
    }
    
    return '''🐻 **Hello! I'm Sathi!**

Your financial companion!

I'm currently in offline mode, but I can still help you:

• 💰 **Savings tips** - Say "savings"
• 💳 **Loan info** - Say "loan"
• 🏛️ **Government schemes** - Say "scheme"
• 🏪 **Business ideas** - Say "business"
• 📊 **Track expenses** - Say "budget"

Or ask me anything, I'll try my best!

📶 I'll be smarter when internet is back! 😊''';
  }

  static String _getThanksResponse(bool isHindi) {
    if (isHindi) {
      return '''😊 **आपका स्वागत है!**

मदद करके खुशी हुई! 🐻

कुछ और जानना है तो बेझिझक पूछें।

💡 **Quick tip:** रोज ₹10 बचाना भी बड़ी शुरुआत है!

आपके साथी,
🐻 Sathi AI''';
    }
    
    return '''😊 **You're welcome!**

Happy to help! 🐻

Feel free to ask if you need anything else.

💡 **Quick tip:** Saving even ₹10 daily is a great start!

Your companion,
🐻 Sathi AI''';
  }

  static String _getDefaultResponse(bool isHindi) {
    if (isHindi) {
      return '''🐻 **मैं साथी हूं - आपका financial दोस्त!**

अभी मैं offline mode में हूं।

**मैं इन विषयों पर मदद कर सकता हूं:**
• 💰 बचत कैसे करें
• 💳 लोन और योजनाएं
• 🏪 छोटा व्यापार शुरू करें
• 📊 खर्च track करें
• 🛡️ धोखे से बचाव

**बोलें:** "बचत", "लोन", "योजना", "व्यापार"

📶 इंटरनेट आने पर मैं आपको:
• पूरी योजना बनाकर दूंगा
• हर सवाल का जवाब दूंगा
• Weekly tasks बनाऊंगा

🐻 चिंता न करें, मैं साथ हूं!''';
    }
    
    return '''🐻 **I'm Sathi - Your Financial Friend!**

I'm currently in offline mode.

**I can help with:**
• 💰 How to save money
• 💳 Loans and schemes
• 🏪 Starting small business
• 📊 Tracking expenses
• 🛡️ Avoiding scams

**Say:** "savings", "loan", "scheme", "business"

📶 When online, I'll:
• Create detailed plans for you
• Answer every question
• Make weekly tasks

🐻 Don't worry, I'm with you!''';
  }

  /// Get a random daily tip
  static String getDailyTip(String language, String? occupation) {
    final tips = language == 'hi' ? _hindiTips : _englishTips;
    final random = DateTime.now().day % tips.length;
    return tips[random];
  }

  static const List<String> _hindiTips = [
    '💡 आज का सुझाव: एक छोटा डिब्बा रखें और रोज का छुट्टा उसमें डालें। महीने के अंत में गिनें!',
    '💡 आज का सुझाव: बाहर खाने से पहले सोचें - घर का खाना सस्ता और healthy है!',
    '💡 आज का सुझाव: हर खरीदारी से पहले पूछें - क्या यह जरूरी है या सिर्फ चाहत?',
    '💡 आज का सुझाव: अगले त्योहार के लिए आज से ₹50/दिन बचाना शुरू करें!',
    '💡 आज का सुझाव: Jan Dhan account खोलें - यह मुफ्त है और बीमा भी मिलता है!',
    '💡 आज का सुझाव: बच्चों को पैसे की समझ दें - piggy bank दें उन्हें!',
    '💡 आज का सुझाव: बिजली और पानी बचाएं - छोटी बचत, बड़ा फायदा!',
  ];

  static const List<String> _englishTips = [
    '💡 Tip: Keep a small box, put daily change in it. Count at month end!',
    '💡 Tip: Before eating out, think - home food is cheaper and healthier!',
    '💡 Tip: Before buying, ask - is this a need or just a want?',
    '💡 Tip: Start saving ₹50/day now for the next festival!',
    '💡 Tip: Open a Jan Dhan account - it\'s free and includes insurance!',
    '💡 Tip: Teach kids about money - give them a piggy bank!',
    '💡 Tip: Save electricity and water - small savings, big benefits!',
  ];
}

/// User intent categories
enum UserIntent {
  savings,
  loan,
  scheme,
  business,
  budget,
  investment,
  insurance,
  emergency,
  scamAlert,
  greeting,
  thanks,
  unknown,
}
