// lib/features/ticket/history_page.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../api_config.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  bool isLoggedIn = false;
  List pemesananData = [];
  List pendaftaranData = [];
  bool isLoading = true;

  // State untuk manajemen pengurutan tanggal (true = terbaru, false = terlama)
  bool _isNewestFirst = true;

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token != null) {
      setState(() {
        isLoggedIn = true;
      });
      fetchHistory();
    } else {
      setState(() {
        isLoggedIn = false;
        isLoading = false;
      });
    }
  }

  Future<void> fetchHistory() async {
    setState(() => isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      // 1. Ambil data untuk Tab Pemesanan
      final resPemesanan = await http
          .get(
            Uri.parse("${ApiConfig.baseUrl}/user/bookings"),
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 5));

      // 2. Ambil data untuk Tab Pendaftaran
      final resPendaftaran = await http.get(
        Uri.parse("${ApiConfig.baseUrl}/user/admin-requests"),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      print("STATUS ADMIN REQUEST = ${resPendaftaran.statusCode}");
      print("BODY ADMIN REQUEST = ${resPendaftaran.body}");
      
      if (resPemesanan.statusCode == 200) {
        final Map<String, dynamic> bodyPemesanan = json.decode(
          resPemesanan.body,
        );
        final List rawPemesanan = bodyPemesanan['data']['data'] ?? [];

        List rawPendaftaran = [];
        if (resPendaftaran.statusCode == 200) {
          print("ADMIN REQUEST BODY:");
          print(resPendaftaran.body);

          final Map<String, dynamic> bodyPendaftaran = json.decode(
            resPendaftaran.body,
          );

          rawPendaftaran = bodyPendaftaran['data']?? [];
        }

        setState(() {
          pemesananData = rawPemesanan.map((item) {
            var rawPrice =
                item['total_price'] ??
                item['harga'] ??
                item['harga_total'] ??
                0;
            int parsedPrice =
                double.tryParse(rawPrice.toString())?.toInt() ?? 0;

            return {
              'id': item['id'],
              'date': item['tanggal_naik'],
              'status': item['status'],
              'total_price': parsedPrice,
              'basecamp': item['basecamp'] != null
                  ? item['basecamp']['nama']
                  : 'Basecamp',
              'jumlah_pendaki': item['jumlah_pendaki'] ?? 1,
              'durasi': item['durasi_pendakian'] ?? 2,
            };
          }).toList();

          pendaftaranData = rawPendaftaran.map((item) {
            return {
              'id': item['id'],
              'date': item['created_at'],
              'status': item['status'],
              'type': item['request_type'],
              'basecamp': item['basecamp_id'] ?? '-',
            };
          }).toList();

          // Jalankan fungsi sorting bawaan di awal load data
          _urutkanData();
          isLoading = false;
        });
        print("TOTAL REQUEST: ${pendaftaranData.length}");
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint("Error fetchHistory: $e");
    }
  }

  // Fungsi Logika Mengurutkan Tanggal Pendakian
  void _urutkanData() {
    int Function(dynamic, dynamic) sortLogic = (a, b) {
      DateTime dateA =
          DateTime.tryParse(a['date']?.toString() ?? '') ?? DateTime(1970);
      DateTime dateB =
          DateTime.tryParse(b['date']?.toString() ?? '') ?? DateTime(1970);
      return _isNewestFirst ? dateB.compareTo(dateA) : dateA.compareTo(dateB);
    };

    pemesananData.sort(sortLogic);
    pendaftaranData.sort(sortLogic);
  }

  // Fungsi Menampilkan Tiket Detail/Struk Digital untuk Bukti
  void _tampilkanDetailTiket(Map<String, dynamic> booking, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final statusColor = _getStatusColor(booking['status']);
        return Container(
          margin: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "E-TIKET PENDAKIAN",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "Tunjukkan bukti ini kepada petugas basecamp",
                  style: TextStyle(color: Colors.grey[500], fontSize: 11),
                ),
                const SizedBox(height: 20),

                // Pembatas Garis Putus-putus Atas
                Text(
                  "--------------------------------------------------",
                  style: TextStyle(color: Colors.grey[300]),
                ),

                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Nama Basecamp",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      "${booking['basecamp']}",
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2F4B7C),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Order ID",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      "#${booking['id']}",
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Tanggal Naik",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      "${booking['date']}",
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Status Pembayaran",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        "${booking['status']}".toUpperCase(),
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 15),
                // Pembatas Garis Putus-putus Bawah
                Text(
                  "--------------------------------------------------",
                  style: TextStyle(color: Colors.grey[300]),
                ),
                const SizedBox(height: 15),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Total Pembayaran",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Rp ${booking['total_price']}",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                // Tombol Tutup Struk
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2F4B7C),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      "Selesai & Tutup",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> cancelBooking(int bookingId) async {
    bool konfirmasi =
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              "Batalkan Booking",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            content: const Text(
              "Apakah kamu yakin ingin membatalkan pesanan tiket pendakian ini?",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Kembali"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  "Ya, Batalkan",
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ) ??
        false;

    if (!konfirmasi) return;

    setState(() => isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final response = await http.patch(
        Uri.parse("${ApiConfig.baseUrl}/user/bookings/$bookingId/cancel"),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Booking sukses dibatalkan!")),
        );
        fetchHistory();
      } else {
        final errorResponse = jsonDecode(response.body);
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              errorResponse['message'] ?? "Gagal membatalkan booking",
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint("Error cancelBooking: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (!isLoggedIn) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.lock_outline,
                  size: 100,
                  color: isDark ? Colors.grey[600] : Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  "Kamu belum login",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF2F4B7C),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Silakan login untuk melihat riwayat transaksi.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isDark ? Colors.grey[400] : Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/login'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark
                        ? const Color(0xFF1E1E1E)
                        : const Color(0xFF2F4B7C),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: const Text(
                    "Login Sekarang",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Column(
          children: [
            // 1. TOP HEADER AREA
            Stack(
              children: [
                Container(
                  height: 175,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF1E3A8A), Color(0xFF2F4B7C)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.elliptical(200, 20),
                    ),
                  ),
                ),
                Positioned(
                  top: -40,
                  right: -20,
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.04),
                    ),
                  ),
                ),
                Positioned(
                  top: 30,
                  left: -30,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.03),
                    ),
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Image.asset(
                                'assets/images/logosummitgo.png',
                                height: 35,
                                errorBuilder: (context, e, s) => const Icon(
                                  Icons.landscape,
                                  color: Colors.white,
                                ),
                              ),
                              const Text(
                                "Riwayat Tiket",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(width: 40),
                            ],
                          ),
                        ),
                        const SizedBox(height: 25),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 40),
                          child: TabBar(
                            indicatorColor: Colors.white,
                            indicatorWeight: 3,
                            indicatorSize: TabBarIndicatorSize.label,
                            labelColor: Colors.white,
                            labelStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            unselectedLabelColor: Colors.white70,
                            unselectedLabelStyle: TextStyle(
                              fontWeight: FontWeight.normal,
                              fontSize: 14,
                            ),
                            tabs: [
                              Tab(text: "Pemesanan"),
                              Tab(text: "Pendaftaran"),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // 2. FILTER DROPDOWN AKSI (Hanya Urutkan Tanggal yang Tersisa)
            Padding(
              padding: const EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: 10,
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isNewestFirst =
                            !_isNewestFirst; // Toggle urutan tanggal
                        _urutkanData(); // Jalankan penyusunan ulang
                      });
                    },
                    child: filterDropdown(
                      _isNewestFirst ? "Urutan: Terbaru" : "Urutan: Terlama",
                      isDark,
                    ),
                  ),
                ],
              ),
            ),

            // 3. TAB CONTENT VIEWS
            Expanded(
              child: TabBarView(
                children: [
                  buildListView(pemesananData, isDark, isPemesananTab: true),
                  buildListView(pendaftaranData, isDark, isPemesananTab: false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildListView(List data, bool isDark, {required bool isPemesananTab}) {
    if (isLoading)
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF2F4B7C)),
      );
    if (data.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.confirmation_number_outlined,
              size: 60,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 10),
            Text(
              "Belum ada riwayat transaksi.",
              style: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      itemCount: data.length,
      itemBuilder: (context, index) {
        final currentBooking = data[index];
        final String currentStatus = currentBooking['status'] ?? 'pending';

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 10),
              title: Text(
                isPemesananTab
                    ? "${currentBooking['basecamp']}"
                    : "Pengajuan Admin Gunung",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: isDark ? Colors.white : const Color(0xFF2F4B7C),
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 6),
                  Text(
                    "Order ID: #${currentBooking['id']}",
                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 12,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "${currentBooking['date']}",
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.grey[400] : Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  if (isPemesananTab)
                    Text(
                      "Rp ${currentBooking['total_price']}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.teal,
                      ),
                    )
                  else
                    Text(
                      "Role: ${currentBooking['type']}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Colors.blue,
                      ),
                    ),
                  const SizedBox(height: 8),

                  // TOMBOL BARU: LIHAT DETAIL E-TIKET
                  if (isPemesananTab)
                    TextButton.icon(
                      onPressed: () =>
                          _tampilkanDetailTiket(currentBooking, isDark),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(50, 30),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      icon: const Icon(
                        Icons.receipt_long_rounded,
                        size: 14,
                        color: Color(0xFF2F4B7C),
                      ),
                      label: const Text(
                        "Lihat Detail",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2F4B7C),
                        ),
                      ),
                    ),
                ],
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(currentStatus).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      currentStatus.toUpperCase(),
                      style: TextStyle(
                        color: _getStatusColor(currentStatus),
                        fontWeight: FontWeight.bold,
                        fontSize: 9,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                  if (isPemesananTab &&
                      currentStatus.toLowerCase() == 'pending') ...[
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () => cancelBooking(currentBooking['id']),
                      child: const Text(
                        "Batalkan",
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget filterDropdown(String hint, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : const Color(0xFFF2F2F7),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            hint,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.grey[400] : Colors.grey[700],
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            Icons
                .swap_vert_rounded, // Mengganti icon agar merepresentasikan sorting atas-bawah
            size: 16,
            color: isDark ? Colors.grey[500] : Colors.grey[600],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'success':
      case 'confirmed':
      case 'approved':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
