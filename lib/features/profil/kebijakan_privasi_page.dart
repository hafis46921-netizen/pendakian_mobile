// lib/features/profile/kebijakan_privasi_page.dart
import 'package:flutter/material.dart';

class KebijakanPrivasiPage extends StatelessWidget {
  const KebijakanPrivasiPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Deteksi apakah sistem sedang menggunakan mode gelap
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // FIX: Menghapus warna kaku agar background mengikuti sistem tema aktif (Scaffold atau Canvas)
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          "Kebijakan Privasi", 
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        // FIX: Warna AppBar menyesuaikan mode malam menggunakan permukaan card gelap bawaan
        backgroundColor: isDark ? Theme.of(context).cardColor : const Color(0xFF2F4B7C),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            // FIX: Menggunakan cardColor dinamis agar otomatis menjadi abu-abu gelap saat dark mode
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
                "Kebijakan Privasi Pengguna", 
                style: TextStyle(
                  fontSize: 15, 
                  fontWeight: FontWeight.bold, 
                  // FIX: Judul adaptif, menggunakan biru terang di mode gelap agar kontras
                  color: isDark ? const Color(0xFF6A93D4) : const Color(0xFF2F4B7C),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Kami di SummitGo berkomitmen untuk melindungi seluruh informasi pribadi serta data privasi yang Anda berikan saat melakukan registrasi akun atau pendaftaran data diri pendaki.\n\n"
                "1. Pengumpulan Data: Kami mengumpulkan data nama, nomor identitas (KTP/SIM), serta nomor telepon untuk keperluan validasi manifest keselamatan di basecamp pendakian resmi.\n\n"
                "2. Penggunaan Data: Data Anda dilindungi dan hanya akan dibagikan kepada pihak pengelola pengawasan taman nasional atau kepolisian jika terjadi kondisi darurat (SAR) di gunung terkait.\n\n"
                "Kami tidak akan pernah menjual atau menyalahgunakan data pribadi Anda kepada pihak ketiga untuk kepentingan eksternal komersial.",
                style: TextStyle(
                  fontSize: 12, 
                  // FIX: Menghapus warna kaku black87 agar teks berubah putih soft/abu terang saat gelap
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