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

  // Fungsi cek login dari SharedPreferences
  Future<void> checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    
    if (token != null) {
      setState(() {
        isLoggedIn = true;
      });
      fetchData();
    } else {
      setState(() {
        isLoggedIn = false;
        isLoading = false;
      });
    }
  }

  // Ambil data dari Laravel
  Future<void> fetchData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    try {
      final response = await http.get(
        Uri.parse("${ApiConfig.baseUrl}/history"),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          pemesananData = data['pemesanan'] ?? [];
          pendaftaranData = data['pendaftaran'] ?? [];
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
      print("Error fetch: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // Tampilan jika BELUM LOGIN
    if (!isLoggedIn) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline, size: 100, color: Colors.grey),
              const SizedBox(height: 16),
              const Text("Kamu belum login", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Text("Silakan login untuk melihat riwayat transaksi."),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/login'),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2F4B7C)),
                child: const Text("Login Sekarang", style: TextStyle(color: Colors.white)),
              )
            ],
          ),
        ),
      );
    }

    // Tampilan UTAMA (Sudah Login)
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
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
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Image.asset('assets/images/logosummitgo.png', height: 40),
                        const Text("Riwayat", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 40), // Spacer agar teks tengah
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
            // Filter bar (Tanggal & Status)
            Padding(
              padding: const EdgeInsets.all(15),
              child: Row(
                children: [
                  filterDropdown("Tanggal"),
                  const SizedBox(width: 10),
                  filterDropdown("Status"),
                ],
              ),
            ),
            // Isi Konten
            Expanded(
              child: TabBarView(
                children: [
                  buildListView(pemesananData),
                  buildListView(pendaftaranData),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget List Data
  Widget buildListView(List data) {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    if (data.isEmpty) return const Center(child: Text("Belum ada transaksi."));

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      itemCount: data.length,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            title: Text("Order #${data[index]['id']}"),
            subtitle: Text("Tanggal: ${data[index]['date']}"),
            trailing: Text(data[index]['status'], style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
          ),
        );
      },
    );
  }

  // Widget Filter Dropdown
  Widget filterDropdown(String hint) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Text(hint, style: const TextStyle(fontSize: 12)),
          const Icon(Icons.arrow_drop_down),
        ],
      ),
    );
  }
}