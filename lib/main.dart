import 'dart:async';

import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'core/routes.dart';
import 'features/profil/theme_notifier.dart';
import 'features/tracking/tracking_service.dart';
import 'firebase_options.dart';

final ThemeNotifier themeNotifier = ThemeNotifier(); // Inisialisasi ThemeNotifier global

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }

    await FirebaseAppCheck.instance.activate(
      providerAndroid: kDebugMode
          ? const AndroidDebugProvider()
          : const AndroidPlayIntegrityProvider(),
      providerApple: kDebugMode
          ? const AppleDebugProvider()
          : const AppleAppAttestProvider(),
    );
  } on FirebaseException catch (e) {
    if (e.code != 'already-initialized') {
      debugPrint('Firebase/AppCheck init failed: $e');
    }
  } catch (e, st) {
    debugPrint('Firebase/AppCheck init failed: $e');
    debugPrint('$st');
  }

  await TrackingService.instance.initialize();
  runApp(const MyApp());

  // Lanjutkan sesi tracking yang masih aktif tanpa menampilkan dialog izin.
  unawaited(TrackingService.instance.resumeIfActive());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // WAJIB: Dibungkus dengan AnimatedBuilder agar MaterialApp mendengarkan perubahan tema
    return AnimatedBuilder(
      animation: themeNotifier,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'SummitGo',

          // Pengaturan Tema Terang (Light)
          theme: ThemeData(
            brightness: Brightness.light,
            scaffoldBackgroundColor: const Color(0xFFF4F7FA),
            primaryColor: const Color(0xFF2F4B7C),
            // Mengatur warna teks & icon di AppBar agar default cerah
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF2F4B7C),
              foregroundColor: Colors.white,
            ),
          ),
          
          // Pengaturan Tema Gelap (Dark)
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF121212),
            primaryColor: const Color(0xFF1F1F1F),
            // Menyesuaikan AppBar di mode gelap
            appBarTheme: Colors.grey[900] != null 
                ? AppBarTheme(backgroundColor: Colors.grey[900], foregroundColor: Colors.white)
                : const AppBarTheme(foregroundColor: Colors.white),
          ),

          // Menggunakan ThemeNotifier untuk mengatur tema secara dinamis
          themeMode: themeNotifier.isDarkMode ? ThemeMode.dark : ThemeMode.light,

          initialRoute: '/',
          routes: AppRoutes.routes,
        );
      },
    );
  }
}