import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController namaController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  
  bool isLoading = false;

  // --- FUNGSI BARU: MENAMPILKAN POP-UP ---
  void _showResultDialog(String title, String message, {bool isSuccess = false}) {
    showDialog(
      context: context,
      barrierDismissible: false, 
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Tutup dialog
                if (isSuccess) {
                  Navigator.pop(context); // Kembali ke Login jika registrasi berhasil
                }
              },
              child: const Text("OK", style: TextStyle(color: Color(0xFF2F4B7C))),
            ),
          ],
        );
      },
    );
  }

  Future<void> handleRegister() async {
    // 1. Validasi Password
    if (passwordController.text != confirmPasswordController.text) {
      _showResultDialog("Password Tidak Cocok", "Konfirmasi password harus sama dengan password.");
      return;
    }

    // 2. Validasi Input Kosong
    if (namaController.text.isEmpty || emailController.text.isEmpty || passwordController.text.isEmpty) {
      _showResultDialog("Field Kosong", "Semua field wajib diisi sebelum mendaftar.");
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse("http://192.168.100.6:8000/api/register"),
        headers: {
          'Accept': 'application/json',
        },
        body: {
          "name": namaController.text,
          "email": emailController.text,
          "password": passwordController.text,
          "password_confirmation": confirmPasswordController.text,
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        // Berhasil Register
        if (!mounted) return;
        _showResultDialog(
          "Registrasi Berhasil", 
          "Akun SummitGo kamu sudah aktif. Silakan login.", 
          isSuccess: true
        );
      } else {
        // Gagal (Pesan dari Laravel: "Email sudah digunakan", dll)
        if (!mounted) return;
        _showResultDialog("Registrasi Gagal", data['message'] ?? "Terjadi kesalahan sistem.");
      }
    } catch (e) {
      if (!mounted) return;
      _showResultDialog("Masalah Koneksi", "Tidak dapat terhubung ke server Laravel. Cek koneksi Wi-Fi atau IP laptop.");
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2F4B7C),
      body: Column(
        children: [
          // Header Logo
          Container(
            height: 200,
            width: double.infinity,
            child: Center(
              child: Image.asset(
                'assets/images/logosummitgo.png',
                height: 80,
                errorBuilder: (context, error, stackTrace) => 
                  const Icon(Icons.terrain, size: 80, color: Colors.white),
              ),
            ),
          ),

          // Form Area
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    buildLabel("Nama"),
                    TextField(
                      controller: namaController,
                      decoration: inputStyle("Masukkan Nama"),
                    ),
                    const SizedBox(height: 15),
                    
                    buildLabel("Email"),
                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: inputStyle("Masukkan Email"),
                    ),
                    const SizedBox(height: 15),
                    
                    buildLabel("Password"),
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: inputStyle("Masukkan Password"),
                    ),
                    const SizedBox(height: 15),
                    
                    buildLabel("Konfirmasi Password"),
                    TextField(
                      controller: confirmPasswordController,
                      obscureText: true,
                      decoration: inputStyle("Ulangi Password"),
                    ),
                    const SizedBox(height: 25),

                    // Tombol Sign Up
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2F4B7C),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: isLoading ? null : handleRegister,
                        child: isLoading 
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Text("Sign Up", style: TextStyle(color: Colors.white)),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Link Kembali ke Login
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Sudah punya akun? "),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Text(
                            "Log In",
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Text(text, style: const TextStyle(fontSize: 12)),
      ),
    );
  }

  InputDecoration inputStyle(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}