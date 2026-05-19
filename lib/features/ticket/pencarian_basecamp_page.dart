import 'package:flutter/material.dart';
import 'registrasi_tiket_page.dart'; // Pastikan import ini sudah benar

class PencarianBasecampPage extends StatelessWidget {
  final Map<String, dynamic> gunung;

  const PencarianBasecampPage({super.key, required this.gunung});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Image dengan Tombol Back (Stack)
            Stack(
              children: [
                Image.asset(
                  gunung['image'],
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 220,
                    color: Colors.grey[300],
                    child: const Icon(Icons.image, size: 50, color: Colors.grey),
                  ),
                ),
                Positioned(
                  top: 40,
                  left: 15,
                  child: CircleAvatar(
                    backgroundColor: Colors.black.withOpacity(0.3),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                children: [
                  // Card Deskripsi Gunung
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          gunung['nama'],
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2F4B7C)),
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          "Deskripsi",
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          "Lorem ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s...",
                          style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                        ),
                        GestureDetector(
                          onTap: () {
                            // Aksi ketika klik "Baca Selengkapnya"
                          },
                          child: const Text(
                            "Baca Selengkapnya",
                            style: TextStyle(fontSize: 11, color: Colors.blue, decoration: TextDecoration.underline),
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),

                  // List Pilihan Basecamp untuk Gunung ini
                  // Di sini kita menambahkan argumen 'context' ke dalam fungsi helper
                  _buildBasecampCard(
                    context: context, // <-- DI TARUH DI SINI
                    namaBasecamp: "Basecamp Patak Banteng",
                    weekday: gunung['weekday'] ?? "Rp 25.000",
                    weekend: gunung['weekend'] ?? "Rp 30.000",
                    imagePath: gunung['image'],
                  ),
                  _buildBasecampCard(
                    context: context, // <-- DI TARUH DI SINI
                    namaBasecamp: "Basecamp Dieng",
                    weekday: gunung['weekday'] ?? "Rp 25.000",
                    weekend: gunung['weekend'] ?? "Rp 30.000",
                    imagePath: gunung['image'],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget Helper yang sudah ditambahkan parameter BuildContext dan GestureDetector
  Widget _buildBasecampCard({
    required BuildContext context, // <-- Ditambahkan parameter ini agar bisa Navigasi
    required String namaBasecamp,
    required String weekday,
    required String weekend,
    required String imagePath,
  }) {
    return GestureDetector(
      onTap: () {
        // DI TARUH DI SINI: Aksi navigasi perpindahan halaman ke RegistrasiTiketPage
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RegistrasiTiketPage(
              gunungData: {
                "nama": namaBasecamp, // Mengirim nama basecamp yang dipilih
                "tarif_weekday": weekday,
                "tarif_weekend": weekend,
                "image": imagePath,
              },
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: Image.asset(
                imagePath,
                height: 130,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    namaBasecamp,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF2F4B7C)),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Tarif Weekday", style: TextStyle(fontSize: 11, color: Colors.grey)),
                          Text(weekday, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Tarif Weekend", style: TextStyle(fontSize: 11, color: Colors.grey)),
                          Text(weekend, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}