import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; // Ditambahkan untuk komponen khas iOS
import 'dart:async';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _opacity = 0.0; // Mengatur awal animasi memudar (invisible)

  @override
  void initState() {
    super.initState();
    _startAnimation();
    _startSplashScreen();
  }

  // Animasi logo memudar masuk (Fade-in) khas iOS awal boot aplikasi
  _startAnimation() {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        setState(() {
          _opacity = 1.0; // Logo memudar penuh ke terlihat
        });
      }
    });
  }

  _startSplashScreen() async {
    var duration = const Duration(seconds: 3);
    return Timer(duration, () {
      if (mounted) {
        // Pindah ke MainNavigation secara otomatis
        Navigator.pushReplacementNamed(context, '/main');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Deteksi mode gelap sistem agar background adaptif dan nyaman di mata
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // Warna background adaptif khas ekosistem SummitGo
      backgroundColor: isDark ? const Color(0xFF1E3253) : const Color(0xFF2F4B7C),
      body: Stack(
        children: [
          // Konten Utama di Tengah Layar
          Center(
            child: AnimatedOpacity(
              opacity: _opacity,
              duration: const Duration(milliseconds: 1000), // Kecepatan transisi fade-in 1 detik
              curve: Curves.easeOut,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo Utama SummitGo
                  Image.asset(
                    'assets/images/logosummitgo.png',
                    width: 180, // Disesuaikan agar proporsinya pas dan elegan
                    errorBuilder: (context, error, stackTrace) => 
                      const Icon(Icons.terrain, size: 80, color: Colors.white),
                  ),
                  const SizedBox(height: 30),
                  
                  // Indikator Loading Bergaya iOS (Cupertino)
                  const CupertinoActivityIndicator(
                    color: Colors.white,
                    radius: 14, // Ukuran indikator yang pas & clean
                  ),
                ],
              ),
            ),
          ),
          
          // Teks Hak Cipta / Branding di Bagian Bawah Layar khas Aplikasi iOS Modern
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: AnimatedOpacity(
              opacity: _opacity,
              duration: const Duration(milliseconds: 1200),
              child: const Column(
                children: [
                  Text(
                    "SUMMITGO",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 3, // Jarak renggang antar huruf yang estetik
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Safe Climbing, Better Experience",
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}