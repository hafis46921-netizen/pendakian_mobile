// lib/features/ticket/isi_data_diri_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert'; // Ditambahkan untuk JSON Encode
import 'package:http/http.dart'
    as http; // Ditambahkan untuk HTTP Request ke Laravel
import 'package:shared_preferences/shared_preferences.dart'; // Ditambahkan untuk mengambil Token Auth
import '../../api_config.dart'; // Ditambahkan untuk konfigurasi Base URL API kamu

class IsiDataDiriPage extends StatefulWidget {
  final Map<String, dynamic> dataTiket;

  const IsiDataDiriPage({super.key, required this.dataTiket});

  @override
  State<IsiDataDiriPage> createState() => _IsiDataDiriPageState();
}

class _IsiDataDiriPageState extends State<IsiDataDiriPage> {
  final _formKey = GlobalKey<FormState>();

  final List<TextEditingController> _namaControllers = [];
  final List<TextEditingController> _alamatControllers = [];
  final List<TextEditingController> _tanggalLahirControllers = [];
  final List<TextEditingController> _genderControllers = [];
  final List<TextEditingController> _identitasControllers = [];

  int _jumlahPendaki = 1;

  @override
  void initState() {
    super.initState();
    _jumlahPendaki = widget.dataTiket['jumlah_pendaki'] ?? 1;

    // Debugging untuk memantau aliran data dari halaman sebelumnya
    print("=== DEBUG DATA TIKET DI HALAMAN DATA DIRI ===");
    print(
      "Basecamp ID dari halaman sebelumnya: ${widget.dataTiket['basecamp_id']}",
    );
    print("Gunung: ${widget.dataTiket['gunung']}");
    print(
      "Jalur/Basecamp: ${widget.dataTiket['basecamp_nama'] ?? widget.dataTiket['jalur']}",
    );
    print("============================================");

    for (int i = 0; i < _jumlahPendaki; i++) {
      _namaControllers.add(TextEditingController());
      _alamatControllers.add(TextEditingController());
      _tanggalLahirControllers.add(TextEditingController());
      _genderControllers.add(TextEditingController(text: "L"));
      _identitasControllers.add(TextEditingController());
    }
  }

  @override
  void dispose() {
    for (int i = 0; i < _jumlahPendaki; i++) {
      _namaControllers[i].dispose();
      _alamatControllers[i].dispose();
      _tanggalLahirControllers[i].dispose();
      _genderControllers[i].dispose();
      _identitasControllers[i].dispose();
    }
    super.dispose();
  }

  // Mengonversi format tanggal DD/MM/YYYY dari aplikasi ke YYYY-MM-DD standar MySQL/Laravel
  String _formatTanggalKeDatabase(String tanggal) {
    try {
      if (tanggal.isEmpty) return '';

      if (tanggal.contains('/')) {
        List<String> parts = tanggal.split('/');
        if (parts.length == 3) {
          String hari = parts[0].padLeft(2, '0');
          String bulan = parts[1].padLeft(2, '0');
          String tahun = parts[2];
          return "$tahun-$bulan-$hari"; // Menjadi YYYY-MM-DD
        }
      }

      if (tanggal.contains('-')) {
        List<String> parts = tanggal.split('-');
        if (parts.length == 3 && parts[0].length == 2) {
          String hari = parts[0].padLeft(2, '0');
          String bulan = parts[1].padLeft(2, '0');
          String tahun = parts[2];
          return "$tahun-$bulan-$hari"; // Menjadi YYYY-MM-DD
        }
      }
      return tanggal;
    } catch (e) {
      print("Error format tanggal: $e");
      return tanggal;
    }
  }

  // FUNGSI HTTP REQUEST: Mengirim data registrasi dan menyimpannya ke MySQL via Laravel
  Future<Map<String, dynamic>?> storeBooking() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      // Mengemas data dinamis seluruh pendaki dari form textfield
      List<Map<String, String>> anggotaList = [];
      for (int i = 0; i < _jumlahPendaki; i++) {
        anggotaList.add({
          'nama': _namaControllers[i].text,
          'alamat': _alamatControllers[i].text,
          'tanggal_lahir': _formatTanggalKeDatabase(
            _tanggalLahirControllers[i].text,
          ),
          'jenis_kelamin': _genderControllers[i].text,
          'identitas': _identitasControllers[i].text,
        });
      }

      String tanggalMasukMentah = widget.dataTiket['tanggal_masuk'] ?? '';
      String tanggalNaikFormatted = _formatTanggalKeDatabase(
        tanggalMasukMentah,
      );

      // Mengonversi harga ke tipe data angka (int/double) agar sinkron dengan Laravel
      final hargaRaw = widget.dataTiket['harga_raw'];
      int hargaPerOrang = 25000; // default fallback
      if (hargaRaw is int) {
        hargaPerOrang = hargaRaw;
      } else if (hargaRaw is String) {
        hargaPerOrang = int.tryParse(hargaRaw) ?? 25000;
      } else if (widget.dataTiket['harga'] != null) {
        String cleanHarga = widget.dataTiket['harga'].toString().replaceAll(
          RegExp(r'[^0-9]'),
          '',
        );
        hargaPerOrang = int.tryParse(cleanHarga) ?? 25000;
      }

