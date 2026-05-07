import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String name = "";
  String email = "";
  bool isLoggedIn = false; // Status login user

  @override
  void initState() {
    super.initState();
    getUser();
  }

  Future getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token'); // Cek token di storage

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
    // Jika belum login, tampilkan layar pengunci
    if (!isLoggedIn) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline, size: 100, color: Colors.grey),
              const SizedBox(height: 16),
              const Text("Kamu belum login", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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

    // Jika sudah login, tampilkan profil seperti biasa
    return Scaffold(
      backgroundColor: Color(0xFFF1F2F6),
      body: Column(
        children: [
          // ... Bagian Header (Stack dengan Foto & Nama) tetap sama ...
          Container(
            height: 170,
            width: double.infinity,
            decoration: BoxDecoration(color: Color(0xFF2F4B7C)),
            child: Stack(
              children: [
                Positioned(
                  top: 40,
                  left: 20,
                  child: Image.asset('assets/images/logosummitgo.png', height: 45),
                ),
                Positioned(
                  top: 45,
                  left: 120,
                  child: Text(
                    "Profile",
                    style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
                Positioned(
                  bottom: -5,
                  left: 20,
                  right: 20,
                  child: Container(
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: Colors.grey[300],
                          child: Icon(Icons.person, size: 35, color: Colors.grey[700]),
                        ),
                        SizedBox(width: 15),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            SizedBox(height: 4),
                            Text(email, style: TextStyle(color: Colors.grey, fontSize: 13)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 20),

          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Pengaturan akun",
                      style: TextStyle(color: Color(0xFF2F4B7C), fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    menuItem("Ubah Profil"),
                    menuItem("Kata Sandi"),
                    menuItem("Riwayat Pendakian"),

                    SizedBox(height: 25),

                    Text(
                      "Seputar Aplikasi",
                      style: TextStyle(color: Color(0xFF2F4B7C), fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    menuItem("Tentang Aplikasi"),
                    menuItem("Kebijakan Privasi"),
                    menuItem("Syarat dan Ketentuan"),
                    menuItem("Tema"),

                    SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () async {
                          SharedPreferences prefs = await SharedPreferences.getInstance();
                          await prefs.clear();
                          Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                        },
                        child: Text("Logout", style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget menuItem(String title) {
    return Container(
      margin: EdgeInsets.only(bottom: 2),
      decoration: BoxDecoration(color: Colors.white),
      child: ListTile(
        title: Text(title, style: TextStyle(fontSize: 14)),
        trailing: Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {},
      ),
    );
  }
}