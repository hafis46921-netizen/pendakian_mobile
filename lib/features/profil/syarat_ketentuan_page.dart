// lib/features/profile/syarat_ketentuan_page.dart
import 'package:flutter/material.dart';

class SyaratKetentuanPage extends StatelessWidget {
  const SyaratKetentuanPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Deteksi status mode gelap dari sistem
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // FIX: Mengikuti background tema global (Scaffold/Canvas) agar tidak kaku
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          "Syarat & Ketentuan", 
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        // FIX: AppBar otomatis menggunakan warna permukaan gelap saat dark mode aktif
        backgroundColor: isDark ? Theme.of(context).cardColor : const Color(0xFF2F4B7C),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            // FIX: Menggunakan cardColor agar kotak putih otomatis berubah menjadi abu-abu gelap
            color: Theme.of(context).cardColor, 
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Syarat & Ketentuan Penggunaan", 
                style: TextStyle(
                  fontSize: 15, 
                  fontWeight: FontWeight.bold, 
                  // FIX: Warna judul menjadi biru soft saat malam hari agar kontrasnya pas
                  color: isDark ? const Color(0xFF6A93D4) : const Color(0xFF2F4B7C),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Dengan menggunakan platform layanan pemesanan tiket online di aplikasi SummitGo, Anda dianggap menyetujui seluruh aturan hukum di bawah ini:\n\n"
                "1. Pengguna wajib memberikan data yang valid, akurat, dan dapat dipertanggungjawabkan saat melakukan booking tiket.\n\n"
                "2. Pembatalan atau refund tiket diatur sepenuhnya oleh kebijakan dari masing-masing pihak basecamp pengelola gunung dan bukan tanggung jawab absolut dari aplikasi.\n\n"
                "3. Pendaki wajib mematuhi jam operasional naik/turun serta dilarang keras membawa barang terlarang demi keamanan bersama.",
                style: TextStyle(
                  fontSize: 12, 
                  // FIX: Teks otomatis berganti menjadi abu-abu terang/putih lembut di dark mode
                  color: isDark ? Colors.grey[300] : Colors.black87, 
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}