import 'package:flutter/material.dart';
import 'peraturan_dialog.dart'; // Pastikan path import ini sudah sesuai dengan struktur foldermu

class RegistrasiTiketPage extends StatefulWidget {
  final Map<String, dynamic> gunungData;

  const RegistrasiTiketPage({super.key, required this.gunungData});

  @override
  State<RegistrasiTiketPage> createState() => _RegistrasiTiketPageState();
}

class _RegistrasiTiketPageState extends State<RegistrasiTiketPage> {
  final _tanggalMasukController = TextEditingController();
  final _tanggalKeluarController = TextEditingController();
  final _jumlahPendakiController = TextEditingController();

  // Fungsi untuk memunculkan DatePicker saat field tanggal diklik
  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        controller.text = "${picked.day}-${picked.month}-${picked.year}";
      });
    }
  }

  @override
  void dispose() {
    _tanggalMasukController.dispose();
    _tanggalKeluarController.dispose();
    _jumlahPendakiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Mengambil data operan dari halaman sebelumnya
    String namaGunung = widget.gunungData['nama'] ?? "Gunung Prau";
    String deskripsi = widget.gunungData['deskripsi'] ?? 
        "Lorem ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s.";
    String tarifWeekday = widget.gunungData['tarif_weekday'] ?? "Rp 25.000";
    String tarifWeekend = widget.gunungData['tarif_weekend'] ?? "Rp 30.000";

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. Header Image dengan Tombol Back (Stack)
            Stack(
              children: [
                Container(
                  height: 240,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/puncak_ciremai.jpg'), // Ganti sesuai asset lokal atau network
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Container(
                  height: 240,
                  width: double.infinity,
                  color: Colors.black.withOpacity(0.15),
                ),
                Positioned(
                  top: 45,
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

            // Konten Form & Deskripsi
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              child: Column(
                children: [
                  // 2. Card Deskripsi Gunung
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          namaGunung,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2F4B7C)),
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          "Deskripsi",
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          deskripsi,
                          style: TextStyle(fontSize: 11, color: Colors.grey[600], height: 1.4),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 15),

                  // 3. Card Form Input Tiket
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        // Field Tanggal Masuk
                        _buildInputField(
                          label: "Tanggal Masuk",
                          controller: _tanggalMasukController,
                          hint: "Pilih Tanggal Masuk",
                          readOnly: true,
                          onTap: () => _selectDate(context, _tanggalMasukController),
                        ),
                        
                        // Field Tanggal Keluar
                        _buildInputField(
                          label: "Tanggal Keluar",
                          controller: _tanggalKeluarController,
                          hint: "Pilih Tanggal Keluar",
                          readOnly: true,
                          onTap: () => _selectDate(context, _tanggalKeluarController),
                        ),
                        
                        // Field Jumlah Pendaki
                        _buildInputField(
                          label: "Jumlah Pendaki",
                          controller: _jumlahPendakiController,
                          hint: "Masukkan Jumlah Anggota",
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 15),

                  // 4. Card Rincian Harga Tiket
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Rincian Harga Tiket/Orang",
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Tarif Weekday", style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                                const SizedBox(height: 3),
                                Text(tarifWeekday, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF2F4B7C))),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text("Tarif Weekend", style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                                const SizedBox(height: 3),
                                Text(tarifWeekend, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF2F4B7C))),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  // 5. Tombol Lanjutkan Pembayaran (Sudah Diupdate)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2F4B7C),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        // Validasi sederhana agar form tidak boleh kosong
                        if (_tanggalMasukController.text.isEmpty ||
                            _tanggalKeluarController.text.isEmpty ||
                            _jumlahPendakiController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Harap isi semua formulir pendaftaran terlebih dahulu!"),
                              backgroundColor: Colors.redAccent,
                            ),
                          );
                          return;
                        }

                        // Menampilkan Pop-up Peraturan dari file terpisah
                        showDialog(
                          context: context,
                          barrierDismissible: false, // Tidak bisa tutup dialog dengan klik sembarang luar area
                          builder: (BuildContext context) {
                            return PeraturanDialog(
                              namaGunung: namaGunung,
                              dataTiketAwal: {
                                "gunung": namaGunung,
                                "tanggal_masuk": _tanggalMasukController.text,
                                "tanggal_keluar": _tanggalKeluarController.text,
                                "jumlah_pendaki": _jumlahPendakiController.text,
                                "harga": tarifWeekend, // Mengirimkan tarif sebagai referensi total bayar
                              },
                            );
                          },
                        );
                      },
                      child: const Text("Lanjut ke Pembayaran", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget Helper Reusable untuk Input Field Form
  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hint,
    bool readOnly = false,
    VoidCallback? onTap,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2F4B7C), fontSize: 13)),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            readOnly: readOnly,
            onTap: onTap,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
              filled: true,
              fillColor: const Color(0xFFF0F0F0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
            ),
          ),
        ],
      ),
    );
  }
}