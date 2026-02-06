/// Detailed lesson content for financial literacy education
/// Each lesson has content steps and MCQ questions with multiple variants

class LessonData {
  static const Map<String, List<Map<String, dynamic>>> lessonsByCategory = {
    'savings': savingsLessons,
    'banking': bankingLessons,
    'credit': creditLessons,
    'investment': investmentLessons,
    'business': businessLessons,
    'digital': digitalLessons,
  };

  // ========== SAVINGS LESSONS ==========
  static const List<Map<String, dynamic>> savingsLessons = [
    {
      'id': 'savings_1',
      'title': 'Why Save Money?',
      'titleHi': 'पैसे क्यों बचाएं?',
      'icon': '💰',
      'xpReward': 25,
      'content': [
        {
          'type': 'text',
          'en': '## 🎯 What is Saving?\n\nSaving means keeping some money aside instead of spending all of it.\n\n**Example:** If you earn ₹500 and spend ₹450, you save ₹50.',
          'hi': '## 🎯 बचत क्या है?\n\nबचत का मतलब है सारा पैसा खर्च करने की बजाय कुछ पैसा अलग रखना।\n\n**उदाहरण:** अगर आप ₹500 कमाते हैं और ₹450 खर्च करते हैं, तो ₹50 बच जाते हैं।',
        },
        {
          'type': 'text',
          'en': '## 🏥 Why is Saving Important?\n\n1. **Emergencies** - Hospital bills, accidents\n2. **Big Goals** - Phone, bike, education\n3. **Peace of Mind** - No tension about money\n4. **Family Security** - Help in difficult times',
          'hi': '## 🏥 बचत क्यों जरूरी है?\n\n1. **इमरजेंसी** - अस्पताल का खर्चा, दुर्घटना\n2. **बड़े लक्ष्य** - फोन, बाइक, पढ़ाई\n3. **मन की शांति** - पैसों की चिंता नहीं\n4. **परिवार की सुरक्षा** - मुश्किल में मदद',
        },
        {
          'type': 'text',
          'en': '## 💡 The 50-30-20 Rule\n\nA simple way to manage your money:\n\n- **50%** → Needs (food, rent, bills)\n- **30%** → Wants (movies, snacks)\n- **20%** → Savings\n\n**If you earn ₹10,000:**\n- ₹5,000 for needs\n- ₹3,000 for wants\n- ₹2,000 for savings',
          'hi': '## 💡 50-30-20 नियम\n\nपैसे संभालने का आसान तरीका:\n\n- **50%** → जरूरतें (खाना, किराया, बिल)\n- **30%** → इच्छाएं (फिल्म, नाश्ता)\n- **20%** → बचत\n\n**अगर आप ₹10,000 कमाते हैं:**\n- ₹5,000 जरूरतों के लिए\n- ₹3,000 इच्छाओं के लिए\n- ₹2,000 बचत के लिए',
        },
      ],
      'mcqs': [
        {
          'question': 'What percentage should you save according to 50-30-20 rule?',
          'questionHi': '50-30-20 नियम के अनुसार आपको कितना प्रतिशत बचाना चाहिए?',
          'options': ['10%', '20%', '30%', '50%'],
          'correct': 1,
        },
        {
          'question': 'If you earn ₹1000 and save ₹200, how much did you spend?',
          'questionHi': 'अगर आप ₹1000 कमाते हैं और ₹200 बचाते हैं, तो कितना खर्च किया?',
          'options': ['₹600', '₹700', '₹800', '₹900'],
          'correct': 2,
        },
        {
          'question': 'Which is NOT a benefit of saving?',
          'questionHi': 'इनमें से कौन बचत का फायदा नहीं है?',
          'options': ['Emergency help', 'Buying bigger goals', 'Getting into debt', 'Peace of mind'],
          'correct': 2,
        },
      ],
    },
    {
      'id': 'savings_2',
      'title': 'Where to Save Money?',
      'titleHi': 'पैसे कहाँ बचाएं?',
      'icon': '🏦',
      'xpReward': 30,
      'content': [
        {
          'type': 'text',
          'en': '## 🏠 Saving at Home vs Bank\n\n**At Home (Piggy Bank):**\n- ✅ Easy access\n- ❌ Can get stolen\n- ❌ No interest earned\n- ❌ Easy to spend\n\n**At Bank:**\n- ✅ Safe and secure\n- ✅ Earns interest\n- ✅ Government protection\n- ✅ ATM anywhere',
          'hi': '## 🏠 घर पर vs बैंक में बचत\n\n**घर पर (गुल्लक):**\n- ✅ आसानी से मिल जाता है\n- ❌ चोरी हो सकती है\n- ❌ ब्याज नहीं मिलता\n- ❌ खर्च हो जाता है\n\n**बैंक में:**\n- ✅ सुरक्षित\n- ✅ ब्याज मिलता है\n- ✅ सरकारी सुरक्षा\n- ✅ ATM कहीं भी',
        },
        {
          'type': 'text',
          'en': '## 📊 Types of Bank Savings\n\n**1. Savings Account**\n- Minimum ₹500-1000 to open\n- 3-4% interest per year\n- Withdraw anytime\n\n**2. Fixed Deposit (FD)**\n- Lock money for 1-5 years\n- Higher interest 5-7%\n- Penalty for early withdrawal\n\n**3. Recurring Deposit (RD)**\n- Save fixed amount monthly\n- Good for regular savers\n- 5-6% interest',
          'hi': '## 📊 बैंक बचत के प्रकार\n\n**1. बचत खाता**\n- खोलने के लिए ₹500-1000\n- 3-4% सालाना ब्याज\n- कभी भी निकालें\n\n**2. सावधि जमा (FD)**\n- 1-5 साल के लिए पैसा रखें\n- ज्यादा ब्याज 5-7%\n- जल्दी निकालने पर जुर्माना\n\n**3. आवर्ती जमा (RD)**\n- हर महीने तय राशि जमा\n- नियमित बचत के लिए\n- 5-6% ब्याज',
        },
        {
          'type': 'text',
          'en': '## 🆓 Jan Dhan Account - Free!\n\n**PM Jan Dhan Yojana gives you:**\n- ✅ Zero balance account\n- ✅ Free ATM card (RuPay)\n- ✅ ₹2 lakh accident insurance\n- ✅ ₹10,000 overdraft facility\n\n**Documents needed:**\n- Aadhaar card\n- Passport photo',
          'hi': '## 🆓 जन धन खाता - मुफ्त!\n\n**PM जन धन योजना देती है:**\n- ✅ जीरो बैलेंस खाता\n- ✅ मुफ्त ATM कार्ड (RuPay)\n- ✅ ₹2 लाख दुर्घटना बीमा\n- ✅ ₹10,000 ओवरड्राफ्ट\n\n**जरूरी दस्तावेज:**\n- आधार कार्ड\n- पासपोर्ट फोटो',
        },
      ],
      'mcqs': [
        {
          'question': 'Which gives higher interest - Savings Account or FD?',
          'questionHi': 'किसमें ज्यादा ब्याज मिलता है - बचत खाता या FD?',
          'options': ['Savings Account', 'Fixed Deposit (FD)', 'Both same', 'None gives interest'],
          'correct': 1,
        },
        {
          'question': 'What insurance does Jan Dhan account provide?',
          'questionHi': 'जन धन खाते में कितना दुर्घटना बीमा मिलता है?',
          'options': ['₹50,000', '₹1 lakh', '₹2 lakh', '₹5 lakh'],
          'correct': 2,
        },
        {
          'question': 'What is a disadvantage of keeping money at home?',
          'questionHi': 'घर पर पैसे रखने का नुकसान क्या है?',
          'options': ['Earns interest', 'Safe from theft', 'No interest, can be stolen', 'Government protects it'],
          'correct': 2,
        },
      ],
    },
    {
      'id': 'savings_3',
      'title': 'Smart Saving Tips',
      'titleHi': 'स्मार्ट बचत टिप्स',
      'icon': '🧠',
      'xpReward': 35,
      'content': [
        {
          'type': 'text',
          'en': '## 🎯 Start Small, Stay Consistent\n\n**The ₹10 Challenge:**\n- Save ₹10 daily = ₹300/month = ₹3,600/year!\n- Save ₹20 daily = ₹600/month = ₹7,200/year!\n\n**Tip:** Save first, then spend. Not the other way!',
          'hi': '## 🎯 छोटी शुरुआत, नियमित रहें\n\n**₹10 की चुनौती:**\n- रोज ₹10 बचाएं = ₹300/महीना = ₹3,600/साल!\n- रोज ₹20 बचाएं = ₹600/महीना = ₹7,200/साल!\n\n**टिप:** पहले बचाएं, फिर खर्च करें। उल्टा नहीं!',
        },
        {
          'type': 'text',
          'en': '## 💡 Simple Saving Tricks\n\n1. **Round up purchases** - Bought for ₹47? Save ₹3 to make ₹50\n2. **No-spend days** - One day a week, spend nothing extra\n3. **Wait 24 hours** - Before buying anything big, wait a day\n4. **Compare prices** - Check 2-3 shops before buying\n5. **Use leftovers** - Don\'t waste food',
          'hi': '## 💡 आसान बचत ट्रिक्स\n\n1. **राउंड अप करें** - ₹47 का सामान? ₹3 बचाकर ₹50 करें\n2. **बिना खर्च का दिन** - हफ्ते में एक दिन कुछ एक्स्ट्रा नहीं\n3. **24 घंटे रुकें** - बड़ी चीज़ खरीदने से पहले एक दिन सोचें\n4. **दाम तुलना करें** - खरीदने से पहले 2-3 दुकान देखें\n5. **बचा हुआ खाना** - खाना बर्बाद न करें',
        },
        {
          'type': 'text',
          'en': '## 🎁 Automate Your Savings\n\n**Set up auto-transfer:**\n- Every month, auto-send ₹500 to RD\n- You won\'t miss what you don\'t see!\n\n**Use apps:**\n- UPI apps can schedule transfers\n- Set reminder for 1st of every month',
          'hi': '## 🎁 बचत को ऑटोमैटिक करें\n\n**ऑटो-ट्रांसफर सेट करें:**\n- हर महीने ₹500 RD में ऑटो भेजें\n- जो दिखता नहीं, वो खर्च नहीं होता!\n\n**ऐप्स का उपयोग:**\n- UPI ऐप्स में शेड्यूल ट्रांसफर करें\n- हर महीने की 1 तारीख की याद दिलाई लगाएं',
        },
      ],
      'mcqs': [
        {
          'question': 'If you save ₹20 daily, how much will you save in a year?',
          'questionHi': 'अगर आप रोज ₹20 बचाएं, तो साल में कितना बचेगा?',
          'options': ['₹3,600', '₹5,400', '₹7,200', '₹10,000'],
          'correct': 2,
        },
        {
          'question': 'What should you do before buying something expensive?',
          'questionHi': 'महंगी चीज़ खरीदने से पहले क्या करना चाहिए?',
          'options': ['Buy immediately', 'Wait 24 hours', 'Borrow money', 'Ignore the price'],
          'correct': 1,
        },
        {
          'question': 'What is the best order for managing money?',
          'questionHi': 'पैसे संभालने का सबसे अच्छा तरीका क्या है?',
          'options': ['Spend first, save later', 'Save first, then spend', 'Don\'t save at all', 'Spend everything'],
          'correct': 1,
        },
      ],
    },
  ];

