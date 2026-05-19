import 'package:flutter/material.dart';
import 'package:pendakian/features/home/main_navigator.dart';
//import '../features/home/home_page.dart';
import '../features/auth/login_page.dart';
import '../features/auth/register_page.dart';
import '../features/ticket/pesan_tiket_page.dart';
import '../features/auth/splash_screen.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> routes = {
    '/': (context) => const SplashScreen(),
    '/main': (context) => MainNavigation(),
    '/login': (context) => LoginPage(),
    '/register': (context) => RegisterPage(),
    '/ticket': (context) => PesanTiketPage(),
  };
}