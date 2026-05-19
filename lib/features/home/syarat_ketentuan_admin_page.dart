import 'package:flutter/material.dart';

class SyaratKetentuanAdminPage extends StatefulWidget {
  final Map<String, String> registrationData;

  const SyaratKetentuanAdminPage({super.key, required this.registrationData});

  @override
  State<SyaratKetentuanAdminPage> createState() => _SyaratKetentuanAdminPageState();
}

class _SyaratKetentuanAdminPageState extends State<SyaratKetentuanAdminPage> {
  bool _isAgreed = false; // Status checkbox

  // Fungsi memunculkan pop-up dialog sukses sesuai mockup sebelah kanan
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Registrasi anda sudah berhasil tunggu Admin menyetujuinya",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF2F4B7C),
                  ),
                ),
                const SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2F4B7C),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {
                      Navigator.pop(context); // Tutup dialog
                      Navigator.pop(context); // Kembali dari halaman S&K
                      Navigator.pop(context); // Kembali ke halaman utama/login
                    },
                    child: const Text("Selanjutnya", style: TextStyle(color: Colors.white)),
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text(
              "Undang Undang Perusahaan",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF2F4B7C)),
            ),
            const SizedBox(height: 15),

            // Box Aturan dengan Scroll View Internal (Diperbaiki dari gambar ketigamu)
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    "Lorem ipsum dolor sit amet, consectetur adipiscing elit. " * 30, // Mengulang teks agar panjang
                    style: TextStyle(fontSize: 12, color: Colors.grey[700], height: 1.5),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),

            // Checkbox Persetujuan Hijau sesuai Mockup Gambar Kedua
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                border: Border.all(color: Colors.green.withOpacity(0.5)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Theme(
                    data: ThemeData(unselectedWidgetColor: Colors.green),
                    child: Checkbox(
                      value: _isAgreed,
                      activeColor: Colors.green,
                      onChanged: (value) {
                        setState(() {
                          _isAgreed = value ?? false;
                        });
                      },
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      "Saya menyetujui seluruh syarat dan ketentuan undang-undang yang berlaku di perusahaan ini.",
                      style: TextStyle(fontSize: 11, color: Colors.black87),
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
                  backgroundColor: const Color(0xFF2F4B7C),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                // Tombol hanya aktif jika checkbox dicentang
                onPressed: _isAgreed ? _showSuccessDialog : null, 
                child: const Text("Selanjutnya", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}