import 'package:flutter/material.dart';
import '../features/home/home_page.dart';
import '../features/auth/login_page.dart';
import '../features/auth/register_page.dart';
import '../features/ticket/ticket_page.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> routes = {
    '/': (context) => HomePage(),
    '/login': (context) => LoginPage(),
    '/register': (context) => RegisterPage(),
    '/ticket': (context) => TicketPage(),
  };
}