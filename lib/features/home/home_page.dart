import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../ticket/pencarian_basecamp_page.dart'; 
import 'daftar_gunung_page.dart'; 
import '../../api_config.dart'; 
import 'dart:async';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // --- KODE BANNER SLIDER ---
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;
  Timer? _timer;

  // Variabel penampung data user
  String name = "Pendaki";
  String email = "pendaki@email.com";
  bool isLoggedIn = false;

  // Daftar gambar banner promo
  final List<String> bannerImages = [
    "assets/images/puncak_ciremai.jpg",
    "assets/images/gunung_prau.jpg",
    "assets/images/puncak_ciremai.jpg",
  ];

  // PERBAIKAN: Menambah 2 gunung (Total 6) dengan struktur data objek basecamp lengkap
  final List<Map<String, dynamic>> gunungLokal = [
    {
      "nama": "Gunung Ciremai",
      "lokasi": "Jawa Barat",
      "image": "assets/images/puncak_ciremai.jpg",
      "deskripsi": "Gunung tertinggi di Jawa Barat dengan tantangan jalur pendakian yang eksotis dan kaya akan keanekaragaman hayati.",
      "tarif_weekday": "Rp 50.000",
      "tarif_weekend": "Rp 75.000",
      "basecamps": [
        {"id": 1, "nama": "Apuy"},
        {"id": 2, "nama": "Palutungan"},
        {"id": 3, "nama": "Linggajati"},
        {"id": 4, "nama": "Linggasana"},
        {"id": 5, "nama": "Sadarehe"}
      ]
    },
    {
      "nama": "Gunung Prau",
      "lokasi": "Jawa Tengah",
      "image": "assets/images/gunung_prau.jpg",
      "deskripsi": "Terkenal dengan pemandangan golden sunrise terbaik di Asia Tenggara dan bukit teletubbies yang memanjakan mata.",
      "tarif_weekday": "Rp 25.000",
      "tarif_weekend": "Rp 30.000",
      "basecamps": [
        {"id": 6, "nama": "Patak Banteng"},
        {"id": 7, "nama": "Dieng"},
        {"id": 8, "nama": "Kalilembu"}
      ]
    },
    {
      "nama": "Gunung Semeru",
      "lokasi": "Jawa Timur",
      "image": "assets/images/puncak_ciremai.jpg",
      "deskripsi": "Gunung tertinggi di Pulau Jawa dengan keindahan danau Ranu Kumbolo yang melegenda.",
      "tarif_weekday": "Rp 22.500",
      "tarif_weekend": "Rp 32.500",
      "basecamps": [
        {"id": 9, "nama": "Ranu Pane"}
      ]
    },
    {
      "nama": "Gunung Merbabu",
      "lokasi": "Jawa Tengah",
      "image": "assets/images/gunung_prau.jpg",
      "deskripsi": "Gunung dengan hamparan sabana hijau yang sangat luas dan pemandangan Gunung Merapi yang megah.",
      "tarif_weekday": "Rp 30.000",
      "tarif_weekend": "Rp 40.000",
      "basecamps": [
        {"id": 10, "nama": "Selo"},
        {"id": 11, "nama": "Suwanting"},
        {"id": 12, "nama": "Wekas"}
      ]
    },
    {
      "nama": "Gunung Sindoro",
      "lokasi": "Jawa Tengah",
      "image": "assets/images/gunung_prau.jpg",
      "deskripsi": "Kembaran Gunung Sumbing yang memiliki padang edelweiss luas di dekat puncak dan kawah aktif menakjubkan.",
      "tarif_weekday": "Rp 25.000",
      "tarif_weekend": "Rp 30.000",
      "basecamps": [
        {"id": 13, "nama": "Kledung"},
        {"id": 14, "nama": "Alang-Alang Sewu"},
        {"id": 15, "nama": "Bansari"}
      ]
    },
    {
      "nama": "Gunung Lawu",
      "lokasi": "Jawa Timur",
      "image": "assets/images/puncak_ciremai.jpg",
      "deskripsi": "Gunung sarat sejarah di perbatasan Jateng-Jatim, terkenal dengan warung tertinggi Mbok Yem.",
      "tarif_weekday": "Rp 20.000",
      "tarif_weekend": "Rp 25.000",
      "basecamps": [
        {"id": 16, "nama": "Cetho"},
        {"id": 17, "nama": "Cemoro Sewu"},
        {"id": 18, "nama": "Cemoro Kandang"}
      ]
    },
  ];

  @override
  void initState() {
    super.initState();
    getUser();

    _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (_currentPage < bannerImages.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }

      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeIn,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    if (token != null) {
      setState(() {
        isLoggedIn = true;
        name = prefs.getString('name') ?? "Pendaki";
        email = prefs.getString('email') ?? "pendaki@email.com";
      });
    } else {
      setState(() {
        isLoggedIn = false;
      });
    }
  }

  Future<List<dynamic>> getGunung() async {
    try {
      final response = await http
          .get(Uri.parse("${ApiConfig.baseUrl}/gunungs"))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint("Koneksi API Gagal, memuat data lokal: $e");
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. HEADER AREA DENGAN LENGKUBAN MODEREN
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Image.asset(
                              'assets/images/logosummitgo.png',
                              height: 35,
                            ),
                            const Icon(
                              Icons.notifications_none_outlined,
                              color: Colors.white,
                              size: 26,
                            ),
                          ],
                        ),
                        const SizedBox(height: 25),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.local_fire_department,
                                color: Colors.orange,
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  "Terdapat promo yang belum kamu ambil",
                                  style: TextStyle(
                                    color: isDark
                                        ? Colors.white70
                                        : const Color(0xFF2F4B7C).withOpacity(0.8),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
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
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      height: 130,
                      width: double.infinity,
                      color: Theme.of(context).cardColor,
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: bannerImages.length,
                        onPageChanged: (int page) {
                          setState(() {
                            _currentPage = page;
                          });
                        },
                        itemBuilder: (context, index) {
                          return Image.asset(
                            bannerImages[index],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Center(
                                  child: Text(
                                    "Banner Wisata Pendaki Gunung",
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      bannerImages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 6,
                        width: _currentPage == index ? 18 : 6,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? const Color(0xFF2F4B7C)
                              : Colors.grey[isDark ? 700 : 300],
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 3. KOLOM PENCARIAN
            Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                style: TextStyle(color: Theme.of(context).canvasColor),
                decoration: const InputDecoration(
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
                  Text(
                    "Daftar Gunung",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF2F4B7C),
                    ),
                  ),
                  Text(
                    "Nikmati pengalaman mendaki yang tak tergantikan",
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),

            // 5. GRID DAFTAR GUNUNG (Menampilkan seluruh isi item secara proporsional)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: FutureBuilder<List<dynamic>>(
                future: getGunung(),
                builder: (context, snapshot) {
                  List<dynamic> items =
                      (snapshot.hasData && snapshot.data!.isNotEmpty)
                      ? snapshot.data!
                      : gunungLokal;

                  return GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: items.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3, 
                      childAspectRatio: 0.7,
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

            // 6. TOMBOL LIHAT SEMUA
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 20, bottom: 25, top: 10),
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const DaftarGunungPage()),
                    );
                  },
                  child: const Text(
                    "Lihat semua",
                    style: TextStyle(
                      color: Color(0xFF2F4B7C),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget gunungCardNew(BuildContext context, dynamic data) {
    String nama = data['name'] ?? data['nama'] ?? data['nama_gunung'] ?? "Gunung";
    String lokasi = data['lokasi'] ?? "Jawa Barat";
    String pathGambar = data['image'] ?? "";
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PencarianBasecampPage(gunung: data),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.2 : 0.02),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                child: SizedBox(
                  width: double.infinity,
                  child: pathGambar.startsWith('assets/')
                      ? Image.asset(pathGambar, fit: BoxFit.cover)
                      : Image.network(
                          "${ApiConfig.baseUrl}/storage/$pathGambar",
                          fit: BoxFit.cover,
                          errorBuilder: (context, e, s) => Container(
                            color: isDark ? Colors.grey[800] : Colors.grey[300],
                            child: const Icon(Icons.image, size: 20, color: Colors.grey),
                          ),
                        ),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      nama,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        color: isDark ? Colors.white : const Color(0xFF2F4B7C),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      lokasi,
                      style: TextStyle(
                        fontSize: 9,
                        color: isDark ? Colors.grey[400] : const Color(0xFF666666),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}