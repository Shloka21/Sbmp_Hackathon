/// Game Event Model for Sathi Village
class GameEvent {
  final String id;
  final String title;
  final String titleHi;
  final String description;
  final String descriptionHi;
  final String emoji;
  final EventType type;
  final List<EventChoice> choices;
  final String? requiresBuilding; // Only show if player has this building

  const GameEvent({
    required this.id,
    required this.title,
    required this.titleHi,
    required this.description,
    required this.descriptionHi,
    required this.emoji,
    required this.type,
    required this.choices,
    this.requiresBuilding,
  });

  String getTitle(bool isHindi) => isHindi ? titleHi : title;
  String getDescription(bool isHindi) => isHindi ? descriptionHi : description;
}

/// Event types
enum EventType {
  income,
  expense,
  choice,
  opportunity,
  crisis,
}

/// Choice within an event
class EventChoice {
  final String id;
  final String text;
  final String textHi;
  final int coinChange;
  final int xpReward;
  final String consequence;
  final String consequenceHi;
  final String sathiAdvice;
  final String sathiAdviceHi;
  final String? requiresBuilding;
  final bool takesDept;

  const EventChoice({
    required this.id,
    required this.text,
    required this.textHi,
    required this.coinChange,
    this.xpReward = 10,
    required this.consequence,
    required this.consequenceHi,
    required this.sathiAdvice,
    required this.sathiAdviceHi,
    this.requiresBuilding,
    this.takesDept = false,
  });

  String getText(bool isHindi) => isHindi ? textHi : text;
  String getConsequence(bool isHindi) => isHindi ? consequenceHi : consequence;
  String getAdvice(bool isHindi) => isHindi ? sathiAdviceHi : sathiAdvice;
}

