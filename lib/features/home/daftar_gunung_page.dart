// lib/features/home/daftar_gunung_page.dart
import 'package:flutter/material.dart';
import '../ticket/pencarian_basecamp_page.dart';

class DaftarGunungPage extends StatefulWidget {
  const DaftarGunungPage({super.key});

  @override
  State<DaftarGunungPage> createState() => _DaftarGunungPageState();
}

class _DaftarGunungPageState extends State<DaftarGunungPage> {
  final List<Map<String, dynamic>> semuaGunung = const [
    {
      "nama": "Gunung Ciremai",
      "lokasi": "Jawa Barat",
      "image": "assets/images/puncak_ciremai.png",
      "deskripsi":
          "Gunung tertinggi di Jawa Barat dengan tantangan jalur pendakian yang eksotis.",
      "basecamps": [
        "Apuy",
        "Palutungan",
        "Linggajati",
        "Linggasana",
        "Sadarehe",
      ],
    },
    {
      "nama": "Gunung Prau",
      "lokasi": "Jawa Tengah",
      "image": "assets/images/gunung_prau.png",
      "deskripsi":
          "Terkenal dengan pemandangan golden sunrise terbaik di Asia Tenggara.",
      "basecamps": ["Patak Banteng", "Dieng", "Dwarf", "Kalilembu"],
    },
    {
      "nama": "Gunung Semeru",
      "lokasi": "Jawa Timur",
      "image": "assets/images/semeru.png",
      "deskripsi":
          "Gunung tertinggi di Pulau Jawa dengan keindahan Danau Ranu Kumbolo.",
      "basecamps": ["Ranu Pane"],
    },
    {
      "nama": "Gunung Merbabu",
      "lokasi": "Jawa Tengah",
      "image": "assets/images/merbabu.png",
      "deskripsi":
          "Gunung dengan hamparan sabana hijau yang sangat luas dan indah.",
      "basecamps": ["Selo", "Suwanting", "Wekas", "Thekelan"],
    },
    {
      "nama": "Gunung Sindoro",
      "lokasi": "Jawa Tengah",
      "image": "assets/images/sindoro.png",
      "deskripsi":
          "Memiliki padang edelweiss luas di dekat puncak dan kawah aktif.",
      "basecamps": ["Kledung", "Alang-Alang Sewu", "Bansari"],
    },
    {
      "nama": "Gunung Lawu",
      "lokasi": "Jawa Tengah",
      "image": "assets/images/lawu.png",
      "deskripsi":
          "Gunung sarat sejarah, terkenal dengan warung tertinggi Mbok Yem.",
      "basecamps": ["Cetho", "Cemoro Sewu", "Cemoro Kandang"],
    },
    {
      "nama": "Gunung Sumbing",
      "lokasi": "Jawa Tengah",
      "image": "assets/images/sumbing.png",
      "deskripsi":
          "Gunung tertinggi kedua di Jawa Tengah dengan jalur menantang.",
      "basecamps": ["Garung", "Mangli", "Bowongso"],
    },
  ];

  List<Map<String, dynamic>> gunungTerfilter = [];
  String queryPencarian = "";

  @override
  void initState() {
    super.initState();
    gunungTerfilter = semuaGunung;
  }

  void filterGunung(String query) {
    setState(() {
      queryPencarian = query;
      if (query.isEmpty) {
        gunungTerfilter = semuaGunung;
      } else {
        gunungTerfilter = semuaGunung
            .where(
              (gunung) => gunung['nama'].toString().toLowerCase().contains(
                query.toLowerCase(),
              ),
            )
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
        backgroundColor: const Color(
          0xFF1E3A8A,
        ), // Biru gelap solid sesuai gambar referensi
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: TextField(
              onChanged: filterGunung,
              decoration: InputDecoration(
                hintText: "Cari Gunung yang ingin kamu daki...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Theme.of(context).cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Daftar Gunung Menggunakan ListView
          Expanded(
            child: gunungTerfilter.isNotEmpty
                ? ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    itemCount: gunungTerfilter.length,
                    itemBuilder: (context, index) {
                      final gunung = gunungTerfilter[index];
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
                          margin: const EdgeInsets.only(
                            bottom: 15,
                          ), // AMAN: Menggunakan .only(bottom: 15)
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
                              // Gambar Gunung Banner Penuh
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(15),
                                ),
                                child: Image.asset(
                                  gunung['image'],
                                  width: double.infinity,
                                  height: 160,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                        height: 160,
                                        color: isDark
                                            ? Colors.grey[850]
                                            : Colors.grey[300],
                                        child: const Icon(
                                          Icons.image,
                                          color: Colors.grey,
                                          size: 40,
                                        ),
                                      ),
                                ),
                              ),

                              // Informasi Detail Gunung (Tanpa komponen Tarif Harga)
                              Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      gunung['nama'],
                                      style: TextStyle(
                                        fontWeight: FontWeight
                                            .w800, // AMAN: Menggunakan .w800 sebagai pengganti extrabold
                                        fontSize: 16,
                                        color: isDark
                                            ? Colors.white
                                            : const Color(0xFF1E3A8A),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      gunung['deskripsi'] ??
                                          "Destinasi jalur pendakian Indonesia resmi.",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isDark
                                            ? Colors.grey[400]
                                            : Colors.grey[600],
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
