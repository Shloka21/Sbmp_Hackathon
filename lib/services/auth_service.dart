import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:sms_autofill/sms_autofill.dart';

import '../models/sim_card.dart';

/// Authentication & Session Service with SIM Detection
class AuthService {
  static const String _phoneKey = 'user_phone';
  static const String _lastAuthKey = 'last_full_auth';
  static const String _localAuthEnabledKey = 'local_auth_enabled';
  static const String _pinKey = 'user_pin';
  static const String _lastActivityKey = 'last_activity';
  static const int _reAuthDays = 7; // Require full auth after 7 days
  static const int _lockoutMinutes = 30; // Require local auth after 30 mins inactivity
  
  // Platform channel for phone number
  static const _phoneChannel = MethodChannel('com.sathi/phone');
  static const platform = MethodChannel('com.sathi.app/sim');
  
  // Local auth
  final LocalAuthentication _localAuth = LocalAuthentication();
  
  SharedPreferences? _prefs;
  
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    // Do NOT update activity here, otherwise we can't detect inactivity on startup
  }
  
  /// Update activity timestamp (call on any user action)
  Future<void> updateLastActivity() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    await prefs.setString(_lastActivityKey, DateTime.now().toIso8601String());
  }
  
  /// Check if user needs local auth (after inactivity)
  Future<bool> needsLocalAuth() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    final lastActivityStr = prefs.getString(_lastActivityKey);
    
    if (lastActivityStr == null) return false;
    
    final lastActivity = DateTime.tryParse(lastActivityStr);
    if (lastActivity == null) return false;
    
    final minutesSinceActivity = DateTime.now().difference(lastActivity).inMinutes;
    return minutesSinceActivity >= _lockoutMinutes;
  }
  
  /// Check if user needs full authentication (OTP)
  Future<bool> needsFullAuth() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    final lastAuthStr = prefs.getString(_lastAuthKey);
    
    if (lastAuthStr == null) return true;
    
    final lastAuth = DateTime.tryParse(lastAuthStr);
    if (lastAuth == null) return true;
    
    final daysSinceAuth = DateTime.now().difference(lastAuth).inDays;
    return daysSinceAuth >= _reAuthDays;
  }
  
  /// Check if user is registered
  Future<bool> isRegistered() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    return prefs.getString(_phoneKey) != null;
  }
  
  /// Get stored phone number
  Future<String?> getPhoneNumber() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    return prefs.getString(_phoneKey);
  }
  
  /// Save phone number after successful OTP
  Future<void> savePhoneAuth(String phoneNumber) async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    await prefs.setString(_phoneKey, phoneNumber);
    await prefs.setString(_lastAuthKey, DateTime.now().toIso8601String());
    await updateLastActivity();
  }
  
  /// Update last auth timestamp
  Future<void> updateLastAuth() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    await prefs.setString(_lastAuthKey, DateTime.now().toIso8601String());
    await updateLastActivity();
  }
  
  /// Check if local auth (PIN/biometric) is enabled
  Future<bool> isLocalAuthEnabled() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    return prefs.getBool(_localAuthEnabledKey) ?? false;
  }
  
  /// Enable local auth
  Future<void> setLocalAuthEnabled(bool enabled) async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    await prefs.setBool(_localAuthEnabledKey, enabled);
  }
  
  /// Save PIN
  Future<void> savePin(String pin) async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    await prefs.setString(_pinKey, pin);
    await prefs.setBool(_localAuthEnabledKey, true);
  }
  
  /// Verify PIN
  Future<bool> verifyPin(String pin) async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    final savedPin = prefs.getString(_pinKey);
    final verified = savedPin == pin;
    if (verified) {
      await updateLastActivity();
    }
    return verified;
  }
  
  /// Check if biometric auth is available
  Future<bool> isBiometricAvailable() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      return canCheck && isDeviceSupported;
    } catch (e) {
      debugPrint('Biometric check error: $e');
      return false;
    }
  }
  
  /// Authenticate with biometrics
  Future<bool> authenticateWithBiometrics() async {
    try {
      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Scan your fingerprint or face to unlock Sathi',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
        authMessages: const [
           AndroidAuthMessages(
            signInTitle: 'Unlock Sathi 🔒',
            cancelButton: 'Cancel',
            biometricHint: 'Verify identity',
          ),
        ],
      );
      if (authenticated) {
        await updateLastActivity();
      }
      return authenticated;
    } catch (e) {
      debugPrint('Biometric auth error: $e');
      return false;
    }
  }
  
  /// Generate mock OTP (for hackathon demo)
  String generateOTP() {
    // In production, this would call an SMS API
    return '123456'; // Demo OTP
  }
  
  /// Verify OTP (mock for hackathon)
  bool verifyOTP(String enteredOTP, String generatedOTP) {
    return enteredOTP == generatedOTP;
  }
  
   Future<List<SimCard>> detectAllSimCards() async {
    try {
      final List<dynamic> result = await platform.invokeMethod('getAllSimCards');
      
      return result.map((sim) => SimCard(
        phoneNumber: sim['phoneNumber'] ?? '',
        carrierName: sim['carrierName'],
        isPrimary: sim['isPrimary'] ?? false,
        slotIndex: sim['slotIndex'] ?? 0,
      )).toList();
    } catch (e) {
      print('Error detecting SIM cards: $e');
      return [];
    }
  }
  
  /// Detect phone number from SIM (Android only)
  Future<String?> detectPhoneNumber() async {
    try {
      final String? phoneNumber = await _phoneChannel.invokeMethod('getPhoneNumber');
      if (phoneNumber != null && phoneNumber.isNotEmpty) {
        // Clean and format
        final cleaned = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
        if (cleaned.length >= 10) {
          return cleaned.substring(cleaned.length - 10);
        }
      }
      return null;
    } on PlatformException catch (e) {
      debugPrint('Phone number detection failed: $e');
      return null;
    } catch (e) {
      debugPrint('Phone detection error: $e');
      return null;
    }
  }
  
  /// Request phone number hint (Google Smart Lock)
  Future<String?> requestPhoneHint() async {
    try {
      final SmsAutoFill smsAutoFill = SmsAutoFill();
      final String? phoneNumber = await smsAutoFill.hint;
      
      if (phoneNumber != null && phoneNumber.isNotEmpty) {
        // Clean and format
        // Usually returns +91XXXXXXXXXX
        final cleaned = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
        if (cleaned.length >= 10) {
          return cleaned.substring(cleaned.length - 10);
        }
        return cleaned;
      }
      return null;
    } catch (e) {
      debugPrint('Smart Lock hint error: $e');
      return null;
    }
  }

  /// Logout (soft - keep phone for quick re-login)
  Future<void> logout() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    await prefs.remove(_lastAuthKey);
    await prefs.remove(_lastActivityKey);
    try {
      await SmsAutoFill().unregisterListener();
    } catch (_) {}
  }
  
  /// Full logout (clear all)
  Future<void> fullLogout() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    await prefs.remove(_phoneKey);
    await prefs.remove(_lastAuthKey);
    await prefs.remove(_localAuthEnabledKey);
    await prefs.remove(_pinKey);
    await prefs.remove(_lastActivityKey);
    try {
      await SmsAutoFill().unregisterListener();
    } catch (_) {}
  }
}
