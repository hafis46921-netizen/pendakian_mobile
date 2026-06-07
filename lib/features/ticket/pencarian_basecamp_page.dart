import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'registrasi_tiket_page.dart';
import '../../api_config.dart';

class PencarianBasecampPage extends StatelessWidget {
  final Map<String, dynamic> gunung;

  const PencarianBasecampPage({super.key, required this.gunung});

  // Mengambil data Basecamp secara dinamis berdasarkan ID Gunung dari API Laravel
  Future<List<dynamic>> fetchBasecampsByGunung(int gunungId) async {
  try {
    final response = await http
        .get(
          Uri.parse(
            "${ApiConfig.baseUrl}/user/basecamps?gunung_id=$gunungId",
          ),
        )
        .timeout(const Duration(seconds: 5));

    if (response.statusCode == 200) {
      debugPrint("BASECAMP RESPONSE: ${response.body}");

      final decodedData = jsonDecode(response.body);

      return decodedData['data']['data'] ?? [];
    }
  } catch (e) {
    debugPrint("Koneksi API Basecamp Gagal: $e");
  }

  return [];
}

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    int gunungId = gunung['id'] ?? 0;
    String fotoGunung = gunung['foto_utama'] ?? "";

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Image dengan Tombol Back
            Stack(
              children: [
                SizedBox(
                  height: 220,
                  width: double.infinity,
                  child: fotoGunung.startsWith('assets/')
                      ? Image.asset(fotoGunung, fit: BoxFit.cover)
                      : Image.network(
                          "${ApiConfig.baseUrl}/storage/$fotoGunung",
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                color: isDark
                                    ? Colors.grey[850]
                                    : Colors.grey[300],
                                child: Icon(
                                  Icons.image,
                                  size: 50,
                                  color: isDark
                                      ? Colors.grey[600]
                                      : Colors.grey,
                                ),
                              ),
                        ),
                ),
                Container(height: 220, color: Colors.black.withOpacity(0.15)),
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
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          gunung['nama'] ?? "Gunung",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? const Color(0xFF6A93D4)
                                : const Color(0xFF2F4B7C),
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
                          gunung['deskripsi'] ??
                              "Belum ada deskripsi untuk gunung ini.",
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                            height: 1.5,
                          ),
                        ),
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

                  // List Pilihan Basecamp Menggunakan FutureBuilder Dari Server
                  FutureBuilder<List<dynamic>>(
                    future: fetchBasecampsByGunung(gunungId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 30.0),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      List<dynamic> jalurBasecamp = snapshot.data ?? [];
                      debugPrint("DATA BASECAMP: $jalurBasecamp");

                      if (jalurBasecamp.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Center(
                            child: Text(
                              "Belum ada jalur basecamp resmi tersedia.",
                            ),
                          ),
                        );
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: jalurBasecamp.length,
                        itemBuilder: (context, index) {
                          final basecamp = jalurBasecamp[index];

                          // Konversi harga tiket ke representasi teks IDR
                          final harga =
    double.tryParse(basecamp['harga_tiket'].toString())?.toInt() ?? 0;

String formattedHarga = harga > 0
    ? "Rp ${harga.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]}.',
      )}"
    : "Rp 25.000";
                          return _buildBasecampCard(
                            context: context,
                            isDark: isDark,
                            basecampId: basecamp['id'] ?? 0,
                            namaBasecamp:
                                "Basecamp ${basecamp['nama'] ?? 'Unknown'}",
                            weekday: formattedHarga,
                            weekend:
                                formattedHarga, // Mengikuti data tunggal 'harga_tiket' dari skema kamu
                            imagePath: basecamp['foto_utama'] ?? fotoGunung,
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasecampCard({
    required BuildContext context,
    required bool isDark,
    required int basecampId,
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
                "basecamp_id": basecampId,
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
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              child: SizedBox(
                height: 130,
                width: double.infinity,
                child: imagePath.startsWith('assets/')
                    ? Image.asset(imagePath, fit: BoxFit.cover)
                    : Image.network(
                        "${ApiConfig.baseUrl}/storage/$imagePath",
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: isDark ? Colors.grey[850] : Colors.grey[300],
                          child: const Icon(
                            Icons.image,
                            size: 40,
                            color: Colors.grey,
                          ),
                        ),
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
                      color: isDark
                          ? const Color(0xFF6A93D4)
                          : const Color(0xFF2F4B7C),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Tarif Weekday",
                            style: TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            weekday,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Tarif Weekend",
                            style: TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            weekend,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
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
