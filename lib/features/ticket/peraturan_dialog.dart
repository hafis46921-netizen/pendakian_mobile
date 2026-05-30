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
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(20),
        constraints: const BoxConstraints(maxHeight: 520),
        child: Column(
          children: [
            Text(
              "Peraturan Pendakian",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark
                    ? const Color(0xFF6A93D4)
                    : const Color(0xFF2F4B7C),
              ),
            ),
            const SizedBox(height: 15),

            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[850] : Colors.grey[100],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Peraturan & Kebijakan Basecamp:",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.grey[300] : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "1. Setiap pendaki wajib membawa kartu identitas asli (KTP/SIM/Paspor).\n"
                        "2. Dilarang keras membawa senjata tajam, obat-obatan terlarang, serta minuman keras.\n"
                        "3. Wajib membawa perlengkapan mendaki yang standar dan logistik yang cukup.\n"
                        "4. Dilarang melakukan vandalisme, memotong pohon, atau memetik bunga Edelweiss.\n"
                        "5. Sampah logistik wajib dibawa turun kembali ke basecamp. Jika melanggar akan dikenakan denda.\n"
                        "6. Mematuhi segala instruksi dan arahan dari petugas registrasi basecamp.",
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? Colors.grey[400] : Colors.black,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 15),

            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1B3B2B)
                    : const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isDark ? Colors.green.shade800 : Colors.green.shade200,
                ),
              ),
              child: Row(
                children: [
                  Checkbox(
                    activeColor: Colors.green,
                    side: BorderSide(
                      color: isDark ? Colors.green.shade300 : Colors.grey,
                    ),
                    value: isChecked,
                    onChanged: (bool? value) {
                      setState(() => isChecked = value ?? false);
                    },
                  ),
                  Expanded(
                    child: Text(
                      "Saya menerima dan menyetujui seluruh peraturan pendakian yang berlaku.",
                      style: TextStyle(
                        fontSize: 10,
                        color: isDark ? Colors.green[300] : Colors.green[800],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isChecked
                      ? (isDark
                            ? const Color(0xFF3A5A98)
                            : const Color(0xFF2F4B7C))
                      : (isDark ? Colors.grey[800] : Colors.grey[400]),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: isChecked
                    ? () {
                        Navigator.pop(context); // Tutup Dialog Peraturan

                        // Pindah Halaman ke IsiDataDiriPage
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => IsiDataDiriPage(
                              dataTiket: widget.dataTiketAwal,
                            ),
                          ),
                        );
                      }
                    : null,
                child: Text(
                  "Selanjutnya",
                  style: TextStyle(
                    color: isChecked
                        ? Colors.white
                        : (isDark ? Colors.grey[500] : Colors.grey[200]),
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
