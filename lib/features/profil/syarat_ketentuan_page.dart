// lib/features/profile/syarat_ketentuan_page.dart
import 'package:flutter/material.dart';

class SyaratKetentuanPage extends StatelessWidget {
  const SyaratKetentuanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      appBar: AppBar(
        title: const Text("Syarat & Ketentuan", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF2F4B7C),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Syarat & Ketentuan Penggunaan", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF2F4B7C))),
              SizedBox(height: 10),
              Text(
                "Dengan menggunakan platform layanan pemesanan tiket online di aplikasi SummitGo, Anda dianggap menyetujui seluruh aturan hukum di bawah ini:\n\n"
                "1. Pengguna wajib memberikan data yang valid, akurat, dan dapat dipertanggungjawabkan saat melakukan booking tiket.\n\n"
                "2. Pembatalan atau refund tiket diatur sepenuhnya oleh kebijakan dari masing-masing pihak basecamp pengelola gunung dan bukan tanggung jawab absolut dari aplikasi.\n\n"
                "3. Pendaki wajib mematuhi jam operasional naik/turun serta dilarang keras membawa barang terlarang demi keamanan bersama.",
                style: TextStyle(fontSize: 12, color: Colors.black87, height: 1.6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}