      int totalPrice = hargaPerOrang * _jumlahPendaki;

      // PENANGANAN FALLBACK AMAN JIKA DATA SEBELUMNYA NULL
      // Di dalam isi_data_diri_page.dart fungsi storeBooking()
      // 🔍 CARI KODE INI PADA FUNGSI storeBooking():
      final basecampIdRaw = widget.dataTiket['basecamp_id'];

      // 📝 UBAH BAGIAN INI:
      int defaultBasecampId =
          1; // Ubah dari 2 menjadi 1 (sesuai database lokalmu)
      int basecampId = defaultBasecampId;

      if (basecampIdRaw is int) {
        basecampId = basecampIdRaw;
      } else if (basecampIdRaw is String) {
        basecampId = int.tryParse(basecampIdRaw) ?? defaultBasecampId;
      }

      print("=== MENGIRIM REQUEST BOOKING ===");
      print("Mengirim Basecamp ID ke Laravel: $basecampId");
      print("Total Price: $totalPrice");

      final response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/user/bookings"),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'basecamp_id': basecampId,
          'tanggal_naik': tanggalNaikFormatted,
          'jumlah_pendaki': _jumlahPendaki,
          'harga_per_orang': hargaPerOrang,
          'total_price': totalPrice,
          'status': 'pending',
          'checkout_by': 1, // Mengantisipasi constraint default value database
          'anggota': anggotaList,
        }),
      );

      print("======= STATUS CODE DARI SERVER: ${response.statusCode} =======");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        return responseData['data'];
      } else {
        print("======== ERROR DARI LARAVEL ========");
        print("Respon Server: ${response.body}");
        print("====================================");
        return null;
      }
    } catch (e) {
      print("Error pada fungsi storeBooking: $e");
      return null;
    }
  }

  Future<void> _selectDate(BuildContext context, int index, bool isDark) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2005),
      firstDate: DateTime(1960),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 10)),
      builder: (context, child) {
        return Theme(
          data: isDark
              ? ThemeData.dark().copyWith(
                  colorScheme: const ColorScheme.dark(
                    primary: Color(0xFF6A93D4),
                    onPrimary: Colors.white,
                    surface: Color(0xFF1E1E1E),
                  ),
                )
              : ThemeData.light().copyWith(
                  colorScheme: const ColorScheme.light(
                    primary: Color(0xFF2F4B7C),
                  ),
                ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _tanggalLahirControllers[index].text =
            "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      });
    }
  }

  void _showKonfirmasiBottomSheet(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
          ),
          padding: const EdgeInsets.all(25),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Data Tiket",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? const Color(0xFF6A93D4)
                        : const Color(0xFF2F4B7C),
                  ),
                ),
                const SizedBox(height: 8),
                _buildTextRow(
                  "Gunung:",
                  widget.dataTiket['gunung'] ?? "-",
                  isDark,
                ),
                _buildTextRow(
                  "Jalur:",
                  widget.dataTiket['basecamp_nama'] ??
                      widget.dataTiket['jalur'] ??
                      "-",
                  isDark,
                ),
                _buildTextRow(
                  "Tanggal Masuk:",
                  widget.dataTiket['tanggal_masuk'] ?? "-",
                  isDark,
                ),
                _buildTextRow(
                  "Tanggal Keluar:",
                  widget.dataTiket['tanggal_keluar'] ?? "-",
                  isDark,
                ),
                _buildTextRow(
                  "Jumlah Pendaki:",
                  "$_jumlahPendaki Orang",
                  isDark,
                ),
                _buildTextRow(
                  "Harga Tiket:",
                  widget.dataTiket['harga'] ?? "-",
                  isDark,
                  isBold: true,
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Divider(
                    color: isDark ? Colors.grey[800] : Colors.grey[300],
                  ),
                ),

                Text(
                  "Data Penanggung Jawab (Ketua)",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? const Color(0xFF6A93D4)
                        : const Color(0xFF2F4B7C),
                  ),
                ),
                const SizedBox(height: 8),
                _buildTextRow(
                  "Nama Ketua:",
                  _namaControllers[0].text.isEmpty
                      ? "Pendaki"
                      : _namaControllers[0].text,
                  isDark,
                ),
                _buildTextRow(
                  "No ID / KTP:",
                  _identitasControllers[0].text.isEmpty
                      ? "-"
                      : _identitasControllers[0].text,
                  isDark,
                ),

                const SizedBox(height: 25),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark
                          ? const Color(0xFF3A5A98)
                          : const Color(0xFF2F4B7C),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      final navigator = Navigator.of(context);
                      final scaffoldMessenger = ScaffoldMessenger.of(context);

                      navigator.pop(); // Tutup bottom sheet tinjau

                      // Tampilkan Loading Dialog
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF2F4B7C),
                          ),
                        ),
                      );

                      // Eksekusi fungsi HTTP POST menyimpan ke database Laravel
                      final bookingResult = await storeBooking();

                      // Tutup Loading Dialog
                      navigator.pop();

                      if (bookingResult != null) {
                        scaffoldMessenger.showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Data berhasil disimpan! Membuka halaman pembayaran...",
                            ),
                          ),
                        );

                        // Arahkan menuju halaman invoice
                        navigator.pushReplacementNamed(
                          '/invoice_pembayaran',
                          arguments: bookingResult,
                        );
                      } else {
                        scaffoldMessenger.showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Gagal memproses pendaftaran. Coba periksa database atau log Laravel kamu.",
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    child: const Text(
                      "Bayar Sekarang",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    String imagePath =
        widget.dataTiket['image'] ?? 'assets/images/puncak_ciremai.jpg';

    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xFFF4F6F9),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
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

              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                itemCount: _jumlahPendaki,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 20),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          index == 0
                              ? "Data Ketua Kelompok"
                              : "Data Anggota #$index",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? const Color(0xFF6A93D4)
                                : const Color(0xFF2F4B7C),
                          ),
                        ),
                        const SizedBox(height: 15),

                        _buildFormRow(
                          "Nama",
                          _namaControllers[index],
                          "Masukkan Nama Lengkap",
                          isDark,
                        ),
                        _buildFormRow(
                          "Alamat",
                          _alamatControllers[index],
                          "Masukkan Alamat Lengkap & Kota Asal",
                          isDark,
                          maxLines: 2,
                        ),
                        _buildDatePickerRow(
                          "Tanggal Lahir",
                          _tanggalLahirControllers[index],
                          "Pilih Tanggal Lahir",
                          isDark,
                          () {
                            _selectDate(context, index, isDark);
                          },
                        ),
                        _buildGenderRow(
                          "Jenis Kelamin",
                          _genderControllers[index],
                          isDark,
                        ),
                        _buildFormRow(
                          "Kartu Identitas",
                          _identitasControllers[index],
                          "Nomor NIK KTP / Kartu Pelajar (16 Digit)",
                          isDark,
                          isNumeric: true,
                          maxLength: 16,
                        ),
                      ],
                    ),
                  );
                },
              ),

              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, bottom: 30),
                child: SizedBox(
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
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _showKonfirmasiBottomSheet(context, isDark);
                      }
                    },
                    child: const Text(
                      "Tinjau Pembayaran",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormRow(
    String label,
    TextEditingController controller,
    String hint,
    bool isDark, {
    int maxLines = 1,
    bool isNumeric = false,
    int? maxLength,
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
            maxLines: maxLines,
            maxLength: maxLength,
            keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
            inputFormatters: isNumeric
                ? [FilteringTextInputFormatter.digitsOnly]
                : [],
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 13,
            ),
            validator: (val) {
              if (val == null || val.isEmpty) return "$label wajib diisi";
              if (isNumeric && maxLength != null && val.length < 12) {
                return "$label minimal berkisar antara 12-16 digit";
              }
              return null;
            },
            decoration: InputDecoration(
              hintText: hint,
              counterText: "",
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

  Widget _buildDatePickerRow(
    String label,
    TextEditingController controller,
    String hint,
    bool isDark,
    VoidCallback onTap,
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
              color: isDark ? Colors.grey[300] : const Color(0xFF2F4B7C),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            readOnly: true,
            onTap: onTap,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 13,
            ),
            validator: (val) =>
                val == null || val.isEmpty ? "$label belum dipilih" : null,
            decoration: InputDecoration(
              hintText: hint,
              suffixIcon: Icon(
                Icons.calendar_month,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                size: 18,
              ),
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

  Widget _buildGenderRow(
    String label,
    TextEditingController controller,
    bool isDark,
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
              color: isDark ? Colors.grey[300] : const Color(0xFF2F4B7C),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ChoiceChip(
                  label: const Center(
                    child: Text("Laki-laki", style: TextStyle(fontSize: 12)),
                  ),
                  selected: controller.text == "L",
                  selectedColor: const Color(0xFF2F4B7C),
                  labelStyle: TextStyle(
                    color: controller.text == "L"
                        ? Colors.white
                        : (isDark ? Colors.grey[300] : Colors.black87),
                    fontWeight: controller.text == "L"
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                  onSelected: (bool selected) {
                    if (selected) setState(() => controller.text = "L");
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ChoiceChip(
                  label: const Center(
                    child: Text("Perempuan", style: TextStyle(fontSize: 12)),
                  ),
                  selected: controller.text == "P",
                  selectedColor: const Color(0xFF2F4B7C),
                  labelStyle: TextStyle(
                    color: controller.text == "P"
                        ? Colors.white
                        : (isDark ? Colors.grey[300] : Colors.black87),
                    fontWeight: controller.text == "P"
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                  onSelected: (bool selected) {
                    if (selected) setState(() => controller.text = "P");
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextRow(
    String title,
    String value,
    bool isDark, {
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.grey[400] : Colors.grey[700],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isBold
                  ? (isDark ? const Color(0xFF6A93D4) : const Color(0xFF2F4B7C))
                  : (isDark ? Colors.white : Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
