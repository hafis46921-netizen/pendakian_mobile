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
    // Deteksi apakah sedang dalam mode gelap
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // FIX: Menghapus warna F5F5F5 kaku agar mengikuti tema global aplikasi
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                  // FIX: Opasitas overlay sedikit digelapkan di dark mode agar teks header lebih stand out
                  color: Colors.black.withOpacity(isDark ? 0.4 : 0.2),
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
                  // FIX: Menggunakan cardColor agar otomatis berwarna abu-abu gelap saat dark mode
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildField("Username", _usernameController, "Masukkan Username", isDark),
                    _buildField("Email", _emailController, "Masukkan Email", isDark, keyboardType: TextInputType.emailAddress),
                    _buildField("Password", _passwordController, "Masukkan Password", isDark, obscureText: true),
                    _buildField("Konfirmasi Password", _confirmPasswordController, "Ulangi Password", isDark, obscureText: true),
                    _buildField("Nama Lengkap", _namaLengkapController, "Masukkan Nama Lengkap", isDark),
                    
                    const SizedBox(height: 20),
                    
                    // Tombol Selanjutnya
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          // FIX: Menyesuaikan warna tombol utama saat mode gelap
                          backgroundColor: isDark ? const Color(0xFF3A5A98) : const Color(0xFF2F4B7C),
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
                        child: const Text("Selanjutnya", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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

  // FIX: Menambahkan parameter bool isDark agar komponen input field adaptif terhadap warna tema
  Widget _buildField(String label, TextEditingController controller, String hint, bool isDark, {bool obscureText = false, TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // FIX: Warna label dinamis (Putih soft saat gelap, biru tua saat terang)
          Text(
            label, 
            style: TextStyle(
              fontWeight: FontWeight.bold, 
              color: isDark ? Colors.grey[300] : const Color(0xFF2F4B7C), 
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            // FIX: Mengatur style teks input agar warnanya kontras di kedua mode
            style: TextStyle(color: isDark ? Colors.white : Colors.black87),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[400]),
              filled: true,
              // FIX: Mengganti grey[100] dengan warna yang lebih gelap di mode malam agar nyaman di mata
              fillColor: isDark ? Colors.grey[850] : Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ],
      ),
    );
  }
}