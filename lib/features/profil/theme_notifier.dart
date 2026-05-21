// lib/theme_notifier.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeNotifier extends ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  ThemeNotifier() {
    _loadTheme();
  }

  // Mengubah tema dan menyimpannya secara permanen di SharedPreferences
  void toggleTheme(bool isDark) async {
    _isDarkMode = isDark;
    notifyListeners(); // Memberitahu seluruh aplikasi untuk mengganti warna tampilan

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDark);
  }

  // Mengambil status tema yang tersimpan saat aplikasi pertama kali dibuka
  void _loadTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    notifyListeners();
  }
}