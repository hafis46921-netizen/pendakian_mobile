import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart';

class AppCheckService {
  static Future<String?> getToken() async {
    try {
      final token = await FirebaseAppCheck.instance.getToken();
      if (token != null && token.isNotEmpty) return token;
    } catch (e) {
      debugPrint('AppCheck getToken error: $e');
    }
    return null;
  }

  static Future<Map<String, String>> headers() async {
    final token = await getToken();
    return {
      if (token != null && token.isNotEmpty) 'X-Firebase-AppCheck': token,
    };
  }
}
