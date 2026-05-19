import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../ticket/pesan_tiket_page.dart'; // Sesuaikan file halaman tiket kamu

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Data dummy list gunung lokal sebagai fallback jika API bermasalah
  final List<Map<String, String>> gunungLokal = [
    {"nama": "Gunung Ciremai", "lokasi": "Jawa Barat", "image": "assets/images/puncak_ciremai.jpg"},
    {"nama": "Gunung Rinjani", "lokasi": "Nusa Tenggara Barat", "image": "assets/images/gunung_prau.jpg"},
    {"nama": "Gunung Semeru", "lokasi": "Jawa Timur", "image": "assets/images/puncak_ciremai.jpg"},
    {"nama": "Gunung Merbabu", "lokasi": "Jawa Tengah", "image": "assets/images/gunung_prau.jpg"},
  ];

  // Fungsi fetch data dari Laravel API
  Future<List<dynamic>> getGunung() async {
    try {
      final response = await http.get(
        Uri.parse("http://192.168.0.101:8000/api/gunungs"),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint("Koneksi API Gagal, memuat data lokal: $e");
    }
    return []; // Mengembalikan array kosong jika API offline agar fallback lokal jalan
  }

  // Fungsi validasi login session
  Future<void> aksiPesan(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (!mounted) return;

    if (token == null) {
      Navigator.pushNamed(context, '/login');
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const PesanTiketPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. HEADER AREA DENGAN LENGKUBAN MODEREN (Custom Paint/Decoration)
            Stack(
              children: [
                Container(
                  height: 190,
                  decoration: const BoxDecoration(
                    color: Color(0xFF2F4B7C),
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.elliptical(200, 30),
                    ),
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Column(
                      children: [
                        // Row Logo & Notifikasi
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Image.asset('assets/images/logosummitgo.png', height: 35),
                            const Icon(Icons.notifications_none_outlined, color: Colors.white, size: 26),
                          ],
                        ),
                        const SizedBox(height: 25),
                        // Card Notif Promo Orange-Putih
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              )
                            ],
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.local_fire_department, color: Colors.orange, size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  "Terdapat promo yang belum kamu ambil",
                                  style: TextStyle(color: Colors.grey[700], fontSize: 12, fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            // 2. BANNER HERO IMAGES
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  height: 130,
                  width: double.infinity,
                  color: Colors.grey[300],
                  child: Image.asset(
                    'assets/images/puncak_ciremai.jpg', // Ganti dengan asset banner promosimu
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Center(
                      child: Text("Banner Wisata Pendaki Gunung", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              ),
            ),

            // 3. KOLOM PENCARIAN
            Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: "Cari Gunung yang ingin kamu daki...",
                  hintStyle: TextStyle(fontSize: 13, color: Colors.grey),
                  border: InputBorder.none,
                  icon: Icon(Icons.search, color: Colors.grey),
                ),
              ),
            ),

            // 4. SEKSI DAFTAR GUNUNG TEXT
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Daftar Gunung",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2F4B7C)),
                  ),
                  Text(
                    "Nikmati pengalaman mendaki yang tak tergantikan",
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),

            // 5. GRID DAFTAR GUNUNG (Menggunakan FutureBuilder Terintegrasi)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: FutureBuilder<List<dynamic>>(
                future: getGunung(),
                builder: (context, snapshot) {
                  // Jika data dari API ada, pakai data API, jika tidak pakai data Dummy Lokal
                  List<dynamic> items = (snapshot.hasData && snapshot.data!.isNotEmpty)
                      ? snapshot.data!
                      : gunungLokal;

                  return GridView.builder(
                    physics: const NeverScrollableScrollPhysics(), // Supaya tidak bentrok scroll dengan SingleChildScrollView
                    shrinkWrap: true,
                    itemCount: items.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3, // Diubah jadi 3 kolom merapat sesuai gambar kanan
                      childAspectRatio: 0.7, // Ratio diperpanjang ke bawah agar teks & gambar pas tidak meluber (No Overflow)
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 10,
                    ),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return gunungCardNew(context, item);
                    },
                  );
                },
              ),
            ),

            // 6. TOMBOL LIHAT SEMUA DI BAGIAN BAWAH
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 20, bottom: 25, top: 10),
                child: TextButton(
                  onPressed: () => aksiPesan(context),
                  child: const Text(
                    "Lihat semua",
                    style: TextStyle(color: Color(0xFF2F4B7C), fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  // Tampilan Card Gunung Minimalis Modern Baru (Tanpa Tombol Pesan Kaku di dalam Card)
  Widget gunungCardNew(BuildContext context, dynamic data) {
    String nama = data['name'] ?? data['nama'] ?? data['nama_gunung'] ?? "Gunung";
    String lokasi = data['lokasi'] ?? "Jawa Barat";
    String pathGambar = data['image'] ?? "";

    return GestureDetector(
      onTap: () => aksiPesan(context), // Diklik di bagian mana saja pada card langsung memproses tiket
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 5,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail Gambar Gunung
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                child: SizedBox(
                  width: double.infinity,
                  child: pathGambar.startsWith('assets/')
                      ? Image.asset(pathGambar, fit: BoxFit.cover)
                      : Image.network(
                          "http://192.168.0.101:8000/storage/$pathGambar",
                          fit: BoxFit.cover,
                          errorBuilder: (context, e, s) => Container(
                            color: Colors.grey[300],
                            child: const Icon(Icons.image, size: 20, color: Colors.grey),
                          ),
                        ),
                ),
              ),
            ),
            // Teks Keterangan Gunung
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(6.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      nama,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.black87),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      lokasi,
                      style: const TextStyle(fontSize: 9, color: Colors.grey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}