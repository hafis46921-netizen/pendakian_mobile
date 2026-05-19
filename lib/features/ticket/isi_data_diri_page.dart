// lib/features/ticket/isi_data_diri_page.dart
import 'package:flutter/material.dart';

class IsiDataDiriPage extends StatefulWidget {
  final Map<String, dynamic> dataTiket;

  const IsiDataDiriPage({super.key, required this.dataTiket});

  @override
  State<IsiDataDiriPage> createState() => _IsiDataDiriPageState();
}

class _IsiDataDiriPageState extends State<IsiDataDiriPage> {
  final _namaController = TextEditingController();
  final _alamatController = TextEditingController();
  final _tanggalLahirController = TextEditingController();
  final _genderController = TextEditingController();
  final _identitasController = TextEditingController();

  // Fungsi memunculkan Bottom Sheet Rincian Data Akhir (Gambar kanan bawah)
  void _showKonfirmasiBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, // Agar background rounded terlihat clean
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Sesuai ukuran konten kontainer saja
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bagian Informasi Data Tiket
              const Text("Data Tiket", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF2F4B7C))),
              const SizedBox(height: 8),
              _buildTextRow("Gunung:", widget.dataTiket['gunung']),
              _buildTextRow("Jalur:", "Sadarehe"), // Default/Dinamis sesuai pilihan awal
              _buildTextRow("Tanggal Masuk:", widget.dataTiket['tanggal_masuk']),
              _buildTextRow("Tanggal Keluar:", widget.dataTiket['tanggal_keluar']),
              _buildTextRow("Jumlah Pendaki:", "${widget.dataTiket['jumlah_pendaki']} Orang"),
              _buildTextRow("Harga Tiket:", widget.dataTiket['harga'], isBold: true),
              
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(),
              ),

              // Bagian Informasi Data Pendaki
              const Text("Data Pendaki", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF2F4B7C))),
              const SizedBox(height: 8),
              _buildTextRow("Nama Ketua:", _namaController.text.isEmpty ? "Agung" : _namaController.text),
              _buildTextRow("No ID:", _identitasController.text.isEmpty ? "-" : _identitasController.text),
              
              const SizedBox(height: 25),

              // Tombol Selanjutnya / Bayar Sekarang
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2F4B7C),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    Navigator.pop(context); // Tutup bottom sheet
                    // Lanjut ke gateway sistem pembayaran (Midtrans/Stripe/Transfer)
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Membuka Gerbang Pembayaran..."))
                    );
                  },
                  child: const Text("Selanjutnya", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Gambar (Sesuai mockup kanan atas)
            Stack(
              children: [
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/puncak_ciremai.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: 45,
                  left: 15,
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white, size: 26),
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

            // Form Isian Identitas Pendaki (Kanan Atas Mockup)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    _buildFormRow("Nama", _namaController, "Masukkan Nama Lengkap"),
                    _buildFormRow("Alamat", _alamatController, "Masukkan Alamat Tinggal"),
                    _buildFormRow("Tanggal Lahir", _tanggalLahirController, "HH-BB-TTTT"),
                    _buildFormRow("Jenis Kelamin", _genderController, "Laki-laki / Perempuan"),
                    _buildFormRow("Kartu Identitas", _identitasController, "Nomor NIK KTP / SIM"),
                    
                    const SizedBox(height: 20),

                    // Tombol Trigger Konfirmasi Nota Pembayaran
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2F4B7C),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () => _showKonfirmasiBottomSheet(context),
                        child: const Text("Tinjau Pembayaran", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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

  // Widget Helper Form Input Field
  Widget _buildFormRow(String label, TextEditingController controller, String hint) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2F4B7C), fontSize: 13)),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
              filled: true,
              fillColor: const Color(0xFFF2F2F2),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  // Widget Helper Data Row Nota Ringkasan
  Widget _buildTextRow(String title, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
          Text(value, style: TextStyle(fontSize: 12, fontWeight: isBold ? FontWeight.bold : FontWeight.normal, color: isBold ? const Color(0xFF2F4B7C) : Colors.black87)),
        ],
      ),
    );
  }
}