// lib/features/profile/tentang_aplikasi_page.dart
import 'package:flutter/material.dart';

class TentangAplikasiPage extends StatelessWidget {
  const TentangAplikasiPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Deteksi status mode gelap dari sistem
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // FIX: Menghapus warna kaku agar mengikuti background canvas tema aktif global
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          "Tentang Aplikasi", 
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        // FIX: Warna AppBar menyesuaikan mode malam (menggunakan warna surface gelap bawaan)
        backgroundColor: isDark ? Theme.of(context).cardColor : const Color(0xFF2F4B7C),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(25),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Logo Aplikasi SummitGo
              Image.asset(
                'assets/images/logosummitgo.png', 
                height: 90, 
                // FIX: Menyesuaikan warna icon cadangan jika file logo gagal dimuat di mode gelap
                errorBuilder: (c, e, s) => Icon(
                  Icons.terrain_rounded, 
                  size: 80, 
                  color: isDark ? const Color(0xFF6A93D4) : const Color(0xFF2F4B7C),
                ),
              ),
              const SizedBox(height: 15),
              Text(
                "SummitGo App", 
                style: TextStyle(
                  fontSize: 22, 
                  fontWeight: FontWeight.bold, 
                  // FIX: Judul teks menggunakan warna biru soft saat dark mode agar kontras
                  color: isDark ? const Color(0xFF6A93D4) : const Color(0xFF2F4B7C),
                ),
              ),
              // FIX: Menggunakan warna grey bawaan mode agar teks versi tetap proporsional
              Text(
                "Versi 1.0.0 (Production)", 
                style: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 25),
              Text(
                "SummitGo adalah aplikasi platform booking online tiket pendakian gunung yang mempermudah para pendaki untuk melakukan registrasi basecamp, pengelolaan izin administrasi, dan sistem pembayaran digital secara aman dan efisien.",
                textAlign: TextAlign.center,
                // FIX: Mengubah warna hitam kaku menjadi abu terang/putih lembut di dark mode
                style: TextStyle(
                  fontSize: 13, 
                  color: isDark ? Colors.grey[300] : Colors.black87, 
                  height: 1.6,
                ),
              ),
              const Spacer(),
              Text(
                "© 2026 SummitGo Indonesia. All Rights Reserved.", 
                style: TextStyle(color: isDark ? Colors.grey[600] : Colors.grey, fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }
}