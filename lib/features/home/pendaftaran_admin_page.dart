import 'package:flutter/material.dart';

class PendaftaranAdminPage extends StatefulWidget {
  const PendaftaranAdminPage({super.key});

  @override
  State<PendaftaranAdminPage> createState() => _PendaftaranAdminPageState();
}

class _PendaftaranAdminPageState extends State<PendaftaranAdminPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isAgreed = false;

  // Fungsi untuk menampilkan Pop-up Sukses
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                const Text(
                  "Registrasi anda sudah berhasil tunggu Admin menyetujuinya",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2F4B7C),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2F4B7C),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {
                      Navigator.pop(context); // Tutup dialog
                      Navigator.pop(context); // Kembali ke halaman sebelumnya
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Image (Puncak Ciremai)
            Stack(
              children: [
                Image.network(
                  "https://your-image-url.com/puncak_ciremai.jpg", // Ganti dengan asset lokal jika ada
                  height: 250,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  top: 40,
                  left: 20,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const Positioned(
                  top: 45,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Text(
                      "Pendaftaran",
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
            
            // Form Section
            Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildField("Username"),
                    _buildField("Email"),
                    _buildField("Password", isObscure: true),
                    _buildField("Konfirmasi Password", isObscure: true),
                    _buildField("Nama Lengkap"),
                    
                    const SizedBox(height: 20),
                    const Text("Undang Undang Perusahaan", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Container(
                      height: 150,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const SingleChildScrollView(
                        child: Text(
                          "Lorem ipsum dolor sit amet, consectetur adipiscing elit. " * 20,
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ),
                    ),
                    
                    Row(
                      children: [
                        Checkbox(
                          value: _isAgreed,
                          onChanged: (val) => setState(() => _isAgreed = val!),
                        ),
                        const Expanded(
                          child: Text("Saya menyetujui syarat dan ketentuan", style: TextStyle(fontSize: 12)),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2F4B7C),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: _isAgreed ? _showSuccessDialog : null,
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

  Widget _buildField(String label, {bool isObscure = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2F4B7C))),
          const SizedBox(height: 5),
          TextFormField(
            obscureText: isObscure,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey[200],
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
            ),
          ),
        ],
      ),
    );
  }
}