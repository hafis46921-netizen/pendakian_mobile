import 'package:flutter/material.dart';

class SyaratKetentuanAdminPage extends StatefulWidget {
  final Map<String, String> registrationData;

  const SyaratKetentuanAdminPage({super.key, required this.registrationData});

  @override
  State<SyaratKetentuanAdminPage> createState() => _SyaratKetentuanAdminPageState();
}

class _SyaratKetentuanAdminPageState extends State<SyaratKetentuanAdminPage> {
  bool _isAgreed = false; // Status checkbox

  // Fungsi memunculkan pop-up dialog sukses (FIX: Adaptif Mode Gelap)
  void _showSuccessDialog(bool isDark) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).cardColor, // FIX: Mengikuti tema background dialog global
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Registrasi anda sudah berhasil tunggu Admin menyetujuinya",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    // FIX: Warna teks dialog tidak tenggelam saat mode gelap
                    color: isDark ? Colors.white : const Color(0xFF2F4B7C),
                  ),
                ),
                const SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? const Color(0xFF3A5A98) : const Color(0xFF2F4B7C),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {
                      Navigator.pop(context); // Tutup dialog
                      Navigator.pop(context); // Kembali dari halaman S&K
                      Navigator.pop(context); // Kembali ke halaman utama/login
                    },
                    child: const Text("Selanjutnya", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Deteksi apakah sedang dalam mode gelap
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // FIX: Menghapus Colors.white kaku agar background mengikuti sistem global
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          // FIX: Tombol back otomatis putih di mode gelap, hitam di mode terang
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(
              "Undang Undang Perusahaan",
              style: TextStyle(
                fontWeight: FontWeight.bold, 
                fontSize: 16, 
                color: isDark ? Colors.grey[300] : const Color(0xFF2F4B7C), // FIX: Teks judul adaptif
              ),
            ),
            const SizedBox(height: 15),

            // Box Aturan dengan Scroll View Internal
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  // FIX: Latar belakang box teks hukum menggunakan warna permukaan yang gelap saat malam
                  color: isDark ? Colors.grey[900] : Colors.grey[100],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    "Lorem ipsum dolor sit amet, consectetur adipiscing elit. " * 30,
                    // FIX: Kontras warna teks paragraf disesuaikan dengan latar belakangnya
                    style: TextStyle(
                      fontSize: 12, 
                      color: isDark ? Colors.grey[400] : Colors.grey[700], 
                      height: 1.5,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),

            // Checkbox Persetujuan Hijau sesuai Mockup Gambar Kedua
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                // FIX: Modifikasi opasitas warna hijau agar lebih nyaman dipandang saat mode gelap
                color: Colors.green.withOpacity(isDark ? 0.15 : 0.1),
                border: Border.all(color: Colors.green.withOpacity(isDark ? 0.6 : 0.5)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Theme(
                    // FIX: unselectedWidgetColor diubah dengan cara modern yang mendukung dark mode
                    data: Theme.of(context).copyWith(
                      checkboxTheme: CheckboxThemeData(
                        side: BorderSide(color: isDark ? Colors.green[400]! : Colors.green),
                      ),
                    ),
                    child: Checkbox(
                      value: _isAgreed,
                      activeColor: Colors.green,
                      checkColor: Colors.white,
                      onChanged: (value) {
                        setState(() {
                          _isAgreed = value ?? false;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: Text(
                      "Saya menyetujui seluruh syarat dan ketentuan undang-undang yang berlaku di perusahaan ini.",
                      // FIX: Menghapus Colors.black87 kaku agar teks deskripsi tidak hilang di mode gelap
                      style: TextStyle(
                        fontSize: 11, 
                        color: isDark ? Colors.grey[300] : Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Tombol Selanjutnya / Submit
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  // FIX: Warna tombol dinamis (biru hidup di mode gelap, biru tua di mode terang)
                  backgroundColor: isDark ? const Color(0xFF3A5A98) : const Color(0xFF2F4B7C),
                  disabledBackgroundColor: isDark ? Colors.grey[800] : Colors.grey[300], // Warna pas tombol mati
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                // Tombol hanya aktif jika checkbox dicentang
                onPressed: _isAgreed ? () => _showSuccessDialog(isDark) : null, 
                child: Text(
                  "Selanjutnya", 
                  style: TextStyle(
                    color: _isAgreed ? Colors.white : (isDark ? Colors.grey[600] : Colors.grey[500]),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}