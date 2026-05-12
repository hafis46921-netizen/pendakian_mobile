import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../profil/edit_profile_page.dart'; // Pastikan path import ini benar sesuai folder kamu

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String name = "";
  String email = "";
  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    getUser();
  }

  // Fungsi untuk ambil data dari SharedPreferences
  Future getUser() async {
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

  @override
  Widget build(BuildContext context) {
    // Tampilan jika belum login
    if (!isLoggedIn) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline, size: 100, color: Colors.grey),
              const SizedBox(height: 16),
              const Text("Kamu belum login", 
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Text("Silakan login untuk melihat Profil"),
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

    // Tampilan jika sudah login
    return Scaffold(
      backgroundColor: const Color(0xFFF1F2F6),
      body: Column(
        children: [
          // Header Biru
          Container(
            height: 170,
            width: double.infinity,
            decoration: const BoxDecoration(color: Color(0xFF2F4B7C)),
            child: Stack(
              clipBehavior: Clip.none, // Agar card profil bisa agak keluar
              children: [
                Positioned(
                  top: 40,
                  left: 20,
                  child: Image.asset('assets/images/logosummitgo.png', height: 45),
                ),
                const Positioned(
                  top: 45,
                  left: 120,
                  child: Text("Profile", 
                    style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                ),
                // Card Nama & Email
                Positioned(
                  bottom: -15, // Dibuat melayang sedikit
                  left: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
                      ],
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: Colors.grey[300],
                          child: Icon(Icons.person, size: 35, color: Colors.grey[700]),
                        ),
                        const SizedBox(width: 15),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 4),
                            Text(email, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 35),

          // Menu List
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Pengaturan akun", 
                    style: TextStyle(color: Color(0xFF2F4B7C), fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  
                  // MENU UBAH PROFIL
                  menuItem("Ubah Profil", onTap: () async {
                    // Berpindah ke halaman edit
                    final bool? isUpdated = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const EditProfilePage()),
                    );
                    
                    // Jika kembali dan ada status updated=true, refresh data
                    if (isUpdated == true) {
                      getUser();
                    }
                  }),
                  
                  menuItem("Kata Sandi", onTap: () {}),
                  menuItem("Riwayat Pendakian", onTap: () {}),

                  const SizedBox(height: 25),

                  const Text("Seputar Aplikasi", 
                    style: TextStyle(color: Color(0xFF2F4B7C), fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  menuItem("Tentang Aplikasi", onTap: () {}),
                  menuItem("Kebijakan Privasi", onTap: () {}),
                  menuItem("Syarat dan Ketentuan", onTap: () {}),
                  menuItem("Tema", onTap: () {}),

                  const SizedBox(height: 20),

                  // Tombol Logout
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () async {
                        SharedPreferences prefs = await SharedPreferences.getInstance();
                        await prefs.clear();
                        if (!mounted) return;
                        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                      },
                      child: const Text("Logout", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // WIDGET HELPER MENU ITEM (DIPERBAIKI)
  Widget menuItem(String title, {VoidCallback? onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10), // Sedikit rounded agar cantik
      ),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontSize: 14)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
        onTap: onTap, // Sekarang bisa diklik
      ),
    );
  }
}