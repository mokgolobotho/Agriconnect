import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../Home/HomePage.dart';
import 'LoginPage.dart';
import '../../Services/api_service.dart'; // Make sure this is your API service

class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    try {
      await _initializeFCM();
      await _checkLogin();
    } catch (e) {
      print("Error during splash initialization: $e");
    }
  }

  Future<void> _initializeFCM() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // Request permission for iOS
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    print('User granted permission: ${settings.authorizationStatus}');

    // Get device token
    String? token = await messaging.getToken();
    print('FCM Token: $token');

    // Save token to backend if user is logged in
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');

    if (userId != null && userId > 0 && token != null) {
      final result = await ApiService.saveFcmToken(userId: userId, fcmToken: token);
      if (result['success']) {
        print("FCM token saved successfully for user $userId");
      } else {
        print("Failed to save FCM token: ${result['error']}");
      }
    }
  }

  Future<void> _checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id') ?? 0;

    // Optional: splash delay
    await Future.delayed(Duration(seconds: 2));

    if (!mounted) return;

    if (userId > 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomePage()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