  // ========== BANKING LESSONS ==========
  static const List<Map<String, dynamic>> bankingLessons = [
    {
      'id': 'banking_1',
      'title': 'Opening a Bank Account',
      'titleHi': 'बैंक खाता खोलना',
      'icon': '🏦',
      'xpReward': 25,
      'content': [
        {
          'type': 'text',
          'en': '## 🏦 What is a Bank Account?\n\nA bank account is a safe place to keep your money. The bank:\n- Keeps your money secure\n- Pays you interest\n- Lets you withdraw anytime\n- Provides ATM card',
          'hi': '## 🏦 बैंक खाता क्या है?\n\nबैंक खाता आपके पैसे रखने की सुरक्षित जगह है। बैंक:\n- पैसे सुरक्षित रखता है\n- ब्याज देता है\n- कभी भी निकालने देता है\n- ATM कार्ड देता है',
        },
        {
          'type': 'text',
          'en': '## 📄 Documents Needed\n\n**KYC (Know Your Customer):**\n\n1. **Identity Proof** (any one):\n   - Aadhaar Card ✓\n   - PAN Card\n   - Voter ID\n\n2. **Address Proof** (any one):\n   - Aadhaar Card ✓\n   - Electricity Bill\n   - Ration Card\n\n3. **Passport Photo** - 2 copies\n\n**Tip:** Aadhaar works for both!',
          'hi': '## 📄 जरूरी दस्तावेज\n\n**KYC (ग्राहक पहचान):**\n\n1. **पहचान प्रमाण** (कोई एक):\n   - आधार कार्ड ✓\n   - पैन कार्ड\n   - वोटर ID\n\n2. **पता प्रमाण** (कोई एक):\n   - आधार कार्ड ✓\n   - बिजली बिल\n   - राशन कार्ड\n\n3. **पासपोर्ट फोटो** - 2 कॉपी\n\n**टिप:** आधार दोनों के लिए चलता है!',
        },
        {
          'type': 'text',
          'en': '## 📝 Steps to Open Account\n\n1. **Visit bank** with documents\n2. **Fill form** - Bank staff will help\n3. **Submit documents** - Original + photocopy\n4. **Initial deposit** - ₹500-1000 (or ₹0 for Jan Dhan)\n5. **Get passbook** - Same day or next day\n6. **Link mobile** - For SMS alerts\n7. **Get ATM card** - In 7-10 days',
          'hi': '## 📝 खाता खोलने के स्टेप्स\n\n1. **बैंक जाएं** - दस्तावेजों के साथ\n2. **फॉर्म भरें** - बैंक स्टाफ मदद करेगा\n3. **दस्तावेज जमा करें** - ओरिजिनल + फोटोकॉपी\n4. **शुरुआती जमा** - ₹500-1000 (जन धन में ₹0)\n5. **पासबुक लें** - उसी दिन या अगले दिन\n6. **मोबाइल लिंक करें** - SMS अलर्ट के लिए\n7. **ATM कार्ड मिलेगा** - 7-10 दिन में',
        },
      ],
      'mcqs': [
        {
          'question': 'Which document works for both identity and address proof?',
          'questionHi': 'कौन सा दस्तावेज पहचान और पता दोनों के लिए चलता है?',
          'options': ['PAN Card', 'Voter ID', 'Aadhaar Card', 'Driving License'],
          'correct': 2,
        },
        {
          'question': 'How much initial deposit is needed for Jan Dhan account?',
          'questionHi': 'जन धन खाते के लिए शुरुआती जमा कितनी चाहिए?',
          'options': ['₹500', '₹1000', '₹0 (Zero)', '₹100'],
          'correct': 2,
        },
        {
          'question': 'When do you get the ATM card after opening account?',
          'questionHi': 'खाता खोलने के बाद ATM कार्ड कब मिलता है?',
          'options': ['Same day', '7-10 days', '1 month', '6 months'],
          'correct': 1,
        },
      ],
    },
    {
      'id': 'banking_2',
      'title': 'Using ATM Safely',
      'titleHi': 'ATM का सुरक्षित उपयोग',
      'icon': '💳',
      'xpReward': 30,
      'content': [
        {
          'type': 'text',
          'en': '## 🏧 What is ATM?\n\n**ATM = Automated Teller Machine**\n\nA machine that lets you:\n- Withdraw cash 24x7\n- Check balance\n- Change PIN\n- Mini statement\n\n**Free transactions:**\n- Own bank ATM: 5/month\n- Other bank ATM: 3/month',
          'hi': '## 🏧 ATM क्या है?\n\n**ATM = ऑटोमेटेड टेलर मशीन**\n\nएक मशीन जो आपको देती है:\n- 24x7 कैश निकालना\n- बैलेंस चेक करना\n- PIN बदलना\n- मिनी स्टेटमेंट\n\n**मुफ्त लेनदेन:**\n- अपने बैंक का ATM: 5/महीना\n- दूसरे बैंक का ATM: 3/महीना',
        },
        {
          'type': 'text',
          'en': '## 🔐 ATM Safety Rules\n\n**DO:**\n- ✅ Cover keypad while entering PIN\n- ✅ Collect card and cash before leaving\n- ✅ Take receipt or press cancel\n- ✅ Use ATMs in safe locations\n\n**DON\'T:**\n- ❌ Never share PIN with anyone\n- ❌ Don\'t write PIN on card\n- ❌ Don\'t take help from strangers\n- ❌ Never give OTP to callers',
          'hi': '## 🔐 ATM सुरक्षा नियम\n\n**करें:**\n- ✅ PIN डालते समय कीपैड छुपाएं\n- ✅ जाने से पहले कार्ड और पैसे लें\n- ✅ रसीद लें या कैंसल दबाएं\n- ✅ सुरक्षित जगह का ATM इस्तेमाल करें\n\n**न करें:**\n- ❌ PIN किसी को न बताएं\n- ❌ कार्ड पर PIN न लिखें\n- ❌ अजनबियों से मदद न लें\n- ❌ कॉल पर OTP न दें',
        },
        {
          'type': 'text',
          'en': '## 🚨 If Card is Stolen/Lost\n\n**Immediately:**\n1. Call bank helpline (on card back)\n2. Say \"Block my ATM card\"\n3. Note complaint number\n4. Visit bank for new card\n\n**Common Bank Helplines:**\n- SBI: 1800-11-2211\n- PNB: 1800-180-2222\n- BOB: 1800-22-0100',
          'hi': '## 🚨 अगर कार्ड चोरी/गुम हो जाए\n\n**तुरंत:**\n1. बैंक हेल्पलाइन कॉल करें (कार्ड पीछे)\n2. कहें \"मेरा ATM कार्ड ब्लॉक करें\"\n3. शिकायत नंबर नोट करें\n4. नए कार्ड के लिए बैंक जाएं\n\n**आम बैंक हेल्पलाइन:**\n- SBI: 1800-11-2211\n- PNB: 1800-180-2222\n- BOB: 1800-22-0100',
        },
      ],
      'mcqs': [
        {
          'question': 'How many free transactions at other bank ATM per month?',
          'questionHi': 'दूसरे बैंक के ATM पर महीने में कितने मुफ्त लेनदेन?',
          'options': ['1', '3', '5', '10'],
          'correct': 1,
        },
        {
          'question': 'What should you do while entering PIN?',
          'questionHi': 'PIN डालते समय क्या करना चाहिए?',
          'options': ['Say it loud', 'Cover the keypad', 'Show to friend', 'Write it down'],
          'correct': 1,
        },
        {
          'question': 'What to do first if ATM card is stolen?',
          'questionHi': 'ATM कार्ड चोरी होने पर सबसे पहले क्या करें?',
          'options': ['Wait and see', 'Call bank to block', 'Do nothing', 'Make a new card'],
          'correct': 1,
        },
      ],
    },
  ];

