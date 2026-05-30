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

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  // Fungsi pengecekan status login terpusat
  Future<void> checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token != null) {
      setState(() {
        isLoggedIn = true;
      });
      fetchHistory(); // Jalankan pengambilan data secara terpadu ke Laravel
    } else {
      setState(() {
        isLoggedIn = false;
        isLoading = false;
      });
    }
  }

  // AMBIL DATA RIWAYAT DARI LARAVEL (Sinkron dengan BookingController)
  Future<void> fetchHistory() async {
    setState(() => isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      // 1. Ambil data untuk Tab Pemesanan (Semua riwayat booking milik user yang login)
      final resPemesanan = await http
          .get(
            Uri.parse(
              "${ApiConfig.baseUrl}/user/bookings",
            ), // Diubah agar sesuai route auth user kelompokmu
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 5));

      // 2. Ambil data untuk Tab Pendaftaran (Hanya riwayat pendakian yang selesai/confirmed)
      final resPendaftaran = await http
          .get(
            Uri.parse(
              "${ApiConfig.baseUrl}/user/bookings/history",
            ), // Menyasar rute history confirmed/completed
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 5));

      if (resPemesanan.statusCode == 200) {
        final Map<String, dynamic> bodyPemesanan = json.decode(
          resPemesanan.body,
        );

        // Membaca array dari pagination bawaan Laravel: data -> data
        final List rawPemesanan = bodyPemesanan['data']['data'] ?? [];

        List rawPendaftaran = [];
        if (resPendaftaran.statusCode == 200) {
          final Map<String, dynamic> bodyPendaftaran = json.decode(
            resPendaftaran.body,
          );
          rawPendaftaran = bodyPendaftaran['data']['data'] ?? [];
        }

        setState(() {
          pemesananData = rawPemesanan.map((item) {
            // 🛠️ Pengecekan multi-key: Memeriksa 'total_price', 'harga', atau 'harga_total'
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
              'total_price': parsedPrice, // Nilai harga asli database kamu
              'basecamp': item['basecamp'] != null
                  ? item['basecamp']['nama']
                  : 'Basecamp',
            };
          }).toList();

          pendaftaranData = rawPendaftaran.map((item) {
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
            };
          }).toList();

          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint("Error fetchHistory: $e");
    }
  }

  // FUNGSI AKSI: MEMBATALKAN BOOKING KE BACKEND LARAVEL
  // FUNGSI AKSI: MEMBATALKAN BOOKING KE BACKEND LARAVEL
  Future<void> cancelBooking(int bookingId) async {
    // Tampilkan konfirmasi dialog sebelum menghapus/membatalkan
    bool konfirmasi =
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
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
                  style: TextStyle(color: Colors.red),
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

      // 🛠️ PERBAIKAN UTAMA: Mengubah http.post menjadi http.patch sesuai instruksi Laravel
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
        fetchHistory(); // Refresh data agar statusnya berubah jadi 'cancelled'
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
                  color: isDark ? Colors.grey[600] : Colors.grey,
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
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(160),
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xFF2F4B7C),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Image.asset(
                          'assets/images/logosummitgo.png',
                          height: 40,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                                Icons.landscape,
                                color: Colors.white,
                                size: 30,
                              ),
                        ),
                        const Text(
                          "Riwayat",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 40),
                      ],
                    ),
                  ),
                  const TabBar(
                    indicatorColor: Colors.yellow,
                    indicatorWeight: 3,
                    labelColor: Colors.yellow,
                    unselectedLabelColor: Colors.white,
                    tabs: [
                      Tab(text: "Pemesanan"),
                      Tab(text: "Pendaftaran"),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        body: Column(
          children: [
            // Filter bar
            Padding(
              padding: const EdgeInsets.all(15),
              child: Row(
                children: [
                  filterDropdown("Tanggal", isDark),
                  const SizedBox(width: 10),
                  filterDropdown("Status", isDark),
                ],
              ),
            ),
            // Konten Tab
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

  // Widget List Data dengan dukungkan fungsi Hapus/Cancel otomatis
  Widget buildListView(List data, bool isDark, {required bool isPemesananTab}) {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    if (data.isEmpty) {
      return Center(
        child: Text(
          "Belum ada transaksi.",
          style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[700]),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      itemCount: data.length,
      itemBuilder: (context, index) {
        final currentBooking = data[index];
        final String currentStatus = currentBooking['status'] ?? 'pending';

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          color: Theme.of(context).cardColor,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListTile(
              title: Text(
                "${currentBooking['basecamp']} - Order #${currentBooking['id']}",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    "Tanggal Naik: ${currentBooking['date']}",
                    style: TextStyle(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "Total Biaya: Rp ${currentBooking['total_price']}",
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.teal,
                    ),
                  ),
                ],
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Label Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(currentStatus).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      currentStatus.toUpperCase(),
                      style: TextStyle(
                        color: _getStatusColor(currentStatus),
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  // TOMBOL PEMBATALAN: Hanya muncul di tab Pemesanan jika statusnya masih 'pending'
                  if (isPemesananTab &&
                      currentStatus.toLowerCase() == 'pending')
                    GestureDetector(
                      onTap: () => cancelBooking(currentBooking['id']),
                      child: const Text(
                        "Batalkan",
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
        ),
      ),
      child: Row(
        children: [
          Text(
            hint,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.grey[300] : Colors.black87,
            ),
          ),
          Icon(
            Icons.arrow_drop_down,
            color: isDark ? Colors.grey[400] : Colors.black54,
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
