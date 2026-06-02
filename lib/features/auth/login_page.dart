import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart'; // 🛠️ IMPORT PACKAGE BARU
import '../../api_config.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  bool _obscurePassword = true;

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId:
        '150860744573-obqkarhhii5fj85q7tmq94i7gg4748gt.apps.googleusercontent.com', // ◄── GANTI DENGAN WEB CLIENT ID KAMU
    scopes: ['email', 'profile'],
  );

  // 🛠️ FUNGSI HANDLER GOOGLE SIGN IN
  Future<void> handleGoogleSignIn() async {
    setState(() {
      isLoading = true;
    });

    try {
      // 1. Memicu dialog pop-up akun Google di HP / Web
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // User membatalkan pemilihan akun Google
        setState(() => isLoading = false);
        return;
      }

      // 2. Mengambil detail autentikasi (ID Token)
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        throw Exception("Gagal mendapatkan ID Token dari Google.");
      }

      print("Mengirim Google ID Token ke Backend Laravel...");

      // 3. Kirim ID Token ke endpoint backend Laravel
      final response = await http
          .post(
            Uri.parse("${ApiConfig.baseUrl}/google-login"),
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({"id_token": idToken}),
          )
          .timeout(const Duration(seconds: 15));

      print("======= STATUS CODE GOOGLE LOGIN: ${response.statusCode} =======");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);

        // 4. Simpan session token autentikasi lokal
        SharedPreferences prefs = await SharedPreferences.getInstance();
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

        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/');
      } else {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? "Gagal autentikasi via backend.");
      }
    } catch (e) {
      print("Error detail Google Sign-In: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Google Sign-In Gagal: ${e.toString().replaceAll('Exception: ', '')}",
          ),
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

  Future<void> handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      print("Mengirim request login ke: ${ApiConfig.baseUrl}/login");

      final response = await http
          .post(
            Uri.parse("${ApiConfig.baseUrl}/login"),
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              "email": emailController.text.trim(),
              "password": passwordController.text,
            }),
          )
          .timeout(const Duration(seconds: 10));

      print(
        "======= STATUS CODE LOGIN FROM SERVER: ${response.statusCode} =======",
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);

        try {
          SharedPreferences prefs = await SharedPreferences.getInstance();
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
              content: Text(
                data['message'] ?? "Login Gagal. Periksa kredensial Anda.",
              ),
              backgroundColor: Colors.orange,
            ),
          );
        } catch (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Server Error (Status: ${response.statusCode}). Hubungi backend developer.",
              ),
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
                key: _formKey,
                child: Column(
                  children: [
                    SizedBox(
                      height: 180,
                      width: double.infinity,
                      child: Center(
                        child: Image.asset(
                          'assets/images/logosummitgo.png',
                          height: 80,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                                Icons.terrain,
                                size: 80,
                                color: Colors.white,
                              ),
                        ),
                      ),
                    ),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(25),
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(30),
                        ),
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
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.grey[300] : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return "Email tidak boleh kosong";
                              }
                              if (!RegExp(
                                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                              ).hasMatch(value.trim())) {
                                return "Format email tidak valid";
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              hintText: "Masukkan Email",
                              hintStyle: TextStyle(
                                fontSize: 12,
                                color: isDark ? Colors.grey[500] : Colors.grey,
                              ),
                              filled: true,
                              fillColor: isDark
                                  ? Colors.grey[850]
                                  : const Color(0xFFF5F5F5),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            "Password",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.grey[300] : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: passwordController,
                            obscureText: _obscurePassword,
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black87,
                            ),
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
                              hintStyle: TextStyle(
                                fontSize: 12,
                                color: isDark ? Colors.grey[500] : Colors.grey,
                              ),
                              filled: true,
                              fillColor: isDark
                                  ? Colors.grey[850]
                                  : const Color(0xFFF5F5F5),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: isDark
                                      ? Colors.grey[400]
                                      : Colors.grey,
                                ),
                                onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          
                          Align(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(context, '/forgot_password');
                              },
                              child: Text(
                                "Lupa Password?",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark
                                      ? const Color(0xFF6A93D4)
                                      : const Color(0xFF2F4B7C),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),

                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isDark
                                    ? const Color(0xFF3A5A98)
                                    : const Color(0xFF2F4B7C),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: isLoading ? null : handleLogin,
                              child: isLoading
                                  ? const SizedBox(
                                      height: 22,
                                      width: 22,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                  : const Text(
                                      "Log In",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                            ),
                          ),

                          const SizedBox(height: 25),
                          Center(
                            child: Text(
                              "atau login dengan",
                              style: TextStyle(
                                color: isDark
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // 🛠️ FIX: TOMBOL GOOGLE PREMIUM BERWARNA-WARNI MENGGUNAKAN NETWORK IMAGE RESMI
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                backgroundColor: isDark ? Colors.grey[900] : Colors.white,
                              ),
                              onPressed: isLoading ? null : handleGoogleSignIn,
                              child: isLoading
                                  ? const SizedBox(
                                      height: 22,
                                      width: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Image.network(
                                          'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/24px-Google_%22G%22_logo.svg.png',
                                          height: 20,
                                          width: 20,
                                          errorBuilder: (context, error, stackTrace) => const Icon(
                                            Icons.g_mobiledata,
                                            size: 24,
                                            color: Colors.blue,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          "Masuk dengan Google",
                                          style: TextStyle(
                                            color: isDark ? Colors.white : Colors.black87,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                          const SizedBox(height: 40),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Belum punya akun? ",
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.grey[300]
                                      : Colors.black87,
                                  fontSize: 13,
                                ),
                              ),
                              GestureDetector(
                                onTap: () =>
                                    Navigator.pushNamed(context, '/register'),
                                child: Text(
                                  "Sign Up",
                                  style: TextStyle(
                                    color: isDark
                                        ? const Color(0xFF6A93D4)
                                        : Colors.blue,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
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