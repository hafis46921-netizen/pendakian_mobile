import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../ticket/pencarian_basecamp_page.dart';
import '../../api_config.dart';

class DaftarGunungPage extends StatefulWidget {
  const DaftarGunungPage({super.key});

  @override
  State<DaftarGunungPage> createState() => _DaftarGunungPageState();
}

class _DaftarGunungPageState extends State<DaftarGunungPage> {
  // Data Gunung Lokal (Fallback jika API Gagal / Kosong)
  final List<Map<String, dynamic>> semuaGunungLokal = const [
    {
      "id": 1,
      "nama": "Gunung Ciremai",
      "lokasi": "Jawa Barat",
      "foto_utama": "assets/images/puncak_ciremai.jpg",
      "deskripsi": "Gunung tertinggi di Jawa Barat dengan tantangan jalur pendakian yang eksotis.",
    },
    {
      "id": 2,
      "nama": "Gunung Prau",
      "lokasi": "Jawa Tengah",
      "foto_utama": "assets/images/gunung_prau.jpg",
      "deskripsi": "Terkenal dengan pemandangan golden sunrise terbaik di Asia Tenggara.",
    },
  ];

  List<dynamic> semuaGunungApi = [];
  List<dynamic> gunungTerfilter = [];
  List<dynamic> rekomendasiSaran = []; // Menyimpan list rekomendasi saat mengetik
  final TextEditingController _searchController = TextEditingController();
  String queryPencarian = "";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDaftarGunung();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> fetchDaftarGunung() async {
    try {
      final response = await http
          .get(Uri.parse("${ApiConfig.baseUrl}/gunungs"))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);
        List<dynamic> dataHasil = [];

        if (decodedData is Map && decodedData.containsKey('data')) {
          dataHasil = decodedData['data'];
        } else if (decodedData is List) {
          dataHasil = decodedData;
        }

        setState(() {
          semuaGunungApi = dataHasil;
          gunungTerfilter = dataHasil.isNotEmpty ? dataHasil : semuaGunungLokal;
          isLoading = false;
        });
        return;
      }
    } catch (e) {
      debugPrint("Koneksi API Daftar Gunung Gagal: $e");
    }

    setState(() {
      gunungTerfilter = semuaGunungLokal;
      isLoading = false;
    });
  }

  void filterGunung(String query) {
    setState(() {
      queryPencarian = query;
      List<dynamic> basisData = semuaGunungApi.isNotEmpty ? semuaGunungApi : semuaGunungLokal;
      
      if (query.isEmpty) {
        gunungTerfilter = basisData;
        rekomendasiSaran = []; // Kosongkan jika kolom pencarian kosong
      } else {
        // Filter untuk list utama
        gunungTerfilter = basisData
            .where((gunung) => gunung['nama'].toString().toLowerCase().contains(query.toLowerCase()))
            .toList();

        // Ambil maksimal 3-4 gunung sebagai "Rekomendasi Cepat" di bawah search bar
        rekomendasiSaran = basisData
            .where((gunung) => gunung['nama'].toString().toLowerCase().contains(query.toLowerCase()))
            .take(3)
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? Theme.of(context).scaffoldBackgroundColor
          : const Color(0xFFF4F6F9),
      appBar: AppBar(
        title: const Text(
          "Daftar Gunung",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF1E3A8A), 
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.only(top: 15.0, left: 15.0, right: 15.0, bottom: 5.0),
            child: TextField(
              controller: _searchController,
              onChanged: filterGunung,
              decoration: InputDecoration(
                hintText: "Cari Gunung yang ingin kamu daki...",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: queryPencarian.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          filterGunung("");
                        },
                      )
                    : null,
                filled: true,
                fillColor: Theme.of(context).cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // FITUR BARU: Panel Rekomendasi Instan / Suggestion Box
          if (rekomendasiSaran.isNotEmpty)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(15),
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
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, bottom: 5),
                    child: Row(
                      children: [
                        Icon(Icons.auto_awesome, size: 14, color: Colors.amber[700]),
                        const SizedBox(width: 5),
                        Text(
                          "Rekomendasi untukmu:",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.grey[400] : Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  // List saran text yang bisa diklik langsung masuk halaman detail/basecamp
                  ...rekomendasiSaran.map((gunungSaran) {
                    return ListTile(
                      dense: true,
                      leading: const Icon(Icons.location_on_outlined, size: 18, color: Colors.blue),
                      title: Text(
                        gunungSaran['nama'] ?? "",
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey),
                      onTap: () {
                        // Hilangkan rekomendasi & set text pencarian sesuai yang dipilih
                        setState(() {
                          _searchController.text = gunungSaran['nama'];
                          filterGunung(gunungSaran['nama']);
                          rekomendasiSaran = []; 
                        });
                        
                        // Opsional: Langsung arahkan ke halaman pilih basecamp gunung tersebut
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PencarianBasecampPage(gunung: gunungSaran),
                          ),
                        );
                      },
                    );
                  }),
                ],
              ),
            ),

          const SizedBox(height: 5),

          // Daftar Utama Gunung
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : gunungTerfilter.isNotEmpty
                    ? ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        itemCount: gunungTerfilter.length,
                        itemBuilder: (context, index) {
                          final gunung = gunungTerfilter[index];
                          String pathGambar = gunung['foto_utama'] ?? "";

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      PencarianBasecampPage(gunung: gunung),
                                ),
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 15),
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Gambar Banner Gunung
                                  ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(15),
                                    ),
                                    child: SizedBox(
                                      width: double.infinity,
                                      height: 160,
                                      child: pathGambar.startsWith('assets/')
                                          ? Image.asset(pathGambar, fit: BoxFit.cover)
                                          : Image.network(
                                              "${ApiConfig.baseUrl}/storage/$pathGambar",
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) =>
                                                  Container(
                                                color: isDark ? Colors.grey[850] : Colors.grey[300],
                                                child: const Icon(Icons.image, color: Colors.grey, size: 40),
                                              ),
                                            ),
                                    ),
                                  ),

                                  // Informasi Detail Gunung
                                  Padding(
                                    padding: const EdgeInsets.all(15.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          gunung['nama'] ?? "Gunung",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 16,
                                            color: isDark ? Colors.white : const Color(0xFF1E3A8A),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          gunung['deskripsi'] ?? "Destinasi jalur pendakian Indonesia resmi.",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      )
                    : const Center(
                        child: Text(
                          "Gunung tidak ditemukan.",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}