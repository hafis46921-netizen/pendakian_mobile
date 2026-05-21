// lib/features/profile/riwayat_pendakian_page.dart
import 'package:flutter/material.dart';

class RiwayatPendakianPage extends StatelessWidget {
  const RiwayatPendakianPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Data dummy riwayat transaksi tiket pendakian
    final List<Map<String, dynamic>> listRiwayat = [
      {"gunung": "Gunung Ciremai", "jalur": "Sadarehe", "tanggal": "11-11-2025", "status": "Selesai", "warna": Colors.green},
      {"gunung": "Gunung Prau", "jalur": "Patakbanteng", "tanggal": "24-01-2026", "status": "Selesai", "warna": Colors.green},
      {"gunung": "Gunung Gede", "jalur": "Cibodas", "tanggal": "18-05-2026", "status": "Pending", "warna": Colors.orange},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      appBar: AppBar(
        title: const Text("Riwayat Pendakian", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF2F4B7C),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(15),
        itemCount: listRiwayat.length,
        itemBuilder: (context, index) {
          final item = listRiwayat[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            elevation: 0,
            child: ListTile(
              contentPadding: const EdgeInsets.all(15),
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: const Color(0xFFE8F0FE), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.terrain, color: Color(0xFF2F4B7C)),
              ),
              title: Text(item['gunung'], style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2F4B7C))),
              subtitle: Text("Jalur: ${item['jalur']}\nTanggal: ${item['tanggal']}", style: const TextStyle(fontSize: 12, height: 1.4)),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: item['warna'].withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                child: Text(item['status'], style: TextStyle(color: item['warna'], fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ),
          );
        },
      ),
    );
  }
}