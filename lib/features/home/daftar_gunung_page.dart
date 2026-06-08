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
  List<dynamic> semuaGunungApi = [];
  List<dynamic> gunungTerfilter = [];
  List<dynamic> rekomendasiSaran =
      []; // Menyimpan list rekomendasi saat mengetik
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
          .get(Uri.parse("${ApiConfig.baseUrl}/user/gunungs"))
          .timeout(const Duration(seconds: 5));

      print("STATUS GUNUNG = ${response.statusCode}");
      print("BODY GUNUNG = ${response.body}");

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);

        List<dynamic> dataHasil = [];

        if (decodedData['data'] != null &&
            decodedData['data']['data'] != null) {
          dataHasil = decodedData['data']['data'];
        }

        setState(() {
          semuaGunungApi = dataHasil;
          gunungTerfilter = dataHasil;
          isLoading = false;
        });

        return;
      }
    } catch (e) {
      debugPrint("Koneksi API Daftar Gunung Gagal: $e");
    }

    setState(() {
      semuaGunungApi = [];
      gunungTerfilter = [];
      isLoading = false;
    });
  }

  void filterGunung(String query) {
    setState(() {
      queryPencarian = query;
      List<dynamic> basisData = semuaGunungApi;

      if (query.isEmpty) {
        gunungTerfilter = basisData;
        rekomendasiSaran = []; // Kosongkan jika kolom pencarian kosong
      } else {
        // Filter untuk list utama
        gunungTerfilter = basisData
            .where(
              (gunung) => gunung['nama'].toString().toLowerCase().contains(
                query.toLowerCase(),
              ),
            )
            .toList();

        // Ambil maksimal 3-4 gunung sebagai "Rekomendasi Cepat" di bawah search bar
        rekomendasiSaran = basisData
            .where(
              (gunung) => gunung['nama'].toString().toLowerCase().contains(
                query.toLowerCase(),
              ),
            )
            .take(3)
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Pola warna khas iOS Sistem Gray & Backgrounds
    final iosBgColor = isDark
        ? const Color(0xFF000000)
        : const Color(0xFFF2F2F7);
    final iosCardColor = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final iosSearchColor = isDark
        ? const Color(0xFF2C2C2E)
        : const Color(0xFF767680).withOpacity(0.12);
    final iosDividerColor = isDark
        ? const Color(0xFF38383A)
        : const Color(0xFFE5E5EA);

    return Scaffold(
      backgroundColor: iosBgColor,
      appBar: AppBar(
        title: const Text(
          "Daftar Gunung",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 17,
            letterSpacing: -0.41, // Karakteristik font San Francisco iOS
          ),
        ),
        centerTitle: true,
        backgroundColor: iosCardColor,
        foregroundColor: isDark ? Colors.white : Colors.black,
        elevation: 0,
        // Garis batas tipis di bawah AppBar khas iOS
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(color: iosDividerColor, height: 0.5),
        ),
      ),
      body: Column(
        children: [
          // Search Bar Bergaya Cupertino / iOS
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            child: TextField(
              controller: _searchController,
              onChanged: filterGunung,
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.white : Colors.black,
              ),
              decoration: InputDecoration(
                hintText: "Cari gunung...",
                hintStyle: TextStyle(
                  color: isDark
                      ? Colors.grey[500]
                      : const Color(0xFF3C3C43).withOpacity(0.6),
                  fontSize: 16,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: isDark
                      ? Colors.grey[500]
                      : const Color(0xFF3C3C43).withOpacity(0.6),
                  size: 20,
                ),
                suffixIcon: queryPencarian.isNotEmpty
                    ? GestureDetector(
                        onTap: () {
                          _searchController.clear();
                          filterGunung("");
                        },
                        child: Icon(
                          Icons.cancel, // Menggunakan icon silang penuh ala iOS
                          color: isDark ? Colors.grey[400] : Colors.grey[500],
                          size: 18,
                        ),
                      )
                    : null,
                filled: true,
                fillColor: iosSearchColor,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    10,
                  ), // Sudut melengkung halus persegi khas iOS
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Panel Rekomendasi Instan / Suggestion Box bergaya iOS Menu
          if (rekomendasiSaran.isNotEmpty)
            Container(
              // GANTI INI:
              // margin: const EdgeInsets.symmetric(horizontal: 16, bottom: 12),

              // MENJADI INI:
              margin: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
              decoration: BoxDecoration(
                color: iosCardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: iosDividerColor, width: 0.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          size: 16,
                          color: Colors.amber,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "Rekomendasi untukmu:",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(color: iosDividerColor, height: 0.5),
                  ...rekomendasiSaran.map((gunungSaran) {
                    return Column(
                      children: [
                        ListTile(
                          dense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 2,
                          ),
                          leading: const Icon(
                            Icons.location_on_outlined,
                            size: 18,
                            color: Colors.blueAccent,
                          ),
                          title: Text(
                            gunungSaran['nama'] ?? "",
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            size: 12,
                            color: Colors.grey[400],
                          ),
                          onTap: () {
                            setState(() {
                              _searchController.text = gunungSaran['nama'];
                              filterGunung(gunungSaran['nama']);
                              rekomendasiSaran = [];
                            });

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    PencarianBasecampPage(gunung: gunungSaran),
                              ),
                            );
                          },
                        ),
                        if (gunungSaran != rekomendasiSaran.last)
                          Padding(
                            padding: const EdgeInsets.only(left: 50.0),
                            child: Container(
                              color: iosDividerColor,
                              height: 0.5,
                            ),
                          ),
                      ],
                    );
                  }),
                ],
              ),
            ),

          // Daftar Utama Gunung
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator.adaptive(),
                  ) // Menggunakan loading bawaan sistem (iOS spinner jika di iPhone)
                : gunungTerfilter.isNotEmpty
                ? ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    itemCount: gunungTerfilter.length,
                    itemBuilder: (context, index) {
                      final gunung = gunungTerfilter[index];
                      String nama = gunung['nama'] ?? "Gunung";
                      String lokasi = gunung['lokasi'] ?? "Tidak Diketahui";
                      dynamic fotoRaw = gunung['foto_utama'];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: iosCardColor,
                          borderRadius: BorderRadius.circular(
                            14,
                          ), // Sudut card lebih halus
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(
                                isDark ? 0.3 : 0.04,
                              ),
                              blurRadius: 12,
                              offset: const Offset(
                                0,
                                4,
                              ), // Bayangan halus menyebar ke bawah
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    PencarianBasecampPage(gunung: gunung),
                              ),
                            );
                          },
                          child: Row(
                            children: [
                              // Wadah Gambar Terpotong Presisi
                              SizedBox(
                                width: 100,
                                height: 100,
                                child:
                                    (fotoRaw == null ||
                                        fotoRaw.toString().isEmpty)
                                    ? Image.asset(
                                        "assets/images/puncak_ciremai.jpg",
                                        fit: BoxFit.cover,
                                      )
                                    : fotoRaw.toString().startsWith('assets/')
                                    ? Image.asset(
                                        fotoRaw.toString(),
                                        fit: BoxFit.cover,
                                      )
                                    : Image.network(
                                        "${ApiConfig.baseUrl.replaceAll('/api', '')}/storage/$fotoRaw",
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, e, s) =>
                                            Container(
                                              color: isDark
                                                  ? Colors.grey[800]
                                                  : Colors.grey[200],
                                              child: Icon(
                                                Icons.image,
                                                color: Colors.grey[400],
                                              ),
                                            ),
                                      ),
                              ),

                              // Detail Informasi Khas Premium iOS Layout
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(14.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        nama,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15,
                                          color: isDark
                                              ? Colors.white
                                              : const Color(0xFF1C1C1E),
                                          letterSpacing: -0.24,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.location_on,
                                            size: 13,
                                            color: Colors.grey[400],
                                          ),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              lokasi,
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: isDark
                                                    ? Colors.grey[400]
                                                    : const Color(0xFF8E8E93),
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // Chevron panah tipis penunjuk jalan masuk
                              Padding(
                                padding: const EdgeInsets.only(right: 16.0),
                                child: Icon(
                                  Icons.arrow_forward_ios,
                                  size: 13,
                                  color: isDark
                                      ? Colors.grey[600]
                                      : const Color(0xFFC7C7CC),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  )
                : Center(
                    child: Text(
                      "Gunung tidak ditemukan",
                      style: TextStyle(color: Colors.grey[500], fontSize: 15),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
