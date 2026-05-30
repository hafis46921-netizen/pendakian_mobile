// lib/features/profile/riwayat_pendakian_page.dart
import 'package:flutter/material.dart';

class RiwayatPendakianPage extends StatelessWidget {
  const RiwayatPendakianPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Deteksi apakah sedang dalam mode gelap
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Data dummy riwayat transaksi tiket pendakian
    final List<Map<String, dynamic>> listRiwayat = [
      {
        "gunung": "Gunung Ciremai",
        "jalur": "Sadarehe",
        "tanggal": "11-11-2025",
        "status": "Selesai",
        "warna": Colors.green,
      },
      {
        "gunung": "Gunung Prau",
        "jalur": "Patakbanteng",
        "tanggal": "24-01-2026",
        "status": "Selesai",
        "warna": Colors.green,
      },
      {
        "gunung": "Gunung Gede",
        "jalur": "Cibodas",
        "tanggal": "18-05-2026",
        "status": "Pending",
        "warna": Colors.orange,
      },
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          "Riwayat Pendakian",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        // Menyesuaikan warna AppBar saat mode gelap agar tidak terlalu kontras berganti warna
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : const Color(0xFF2F4B7C),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(15),
        itemCount: listRiwayat.length,
        itemBuilder: (context, index) {
          final item = listRiwayat[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            color: Theme.of(context).cardColor, // Memastikan card mengikuti tema global
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            elevation: 0,
            child: ListTile(
              contentPadding: const EdgeInsets.all(15),
              // 1. PERBAIKAN: Latar belakang icon terrain disesuaikan agar tidak terlalu terang di mode gelap
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[800] : const Color(0xFFE8F0FE),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.terrain, 
                  color: isDark ? Colors.white70 : const Color(0xFF2F4B7C),
                ),
              ),
              // 2. PERBAIKAN: Mengunci warna teks judul agar kontras di kedua mode
              title: Text(
                item['gunung'],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF2F4B7C),
                ),
              ),
              // 3. PERBAIKAN: Memberikan warna abu-abu dinamis untuk teks subtitle
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  "Jalur: ${item['jalur']}\nTanggal: ${item['tanggal']}",
                  style: TextStyle(
                    fontSize: 12, 
                    height: 1.4,
                    color: isDark ? Colors.grey[400] : Colors.grey[700],
                  ),
                ),
              ),
              trailing: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: item['warna'].withOpacity(isDark ? 0.25 : 0.15), // Sedikit lebih tebal opasitasnya di dark mode
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  item['status'],
                  style: TextStyle(
                    color: item['warna'],
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}