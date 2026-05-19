// lib/features/ticket/peraturan_dialog.dart
import 'package:flutter/material.dart';
import 'isi_data_diri_page.dart';

class PeraturanDialog extends StatefulWidget {
  final String namaGunung;
  final Map<String, dynamic> dataTiketAwal;

  const PeraturanDialog({
    super.key,
    required this.namaGunung,
    required this.dataTiketAwal,
  });

  @override
  State<PeraturanDialog> createState() => _PeraturanDialogState();
}

class _PeraturanDialogState extends State<PeraturanDialog> {
  bool isChecked = false; // State untuk mengontrol checkbox persetujuan

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(20),
        constraints: const BoxConstraints(maxHeight: 550), // Batasi tinggi pop-up agar tidak overflow
        child: Column(
          children: [
            // Judul Pop-up
            const Text(
              "Peraturan Pendakian",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2F4B7C)),
            ),
            const SizedBox(height: 15),
            
            // Box Isi Peraturan yang bisa di-scroll (Sesuai kode di image_9dd31b.png)
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Peraturan & Kebijakan Basecamp:",
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                      SizedBox(height: 6),
                      Text(
                        "1. Setiap pendaki wajib membawa kartu identitas asli (KTP/SIM/Paspor).\n"
                        "2. Dilarang keras membawa senjata tajam, obat-obatan terlarang, serta minuman keras.\n"
                        "3. Wajib membawa perlengkapan mendaki yang standar dan logistik yang cukup.\n"
                        "4. Dilarang melakukan vandalisme, memotong pohon, atau memetik bunga Edelweiss.\n"
                        "5. Sampah logistik wajib dibawa turun kembali ke basecamp. Jika melanggar akan dikenakan sanksi/denda.\n"
                        "6. Mematuhi segala instruksi dan arahan dari petugas registrasi basecamp.\n\n"
                        "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.",
                        style: TextStyle(fontSize: 11, color: Colors.black, height: 1.5),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 15),
            
            // Checkbox Persetujuan Berwarna Hijau (Sesuai mockup kiri atas di image_73b7c9.png)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9), // Background hijau muda
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  Checkbox(
                    activeColor: Colors.green,
                    value: isChecked,
                    onChanged: (bool? value) {
                      setState(() {
                        isChecked = value ?? false;
                      });
                    },
                  ),
                  const Expanded(
                    child: Text(
                      "Saya menerima dan menyetujui seluruh peraturan pendakian yang berlaku.",
                      style: TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 15),
            
            // Tombol Selanjutnya
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isChecked ? const Color(0xFF2F4B7C) : Colors.grey, // Aktif jika dicentang
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: isChecked
                    ? () {
                        Navigator.pop(context); // Tutup pop-up dialog peraturan
                        
                        // Berpindah ke Halaman Pengisian Data Diri dengan membawa data tiket awal
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => IsiDataDiriPage(
                              dataTiket: widget.dataTiketAwal,
                            ),
                          ),
                        );
                      }
                    : null, // Jika belum dicentang, tombol tidak bisa diklik
                child: const Text("Selanjutnya", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}