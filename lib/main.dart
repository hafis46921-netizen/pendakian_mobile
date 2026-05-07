import 'package:flutter/material.dart';
import 'core/routes.dart';
//import 'features/home/main_navigator.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SummitGo',
      initialRoute: '/',
      routes: AppRoutes.routes,
    );
  }
}