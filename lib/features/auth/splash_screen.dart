import 'package:flutter/material.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _startSplashScreen();
  }

  _startSplashScreen() async {
    // Durasi loading (misal: 3 detik)
    var duration = const Duration(seconds: 3);
    return Timer(duration, () {
      // Pindah ke MainNavigation secara otomatis
      Navigator.pushReplacementNamed(context, '/main');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2F4B7C), // Warna biru SummitGo
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo Utama
            Image.asset(
              'assets/images/logosummitgo.png',
              width: 200,
            ),
            const SizedBox(height: 20),
            // Indikator Loading
            const CircularProgressIndicator(
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}