// lib/features/profile/kebijakan_privasi_page.dart
import 'package:flutter/material.dart';

class KebijakanPrivasiPage extends StatelessWidget {
  const KebijakanPrivasiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      appBar: AppBar(
        title: const Text("Kebijakan Privasi", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
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
              Text("Kebijakan Privasi Pengguna", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF2F4B7C))),
              SizedBox(height: 10),
              Text(
                "Kami di SummitGo berkomitmen untuk melindungi seluruh informasi pribadi serta data privasi yang Anda berikan saat melakukan registrasi akun atau pendaftaran data diri pendaki.\n\n"
                "1. Pengumpulan Data: Kami mengumpulkan data nama, nomor identitas (KTP/SIM), serta nomor telepon untuk keperluan validasi manifest keselamatan di basecamp pendakian resmi.\n\n"
                "2. Penggunaan Data: Data Anda dilindungi dan hanya akan dibagikan kepada pihak pengelola pengawasan taman nasional atau kepolisian jika terjadi kondisi darurat (SAR) di gunung terkait.\n\n"
                "Kami tidak akan pernah menjual atau menyalahgunakan data pribadi Anda kepada pihak ketiga untuk kepentingan eksternal komersial.",
                style: TextStyle(fontSize: 12, color: Colors.black87, height: 1.6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}