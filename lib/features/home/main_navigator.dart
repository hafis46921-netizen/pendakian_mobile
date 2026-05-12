import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_page.dart';
import 'history_page.dart';
import 'profil_page.dart';
import 'pendaftaran_admin_page.dart'; // Import halaman pendaftaran yang baru dibuat
import '../auth/login_page.dart'; // Import halaman login kamu

class MainNavigation extends StatefulWidget {
  @override
  _MainNavigationState createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  // Daftar halaman diperbarui menjadi 4 halaman
  final List<Widget> _pages = [
    HomePage(),
    HistoryPage(),
    PendaftaranAdminPage(), // Halaman baru di index 2
    ProfilePage(),          // Profile geser ke index 3
  ];

  // Fungsi navigasi dengan pengecekan login
  void _onItemTapped(int index) async {
    // Jika user menekan Transaksi (1), Daftar Admin (2), atau Profil (3)
    if (index == 1 || index == 2 || index == 3) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      // Cek apakah token ada
      if (token == null || token.isEmpty) {
        if (!mounted) return;
        // Jika tidak ada token, arahkan ke Login
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
        return; // Berhenti di sini, jangan pindah tab
      }
    }

    // Jika sudah login atau memilih Home, baru pindah index
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFF2F4B7C),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped, // Gunakan fungsi pengecekan di sini
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Beranda",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.confirmation_number),
            label: "Transaksi",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_ind), // Ikon pendaftaran/admin
            label: "Admin",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profil",
          ),
        ],
      ),
    );
  }
}