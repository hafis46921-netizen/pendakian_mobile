// lib/features/profile/kebijakan_privasi_page.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class KebijakanPrivasiPage extends StatelessWidget {
  const KebijakanPrivasiPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Deteksi apakah sistem sedang menggunakan mode gelap
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Setup palet warna ala iOS (Apple Design Guidelines)
    final backgroundColor = isDark ? const Color(0xFF000000) : const Color(0xFFF2F2F7);
    final cardColor = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final dividerColor = isDark ? const Color(0xFF38383A) : const Color(0xFFE5E5EA);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: cardColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Kebijakan Privasi",
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontSize: 17,
            fontWeight: FontWeight.w600, // Font weight standar iOS
          ),
        ),
        // Tombol kembali bergaya asli iOS Navigation Bar
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.chevron_back, size: 24, color: Color(0xFF2F4B7C)),
          onPressed: () => Navigator.pop(context),
        ),
        // Divider tipis 0.5 pixel di bawah AppBar khas iPhone
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(color: dividerColor, height: 0.5),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            // Header kategori ala iOS Settings
            _buildSectionHeader("KEBIJAKAN PRIVASI PENGGUNA"),
            
            // Konten utama dibungkus Grouped Card plat iOS
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12), // Mengikuti standard rounded corner iOS 14+
              ),
              child: Text(
                "Kami di SummitGo berkomitmen untuk melindungi seluruh informasi pribadi serta data privasi yang Anda berikan saat melakukan registrasi akun atau pendaftaran data diri pendaki.\n\n"
                "1. Pengumpulan Data: Kami mengumpulkan data nama, nomor identitas (KTP/SIM), serta nomor telepon untuk keperluan validasi manifest keselamatan di basecamp pendakian resmi.\n\n"
                "2. Penggunaan Data: Data Anda dilindungi dan hanya akan dibagikan kepada pihak pengelola pengawasan taman nasional atau kepolisian jika terjadi kondisi darurat (SAR) di gunung terkait.\n\n"
                "Kami tidak akan pernah menjual atau menyalahgunakan data pribadi Anda kepada pihak ketiga untuk kepentingan eksternal komersial.",
                style: TextStyle(
                  fontSize: 14, // Ditingkatkan ke 14 agar lebih nyaman dibaca (iOS default body)
                  color: isDark ? Colors.grey[300] : const Color(0xFF3A3A3C), 
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // Helper widget untuk membuat teks label section kecil di atas card ala iOS
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 32, bottom: 8, top: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12, 
          fontWeight: FontWeight.w400, 
          color: Colors.grey[500], 
          letterSpacing: 0.4
        ),
      ),
    );
  }
}