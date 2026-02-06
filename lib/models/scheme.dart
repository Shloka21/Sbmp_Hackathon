/// Government Scheme Model with eligibility criteria

class Scheme {
  final String id;
  final String name;
  final String nameHi;
  final String description;
  final String descriptionHi;
  final String category;
  final List<String> benefits;
  final List<String> benefitsHi;
  final List<String> eligibility;
  final List<String> eligibilityHi;
  final List<String> documents;
  final List<String> documentsHi;
  final List<String> howToApply;
  final List<String> howToApplyHi;
  final String emoji;
  final String? websiteUrl;

  const Scheme({
    required this.id,
    required this.name,
    required this.nameHi,
    required this.description,
    required this.descriptionHi,
    required this.category,
    required this.benefits,
    required this.benefitsHi,
    required this.eligibility,
    required this.eligibilityHi,
    required this.documents,
    required this.documentsHi,
    required this.howToApply,
    required this.howToApplyHi,
    required this.emoji,
    this.websiteUrl,
  });
}

/// Real Government Schemes Database
class GovernmentSchemes {
  static const List<Scheme> all = [
    // PM-KISAN
    Scheme(
      id: 'pm_kisan',
      name: 'PM-KISAN Samman Nidhi',
      nameHi: 'पीएम किसान सम्मान निधि',
      description: 'Direct income support of ₹6,000 per year to farmer families',
      descriptionHi: 'किसान परिवारों को ₹6,000 प्रति वर्ष की सीधी आय सहायता',
      category: 'farmer',
      benefits: [
        '₹6,000 per year in 3 installments',
        'Direct transfer to bank account',
        'No middlemen involved',
        'Covers small and marginal farmers',
      ],
      benefitsHi: [
        '₹6,000 प्रति वर्ष 3 किस्तों में',
        'सीधे बैंक खाते में ट्रांसफर',
        'कोई बिचौलिया नहीं',
        'छोटे और सीमांत किसानों के लिए',
      ],
      eligibility: [
        'Own cultivable land',
        'Not be a government employee',
        'Not be income tax payer',
        'Land registered in your name',
      ],
      eligibilityHi: [
        'खेती योग्य जमीन का मालिक हो',
        'सरकारी कर्मचारी न हो',
        'आयकर दाता न हो',
        'जमीन आपके नाम पर पंजीकृत हो',
      ],
      documents: [
        'Aadhaar Card',
        'Bank Account Passbook',
        'Land Ownership Documents (Khatauni)',
        'Mobile Number',
      ],
      documentsHi: [
        'आधार कार्ड',
        'बैंक खाता पासबुक',
        'जमीन के कागजात (खतौनी)',
        'मोबाइल नंबर',
      ],
      howToApply: [
        'Visit pmkisan.gov.in or CSC center',
        'Fill New Farmer Registration form',
        'Upload required documents',
        'Submit and note application number',
        'Track status online',
      ],
      howToApplyHi: [
        'pmkisan.gov.in या CSC केंद्र जाएं',
        'नया किसान पंजीकरण फॉर्म भरें',
        'आवश्यक दस्तावेज अपलोड करें',
        'सबमिट करें और आवेदन नंबर नोट करें',
        'ऑनलाइन स्टेटस ट्रैक करें',
      ],
      emoji: '🌾',
      websiteUrl: 'https://pmkisan.gov.in',
    ),

    // Jan Dhan Yojana
    Scheme(
      id: 'jan_dhan',
      name: 'Pradhan Mantri Jan Dhan Yojana',
      nameHi: 'प्रधानमंत्री जन धन योजना',
      description: 'Zero-balance bank account with insurance and overdraft facility',
      descriptionHi: 'बीमा और ओवरड्राफ्ट सुविधा के साथ जीरो बैलेंस बैंक खाता',
      category: 'all',
      benefits: [
        'Zero balance bank account',
        'RuPay Debit Card',
        '₹2 lakh accident insurance',
        '₹30,000 life insurance',
        '₹10,000 overdraft facility',
      ],
      benefitsHi: [
        'जीरो बैलेंस बैंक खाता',
        'रुपे डेबिट कार्ड',
        '₹2 लाख दुर्घटना बीमा',
        '₹30,000 जीवन बीमा',
        '₹10,000 ओवरड्राफ्ट सुविधा',
      ],
      eligibility: [
        'Indian citizen',
        'Age 10 years or above',
        'No existing bank account',
        'Valid identity proof',
      ],
      eligibilityHi: [
        'भारतीय नागरिक',
        'उम्र 10 साल या अधिक',
        'पहले से बैंक खाता न हो',
        'वैध पहचान प्रमाण',
      ],
      documents: [
        'Aadhaar Card',
        'Passport size photo',
        'Address Proof',
      ],
      documentsHi: [
        'आधार कार्ड',
        'पासपोर्ट साइज फोटो',
        'पता प्रमाण',
      ],
      howToApply: [
        'Visit nearest bank branch',
        'Fill Jan Dhan account opening form',
        'Submit KYC documents',
        'Get RuPay card instantly',
      ],
      howToApplyHi: [
        'नज़दीकी बैंक शाखा जाएं',
        'जन धन खाता खोलने का फॉर्म भरें',
        'KYC दस्तावेज जमा करें',
        'तुरंत RuPay कार्ड पाएं',
      ],
      emoji: '🏦',
      websiteUrl: 'https://pmjdy.gov.in',
    ),

    // Mudra Loan
    Scheme(
      id: 'mudra',
      name: 'Pradhan Mantri MUDRA Yojana',
      nameHi: 'प्रधानमंत्री मुद्रा योजना',
      description: 'Collateral-free loans up to ₹10 lakh for small businesses',
      descriptionHi: 'छोटे व्यवसायों के लिए ₹10 लाख तक का गारंटी-मुक्त ऋण',
      category: 'business',
      benefits: [
        'Shishu: Up to ₹50,000',
        'Kishore: ₹50,000 to ₹5 lakh',
        'Tarun: ₹5 lakh to ₹10 lakh',
        'No collateral required',
        'Low interest rates',
      ],
      benefitsHi: [
        'शिशु: ₹50,000 तक',
        'किशोर: ₹50,000 से ₹5 लाख',
        'तरुण: ₹5 लाख से ₹10 लाख',
        'कोई गारंटी नहीं',
        'कम ब्याज दर',
      ],
      eligibility: [
        'Indian citizen',
        'Have a business plan',
        'Non-farm business activity',
        'Not defaulter of any bank',
      ],
      eligibilityHi: [
        'भारतीय नागरिक',
        'व्यापार योजना हो',
        'गैर-कृषि व्यवसाय गतिविधि',
        'किसी बैंक का डिफॉल्टर न हो',
      ],
      documents: [
        'Identity Proof (Aadhaar/PAN)',
        'Address Proof',
        'Business Plan',
        'Bank Statement (6 months)',
        'Passport Photos',
      ],
      documentsHi: [
        'पहचान प्रमाण (आधार/पैन)',
        'पता प्रमाण',
        'व्यापार योजना',
        'बैंक स्टेटमेंट (6 महीने)',
        'पासपोर्ट फोटो',
      ],
      howToApply: [
        'Visit bank or mudra.org.in',
        'Fill Mudra loan application',
        'Submit business plan',
        'Await approval (7-10 days)',
      ],
      howToApplyHi: [
        'बैंक या mudra.org.in जाएं',
        'मुद्रा ऋण आवेदन भरें',
        'व्यापार योजना जमा करें',
        'स्वीकृति का इंतज़ार करें (7-10 दिन)',
      ],
      emoji: '💼',
      websiteUrl: 'https://mudra.org.in',
    ),

    // Sukanya Samriddhi
    Scheme(
      id: 'sukanya',
      name: 'Sukanya Samriddhi Yojana',
      nameHi: 'सुकन्या समृद्धि योजना',
      description: 'Savings scheme for girl child with high interest rate',
      descriptionHi: 'उच्च ब्याज दर के साथ बालिकाओं के लिए बचत योजना',
      category: 'women',
      benefits: [
        '8.2% interest rate (highest)',
        'Tax exemption under 80C',
        'Minimum ₹250/year deposit',
        'Maximum ₹1.5 lakh/year',
        'Matures at age 21',
      ],
      benefitsHi: [
        '8.2% ब्याज दर (सबसे अधिक)',
        '80C के तहत टैक्स छूट',
        'न्यूनतम ₹250/वर्ष जमा',
        'अधिकतम ₹1.5 लाख/वर्ष',
        '21 साल की उम्र में परिपक्व',
      ],
      eligibility: [
        'Girl child below 10 years',
        'Only 2 accounts per family',
        'Parents/guardian as operator',
      ],
      eligibilityHi: [
        '10 साल से कम उम्र की बालिका',
        'प्रति परिवार केवल 2 खाते',
        'माता-पिता/अभिभावक संचालक के रूप में',
      ],
      documents: [
        'Birth Certificate of girl child',
        'Parent\'s ID Proof',
        'Address Proof',
        'Passport Photos',
      ],
      documentsHi: [
        'बालिका का जन्म प्रमाण पत्र',
        'माता-पिता का पहचान प्रमाण',
        'पता प्रमाण',
        'पासपोर्ट फोटो',
      ],
      howToApply: [
        'Visit post office or bank',
        'Fill SSY account opening form',
        'Submit documents',
        'Deposit minimum ₹250',
        'Get passbook',
      ],
      howToApplyHi: [
        'पोस्ट ऑफिस या बैंक जाएं',
        'SSY खाता खोलने का फॉर्म भरें',
        'दस्तावेज जमा करें',
        'न्यूनतम ₹250 जमा करें',
        'पासबुक प्राप्त करें',
      ],
      emoji: '👧',
      websiteUrl: 'https://www.nsiindia.gov.in',
    ),

    // PM-SYM
    Scheme(
      id: 'pm_sym',
      name: 'PM Shram Yogi Maan-dhan',
      nameHi: 'पीएम श्रम योगी मान-धन',
      description: 'Pension scheme for unorganized sector workers',
      descriptionHi: 'असंगठित क्षेत्र के कर्मचारियों के लिए पेंशन योजना',
      category: 'worker',
      benefits: [
        '₹3,000 monthly pension after 60',
        'Government contributes equal amount',
        '₹55-200/month contribution',
        'Family pension available',
      ],
      benefitsHi: [
        '60 के बाद ₹3,000 मासिक पेंशन',
        'सरकार बराबर योगदान देती है',
        '₹55-200/माह योगदान',
        'पारिवारिक पेंशन उपलब्ध',
      ],
      eligibility: [
        'Age 18-40 years',
        'Unorganized worker',
        'Monthly income under ₹15,000',
        'Not under EPFO/ESIC/NPS',
      ],
      eligibilityHi: [
        'उम्र 18-40 साल',
        'असंगठित कर्मचारी',
        'मासिक आय ₹15,000 से कम',
        'EPFO/ESIC/NPS में न हो',
      ],
      documents: [
        'Aadhaar Card',
        'Bank Account',
        'Mobile Number',
      ],
      documentsHi: [
        'आधार कार्ड',
        'बैंक खाता',
        'मोबाइल नंबर',
      ],
      howToApply: [
        'Visit nearest CSC center',
        'Self-registration on maandhan.in',
        'Link bank account',
        'Start monthly contributions',
      ],
      howToApplyHi: [
        'नज़दीकी CSC केंद्र जाएं',
        'maandhan.in पर स्वयं पंजीकरण',
        'बैंक खाता लिंक करें',
        'मासिक योगदान शुरू करें',
      ],
      emoji: '👷',
      websiteUrl: 'https://maandhan.in',
    ),

    // Lakhpati Didi
    Scheme(
      id: 'lakhpati_didi',
      name: 'Lakhpati Didi Scheme',
      nameHi: 'लखपति दीदी योजना',
      description: 'Empowering SHG women to earn ₹1 lakh annually',
      descriptionHi: 'SHG महिलाओं को ₹1 लाख सालाना कमाने में सशक्त बनाना',
      category: 'women',
      benefits: [
        'Skill training programs',
        'Financial literacy training',
        'Access to micro-credit',
        'Marketing support',
        'Target: ₹1 lakh yearly income',
      ],
      benefitsHi: [
        'कौशल प्रशिक्षण कार्यक्रम',
        'वित्तीय साक्षरता प्रशिक्षण',
        'माइक्रो-क्रेडिट तक पहुंच',
        'मार्केटिंग सहायता',
        'लक्ष्य: ₹1 लाख वार्षिक आय',
      ],
      eligibility: [
        'Women Self-Help Group member',
        'Active SHG participation',
        'Rural area resident',
      ],
      eligibilityHi: [
        'महिला स्वयं सहायता समूह सदस्य',
        'सक्रिय SHG भागीदारी',
        'ग्रामीण क्षेत्र निवासी',
      ],
      documents: [
        'SHG Membership Proof',
        'Aadhaar Card',
        'Bank Account',
      ],
      documentsHi: [
        'SHG सदस्यता प्रमाण',
        'आधार कार्ड',
        'बैंक खाता',
      ],
      howToApply: [
        'Join a Self-Help Group',
        'Contact block development office',
        'Enroll in skill training',
        'Apply through SHG federation',
      ],
      howToApplyHi: [
        'स्वयं सहायता समूह से जुड़ें',
        'ब्लॉक विकास कार्यालय संपर्क करें',
        'कौशल प्रशिक्षण में नामांकन करें',
        'SHG फेडरेशन के माध्यम से आवेदन करें',
      ],
      emoji: '👩‍🌾',
    ),

    // PM Awas Yojana
    Scheme(
      id: 'pm_awas',
      name: 'PM Awas Yojana (Rural)',
      nameHi: 'पीएम आवास योजना (ग्रामीण)',
      description: 'Financial assistance for building pucca house',
      descriptionHi: 'पक्का मकान बनाने के लिए वित्तीय सहायता',
      category: 'all',
      benefits: [
        '₹1.2 lakh assistance in plains',
        '₹1.3 lakh in hilly areas',
        '90 days MGNREGA wages',
        'Toilet subsidy included',
      ],
      benefitsHi: [
        'मैदानी क्षेत्र में ₹1.2 लाख सहायता',
        'पहाड़ी क्षेत्रों में ₹1.3 लाख',
        '90 दिन मनरेगा मजदूरी',
        'शौचालय सब्सिडी शामिल',
      ],
      eligibility: [
        'No pucca house',
        'Rural resident',
        'Name in SECC-2011 list',
        'Not received housing assistance before',
      ],
      eligibilityHi: [
        'पक्का मकान न हो',
        'ग्रामीण निवासी',
        'SECC-2011 सूची में नाम',
        'पहले आवास सहायता न मिली हो',
      ],
      documents: [
        'Aadhaar Card',
        'SECC Survey ID',
        'Bank Account',
        'Land Documents',
      ],
      documentsHi: [
        'आधार कार्ड',
        'SECC सर्वे आईडी',
        'बैंक खाता',
        'जमीन के कागजात',
      ],
      howToApply: [
        'Apply through Gram Panchayat',
        'Submit at pmayg.nic.in',
        'Verification by officials',
        'Approval and fund transfer',
      ],
      howToApplyHi: [
        'ग्राम पंचायत के माध्यम से आवेदन करें',
        'pmayg.nic.in पर जमा करें',
        'अधिकारियों द्वारा सत्यापन',
        'स्वीकृति और फंड ट्रांसफर',
      ],
      emoji: '🏠',
      websiteUrl: 'https://pmayg.nic.in',
    ),

    // Student Scholarship
    Scheme(
      id: 'scholarship',
      name: 'National Scholarship Portal',
      nameHi: 'राष्ट्रीय छात्रवृत्ति पोर्टल',
      description: 'Various scholarships for students from all backgrounds',
      descriptionHi: 'सभी पृष्ठभूमि के छात्रों के लिए विभिन्न छात्रवृत्तियां',
      category: 'student',
      benefits: [
        'Pre-matric scholarships',
        'Post-matric scholarships',
        'Merit-cum-means based aid',
        'Covers tuition and fees',
      ],
      benefitsHi: [
        'प्री-मैट्रिक छात्रवृत्ति',
        'पोस्ट-मैट्रिक छात्रवृत्ति',
        'योग्यता-सह-साधन आधारित सहायता',
        'ट्यूशन और फीस कवर',
      ],
      eligibility: [
        'Indian student',
        'Family income criteria',
        'Enrolled in recognized institution',
        'Good academic record',
      ],
      eligibilityHi: [
        'भारतीय छात्र',
        'परिवार की आय मानदंड',
        'मान्यता प्राप्त संस्थान में नामांकित',
        'अच्छा अकादमिक रिकॉर्ड',
      ],
      documents: [
        'Aadhaar Card',
        'Income Certificate',
        'Previous Marksheet',
        'Bank Account',
        'Bonafide Certificate',
      ],
      documentsHi: [
        'आधार कार्ड',
        'आय प्रमाण पत्र',
        'पिछली मार्कशीट',
        'बैंक खाता',
        'बोनाफाइड प्रमाण पत्र',
      ],
      howToApply: [
        'Register on scholarships.gov.in',
        'Find eligible scholarships',
        'Fill online application',
        'Upload documents',
        'Track status',
      ],
      howToApplyHi: [
        'scholarships.gov.in पर रजिस्टर करें',
        'योग्य छात्रवृत्तियां खोजें',
        'ऑनलाइन आवेदन भरें',
        'दस्तावेज अपलोड करें',
        'स्टेटस ट्रैक करें',
      ],
      emoji: '🎓',
      websiteUrl: 'https://scholarships.gov.in',
    ),
  ];

  /// Get schemes by category
  static List<Scheme> getByCategory(String category) {
    if (category == 'all') return all;
    return all.where((s) => s.category == category).toList();
  }

  /// Get scheme by ID
  static Scheme? getById(String id) {
    try {
      return all.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Filter schemes by user occupation
  static List<Scheme> getForOccupation(String occupation) {
    switch (occupation) {
      case 'farmer':
        return all.where((s) => s.category == 'farmer' || s.category == 'all').toList();
      case 'student':
        return all.where((s) => s.category == 'student' || s.category == 'all').toList();
      case 'homemaker':
        return all.where((s) => s.category == 'women' || s.category == 'all').toList();
      case 'daily_worker':
      case 'driver':
      case 'artisan':
        return all.where((s) => s.category == 'worker' || s.category == 'all').toList();
      case 'small_business':
      case 'shopkeeper':
        return all.where((s) => s.category == 'business' || s.category == 'all').toList();
      default:
        return all;
    }
  }
}
