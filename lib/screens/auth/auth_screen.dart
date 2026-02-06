import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../config/theme.dart';
import '../../models/sim_card.dart';
import '../../providers/user_provider.dart';
import '../../services/auth_service.dart';
import '../../services/notification_service.dart';

/// Phone Authentication Screen with SIM-only detection
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final TextEditingController _phoneController = TextEditingController(); // Restored
  final TextEditingController _otpController = TextEditingController();
  final AuthService _authService = AuthService();
  final NotificationService _notificationService = NotificationService();
  
  bool _isLoading = false;
  bool _otpSent = false;
  String? _errorMessage;
  int _resendTimer = 0;
  
  // SIM detection
  List<SimCard> _detectedSims = [];
  SimCard? _selectedSim;
  bool _isDetecting = true;
  bool _permissionDenied = false;

  @override
  void initState() {
    super.initState();
    _initServices();
  }

  Future<void> _initServices() async {
    await _authService.init();
    await _notificationService.init();
    
    // Auto-detect all SIM cards
    await _detectAllSims();
  }

  // Services initialized in initState above

  /// Detect all SIM cards from device
  Future<void> _detectAllSims() async {
    setState(() {
      _isDetecting = true;
      _permissionDenied = false;
      _errorMessage = null;
    });
    
    List<SimCard> foundSims = [];
    
    // 1. Try Native SIM Detection (Permission Based)
    final status = await Permission.phone.request();
    
    if (status.isGranted) {
      try {
        final sims = await _authService.detectAllSimCards();
        foundSims = sims.where((s) => s.phoneNumber.isNotEmpty).toList();
      } catch (e) {
        debugPrint('SIM detection error: $e');
      }
    } else if (status.isPermanentlyDenied) {
      if (mounted) setState(() => _permissionDenied = true);
    }

    // 2. If no SIMs found, try Google Smart Lock (Phone Hint)
    if (foundSims.isEmpty) {
      if (mounted) {
        setState(() {
          _errorMessage = null; // Clear any perm errors temporarily
        });
      }
      
      try {
        // Delay slightly to ensure UI is ready
        await Future.delayed(const Duration(milliseconds: 500));
        final smartLockNumber = await _authService.requestPhoneHint();
        if (smartLockNumber != null) {
          foundSims.add(SimCard(
            phoneNumber: smartLockNumber,
            carrierName: 'Google Account',
            isPrimary: true,
            slotIndex: 0,
          ));
        }
      } catch (e) {
        debugPrint('Smart Lock failed: $e');
      }
    }
    
    if (mounted) {
      setState(() {
        _detectedSims = foundSims;
        _isDetecting = false;
        
        // Auto-select if found
        if (foundSims.isNotEmpty) {
           _selectedSim = foundSims[0];
           _errorMessage = null;
           _permissionDenied = false; // Clear permission warning if we got a number via Smart Lock
        } else if (foundSims.isEmpty && !status.isPermanentlyDenied) {
           _errorMessage = _getLocalizedString('no_sim_found');
        }
      });
    }
  }

  /// Send OTP
  Future<void> _sendOTP() async {
    if (_selectedSim == null) {
      setState(() => _errorMessage = _getLocalizedString('select_sim'));
      return;
    }
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    // Generate OTP
    final otp = _notificationService.generateOTP();
    
    // Send OTP via local notification
    await _notificationService.showOTPNotification(otp);
    
    // Show instruction to check notification
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_getLocalizedString('code_sent')),
          backgroundColor: AppColors.primary,
        ),
      );
    }
    setState(() {
      _isLoading = false;
      _otpSent = true;
      _resendTimer = 30;
    });
    
    _startResendTimer();
  }

  void _startResendTimer() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      
      setState(() {
        if (_resendTimer > 0) _resendTimer--;
      });
      
      return _resendTimer > 0;
    });
  }

  void _autoFillOTP() {
    final otp = _notificationService.getLastOTP();
    if (otp != null) {
      setState(() {
        _otpController.text = otp;
      });
    }
  }

  Future<void> _verifyOTP() async {
    final enteredOTP = _otpController.text.trim();
    
    if (enteredOTP.length != 6) {
      setState(() => _errorMessage = _getLocalizedString('invalid_otp'));
      return;
    }
    
    if (!_notificationService.verifyOTP(enteredOTP)) {
      setState(() => _errorMessage = _getLocalizedString('wrong_otp'));
      return;
    }
    
    setState(() => _isLoading = true);
    
    // Save authentication with selected SIM
    await _authService.savePhoneAuth(_selectedSim!.phoneNumber);
    _notificationService.clearOTP();
    
    if (mounted) {
      final isLocalAuthEnabled = await _authService.isLocalAuthEnabled();
      if (isLocalAuthEnabled) {
        context.go('/home');
      } else {
        context.go('/setup-pin');
      }
    }
  }

  String _getLocalizedString(String key) {
    final userProvider = context.read<UserProvider>();
    final lang = userProvider.language;
    
    final strings = <String, Map<String, String>>{
      'en': {
        'select_sim': 'Please select a SIM card',
        'invalid_otp': 'Please enter 6-digit OTP',
        'wrong_otp': 'Wrong OTP. Please try again.',
        'welcome': 'Welcome to Sathi',
        'your_friend': 'Your Financial Friend',
        'select_number': 'Select your number',
        'detected_sims': 'We found these numbers',
        'send_otp': 'Send OTP',
        'verify': 'Verify',
        'resend': 'Resend',
        'otp_sent': 'OTP Sent',
        'check_notification': 'Check notification 🔔',
        'auto_fill': 'Auto-fill OTP',
        'or_enter': 'or enter manually',
        'change_number': 'Change number',
        'detecting': 'Detecting SIM cards...',
        'no_sim_found': 'No SIM card detected',
        'no_sim_help': 'Please insert a SIM card to continue',
        'retry': 'Retry Detection',
        'sim_1': 'SIM 1',
        'sim_2': 'SIM 2',
        'primary': 'Primary',
        'terms': 'By continuing, you agree to our Terms of Service',
      },
      'hi': {
        'select_sim': 'कृपया एक SIM कार्ड चुनें',
        'invalid_otp': 'कृपया 6 अंकों का OTP दर्ज करें',
        'wrong_otp': 'गलत OTP. कृपया पुनः प्रयास करें.',
        'welcome': 'साथी में आपका स्वागत है',
        'your_friend': 'आपका वित्तीय मित्र',
        'select_number': 'अपना नंबर चुनें',
        'detected_sims': 'हमें ये नंबर मिले',
        'send_otp': 'OTP भेजें',
        'verify': 'सत्यापित करें',
        'resend': 'पुनः भेजें',
        'otp_sent': 'OTP भेजा गया',
        'check_notification': 'नोटिफिकेशन देखें 🔔',
        'auto_fill': 'स्वतः भरें',
        'or_enter': 'या मैन्युअल दर्ज करें',
        'change_number': 'नंबर बदलें',
        'detecting': 'SIM कार्ड खोज रहे हैं...',
        'no_sim_found': 'कोई SIM कार्ड नहीं मिला',
        'no_sim_help': 'जारी रखने के लिए कृपया SIM कार्ड डालें',
        'retry': 'फिर से खोजें',
        'sim_1': 'SIM 1',
        'sim_2': 'SIM 2',
        'primary': 'मुख्य',
        'terms': 'जारी रखकर, आप हमारी सेवा की शर्तों से सहमत हैं',
      },
      'ta': {
        'select_sim': 'ஒரு SIM கார்டைத் தேர்ந்தெடுக்கவும்',
        'invalid_otp': '6 இலக்க OTP உள்ளிடவும்',
        'wrong_otp': 'தவறான OTP. மீண்டும் முயற்சிக்கவும்.',
        'welcome': 'சாத்தியில் வரவேற்கிறோம்',
        'your_friend': 'உங்கள் நிதி நண்பர்',
        'select_number': 'உங்கள் எண்ணைத் தேர்ந்தெடுக்கவும்',
        'detected_sims': 'இந்த எண்களைக் கண்டறிந்தோம்',
        'send_otp': 'OTP அனுப்பு',
        'verify': 'சரிபார்',
        'resend': 'மீண்டும் அனுப்பு',
        'otp_sent': 'OTP அனுப்பப்பட்டது',
        'check_notification': 'அறிவிப்பைப் பார்க்கவும் 🔔',
        'auto_fill': 'தானாக நிரப்பு',
        'or_enter': 'அல்லது கைமுறையாக உள்ளிடவும்',
        'change_number': 'எண் மாற்று',
        'detecting': 'SIM கார்டுகளைக் கண்டறிகிறது...',
        'no_sim_found': 'SIM கார்டு கண்டறியப்படவில்லை',
        'no_sim_help': 'தொடர SIM கார்டைச் செருகவும்',
        'retry': 'மீண்டும் கண்டறி',
        'sim_1': 'SIM 1',
        'sim_2': 'SIM 2',
        'primary': 'முதன்மை',
        'terms': 'தொடர்வதன் மூலம், எங்கள் சேவை விதிமுறைகளை ஒப்புக்கொள்கிறீர்கள்',
      },
    };
    
    return strings[lang]?[key] ?? strings['en']?[key] ?? key;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              
              // Logo and title
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Center(
                        child: Text('🐻', style: TextStyle(fontSize: 50)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _getLocalizedString('welcome'),
                      style: AppTypography.headlineLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getLocalizedString('your_friend'),
                      style: AppTypography.bodyMedium,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 50),
              
              // SIM selection or OTP section
              if (!_otpSent) _buildSimSelectionSection() else _buildOTPSection(),
              
              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red.shade700),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              
              const SizedBox(height: 32),
              
              // Action button
              if (!_isDetecting && (_detectedSims.isNotEmpty || _otpSent))
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : (_otpSent ? _verifyOTP : _sendOTP),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(_otpSent ? Icons.verified : Icons.send),
                              const SizedBox(width: 8),
                              Text(
                                _getLocalizedString(_otpSent ? 'verify' : 'send_otp'),
                                style: AppTypography.buttonText,
                              ),
                            ],
                          ),
                  ),
                ),
              
              const SizedBox(height: 40),
              
              // Terms
              Text(
                _getLocalizedString('terms'),
                style: AppTypography.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSimSelectionSection() {
    if (_permissionDenied) {
      return Center(
        child: Column(
          children: [
            const Icon(Icons.settings_phone, size: 60, color: Colors.orange),
            const SizedBox(height: 16),
            Text(
              'Permission Required',
              style: AppTypography.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'We need phone permission to detect your SIM card for secure authentication.',
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => openAppSettings(),
              child: const Text('Open Settings'),
            ),
            TextButton(
              onPressed: _detectAllSims,
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }


    if (_isDetecting) {
      // Loading state (keep existing)
      return Center(
        child: Column(
          children: [
            // ... (keep existing loading UI)
            const SizedBox(height: 40),
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            Text(
              _getLocalizedString('detecting'),
              style: AppTypography.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Please wait...',
              style: AppTypography.bodySmall,
            ),
          ],
        ),
      );
    }
    
    if (_detectedSims.isEmpty) {
      // No SIM found
      return Center(
        child: Column(
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.sim_card_alert,
                size: 60,
                color: Colors.orange.shade700,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              _getLocalizedString('no_sim_found'),
              style: AppTypography.titleLarge,
            ),
            const SizedBox(height: 12),
            Text(
              _getLocalizedString('no_sim_help'),
              style: AppTypography.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 48,
              child: OutlinedButton.icon(
                onPressed: _detectAllSims,
                icon: const Icon(Icons.refresh),
                label: Text(_getLocalizedString('retry')),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
    
    // SIM cards found - show selection
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _getLocalizedString('select_number'),
          style: AppTypography.titleLarge,
        ),
        // ... rest of list ... (keep existing)
        const SizedBox(height: 8),
        Text(
          _getLocalizedString('detected_sims'),
          style: AppTypography.bodyMedium.copyWith(
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 24),
        
        // SIM cards
        ..._detectedSims.asMap().entries.map((entry) {
          final index = entry.key;
          final sim = entry.value;
          final isSelected = _selectedSim?.phoneNumber == sim.phoneNumber;
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedSim = sim;
                  _errorMessage = null;
                });
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : Colors.grey.shade200,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    // SIM icon
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? AppColors.primary 
                            : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.sim_card,
                        color: isSelected ? Colors.white : Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(width: 16),
                    
                    // SIM details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                _getLocalizedString(index == 0 ? 'sim_1' : 'sim_2'),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected 
                                      ? AppColors.primary 
                                      : Colors.grey.shade600,
                                ),
                              ),
                              if (sim.isPrimary) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    _getLocalizedString('primary'),
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '+91 ${sim.phoneNumber}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? AppColors.primary : Colors.black87,
                            ),
                          ),
                          if (sim.carrierName != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              sim.carrierName!,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    
                    // Selection indicator
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected 
                              ? AppColors.primary 
                              : Colors.grey.shade300,
                          width: 2,
                        ),
                        color: isSelected ? AppColors.primary : Colors.transparent,
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check,
                              size: 16,
                              color: Colors.white,
                            )
                          : null,
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildOTPSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Selected number display
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.phone_android, color: Colors.grey.shade700),
              const SizedBox(width: 12),
              Text(
                '+91 ${_selectedSim?.phoneNumber}',
                style: AppTypography.titleMedium,
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  setState(() {
                    _otpSent = false;
                    _otpController.clear();
                    _errorMessage = null;
                  });
                },
                child: Text(_getLocalizedString('change_number')),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        
        // OTP sent confirmation
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const Icon(Icons.notifications_active, color: AppColors.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getLocalizedString('otp_sent'),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      _getLocalizedString('check_notification'),
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Auto-fill button
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            onPressed: _autoFillOTP,
            icon: const Icon(Icons.auto_fix_high),
            label: Text(_getLocalizedString('auto_fill')),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Divider with "or"
        Row(
          children: [
            Expanded(child: Divider(color: Colors.grey.shade300)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                _getLocalizedString('or_enter'),
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
            ),
            Expanded(child: Divider(color: Colors.grey.shade300)),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Manual OTP input
        TextField(
          controller: _otpController,
          keyboardType: TextInputType.number,
          maxLength: 6,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            hintText: '● ● ● ● ● ●',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            counterText: '',
          ),
          style: const TextStyle(
            fontSize: 28,
            letterSpacing: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Resend button
        Center(
          child: TextButton(
            onPressed: _resendTimer > 0 ? null : _sendOTP,
            child: Text(
              _resendTimer > 0 
                  ? '${_getLocalizedString('resend')} (${_resendTimer}s)'
                  : _getLocalizedString('resend'),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }
}