  // ========== CREDIT LESSONS ==========
  static const List<Map<String, dynamic>> creditLessons = [
    {
      'id': 'credit_1',
      'title': 'Understanding Loans',
      'titleHi': 'लोन को समझें',
      'icon': '💳',
      'xpReward': 30,
      'content': [
        {
          'type': 'text',
          'en': '## 💰 What is a Loan?\n\nA loan is borrowed money that you must return with interest.\n\n**Example:**\n- You borrow ₹10,000\n- Bank charges 12% interest\n- You return ₹11,200\n\n**Interest = Cost of borrowing**',
          'hi': '## 💰 लोन क्या है?\n\nलोन वह पैसा है जो आप उधार लेते हैं और ब्याज के साथ वापस करते हैं।\n\n**उदाहरण:**\n- आप ₹10,000 उधार लें\n- बैंक 12% ब्याज लेता है\n- आप ₹11,200 वापस करें\n\n**ब्याज = उधार की कीमत**',
        },
        {
          'type': 'text',
          'en': '## 📊 Types of Loans\n\n**1. Personal Loan**\n- For any purpose\n- Higher interest (12-24%)\n\n**2. Home Loan**\n- To buy house\n- Lower interest (8-10%)\n\n**3. Education Loan**\n- For studies\n- Low interest, pay after job\n\n**4. Mudra Loan**\n- For small business\n- Government scheme (8-12%)',
          'hi': '## 📊 लोन के प्रकार\n\n**1. पर्सनल लोन**\n- किसी भी काम के लिए\n- ज्यादा ब्याज (12-24%)\n\n**2. होम लोन**\n- घर खरीदने के लिए\n- कम ब्याज (8-10%)\n\n**3. एजुकेशन लोन**\n- पढ़ाई के लिए\n- कम ब्याज, नौकरी के बाद भरें\n\n**4. मुद्रा लोन**\n- छोटे व्यापार के लिए\n- सरकारी योजना (8-12%)',
        },
        {
          'type': 'text',
          'en': '## ⚠️ Before Taking Loan - Check!\n\n1. **Interest Rate** - Lower is better\n2. **EMI Amount** - Can you afford monthly?\n3. **Total Cost** - Principal + all interest\n4. **Hidden Charges** - Processing fee, late fee\n5. **Prepayment** - Can you close early?\n\n**Golden Rule:** Borrow only what you can repay!',
          'hi': '## ⚠️ लोन लेने से पहले - जांचें!\n\n1. **ब्याज दर** - कम अच्छी\n2. **EMI राशि** - हर महीने दे पाएंगे?\n3. **कुल खर्च** - मूलधन + सारा ब्याज\n4. **छुपे चार्ज** - प्रोसेसिंग फीस, लेट फीस\n5. **प्रीपेमेंट** - जल्दी बंद कर सकते हैं?\n\n**सुनहरा नियम:** उतना ही उधार लें जितना चुका सकें!',
        },
      ],
      'mcqs': [
        {
          'question': 'Which loan type has the lowest interest rate?',
          'questionHi': 'किस लोन में सबसे कम ब्याज होता है?',
          'options': ['Personal Loan', 'Home Loan', 'Credit Card', 'Payday Loan'],
          'correct': 1,
        },
        {
          'question': 'If you borrow ₹10,000 at 10% interest, how much do you return?',
          'questionHi': 'अगर ₹10,000 का 10% ब्याज पर लोन लें, तो कितना वापस करें?',
          'options': ['₹10,000', '₹10,500', '₹11,000', '₹12,000'],
          'correct': 2,
        },
        {
          'question': 'What is EMI?',
          'questionHi': 'EMI क्या है?',
          'options': ['One-time payment', 'Monthly installment', 'Interest only', 'Processing fee'],
          'correct': 1,
        },
      ],
    },
  ];

