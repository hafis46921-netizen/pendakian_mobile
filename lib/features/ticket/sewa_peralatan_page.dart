// lib/features/ticket/sewa_peralatan_page.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../api_config.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class SewaPeralatanPage extends StatefulWidget {
  final Map<String, dynamic> dataTiket;

  const SewaPeralatanPage({super.key, required this.dataTiket});

  @override
  State<SewaPeralatanPage> createState() => _SewaPeralatanPageState();
}

class _SewaPeralatanPageState extends State<SewaPeralatanPage> {
  String _selectedCategory = "Semua";
  bool _isLoadingData = true;
  bool _isSubmitting = false;

  List<String> _categories = ["Semua"];
  List<Map<String, dynamic>> _equipments = [];
  final Map<int, int> _cart = {}; // { id_barang : jumlah }

  final TextEditingController _promoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchPeralatan();
  }

  // mengambil data peralatan dari api
  Future<void> _fetchPeralatan() async {
    try {
      final basecampId = widget.dataTiket['basecamp_id'];
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/basecamps/$basecampId/peralatan'),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final List<dynamic> data = responseData['data'];

        List<String> loadedCategories = ["Semua"];
        List<Map<String, dynamic>> loadedEquipments = [];

        for (var categoryGroup in data) {
          String categoryName = categoryGroup['category'];
          loadedCategories.add(categoryName);

          for (var item in categoryGroup['items']) {
            loadedEquipments.add({
              "id": item['id'],
              "category": categoryName,
              "name": item['nama_alat'],
              "desc": item['deskripsi'] ?? '',
              "price": item['harga_sewa'],
              "stock": item['stok'],
              "image":
                  item['foto'], // Sesuaikan jika menggunakan URL penuh dari Laravel
            });
          }
        }

        setState(() {
          _categories = loadedCategories;
          _equipments = loadedEquipments;
          _isLoadingData = false;
        });
      }
    } catch (e) {
      print("Error fetching peralatan: $e");
      setState(() => _isLoadingData = false);
    }
  }

  // mengirim transaksi checkout ke api
  Future<void> _submitBooking() async {
    setState(() => _isSubmitting = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      var request = http.MultipartRequest(
        'POST',
        Uri.parse("${ApiConfig.baseUrl}/user/bookings"),
      );

      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });

      print("DEBUG DATA TIKET: ${widget.dataTiket}");

      // Mengambil nilai tanggal dengan mengecek beberapa opsi key
      String tanggal =
          widget.dataTiket['tanggal_naik'] ??
          widget.dataTiket['tanggal_masuk'] ??
          widget.dataTiket['tanggal'] ??
          '';

      request.fields['tanggal_naik'] = tanggal;

      // Ddata Tiket Dasar
      request.fields['basecamp_id'] = widget.dataTiket['basecamp_id']
          .toString();
      String tanggalRaw = widget.dataTiket['tanggal_naik'] ?? widget.dataTiket['tanggal_masuk'] ?? '';
      
      // Jika formatnya DD/MM/YYYY, pecah dan susun ulang menjadi YYYY-MM-DD
      if (tanggalRaw.contains('/')) {
        List<String> parts = tanggalRaw.split('/');
        if (parts.length == 3) {
          tanggalRaw = '${parts[2]}-${parts[1]}-${parts[0]}';
        }
      }
      request.fields['tanggal_naik'] = tanggalRaw;
      request.fields['jumlah_pendaki'] = widget.dataTiket['jumlah_pendaki']
          .toString();
      request.fields['harga_per_orang'] = widget.dataTiket['harga_raw']
          .toString();

      // Data Promo
      if (_promoController.text.isNotEmpty) {
        request.fields['kode_promo'] = _promoController.text;
      }

      // Data Anggota & File Foto
      List<dynamic> anggota = widget.dataTiket['anggota'] ?? [];
      for (int i = 0; i < anggota.length; i++) {
        request.fields['anggota[$i][nama]'] = anggota[i]['nama'];
        request.fields['anggota[$i][alamat]'] = anggota[i]['alamat'];
        request.fields['anggota[$i][tanggal_lahir]'] =
            anggota[i]['tanggal_lahir'];
        request.fields['anggota[$i][jenis_kelamin]'] =
            anggota[i]['jenis_kelamin'];
        request.fields['anggota[$i][identitas]'] = anggota[i]['identitas'];

        if (anggota[i]['foto_identitas'] != null) {
          var foto = anggota[i]['foto_identitas'];

          if (kIsWeb) {
            var bytes = await foto.readAsBytes();
            request.files.add(
              http.MultipartFile.fromBytes(
                'anggota[$i][foto_identitas]',
                bytes,
                filename: foto.name ?? 'foto_identitas.jpg',
              ),
            );
          } else {
            request.files.add(
              await http.MultipartFile.fromPath(
                'anggota[$i][foto_identitas]',
                foto.path,
              ),
            );
          }
        }
      }

      // Data Sewa Peralatan
      int eqIndex = 0;
      _cart.forEach((peralatanId, jumlah) {
        if (jumlah > 0) {
          request.fields['equipments[$eqIndex][id]'] = peralatanId.toString();
          request.fields['equipments[$eqIndex][jumlah]'] = jumlah.toString();
          eqIndex++;
        }
      });

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final responseData = jsonDecode(response.body);

      setState(() => _isSubmitting = false);

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Pesanan berhasil dibuat!")),
        );
        // Arahkan ke halaman Invoice / Midtrans Payment
        Navigator.pushReplacementNamed(
          context,
          '/invoice_pembayaran',
          arguments:
              responseData['data'], // Melempar data booking dan snap_token
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(responseData['message'] ?? "Gagal memproses pesanan"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      print("Checkout Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Terjadi kesalahan jaringan"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Filter & Grouping Data
  List<Map<String, dynamic>> get filteredEquipments {
    if (_selectedCategory == "Semua") return _equipments;
    return _equipments
        .where((item) => item["category"] == _selectedCategory)
        .toList();
  }

  Map<String, List<Map<String, dynamic>>> get groupedEquipments {
    Map<String, List<Map<String, dynamic>>> grouped = {};
    for (var item in filteredEquipments) {
      if (!grouped.containsKey(item['category'])) {
        grouped[item['category']] = [];
      }
      grouped[item['category']]!.add(item);
    }
    return grouped;
  }

  void _tambahItem(int id, int stock) {
    setState(() {
      int currentQty = _cart[id] ?? 0;
      if (currentQty < stock) {
        _cart[id] = currentQty + 1;
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Stok maksimum tercapai")));
      }
    });
  }

  void _kurangiItem(int id) {
    setState(() {
      if (_cart.containsKey(id) && _cart[id]! > 0) {
        _cart[id] = _cart[id]! - 1;
        if (_cart[id] == 0) _cart.remove(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    String imagePath =
        widget.dataTiket['image'] ?? 'assets/images/puncak_ciremai.jpg';

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF121212)
          : const Color(0xFFF4F6F9),
      body: _isLoadingData
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF2F4B7C)),
            )
          : Stack(
              children: [
                CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      expandedHeight: 220.0,
                      pinned: true,
                      backgroundColor: isDark
                          ? const Color(0xFF1E1E1E)
                          : const Color(0xFF2F4B7C),
                      leading: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      flexibleSpace: FlexibleSpaceBar(
                        title: const Text(
                          "Sewa Peralatan",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        background: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.asset(
                              imagePath, // Sesuaikan jika menggunakan NetworkImage
                              fit: BoxFit.cover,
                            ),
                            Container(color: Colors.black.withOpacity(0.4)),
                          ],
                        ),
                      ),
                    ),

                    // Kategori Chip
                    SliverToBoxAdapter(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            children: _categories.map((category) {
                              bool isSelected = _selectedCategory == category;
                              return Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: ChoiceChip(
                                  label: Text(
                                    category,
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : (isDark
                                                ? Colors.grey[300]
                                                : const Color(0xFF2F4B7C)),
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                  selected: isSelected,
                                  selectedColor: const Color(0xFF2F4B7C),
                                  backgroundColor: isDark
                                      ? Colors.grey[800]
                                      : const Color(0xFFE8EEF5),
                                  showCheckmark: false,
                                  onSelected: (bool selected) {
                                    if (selected)
                                      setState(
                                        () => _selectedCategory = category,
                                      );
                                  },
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),

                    // Grid Peralatan
                    SliverPadding(
                      padding: const EdgeInsets.all(20),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          String categoryTitle = groupedEquipments.keys
                              .elementAt(index);
                          List<Map<String, dynamic>> items =
                              groupedEquipments[categoryTitle]!;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                  bottom: 12,
                                  top: index == 0 ? 0 : 20,
                                ),
                                child: Text(
                                  categoryTitle,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? Colors.white
                                        : const Color(0xFF2F4B7C),
                                  ),
                                ),
                              ),
                              GridView.builder(
                                padding: EdgeInsets.zero,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 15,
                                      mainAxisSpacing: 15,
                                      childAspectRatio: 0.75,
                                    ),
                                itemCount: items.length,
                                itemBuilder: (context, itemIndex) {
                                  final item = items[itemIndex];
                                  final int qty = _cart[item['id']] ?? 0;
                                  return _buildEquipmentCard(item, qty, isDark);
                                },
                              ),
                            ],
                          );
                        }, childCount: groupedEquipments.keys.length),
                      ),
                    ),

                    // Input Promo
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        child: TextField(
                          controller: _promoController,
                          decoration: InputDecoration(
                            hintText: "Masukkan Kode Promo (Opsional)",
                            filled: true,
                            fillColor: isDark ? Colors.grey[800] : Colors.white,
                            prefixIcon: const Icon(
                              Icons.local_offer,
                              color: Color(0xFF2F4B7C),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SliverToBoxAdapter(child: SizedBox(height: 120)),
                  ],
                ),

                // Bottom Bar Checkout
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          offset: const Offset(0, -4),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2F4B7C),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _isSubmitting ? null : _submitBooking,
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              "Lanjut Pembayaran",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildEquipmentCard(Map<String, dynamic> item, int qty, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[800] : Colors.grey[100],
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
              child: Icon(Icons.inventory_2, size: 50, color: Colors.grey[400]),
            ),
          ),
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['name'],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        "Sisa: ${item['stock']}",
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  Text(
                    "Rp ${item['price']}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Color(0xFF4CAF50),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (qty > 0) ...[
                        GestureDetector(
                          onTap: () => _kurangiItem(item['id']),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.grey[700]
                                  : Colors.grey[200],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Icon(Icons.remove, size: 16),
                          ),
                        ),
                        Text(
                          "$qty",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                      ] else
                        const Spacer(),
                      GestureDetector(
                        onTap: () => _tambahItem(item['id'], item['stock']),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2F4B7C),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Icon(
                            Icons.add,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
