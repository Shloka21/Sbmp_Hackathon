import 'dart:math';

/// Daily Financial Tip Service
/// Provides daily financial tips for users
class TipService {
  static final List<Map<String, String>> _tips = [
    {
      'en': '💡 Start saving just ₹10 a day. In a year, you\'ll have ₹3,650!',
      'hi': '💡 रोज़ सिर्फ ₹10 बचाना शुरू करें। एक साल में ₹3,650 हो जाएंगे!',
    },
    {
      'en': '🏦 Keep 3 months of expenses saved for emergencies before investing.',
      'hi': '🏦 निवेश से पहले 3 महीने के खर्चे इमरजेंसी के लिए बचाकर रखें।',
    },
    {
      'en': '📱 Use UPI instead of cash - it\'s safer and you get a digital record!',
      'hi': '📱 कैश की जगह UPI इस्तेमाल करें - ज़्यादा सुरक्षित और रिकॉर्ड भी रहता है!',
    },
    {
      'en': '🎯 Follow the 50-30-20 rule: 50% needs, 30% wants, 20% savings.',
      'hi': '🎯 50-30-20 नियम अपनाएं: 50% जरूरतें, 30% इच्छाएं, 20% बचत।',
    },
    {
      'en': '🔒 Never share your ATM PIN or OTP with anyone - not even bank staff!',
      'hi': '🔒 ATM PIN या OTP किसी को न बताएं - बैंक स्टाफ को भी नहीं!',
    },
    {
      'en': '📝 Write down every expense. Small leaks can sink a big ship!',
      'hi': '📝 हर खर्च लिखें। छोटे-छोटे खर्च मिलकर बड़ा हो जाते हैं!',
    },
    {
      'en': '🌱 Open a recurring deposit (RD) - forced saving works!',
      'hi': '🌱 RD खोलें - हर महीने जमा होने से बचत अपने-आप होती है!',
    },
    {
      'en': '💳 Pay credit card bills in full every month to avoid interest.',
      'hi': '💳 क्रेडिट कार्ड बिल पूरा भरें, नहीं तो भारी ब्याज लगता है।',
    },
    {
      'en': '🏥 Get health insurance - one hospital bill can wipe out savings!',
      'hi': '🏥 हेल्थ इंश्योरेंस लें - एक बड़ा बिल सारी बचत खत्म कर सकता है!',
    },
    {
      'en': '📈 Start investing early. ₹1000/month from age 25 becomes ₹1 crore by 60!',
      'hi': '📈 जल्दी निवेश शुरू करें। 25 साल से ₹1000/महीना 60 तक ₹1 करोड़ बन सकता है!',
    },
    {
      'en': '🛒 Make a shopping list before going to market - avoid impulse buys!',
      'hi': '🛒 बाज़ार जाने से पहले लिस्ट बनाएं - बेवजह खर्च से बचें!',
    },
    {
      'en': '🎁 Use the 24-hour rule: Wait a day before buying anything expensive.',
      'hi': '🎁 24 घंटे का नियम: कोई बड़ी चीज़ खरीदने से पहले एक दिन सोचें।',
    },
    {
      'en': '💰 Pay yourself first - save before you spend!',
      'hi': '💰 पहले खुद को भुगतान करें - खर्च से पहले बचत करें!',
    },
    {
      'en': '📊 Track your net worth monthly - what you own minus what you owe.',
      'hi': '📊 हर महीने हिसाब करें - आपके पास क्या है और कितना कर्ज़ है।',
    },
    {
      'en': '🎓 Invest in yourself - skills increase earning power!',
      'hi': '🎓 खुद में निवेश करें - नई स्किल्स से कमाई बढ़ती है!',
    },
    {
      'en': '🏪 Compare prices at 2-3 shops before making big purchases.',
      'hi': '🏪 बड़ी खरीद से पहले 2-3 दुकानों के दाम देखें।',
    },
    {
      'en': '⚡ Pay utility bills on time to avoid late fees.',
      'hi': '⚡ बिल समय पर भरें - लेट फीस से बचें।',
    },
    {
      'en': '🤝 Avoid lending money you can\'t afford to lose.',
      'hi': '🤝 उतना ही उधार दें जितना खोने की हिम्मत हो।',
    },
    {
      'en': '📚 Read one financial tip daily - small knowledge, big impact!',
      'hi': '📚 रोज़ एक टिप पढ़ें - छोटी जानकारी, बड़ा फायदा!',
    },
    {
      'en': '🎯 Set specific savings goals - "₹50,000 for bike" beats "save money".',
      'hi': '🎯 पक्का लक्ष्य रखें - "बाइक के लिए ₹50,000" बेहतर है "पैसे बचाना" से।',
    },
  ];

  /// Get today's tip (changes daily based on date)
  static Map<String, String> getTodaysTip() {
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
    final index = dayOfYear % _tips.length;
    return _tips[index];
  }

  /// Get a random tip
  static Map<String, String> getRandomTip() {
    final random = Random();
    return _tips[random.nextInt(_tips.length)];
  }

  /// Get tip text for current language
  static String getTip(String language) {
    final tip = getTodaysTip();
    return language == 'hi' ? tip['hi']! : tip['en']!;
  }

  /// Get all tips
  static List<Map<String, String>> getAllTips() => _tips;
}
