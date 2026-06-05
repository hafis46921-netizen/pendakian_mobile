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
  bool _isApiLoading = true; // Flag status loading data gunung

  // --- FITUR PENCARIAN & REKOMENDASI ---
  final TextEditingController _searchController = TextEditingController();
  final OverlayPortalController _tooltipController = OverlayPortalController(); 
  final LayerLink _layerLink = LayerLink(); 
  
  List<dynamic> semuaGunungData = []; 
  List<dynamic> rekomendasiSaran = []; 
  String queryPencarian = "";

  final List<String> bannerImages = [
    "assets/images/puncak_ciremai.jpg",
    "assets/images/gunung_prau.jpg",
    "assets/images/puncak_ciremai.jpg",
  ];

  final List<Map<String, dynamic>> gunungLokal = [
    {
      "nama": "Gunung Ciremai",
      "lokasi": "Jawa Barat",
      "foto_utama": "assets/images/puncak_ciremai.jpg",
      "deskripsi": "Gunung tertinggi di Jawa Barat dengan tantangan jalur pendakian yang eksotis.",
      "ketinggian": 3078,
    },
    {
      "nama": "Gunung Prau",
      "lokasi": "Jawa Tengah",
      "foto_utama": "assets/images/gunung_prau.jpg",
      "deskripsi": "Terkenal dengan pemandangan golden sunrise terbaik di Asia Tenggara.",
      "ketinggian": 2565,
    },
  ];

  @override
  void initState() {
    super.initState();
    getUser();
    initFetchSemuaGunung(); // Ambil data SEKALI SAJA di awal

    _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      // 1. Cek apakah widget masih aktif, kalau tidak langsung matikan timer
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_currentPage < bannerImages.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }

      // 2. Cek ekstra hasClients DAN haveDimensions agar Flutter Web tidak crash
      if (_pageController.hasClients && _pageController.position.haveDimensions) {
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
    _searchController.dispose(); 
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

  // Helper Format Tanggal Indonesia (Pengganti Widget Cuaca)
  String _getFormattedDate() {
    final now = DateTime.now();
    final hari = ['Minggu', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];
    final bulan = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Juni', 
      'Juli', 'Agust', 'Sept', 'Okt', 'Nov', 'Des'
    ];
    
    // DayOfWeek bawaan Dart dimulai dari 1 (Senin) s/d 7 (Minggu)
    String namaHari = hari[now.weekday % 7];
    String namaBulan = bulan[now.month - 1];
    
    return "$namaHari, ${now.day} $namaBulan";
  }

  // Mengambil data awal untuk list grid dan fitur pencarian
  Future<void> initFetchSemuaGunung() async {
    setState(() {
      _isApiLoading = true;
    });
    
    final data = await getGunung();
    
    if (mounted) {
      setState(() {
        // Jika API timeout/gagal, otomatis gunakan data gunungLokal agar tidak kosong
        semuaGunungData = data.isNotEmpty ? data : gunungLokal;
        _isApiLoading = false;
      });
    }
  }

  Future<List<dynamic>> getGunung() async {
    try {
      final response = await http
          .get(Uri.parse("${ApiConfig.baseUrl}/gunungs"))
          .timeout(const Duration(seconds: 5)); // Batas timeout aman

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);
        if (decodedData is Map && decodedData.containsKey('data')) {
          return decodedData['data'];
        }
        if (decodedData is List) {
          return decodedData;
        }
      }
    } catch (e) {
      debugPrint("Koneksi API Gagal (Menggunakan Fallback Lokal): $e");
    }
    return [];
  }

  void filterRekomendasi(String query) {
    setState(() {
      queryPencarian = query;
      if (query.isEmpty) {
        rekomendasiSaran = [];
        _tooltipController.hide();
      } else {
        rekomendasiSaran = semuaGunungData
            .where(
              (gunung) => gunung['nama'].toString().toLowerCase().contains(
                    query.toLowerCase(),
                  ),
            )
            .take(3)
            .toList();

        if (rekomendasiSaran.isNotEmpty) {
          _tooltipController.show();
        } else {
          _tooltipController.hide();
        }
      }
    });
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
            // 1. HEADER AREA & SEARCH BAR
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 220,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF1E3A8A), Color(0xFF2F4B7C)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.elliptical(200, 25),
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
                            Image.asset('assets/images/logosummitgo.png', height: 35),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.notifications_none_outlined, color: Colors.white, size: 24),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Halo, Mau Mendaki Kemana?",
                                  style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.7), letterSpacing: 0.5),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  name,
                                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                              ],
                            ),
                            
                            // --- WIDGET PENGGANTI: TANGGAL DINAMIS ---
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.calendar_month_outlined, color: Colors.white70, size: 15),
                                  const SizedBox(width: 5),
                                  Text(
                                    _getFormattedDate(),
                                    style: const TextStyle(
                                      color: Colors.white, 
                                      fontSize: 11, 
                                      fontWeight: FontWeight.w500
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // SEARCH BAR OVERLAY
                        CompositedTransformTarget(
                          link: _layerLink,
                          child: OverlayPortal(
                            controller: _tooltipController,
                            overlayChildBuilder: (BuildContext context) {
                              return CompositedTransformFollower(
                                link: _layerLink,
                                targetAnchor: Alignment.bottomLeft,
                                followerAnchor: Alignment.topLeft,
                                offset: const Offset(0, 8),
                                child: Align(
                                  alignment: Alignment.topLeft,
                                  child: Material(
                                    color: Colors.transparent,
                                    child: Container(
                                      width: MediaQuery.of(context).size.width - 40,
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).cardColor,
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.15),
                                            blurRadius: 10,
                                            offset: const Offset(0, 5),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: rekomendasiSaran.map((gunungSaran) {
                                          return ListTile(
                                            dense: true,
                                            leading: const Icon(Icons.location_on_outlined, size: 16, color: Colors.blue),
                                            title: Text(gunungSaran['nama'] ?? "", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                            subtitle: Text(gunungSaran['lokasi'] ?? "", style: const TextStyle(fontSize: 10)),
                                            trailing: const Icon(Icons.arrow_forward_ios, size: 10, color: Colors.grey),
                                            onTap: () {
                                              setState(() {
                                                _searchController.clear();
                                                rekomendasiSaran = [];
                                                queryPencarian = "";
                                              });
                                              _tooltipController.hide();
                                              FocusScope.of(context).unfocus();

                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => PencarianBasecampPage(gunung: gunungSaran),
                                                ),
                                              );
                                            },
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.18),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: Colors.white.withOpacity(0.1)),
                              ),
                              child: TextField(
                                controller: _searchController,
                                onChanged: filterRekomendasi,
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  hintText: "Cari destinasi gunungmu...",
                                  hintStyle: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.6)),
                                  border: InputBorder.none,
                                  icon: const Icon(Icons.search, color: Colors.white70, size: 22),
                                  suffixIcon: queryPencarian.isNotEmpty
                                      ? IconButton(
                                          icon: const Icon(Icons.clear, color: Colors.white70, size: 18),
                                          onPressed: () {
                                            _searchController.clear();
                                            filterRekomendasi("");
                                          },
                                        )
                                      : null,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),

            // 2. BANNER HERO
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Transform(
                    transform: Matrix4.identity()..setEntry(3, 2, 0.0012)..rotateX(0.06),
                    alignment: FractionalOffset.center,
                    child: Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.22), blurRadius: 25, offset: const Offset(0, 18)),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
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
                                  const Center(child: Text("Banner Wisata Pendaki Gunung", style: TextStyle(fontWeight: FontWeight.bold))),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      bannerImages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 3.5),
                        height: 5,
                        width: _currentPage == index ? 22 : 5,
                        decoration: BoxDecoration(
                          color: _currentPage == index ? const Color(0xFF2F4B7C) : Colors.grey[isDark ? 700 : 300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),

            // 3. DAFTAR GUNUNG TEXT
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Daftar Gunung",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF2F4B7C)),
                  ),
                  Text(
                    "Nikmati pengalaman mendaki yang tak tergantikan",
                    style: TextStyle(fontSize: 11, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),

            // 4. GRID DAFTAR GUNUNG
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: _isApiLoading
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 30.0),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: semuaGunungData.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 0.7,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 10,
                      ),
                      itemBuilder: (context, index) {
                        return gunungCardNew(context, semuaGunungData[index]);
                      },
                    ),
            ),

            // 5. TOMBOL LIHAT SEMUA
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 20, bottom: 25, top: 10),
                child: TextButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const DaftarGunungPage()));
                  },
                  child: const Text("Lihat semua", style: TextStyle(color: Color(0xFF2F4B7C), fontWeight: FontWeight.bold, fontSize: 13)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget gunungCardNew(BuildContext context, dynamic data) {
    String nama = data['nama'] ?? "Gunung";
    String lokasi = data['lokasi'] ?? "Tidak Diketahui";
    String pathGambar = data['foto_utama'] ?? "";
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => PencarianBasecampPage(gunung: data)));
      },
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(isDark ? 0.2 : 0.02), blurRadius: 5, offset: const Offset(0, 2)),
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
                          "${ApiConfig.baseUrl.replaceAll('/api', '')}/storage/$pathGambar",
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
                    Text(nama, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: isDark ? Colors.white : const Color(0xFF2F4B7C)), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Text(lokasi, style: TextStyle(fontSize: 9, color: isDark ? Colors.grey[400] : const Color(0xFF666666)), maxLines: 1, overflow: TextOverflow.ellipsis),
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