/// Static event definitions
class GameEvents {
  static const List<GameEvent> all = [
    // Medical Emergency
    GameEvent(
      id: 'medical_emergency',
      title: 'Medical Emergency',
      titleHi: 'मेडिकल इमरजेंसी',
      description: 'Your child has a fever. Doctor says treatment costs ₹500.',
      descriptionHi: 'आपके बच्चे को बुखार है। डॉक्टर का कहना है इलाज में ₹500 लगेंगे।',
      emoji: '🏥',
      type: EventType.crisis,
      choices: [
        EventChoice(
          id: 'pay_savings',
          text: '💰 Pay from Savings',
          textHi: '💰 बचत से भुगतान करें',
          coinChange: -500,
          xpReward: 25,
          consequence: 'Child recovered quickly!',
          consequenceHi: 'बच्चा जल्दी ठीक हो गया!',
          sathiAdvice: 'Great! Using savings for emergencies is smart. No debt = No tension!',
          sathiAdviceHi: 'बहुत बढ़िया! इमरजेंसी के लिए बचत का उपयोग समझदारी है। कोई कर्ज नहीं = कोई टेंशन नहीं!',
        ),
        EventChoice(
          id: 'take_loan',
          text: '💳 Take Loan (₹500 + ₹50 EMI)',
          textHi: '💳 लोन लें (₹500 + ₹50 EMI)',
          coinChange: 0,
          xpReward: 10,
          consequence: 'Treatment done. You owe ₹550 now.',
          consequenceHi: 'इलाज हो गया। अब आप पर ₹550 का कर्ज है।',
          sathiAdvice: 'Loans help in emergencies but remember to pay back quickly to avoid more interest.',
          sathiAdviceHi: 'लोन इमरजेंसी में मदद करता है लेकिन जल्दी वापस करें ताकि ज्यादा ब्याज न लगे।',
          takesDept: true,
        ),
        EventChoice(
          id: 'use_insurance',
          text: '🏛️ Use Ayushman Card (FREE)',
          textHi: '🏛️ आयुष्मान कार्ड से (मुफ्त)',
          coinChange: 0,
          xpReward: 50,
          consequence: 'Treatment was FREE under Ayushman Bharat!',
          consequenceHi: 'आयुष्मान भारत के तहत इलाज मुफ्त हुआ!',
          sathiAdvice: 'Excellent! This is why government schemes are so valuable. Zero cost treatment!',
          sathiAdviceHi: 'शानदार! इसीलिए सरकारी योजनाएं इतनी कीमती हैं। बिल्कुल मुफ्त इलाज!',
          requiresBuilding: 'govt',
        ),
      ],
    ),

    // Good Harvest
    GameEvent(
      id: 'good_harvest',
      title: 'Bumper Crop!',
      titleHi: 'बंपर फसल!',
      description: 'Your farm produced extra this season. You earned ₹300 bonus!',
      descriptionHi: 'इस सीजन में आपके खेत में अच्छी फसल हुई। आपको ₹300 बोनस मिला!',
      emoji: '🌾',
      type: EventType.income,
      requiresBuilding: 'farm',
      choices: [
        EventChoice(
          id: 'save_bonus',
          text: '🏦 Save in Bank',
          textHi: '🏦 बैंक में जमा करें',
          coinChange: 300,
          xpReward: 30,
          consequence: 'Money saved! It will grow with interest.',
          consequenceHi: 'पैसे जमा हो गए! ब्याज से और बढ़ेंगे।',
          sathiAdvice: 'Perfect choice! Saving extra income builds your emergency fund.',
          sathiAdviceHi: 'बिल्कुल सही! अतिरिक्त आय बचाना इमरजेंसी फंड बनाता है।',
        ),
        EventChoice(
          id: 'spend_bonus',
          text: '🛍️ Spend on Shopping',
          textHi: '🛍️ शॉपिंग पर खर्च करें',
          coinChange: 300,
          xpReward: 10,
          consequence: 'You bought new clothes and had fun!',
          consequenceHi: 'आपने नए कपड़े खरीदे और मज़े किए!',
          sathiAdvice: 'It is okay to enjoy sometimes, but try to save at least half next time!',
          sathiAdviceHi: 'कभी-कभी मज़े करना ठीक है, लेकिन अगली बार कम से कम आधा बचाने की कोशिश करें!',
        ),
        EventChoice(
          id: 'upgrade_farm',
          text: '🚜 Upgrade Farm',
          textHi: '🚜 खेत अपग्रेड करें',
          coinChange: 0,
          xpReward: 40,
          consequence: 'Farm upgraded! More income next season.',
          consequenceHi: 'खेत अपग्रेड हो गया! अगले सीजन में ज्यादा कमाई।',
          sathiAdvice: 'Investing in your income source is very smart! This will pay off later.',
          sathiAdviceHi: 'अपनी आय के स्रोत में निवेश बहुत समझदारी है! बाद में फायदा होगा।',
        ),
      ],
    ),

    // Festival Expense
    GameEvent(
      id: 'festival',
      title: 'Diwali is Here!',
      titleHi: 'दिवाली आ गई!',
      description: 'Family expects sweets and new clothes. Estimated cost: ₹400',
      descriptionHi: 'परिवार को मिठाई और नए कपड़े चाहिए। अनुमानित खर्च: ₹400',
      emoji: '🪔',
      type: EventType.expense,
      choices: [
        EventChoice(
          id: 'full_celebration',
          text: '🎉 Full Celebration (₹400)',
          textHi: '🎉 पूरा जश्न (₹400)',
          coinChange: -400,
          xpReward: 15,
          consequence: 'Family is very happy! Great memories made.',
          consequenceHi: 'परिवार बहुत खुश है! अच्छी यादें बनीं।',
          sathiAdvice: 'Festivals are important! But plan ahead next time by saving monthly.',
          sathiAdviceHi: 'त्योहार जरूरी हैं! लेकिन अगली बार हर महीने थोड़ा-थोड़ा बचाकर तैयारी करें।',
        ),
        EventChoice(
          id: 'budget_celebration',
          text: '💡 Budget Celebration (₹200)',
          textHi: '💡 बजट में जश्न (₹200)',
          coinChange: -200,
          xpReward: 35,
          consequence: 'Simple but sweet celebration. Money saved!',
          consequenceHi: 'सादा लेकिन प्यारा जश्न। पैसे भी बचे!',
          sathiAdvice: 'Smart! You balanced happiness and savings. Very wise decision!',
          sathiAdviceHi: 'समझदार! आपने खुशी और बचत में संतुलन बनाया। बहुत बुद्धिमान फैसला!',
        ),
        EventChoice(
          id: 'skip_festival',
          text: '🚫 Skip This Year',
          textHi: '🚫 इस साल छोड़ दें',
          coinChange: 0,
          xpReward: 20,
          consequence: 'You saved money but family is disappointed.',
          consequenceHi: 'पैसे बचे लेकिन परिवार निराश है।',
          sathiAdvice: 'Saving is good, but some celebrations are important for family bonds.',
          sathiAdviceHi: 'बचत अच्छी है, लेकिन कुछ जश्न परिवार के रिश्तों के लिए जरूरी हैं।',
        ),
      ],
    ),

    // Shop Opportunity
    GameEvent(
      id: 'bulk_order',
      title: 'Big Customer!',
      titleHi: 'बड़ा ग्राहक!',
      description: 'A customer wants to buy ₹1000 worth of goods. You need to invest ₹600 first.',
      descriptionHi: 'एक ग्राहक ₹1000 का सामान खरीदना चाहता है। आपको पहले ₹600 लगाने होंगे।',
      emoji: '🏪',
      type: EventType.opportunity,
      requiresBuilding: 'shop',
      choices: [
        EventChoice(
          id: 'take_order',
          text: '✅ Take the Order (Invest ₹600)',
          textHi: '✅ ऑर्डर लें (₹600 लगाएं)',
          coinChange: 400, // Net profit
          xpReward: 50,
          consequence: 'Order completed! You made ₹400 profit!',
          consequenceHi: 'ऑर्डर पूरा! आपने ₹400 का मुनाफा कमाया!',
          sathiAdvice: 'Excellent business decision! Investing to earn more is the key to growth.',
          sathiAdviceHi: 'शानदार बिज़नेस फैसला! ज्यादा कमाने के लिए निवेश करना विकास की कुंजी है।',
        ),
        EventChoice(
          id: 'reject_order',
          text: '❌ Reject (Too Risky)',
          textHi: '❌ मना करें (बहुत जोखिम)',
          coinChange: 0,
          xpReward: 5,
          consequence: 'You played it safe. No profit, but no loss either.',
          consequenceHi: 'आपने सुरक्षित खेला। न फायदा, न नुकसान।',
          sathiAdvice: 'Being careful is okay, but calculated risks can bring good rewards.',
          sathiAdviceHi: 'सावधान रहना ठीक है, लेकिन सोचा-समझा जोखिम अच्छा इनाम ला सकता है।',
        ),
      ],
    ),

    // Loan Repayment Reminder
    GameEvent(
      id: 'loan_due',
      title: 'Loan EMI Due!',
      titleHi: 'लोन EMI देनी है!',
      description: 'Your monthly EMI of ₹100 is due today.',
      descriptionHi: 'आज आपकी ₹100 की मासिक EMI देनी है।',
      emoji: '💳',
      type: EventType.expense,
      requiresBuilding: 'loan',
      choices: [
        EventChoice(
          id: 'pay_emi',
          text: '✅ Pay EMI (₹100)',
          textHi: '✅ EMI चुकाएं (₹100)',
          coinChange: -100,
          xpReward: 30,
          consequence: 'EMI paid on time! Good credit record.',
          consequenceHi: 'EMI समय पर चुकाई! अच्छा क्रेडिट रिकॉर्ड।',
          sathiAdvice: 'Great! Paying EMIs on time builds your trust with banks.',
          sathiAdviceHi: 'बहुत बढ़िया! समय पर EMI देने से बैंकों में आपका विश्वास बढ़ता है।',
        ),
        EventChoice(
          id: 'skip_emi',
          text: '⏭️ Skip This Month',
          textHi: '⏭️ इस महीने छोड़ें',
          coinChange: 0,
          xpReward: 0,
          consequence: 'EMI skipped. Extra ₹50 penalty added!',
          consequenceHi: 'EMI छोड़ी। ₹50 जुर्माना जोड़ दिया गया!',
          sathiAdvice: 'Warning! Skipping EMIs adds penalties and hurts your credit score.',
          sathiAdviceHi: 'चेतावनी! EMI छोड़ने से जुर्माना लगता है और क्रेडिट स्कोर खराब होता है।',
          takesDept: true,
        ),
      ],
    ),
  ];

  /// Get a random event for the day
  static GameEvent? getRandomEvent(Set<String> playerBuildings) {
    final available = all.where((e) {
      if (e.requiresBuilding != null) {
        return playerBuildings.contains(e.requiresBuilding);
      }
      return true;
    }).toList();

    if (available.isEmpty) return null;

    final index = DateTime.now().millisecondsSinceEpoch % available.length;
    return available[index];
  }

  /// Get event by ID
  static GameEvent? getById(String id) {
    try {
      return all.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }
}