  // ========== INVESTMENT LESSONS ==========
  static const List<Map<String, dynamic>> investmentLessons = [
    {
      'id': 'investment_1',
      'title': 'Saving vs Investing',
      'titleHi': 'बचत vs निवेश',
      'icon': '📈',
      'xpReward': 30,
      'content': [
        {
          'type': 'text',
          'en': '## 💰 Saving vs Investing\n\n**Saving:**\n- Keep money safe\n- Low return (3-4%)\n- No risk\n- Easy access\n\n**Investing:**\n- Make money grow\n- Higher return (8-15%)\n- Some risk\n- Money locked for time',
          'hi': '## 💰 बचत vs निवेश\n\n**बचत:**\n- पैसा सुरक्षित रखना\n- कम रिटर्न (3-4%)\n- कोई जोखिम नहीं\n- तुरंत निकाल सकते हैं\n\n**निवेश:**\n- पैसा बढ़ाना\n- ज्यादा रिटर्न (8-15%)\n- कुछ जोखिम\n- कुछ समय के लिए लॉक',
        },
        {
          'type': 'text',
          'en': '## 🌱 Power of Compound Interest\n\n**Example: Invest ₹1,000/month for 20 years**\n\n- At 6% (FD): ₹4.6 lakh\n- At 12% (Mutual Fund): ₹9.9 lakh\n\n**Same savings, double the money!**\n\nStart early, let money work for you.',
          'hi': '## 🌱 चक्रवृद्धि ब्याज की ताकत\n\n**उदाहरण: ₹1,000/महीने 20 साल तक निवेश करें**\n\n- 6% पर (FD): ₹4.6 लाख\n- 12% पर (म्यूचुअल फंड): ₹9.9 लाख\n\n**एक जैसी बचत, दोगुना पैसा!**\n\nजल्दी शुरू करें, पैसे को काम करने दें।',
        },
        {
          'type': 'text',
          'en': '## 📊 Safe Investment Options\n\n**1. PPF (Public Provident Fund)**\n- 7.1% interest, tax-free\n- Min ₹500/year, lock 15 years\n\n**2. Sukanya Samriddhi** (for daughters)\n- 8.2% interest\n- For girl child education/marriage\n\n**3. Post Office Schemes**\n- NSC, KVP, Senior Citizen\n- Safe, government backed',
          'hi': '## 📊 सुरक्षित निवेश विकल्प\n\n**1. PPF (पब्लिक प्रॉविडेंट फंड)**\n- 7.1% ब्याज, टैक्स-फ्री\n- न्यूनतम ₹500/साल, 15 साल लॉक\n\n**2. सुकन्या समृद्धि** (बेटियों के लिए)\n- 8.2% ब्याज\n- बेटी की पढ़ाई/शादी के लिए\n\n**3. पोस्ट ऑफिस स्कीम**\n- NSC, KVP, सीनियर सिटीजन\n- सुरक्षित, सरकारी गारंटी',
        },
      ],
      'mcqs': [
        {
          'question': 'Which generally gives higher returns - Saving or Investing?',
          'questionHi': 'आमतौर पर ज्यादा रिटर्न किसमें मिलता है - बचत या निवेश?',
          'options': ['Saving', 'Investing', 'Both same', 'Neither'],
          'correct': 1,
        },
        {
          'question': 'What is the interest rate of Sukanya Samriddhi scheme?',
          'questionHi': 'सुकन्या समृद्धि योजना में ब्याज दर क्या है?',
          'options': ['5%', '6.5%', '7.1%', '8.2%'],
          'correct': 3,
        },
        {
          'question': 'For how many years is PPF locked?',
          'questionHi': 'PPF कितने साल के लिए लॉक होता है?',
          'options': ['5 years', '10 years', '15 years', '20 years'],
          'correct': 2,
        },
      ],
    },
  ];

