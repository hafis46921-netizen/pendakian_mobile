import 'package:flutter/material.dart';
import 'registrasi_tiket_page.dart'; 

class PencarianBasecampPage extends StatelessWidget {
  final Map<String, dynamic> gunung;

  const PencarianBasecampPage({super.key, required this.gunung});

  @override
  Widget build(BuildContext context) {
    // Deteksi status mode gelap sistem global
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Ambil list basecamp dari variabel data gunung secara aman
    final List jalurBasecamp = gunung['basecamps'] ?? [];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                    color: isDark ? Colors.grey[850] : Colors.grey[300],
                    child: Icon(Icons.image, size: 50, color: isDark ? Colors.grey[600] : Colors.grey),
                  ),
                ),
                // Efek overlay tipis agar tombol kembali bulat selalu terlihat kontras
                Container(
                  height: 220,
                  color: Colors.black.withOpacity(0.15),
                ),
                Positioned(
                  top: 40,
                  left: 15,
                  child: CircleAvatar(
                    backgroundColor: Colors.black.withOpacity(0.4),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Card Deskripsi Gunung
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          gunung['nama'],
                          style: TextStyle(
                            fontSize: 18, 
                            fontWeight: FontWeight.bold, 
                            color: isDark ? const Color(0xFF6A93D4) : const Color(0xFF2F4B7C),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Deskripsi",
                          style: TextStyle(
                            fontSize: 12, 
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.grey[300] : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          gunung['deskripsi'] ?? "Lorem ipsum is simply dummy text of the printing and typesetting industry...",
                          style: TextStyle(
                            fontSize: 11, 
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        GestureDetector(
                          onTap: () {
                            // Aksi ketika klik "Baca Selengkapnya"
                          },
                          child: Text(
                            "Baca Selengkapnya",
                            style: TextStyle(
                              fontSize: 11, 
                              color: isDark ? Colors.blue[300] : Colors.blue[700], 
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Label Judul List Basecamp
                  const Text(
                    "Pilih Jalur Basecamp Resmi",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

                  // PERBAIKAN: List Pilihan Basecamp Otomatis Sesuai Gunung yang Dipilih
                  // PERBAIKAN: List Pilihan Basecamp Otomatis Sesuai Gunung yang Dipilih
                  jalurBasecamp.isNotEmpty
                      ? ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: jalurBasecamp.length,
                          itemBuilder: (context, index) {
                            // Ambil item basecamp saat ini (berupa Map)
                            final basecamp = jalurBasecamp[index]; 

                            return _buildBasecampCard(
                              context: context,
                              isDark: isDark,
                              // UBAH: Ambil field 'id' dan 'nama' dari objek basecamp
                              basecampId: basecamp['id'] ?? 1, 
                              namaBasecamp: "Basecamp ${basecamp['nama'] ?? 'Unknown'}",
                              weekday: gunung['tarif_weekday'] ?? "Rp 25.000",
                              weekend: gunung['tarif_weekend'] ?? "Rp 30.000",
                              imagePath: gunung['image'],
                            );
                          },
                        )
                      : const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Center(child: Text("Belum ada jalur basecamp resmi tersedia.")),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

// Widget Helper List Card Basecamp (Ditambahkan parameter basecampId)
  Widget _buildBasecampCard({
    required BuildContext context, 
    required bool isDark, 
    required int basecampId, // <-- Tambahkan baris ini
    required String namaBasecamp,
    required String weekday,
    required String weekend,
    required String imagePath,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RegistrasiTiketPage(
              gunungData: {
                "basecamp_id": basecampId, // <-- Oper ID ini agar mengalir sampai ke proses submit data diri!
                "nama": namaBasecamp, 
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
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
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
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 130,
                  color: isDark ? Colors.grey[850] : Colors.grey[300],
                  child: const Icon(Icons.image, size: 40, color: Colors.grey),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    namaBasecamp,
                    style: TextStyle(
                      fontSize: 15, 
                      fontWeight: FontWeight.bold, 
                      color: isDark ? const Color(0xFF6A93D4) : const Color(0xFF2F4B7C),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Tarif Weekday", style: TextStyle(fontSize: 11, color: Colors.grey)),
                          const SizedBox(height: 2),
                          Text(
                            weekday, 
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: isDark ? Colors.white : Colors.black87),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Tarif Weekend", style: TextStyle(fontSize: 11, color: Colors.grey)),
                          const SizedBox(height: 2),
                          Text(
                            weekend, 
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: isDark ? Colors.white : Colors.black87),
                          ),
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