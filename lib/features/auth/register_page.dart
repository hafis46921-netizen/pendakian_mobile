import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../../api_config.dart';
import 'dart:async';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController namaController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  
  bool isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Menampilkan Pop-up Dialog Adaptif
  void _showResultDialog(String title, String message, {bool isSuccess = false}) {
    showDialog(
      context: context,
      barrierDismissible: false, 
      builder: (BuildContext context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text(
            title, 
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          content: Text(
            message,
            style: TextStyle(color: isDark ? Colors.grey[300] : Colors.black),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Tutup dialog
                if (isSuccess) {
                  Navigator.pop(context); // Kembali ke Login jika registrasi berhasil
                }
              },
              child: Text(
                "OK", 
                style: TextStyle(
                  color: isDark ? const Color(0xFF6A93D4) : const Color(0xFF2F4B7C),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> handleRegister() async {
    if (passwordController.text != confirmPasswordController.text) {
      _showResultDialog("Password Tidak Cocok", "Konfirmasi password harus sama dengan password.");
      return;
    }

    if (namaController.text.isEmpty || emailController.text.isEmpty || passwordController.text.isEmpty) {
      _showResultDialog("Field Kosong", "Semua field wajib diisi sebelum mendaftar.");
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      print("Mengirim request registrasi ke: ${ApiConfig.baseUrl}/register");

      final response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/register"),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json', // Ditambahkan agar Laravel tahu ini JSON
        },
        body: jsonEncode({ // Membungkus data menggunakan jsonEncode
          "name": namaController.text.trim(),
          "email": emailController.text.trim(),
          "password": passwordController.text,
          "password_confirmation": confirmPasswordController.text,
        }),
      ).timeout(const Duration(seconds: 10));

      print("======= STATUS CODE REGISTER: ${response.statusCode} =======");
      print("======= RESPONSE BODY: ${response.body} =======");

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        if (!mounted) return;
        _showResultDialog(
          "Registrasi Berhasil", 
          "Akun SummitGo kamu sudah aktif. Silakan login.", 
          isSuccess: true
        );
      } else {
        if (!mounted) return;
        // Menampilkan pesan error spesifik dari Laravel jika ada (misal email sudah terdaftar)
        String errorMessage = data['message'] ?? "Terjadi kesalahan sistem.";
        if (data['errors'] != null) {
          errorMessage = data['errors'].toString();
        }
        _showResultDialog("Registrasi Gagal", errorMessage);
      }
    } on TimeoutException catch (_) {
      if (!mounted) return;
      _showResultDialog("Waktu Tunggu Habis", "Koneksi ke server timeout. Cek jaringan kamu.");
    } catch (e) {
      if (!mounted) return;
      print("Error detail pada handleRegister: $e");
      _showResultDialog("Masalah Koneksi", "Tidak dapat terhubung ke server. Pastikan IP backend benar.");
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
    // Deteksi status mode gelap sistem
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // Latar belakang atas mengikuti warna khas SummitGo (Menyesuaikan saat dark mode)
      backgroundColor: isDark ? const Color(0xFF1E3253) : const Color(0xFF2F4B7C),
      body: Column(
        children: [
          // Header Logo
          SizedBox(
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
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    buildLabel("Nama", isDark),
                    TextField(
                      controller: namaController,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                      decoration: inputStyle("Masukkan Nama", isDark),
                    ),
                    const SizedBox(height: 15),
                    
                    buildLabel("Email", isDark),
                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                      decoration: inputStyle("Masukkan Email", isDark),
                    ),
                    const SizedBox(height: 15),
                    
                    buildLabel("Password", isDark),
                    TextField(
                      controller: passwordController,
                      obscureText: _obscurePassword,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                      decoration: inputStyle(
                        "Masukkan Password",
                        isDark,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off : Icons.visibility,
                            color: isDark ? Colors.grey[400] : Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    
                    buildLabel("Konfirmasi Password", isDark),
                    TextField(
                      controller: confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                      decoration: inputStyle(
                        "Ulangi Password",
                        isDark,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                            color: isDark ? Colors.grey[400] : Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword = !_obscureConfirmPassword;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),

                    // Tombol Sign Up
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark ? const Color(0xFF3A5A98) : const Color(0xFF2F4B7C),
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
                          : const Text(
                              "Sign Up", 
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Link Kembali ke Login
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Sudah punya akun? ",
                          style: TextStyle(color: isDark ? Colors.grey[300] : Colors.black87),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Text(
                            "Log In",
                            style: TextStyle(
                              color: isDark ? const Color(0xFF6A93D4) : Colors.blue,
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

  // Widget Label Adaptif
  Widget buildLabel(String text, bool isDark) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Text(
          text, 
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.grey[300] : Colors.black87,
          ),
        ),
      ),
    );
  }

  // Input Style Adaptif
  InputDecoration inputStyle(String hint, bool isDark, {Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(fontSize: 12, color: isDark ? Colors.grey[500] : Colors.grey),
      filled: true,
      // Berubah jadi abu-abu arang arsitektural saat dark mode
      fillColor: isDark ? Colors.grey[850] : Colors.white,
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}