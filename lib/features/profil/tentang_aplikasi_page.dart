// lib/features/profile/tentang_aplikasi_page.dart
import 'package:flutter/material.dart';

class TentangAplikasiPage extends StatelessWidget {
  const TentangAplikasiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      appBar: AppBar(
        title: const Text("Tentang Aplikasi", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF2F4B7C),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(25),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo Aplikasi SummitGo (Sesuai aset gambar di image_352212.png)
              Image.asset('assets/images/logosummitgo.png', height: 90, errorBuilder: (c, e, s) => const Icon(Icons.terrain_rounded, size: 80, color: Color(0xFF2F4B7C))),
              const SizedBox(height: 15),
              const Text("SummitGo App", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF2F4B7C))),
              const Text("Versi 1.0.0 (Production)", style: TextStyle(color: Colors.grey, fontSize: 13)),
              const SizedBox(height: 25),
              const Text(
                "SummitGo adalah aplikasi platform booking online tiket pendakian gunung yang mempermudah para pendaki untuk melakukan registrasi basecamp, pengelolaan izin administrasi, dan sistem pembayaran digital secara aman dan efisien.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.black87, height: 1.6),
              ),
              const Spacer(),
              const Text("© 2026 SummitGo Indonesia. All Rights Reserved.", style: TextStyle(color: Colors.grey, fontSize: 11)),
            ],
          ),
        ),
      ),
    );
  }
}