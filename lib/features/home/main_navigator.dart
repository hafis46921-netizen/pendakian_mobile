import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; // Ditambahkan untuk komponen UI khas iPhone
import 'package:shared_preferences/shared_preferences.dart';
import 'home_page.dart';
import 'history_page.dart';
import 'profil_page.dart';
import 'pendaftaran_admin_page.dart'; 
import '../auth/login_page.dart'; 

class MainNavigation extends StatefulWidget {
  final int initialIndex;

  const MainNavigation({
    super.key,
    this.initialIndex = 0,
  });

  @override
  _MainNavigationState createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  final List<Widget> _pages = [
    HomePage(),
    HistoryPage(),
    PendaftaranAdminGunungPage(), 
    ProfilePage(),          
  ];

  // Fungsi navigasi dengan pengecekan token login bawaan kamu
  void _onItemTapped(int index) async {
    if (index == 1 || index == 2 || index == 3) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token == null || token.isEmpty) {
        if (!mounted) return;
        Navigator.push(
          context,
          CupertinoPageRoute(builder: (context) => const LoginPage()), // Diubah ke CupertinoPageRoute agar animasi slide transisi halaman khas iOS
        );
        return; 
      }
    }

    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Skema warna dekoratif transparan (Frosted Glass) khas iOS
    final backgroundColor = isDark 
        ? const Color(0xCC1A1A1A) // Hitam transparan saat dark mode
        : const Color(0xFCEFEEF6); // Abu-abu terang bersih transparan khas iOS Light Mode

    final activeColor = isDark 
        ? const Color(0xFF6A93D4) 
        : const Color(0xFF2F4B7C); // Warna biru khas SummitGo

    return Scaffold(
      // Mengizinkan konten halaman ditarik ke bawah melampaui batas TabBar (efek tembus pandang blur)
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: ClipRect(
        // Efek Blur kaca di atas konten scrollable
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
          child: Container(
            decoration: BoxDecoration(
              color: backgroundColor,
              border: Border(
                top: BorderSide(
                  color: isDark ? Colors.white10 : const Color(0x4D000000), // Garis pemisah tipis khas iPhone
                  width: 0.3,
                ),
              ),
            ),
            child: SafeArea(
              top: false, 
              child: CupertinoTabBar(
                currentIndex: _currentIndex, // Tetap pertahankan yang ini
                onTap: _onItemTapped,
                backgroundColor: Colors.transparent, 
                activeColor: activeColor,
                inactiveColor: isDark ? Colors.grey[500]! : const Color(0xFF8E8E93), 
                iconSize: 24,
                // BARIS YANG DUPLIKAT DI SINI SUDAH DIHAPUS
                items: [
                  BottomNavigationBarItem(
                    icon: const Icon(CupertinoIcons.house), 
                    activeIcon: const Icon(CupertinoIcons.house_fill), 
                    label: "Beranda",
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(CupertinoIcons.ticket),
                    activeIcon: const Icon(CupertinoIcons.ticket_fill),
                    label: "Transaksi",
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(CupertinoIcons.person_badge_plus),
                    activeIcon: const Icon(CupertinoIcons.person_badge_plus_fill),
                    label: "Admin",
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(CupertinoIcons.person_circle),
                    activeIcon: const Icon(CupertinoIcons.person_circle_fill),
                    label: "Profil",
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}