  // ========== BUSINESS LESSONS ==========
  static const List<Map<String, dynamic>> businessLessons = [
    {
      'id': 'business_1',
      'title': 'Starting a Small Business',
      'titleHi': 'छोटा व्यापार शुरू करना',
      'icon': '🏪',
      'xpReward': 35,
      'content': [
        {
          'type': 'text',
          'en': '## 🏪 Small Business Ideas\n\n**Low Investment (Under ₹10,000):**\n- Mobile recharge shop\n- Tiffin service\n- Tailoring\n- Vegetable selling\n\n**Medium Investment (₹10,000-50,000):**\n- Grocery store\n- Beauty parlor\n- Poultry farming\n- Dairy business',
          'hi': '## 🏪 छोटे व्यापार के आइडिया\n\n**कम निवेश (₹10,000 से कम):**\n- मोबाइल रिचार्ज दुकान\n- टिफिन सर्विस\n- सिलाई\n- सब्जी बेचना\n\n**मध्यम निवेश (₹10,000-50,000):**\n- किराना दुकान\n- ब्यूटी पार्लर\n- मुर्गी पालन\n- डेयरी व्यवसाय',
        },
        {
          'type': 'text',
          'en': '## 💰 Government Help - Mudra Loan\n\n**PM Mudra Yojana:**\n\n- **Shishu:** Up to ₹50,000\n- **Kishore:** ₹50,000 to ₹5 lakh\n- **Tarun:** ₹5 lakh to ₹10 lakh\n\n**Benefits:**\n- No collateral needed\n- Low interest (8-12%)\n- Available at all banks',
          'hi': '## 💰 सरकारी मदद - मुद्रा लोन\n\n**PM मुद्रा योजना:**\n\n- **शिशु:** ₹50,000 तक\n- **किशोर:** ₹50,000 से ₹5 लाख\n- **तरुण:** ₹5 लाख से ₹10 लाख\n\n**फायदे:**\n- कोई गारंटी नहीं चाहिए\n- कम ब्याज (8-12%)\n- सभी बैंकों में उपलब्ध',
        },
        {
          'type': 'text',
          'en': '## 📝 Business Tips\n\n1. **Start small** - Test before investing big\n2. **Keep accounts** - Write daily income/expense\n3. **Customer first** - Good service = repeat customers\n4. **Save profits** - Don\'t spend all earnings\n5. **Learn always** - Watch successful businesses',
          'hi': '## 📝 व्यापार टिप्स\n\n1. **छोटी शुरुआत** - बड़ा निवेश से पहले जांचें\n2. **हिसाब रखें** - रोज आय/खर्च लिखें\n3. **ग्राहक पहले** - अच्छी सेवा = दोबारा ग्राहक\n4. **मुनाफा बचाएं** - सारी कमाई खर्च न करें\n5. **सीखते रहें** - सफल व्यापार देखें',
        },
      ],
      'mcqs': [
        {
          'question': 'What is the maximum loan under Mudra Shishu?',
          'questionHi': 'मुद्रा शिशु के तहत अधिकतम लोन कितना है?',
          'options': ['₹10,000', '₹50,000', '₹1 lakh', '₹5 lakh'],
          'correct': 1,
        },
        {
          'question': 'Which business can start with under ₹10,000?',
          'questionHi': '₹10,000 से कम में कौन सा व्यापार शुरू कर सकते हैं?',
          'options': ['Grocery store', 'Tiffin service', 'Beauty parlor', 'Dairy farm'],
          'correct': 1,
        },
        {
          'question': 'What should you do with business profits?',
          'questionHi': 'व्यापार के मुनाफे का क्या करना चाहिए?',
          'options': ['Spend all', 'Save some', 'Give away', 'Hide it'],
          'correct': 1,
        },
      ],
    },
  ];

