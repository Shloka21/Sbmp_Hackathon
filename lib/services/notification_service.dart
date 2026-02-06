import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:math';

/// Notification Service for OTP delivery
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();
  
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  String? _lastOTP;
  
  /// Initialize service
  Future<void> init() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    
    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        debugPrint('Notification tapped: ${response.payload}');
      },
    );
    
    // Request permission for Android 13+
    await _notificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
        
    debugPrint('NotificationService initialized with flutter_local_notifications');
  }
  
  /// Generate a 6-digit OTP
  String generateOTP() {
    final random = Random();
    _lastOTP = (100000 + random.nextInt(900000)).toString();
    return _lastOTP!;
  }
  
  /// Get the last generated OTP (for auto-fill)
  String? getLastOTP() => _lastOTP;
  
  /// Show OTP notification
  Future<void> showOTPNotification(String otp) async {
    const androidDetails = AndroidNotificationDetails(
      'otp_channel',
      'OTP Notifications',
      channelDescription: 'Notifications for authentication codes',
      importance: Importance.max,
      priority: Priority.high,
    );
    
    const details = NotificationDetails(android: androidDetails);
    
    await _notificationsPlugin.show(
      0,
      'Sathi Verification Code',
      'Your OTP is: $otp',
      details,
      payload: otp,
    );
  }
  
  /// Verify OTP
  bool verifyOTP(String enteredOTP) {
    return enteredOTP == _lastOTP;
  }
  
  /// Clear OTP after use
  void clearOTP() {
    _lastOTP = null;
  }
}
