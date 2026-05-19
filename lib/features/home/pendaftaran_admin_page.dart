import 'package:flutter/material.dart';
import 'syarat_ketentuan_admin_page.dart'; // Import halaman kedua

class PendaftaranAdminGunungPage extends StatefulWidget {
  const PendaftaranAdminGunungPage({super.key});

  @override
  State<PendaftaranAdminGunungPage> createState() => _PendaftaranAdminGunungPageState();
}

class _PendaftaranAdminGunungPageState extends State<PendaftaranAdminGunungPage> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _namaLengkapController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Image dengan Tombol Back (Stack)
            Stack(
              children: [
                Container(
                  height: 220,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/puncak_ciremai.jpg'), // Sesuaikan asset lokalmu
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Container(
                  height: 220,
                  width: double.infinity,
                  color: Colors.black.withOpacity(0.2),
                ),
                Positioned(
                  top: 40,
                  left: 15,
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        "Pendaftaran",
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Form Area
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildField("Username", _usernameController, "Masukkan Username"),
                    _buildField("Email", _emailController, "Masukkan Email", keyboardType: TextInputType.emailAddress),
                    _buildField("Password", _passwordController, "Masukkan Password", obscureText: true),
                    _buildField("Konfirmasi Password", _confirmPasswordController, "Ulangi Password", obscureText: true),
                    _buildField("Nama Lengkap", _namaLengkapController, "Masukkan Nama Lengkap"),
                    
                    const SizedBox(height: 20),
                    
                    // Tombol Selanjutnya
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2F4B7C),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          // Validasi sederhana sebelum lanjut
                          if (_usernameController.text.isEmpty || _emailController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Semua field wajib diisi!")),
                            );
                            return;
                          }
                          
                          // Kirim data inputan ke halaman Syarat & Ketentuan
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SyaratKetentuanAdminPage(
                                registrationData: {
                                  "username": _usernameController.text,
                                  "email": _emailController.text,
                                  "password": _passwordController.text,
                                  "name": _namaLengkapController.text,
                                },
                              ),
                            ),
                          );
                        },
                        child: const Text("Selanjutnya", style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, String hint, {bool obscureText = false, TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2F4B7C), fontSize: 13)),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: hint,
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}