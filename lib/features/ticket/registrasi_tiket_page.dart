// lib/features/ticket/registrasi_tiket_page.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // 🛠️ TAMBAHKAN INI
import 'peraturan_dialog.dart';
import '../auth/login_page.dart';

class RegistrasiTiketPage extends StatefulWidget {
  const RegistrasiTiketPage({super.key, required this.gunungData});

  final Map<String, dynamic> gunungData;

  @override
  State<RegistrasiTiketPage> createState() => _RegistrasiTiketPageState();
}

class _RegistrasiTiketPageState extends State<RegistrasiTiketPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _jumlahPendakiController = TextEditingController(
    text: "1",
  );
  DateTime? _tanggalMasuk;
  DateTime? _tanggalKeluar;

  // 🔒 STATUS LOGIN: Sekarang dinamis, bukan hardcode lagi
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _cekStatusLogin(); // 🛠️ Panggil fungsi cek login saat halaman dimuat
    _jumlahPendakiController.addListener(() {
      setState(() {});
    });
  }

  // 🛠️ FUNGSI BARU: Mengambil token asli dari session lokal komputer/HP
  Future<void> _cekStatusLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    if (token != null && token.isNotEmpty) {
      setState(() {
        _isLoggedIn = true;
      });
    }
  }

  @override
  void dispose() {
    _jumlahPendakiController.dispose();
    super.dispose();
  }

  int _parseHarga(String hargaStr) {
    String cleanString = hargaStr.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(cleanString) ?? 0;
  }

  int _hitungDurasiHari() {
    if (_tanggalMasuk == null || _tanggalKeluar == null) return 1;

    DateTime dateMasuk = DateTime(
      _tanggalMasuk!.year,
      _tanggalMasuk!.month,
      _tanggalMasuk!.day,
    );
    DateTime dateKeluar = DateTime(
      _tanggalKeluar!.year,
      _tanggalKeluar!.month,
      _tanggalKeluar!.day,
    );

    int selisihHari = dateKeluar.difference(dateMasuk).inDays;
    return selisihHari <= 0 ? 1 : selisihHari;
  }

  int _hitungTotalBiaya(int tarifDasar) {
    int jumlahPendaki = int.tryParse(_jumlahPendakiController.text) ?? 1;
    if (jumlahPendaki < 1) jumlahPendaki = 1;
    int durasi = _hitungDurasiHari();

    return tarifDasar * jumlahPendaki * durasi;
  }

  String _formatRupiah(int nominal) {
    String str = nominal.toString();
    String hasil = "";
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      hasil = str[i] + hasil;
      count++;
      if (count == 3 && i != 0) {
        hasil = ".$hasil";
        count = 0;
      }
    }
    return "Rp $hasil";
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    String namaGunung = widget.gunungData['nama'] ?? "Gunung Ciremai";
    String imagePath =
        widget.gunungData['image'] ?? 'assets/images/puncak_ciremai.jpg';

    String tarifDasarStr = widget.gunungData['tarif_weekday'] ?? "Rp 25.000";
    int tarifDasar = _parseHarga(tarifDasarStr);
    int totalBiayaFinal = _hitungTotalBiaya(tarifDasar);

    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xFFF4F6F9),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Gambar
            Stack(
              children: [
                Container(
                  height: 220,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(imagePath),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Container(height: 220, color: Colors.black.withOpacity(0.3)),
                Positioned(
                  top: 45,
                  left: 15,
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 26,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        "Pendaftaran",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Form Konten Utama Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        namaGunung,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? const Color(0xFF6A93D4)
                              : const Color(0xFF2F4B7C),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Deskripsi",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.grey[400] : Colors.black87,
                        ),
                      ),
                      Text(
                        widget.gunungData['deskripsi'] ??
                            "Rincian registrasi booking online tiket simaksi pendakian.",
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                          height: 1.4,
                        ),
                      ),

                      const SizedBox(height: 20),
                      const Divider(),
                      const SizedBox(height: 10),

                      _buildDatePickerField(
                        label: "Tanggal Masuk",
                        selectedDate: _tanggalMasuk,
                        isDark: isDark,
                        onTap: () async {
                          DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(
                              const Duration(days: 90),
                            ),
                          );
                          if (picked != null) {
                            setState(() {
                              _tanggalMasuk = picked;
                              _tanggalKeluar = picked.add(
                                const Duration(days: 1),
                              );
                            });
                          }
                        },
                      ),

                      _buildDatePickerField(
                        label: "Tanggal Keluar",
                        selectedDate: _tanggalKeluar,
                        isDark: isDark,
                        onTap: () async {
                          if (_tanggalMasuk == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Pilih tanggal masuk terlebih dahulu!",
                                ),
                              ),
                            );
                            return;
                          }
                          DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate:
                                _tanggalKeluar ??
                                _tanggalMasuk!.add(const Duration(days: 1)),
                            firstDate: _tanggalMasuk!.add(
                              const Duration(days: 1),
                            ),
                            lastDate: _tanggalMasuk!.add(
                              const Duration(days: 14),
                            ),
                          );
                          if (picked != null) {
                            setState(() => _tanggalKeluar = picked);
                          }
                        },
                      ),

                      _buildTextField(
                        label: "Jumlah Pendaki",
                        controller: _jumlahPendakiController,
                        hint: "Masukkan jumlah personil kelompok",
                        isDark: isDark,
                        keyboardType: TextInputType.number,
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return "Jumlah pendaki wajib diisi";
                          }
                          int? num = int.tryParse(val);
                          if (num == null || num < 1) {
                            return "Minimal pendaki adalah 1 orang";
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 15),
                      const Divider(),
                      const SizedBox(height: 10),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Total Pembayaran",
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark
                                      ? Colors.grey[400]
                                      : Colors.grey[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "(${_hitungDurasiHari()} Hari x ${_jumlahPendakiController.text.isEmpty ? "1" : _jumlahPendakiController.text} Orang)",
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            _formatRupiah(totalBiayaFinal),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? Colors.green[400]
                                  : Colors.green[700],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 25),

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
                          onPressed: () async {
                            // 🛠️ Tambahkan async di sini
                            if (_formKey.currentState!.validate()) {
                              if (_tanggalMasuk == null ||
                                  _tanggalKeluar == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Silakan tentukan rincian tanggal simaksi dahulu!",
                                    ),
                                  ),
                                );
                                return;
                              }

                              // 🔒 INTERSEPTOR AUTH: Mengecek status login asli hasil initState
                              if (!_isLoggedIn) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Kamu harus login terlebih dahulu untuk booking tiket!",
                                    ),
                                    backgroundColor: Colors.redAccent,
                                    duration: Duration(seconds: 2),
                                  ),
                                );

                                // Tunggu sampai user selesai di LoginPage
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const LoginPage(),
                                  ),
                                );

                                // Setekah kembali dari LoginPage, cek ulang status loginnya
                                _cekStatusLogin();
                                return;
                              }

                              // ✅ JIKA SUDAH LOGIN: Langsung lemparkan dialog peraturan
                              // ✅ JIKA SUDAH LOGIN: Langsung lemparkan dialog peraturan
                              Map<String, dynamic> dataTiketAwal = {
                                // 🔥 PERBAIKAN: Masukkan basecamp_id dan basecamp_nama agar bisa dioper ke halaman berikutnya!
                                "basecamp_id": widget.gunungData['basecamp_id'],
                                "basecamp_nama":
                                    widget.gunungData['basecamp_nama'] ??
                                    widget.gunungData['jalur'],

                                "gunung": namaGunung,
                                "image": imagePath,
                                "tanggal_masuk":
                                    "${_tanggalMasuk!.day}/${_tanggalMasuk!.month}/${_tanggalMasuk!.year}",
                                "tanggal_keluar":
                                    "${_tanggalKeluar!.day}/${_tanggalKeluar!.month}/${_tanggalKeluar!.year}",
                                "jumlah_pendaki":
                                    int.tryParse(
                                      _jumlahPendakiController.text,
                                    ) ??
                                    1,
                                "harga": _formatRupiah(totalBiayaFinal),
                                "harga_raw":
                                    tarifDasar, // Memastikan harga_raw ikut terkirim secara aman
                              };

                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) => PeraturanDialog(
                                  namaGunung: namaGunung,
                                  dataTiketAwal: dataTiketAwal,
                                ),
                              );
                            }
                          },
                          child: const Text(
                            "Selanjutnya",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePickerField({
    required String label,
    required DateTime? selectedDate,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.grey[300] : const Color(0xFF2F4B7C),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 6),
          InkWell(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[850] : const Color(0xFFF2F2F2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    selectedDate == null
                        ? "Pilih Tanggal"
                        : "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
                    style: TextStyle(
                      fontSize: 13,
                      color: selectedDate == null
                          ? Colors.grey
                          : (isDark ? Colors.white : Colors.black87),
                    ),
                  ),
                  const Icon(
                    Icons.calendar_month,
                    color: Colors.grey,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required bool isDark,
    required TextInputType keyboardType,
    required String? Function(String?) validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.grey[300] : const Color(0xFF2F4B7C),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            validator: validator,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 13,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.grey[600] : Colors.grey,
              ),
              filled: true,
              fillColor: isDark ? Colors.grey[850] : const Color(0xFFF2F2F2),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
