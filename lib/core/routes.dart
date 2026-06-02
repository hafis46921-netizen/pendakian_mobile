import 'package:flutter/material.dart';
import 'package:pendakian/features/home/main_navigator.dart';
//import '../features/home/home_page.dart';
import '../features/auth/login_page.dart';
import '../features/auth/register_page.dart';
import '../features/home/daftar_gunung_page.dart';
import '../features/auth/splash_screen.dart';
import '../features/ticket/invoice_pembayaran_page.dart';
import '../features/home/history_page.dart';
import '../features/auth/forgot_password_page.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> routes = {
    '/': (context) => const SplashScreen(),
    '/main': (context) => MainNavigation(),
    '/login': (context) => LoginPage(),
    '/register': (context) => RegisterPage(),
    '/ticket': (context) => DaftarGunungPage(),
    '/invoice_pembayaran': (context) => const InvoicePembayaranPage(),
    '/history': (context) => const HistoryPage(),
    '/forgot_password': (context) => const ForgotPasswordPage(),
  };
}