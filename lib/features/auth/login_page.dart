import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../api_config.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>(); // Menambahkan form key untuk validasi input
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  bool _obscurePassword = true;

  Future<void> handleLogin() async {
    // Memvalidasi Form sebelum mengirim request ke Laravel
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      print("Mengirim request login ke: ${ApiConfig.baseUrl}/login");
      
      final response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/login"),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json', // Diubah ke JSON agar sinkron dengan Laravel terbaru
        },
        body: jsonEncode({ // Menggunakan jsonEncode untuk membungkus data request
          "email": emailController.text.trim(),
          "password": passwordController.text,
        }),
      ).timeout(const Duration(seconds: 10));

      print("======= STATUS CODE LOGIN FROM SERVER: ${response.statusCode} =======");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        
        try {
          SharedPreferences prefs = await SharedPreferences.getInstance();

          // Deteksi token dari pola response Laravel token umum
          String? token = data['token'] ?? data['access_token'];
          if (token != null) {
            await prefs.setString('token', token);
          }

          if (data['user'] != null) {
            await prefs.setString('name', data['user']['name'].toString());
            await prefs.setString('email', data['user']['email'].toString());
          }

          if (data['role'] != null) {
            await prefs.setString('role', data['role'].toString());
          }
        } catch (e) {
          debugPrint("Gagal menyimpan session: $e");
        }

        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/');
      } else {
        if (!mounted) return;
        try {
          final data = jsonDecode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(data['message'] ?? "Login Gagal. Periksa kredensial Anda."),
              backgroundColor: Colors.orange,
            ),
          );
        } catch (_) {
          print("Response error body: ${response.body}");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Server Error (Status: ${response.statusCode}). Hubungi backend developer."),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } on TimeoutException catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Koneksi gagal. Waktu tunggu habis (Timeout)"),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      print("Error detail pada handleLogin: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Tidak dapat terhubung ke server backend"),
          backgroundColor: Colors.red,
        ),
      );
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: const Color(0xFF2F4B7C),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: Form(
                key: _formKey, // Memasang form validator key
                child: Column(
                  children: [
                    // Header Area Logo
                    SizedBox(
                      height: 180,
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
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(25),
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                      ),
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight - 180 > 0 
                            ? constraints.maxHeight - 180 
                            : 400, 
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),
                          Text(
                            "Email", 
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? Colors.grey[300] : Colors.black87),
                          ),
                          const SizedBox(height: 8),
                          TextFormField( // Diubah dari TextField ke TextFormField
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return "Email tidak boleh kosong";
                              }
                              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
                                return "Format email tidak valid";
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              hintText: "Masukkan Email",
                              hintStyle: TextStyle(fontSize: 12, color: isDark ? Colors.grey[500] : Colors.grey),
                              filled: true,
                              fillColor: isDark ? Colors.grey[850] : const Color(0xFFF5F5F5),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            "Password", 
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? Colors.grey[300] : Colors.black87),
                          ),
                          const SizedBox(height: 8),
                          TextFormField( // Diubah dari TextField ke TextFormField
                            controller: passwordController,
                            obscureText: _obscurePassword,
                            style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Password tidak boleh kosong";
                              }
                              if (value.length < 6) {
                                return "Password minimal berkisar 6 karakter";
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              hintText: "Masukkan Password",
                              hintStyle: TextStyle(fontSize: 12, color: isDark ? Colors.grey[500] : Colors.grey),
                              filled: true,
                              fillColor: isDark ? Colors.grey[850] : const Color(0xFFF5F5F5),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              suffixIcon: IconButton(
                                icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: isDark ? Colors.grey[400] : Colors.grey),
                                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              "Lupa Password?",
                              style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF6A93D4) : const Color(0xFF2F4B7C), fontWeight: FontWeight.w600),
                            ),
                          ),
                          const SizedBox(height: 30),

                          // Tombol Login
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isDark ? const Color(0xFF3A5A98) : const Color(0xFF2F4B7C),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: isLoading ? null : handleLogin,
                              child: isLoading
                                  ? const SizedBox(
                                      height: 22,
                                      width: 22,
                                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                                    )
                                  : const Text("Log In", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                            ),
                          ),

                          const SizedBox(height: 25),
                          Center(child: Text("atau login dengan", style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 12))),
                          const SizedBox(height: 10),
                          Center(child: Icon(Icons.g_mobiledata, size: 45, color: isDark ? Colors.white : Colors.black87)),
                          const SizedBox(height: 40),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Belum punya akun? ", style: TextStyle(color: isDark ? Colors.grey[300] : Colors.black87, fontSize: 13)),
                              GestureDetector(
                                onTap: () => Navigator.pushNamed(context, '/register'),
                                child: Text("Sign Up", style: TextStyle(color: isDark ? const Color(0xFF6A93D4) : Colors.blue, fontWeight: FontWeight.bold, fontSize: 13)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}