  // ========== DIGITAL LESSONS ==========
  static const List<Map<String, dynamic>> digitalLessons = [
    {
      'id': 'digital_1',
      'title': 'Using UPI Payments',
      'titleHi': 'UPI पेमेंट का उपयोग',
      'icon': '📱',
      'xpReward': 25,
      'content': [
        {
          'type': 'text',
          'en': '## 📱 What is UPI?\n\n**UPI = Unified Payments Interface**\n\nSend money instantly using:\n- Phone number\n- UPI ID (name@bank)\n- QR code scan\n\n**Popular UPI Apps:**\n- Google Pay\n- PhonePe\n- Paytm\n- BHIM',
          'hi': '## 📱 UPI क्या है?\n\n**UPI = यूनिफाइड पेमेंट्स इंटरफेस**\n\nतुरंत पैसे भेजें:\n- फोन नंबर से\n- UPI ID से (name@bank)\n- QR कोड स्कैन से\n\n**लोकप्रिय UPI ऐप्स:**\n- Google Pay\n- PhonePe\n- Paytm\n- BHIM',
        },
        {
          'type': 'text',
          'en': '## 🔐 UPI Safety Tips\n\n**Remember:**\n- ✅ Never share UPI PIN\n- ✅ Don\'t click unknown links\n- ✅ Verify receiver before sending\n- ✅ Use app lock\n\n**⚠️ Warning:**\nTo RECEIVE money, you don\'t enter PIN!\nIf someone asks PIN to send you money = FRAUD!',
          'hi': '## 🔐 UPI सुरक्षा टिप्स\n\n**याद रखें:**\n- ✅ UPI PIN कभी शेयर न करें\n- ✅ अनजान लिंक क्लिक न करें\n- ✅ भेजने से पहले रिसीवर जांचें\n- ✅ ऐप लॉक लगाएं\n\n**⚠️ चेतावनी:**\nपैसे लेने के लिए PIN नहीं डालना होता!\nअगर कोई पैसे भेजने के लिए PIN मांगे = धोखा!',
        },
        {
          'type': 'text',
          'en': '## 💸 Benefits of UPI\n\n1. **Free** - No charges for transfer\n2. **Instant** - Money reaches in seconds\n3. **24x7** - Works anytime, holidays too\n4. **Easy** - Just scan and pay\n5. **Limit** - Up to ₹1 lakh per transaction',
          'hi': '## 💸 UPI के फायदे\n\n1. **मुफ्त** - ट्रांसफर पर कोई चार्ज नहीं\n2. **तुरंत** - पैसे सेकंड में पहुंचते हैं\n3. **24x7** - कभी भी, छुट्टी में भी\n4. **आसान** - बस स्कैन करो और पे करो\n5. **लिमिट** - एक बार में ₹1 लाख तक',
        },
      ],
      'mcqs': [
        {
          'question': 'Do you need to enter PIN to receive money via UPI?',
          'questionHi': 'UPI से पैसे लेने के लिए PIN डालना होता है?',
          'options': ['Yes, always', 'No, never', 'Sometimes', 'Only for big amounts'],
          'correct': 1,
        },
        {
          'question': 'What is the transaction limit for UPI?',
          'questionHi': 'UPI की ट्रांजेक्शन लिमिट क्या है?',
          'options': ['₹10,000', '₹50,000', '₹1 lakh', '₹5 lakh'],
          'correct': 2,
        },
        {
          'question': 'Which is NOT a UPI app?',
          'questionHi': 'कौन सा UPI ऐप नहीं है?',
          'options': ['Google Pay', 'PhonePe', 'WhatsApp', 'Calculator'],
          'correct': 3,
        },
      ],
    },
  ];

  /// Get lessons for a specific category
  static List<Map<String, dynamic>> getLessonsForCategory(String categoryId) {
    return lessonsByCategory[categoryId] ?? [];
  }

  /// Get lesson IDs for a category (for unlock checking)
  static List<String> getLessonIdsForCategory(String categoryId) {
    return getLessonsForCategory(categoryId)
        .map((lesson) => lesson['id'] as String)
        .toList();
  }

  /// Get a specific lesson by ID
  static Map<String, dynamic>? getLessonById(String lessonId) {
    for (final lessons in lessonsByCategory.values) {
      for (final lesson in lessons) {
        if (lesson['id'] == lessonId) {
          return lesson;
        }
      }
    }
    return null;
  }
}
