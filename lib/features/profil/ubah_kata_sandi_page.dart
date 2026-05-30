// lib/features/profile/ubah_kata_sandi_page.dart
import 'package:flutter/material.dart';

class UbahKataSandiPage extends StatefulWidget {
  const UbahKataSandiPage({super.key});

  @override
  State<UbahKataSandiPage> createState() => _UbahKataSandiPageState();
}

class _UbahKataSandiPageState extends State<UbahKataSandiPage> {
  final _sandiLamaController = TextEditingController();
  final _sandiBaruController = TextEditingController();
  final _konfirmasiSandiController = TextEditingController();

  // Status state untuk menyembunyikan/memperlihatkan password (fitur opsional tapi krusial untuk UX)
  bool _obscureLama = true;
  bool _obscureBaru = true;
  bool _obscureKonfirmasi = true;

  @override
  void dispose() {
    _sandiLamaController.dispose();
    _sandiBaruController.dispose();
    _konfirmasiSandiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Deteksi status mode gelap global
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Ubah Kata Sandi", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        // FIX: Supaya warna AppBar sinkron saat dark mode (tidak kaku biru tua)
        backgroundColor: isDark ? Theme.of(context).cardColor : const Color(0xFF2F4B7C),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
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
            children: [
              _buildPasswordField(
                "Kata Sandi Lama", 
                _sandiLamaController, 
                _obscureLama, 
                isDark,
                () => setState(() => _obscureLama = !_obscureLama),
              ),
              _buildPasswordField(
                "Kata Sandi Baru", 
                _sandiBaruController, 
                _obscureBaru, 
                isDark,
                () => setState(() => _obscureBaru = !_obscureBaru),
              ),
              _buildPasswordField(
                "Konfirmasi Kata Sandi Baru", 
                _konfirmasiSandiController, 
                _obscureKonfirmasi, 
                isDark,
                () => setState(() => _obscureKonfirmasi = !_obscureKonfirmasi),
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    // FIX: Warna tombol menjadi biru dinamis/lebih terang sedikit saat mode gelap
                    backgroundColor: isDark ? const Color(0xFF3A5A98) : const Color(0xFF2F4B7C),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    // Integrasi API update password di sini
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Kata sandi berhasil diperbarui!")),
                    );
                    Navigator.pop(context);
                  },
                  child: const Text("Simpan Perubahan", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // FIX: Parameter ditambahkan agar mendukung toggle mata (visibility) dan adaptasi warna gelap
  Widget _buildPasswordField(
    String label, 
    TextEditingController controller, 
    bool obscureText, 
    bool isDark,
    VoidCallback onToggleVisibility,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label, 
            style: TextStyle(
              fontWeight: FontWeight.bold, 
              // FIX: Warna label teks adaptif agar kontras di latar belakang gelap
              color: isDark ? Colors.grey[300] : const Color(0xFF2F4B7C), 
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            obscureText: obscureText,
            // FIX: Gaya warna teks input disesuaikan agar tidak tabrakan warna
            style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 14),
            decoration: InputDecoration(
              hintText: "••••••••",
              hintStyle: TextStyle(color: isDark ? Colors.grey[600] : Colors.grey[400]),
              filled: true,
              // FIX: Jika gelap pakai abu-abu sangat tua, jika terang pakai abu-abu sangat muda
              fillColor: isDark ? Colors.grey[850] : const Color(0xFFF1F2F6),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
              // Tambahan UX: Ikon mata untuk mempermudah user melihat sandi yang diketik
              suffixIcon: IconButton(
                icon: Icon(
                  obscureText ? Icons.visibility_off : Icons.visibility,
                  color: isDark ? Colors.grey[500] : Colors.grey[600],
                  size: 20,
                ),
                onPressed: onToggleVisibility,
              ),
            ),
          ),
        ],
      ),
    );
  }
}