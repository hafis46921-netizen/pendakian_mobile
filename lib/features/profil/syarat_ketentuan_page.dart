import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:file_picker/file_picker.dart'; // Import File Picker
import '../../api_config.dart';

class SyaratKetentuanAdminPage extends StatefulWidget {
  final Map<String, String> registrationData;

  const SyaratKetentuanAdminPage({super.key, required this.registrationData});

  @override
  State<SyaratKetentuanAdminPage> createState() => _SyaratKetentuanAdminPageState();
}

class _SyaratKetentuanAdminPageState extends State<SyaratKetentuanAdminPage> {
  bool _isAgreed = false; 
  bool _isLoading = false; 
  
  // Variabel penampung file dokumen yang dipilih
  PlatformFile? _selectedFile;

  // ==================== FUNGSI MEMILIH FILE ====================
  Future<void> _pilihDokumen() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'png'], // Sesuai mimes di Laravel kamu
      );

      if (result != null) {
        setState(() {
          _selectedFile = result.files.first;
        });
      }
    } catch (e) {
      _showSnackBar("Gagal memilih file: $e");
    }
  }

  // ==================== FUNGSI HIT API GABUNGAN ====================
  Future<void> _prosesPendaftaranAdmin(bool isDark) async {
    // Validasi apakah user sudah memilih dokumen pendukung
    if (_selectedFile == null) {
      _showSnackBar("Silahkan unggah dokumen persyaratan terlebih dahulu!");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // LANGKAH 1: Register Akun Terlebih Dahulu
      final regUrl = Uri.parse("${ApiConfig.baseUrl}/register"); 
      final regResponse = await http.post(
        regUrl,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": widget.registrationData["username"],
          "email": widget.registrationData["email"],
          "password": widget.registrationData["password"],
          "name": widget.registrationData["name"],
        }),
      );

      if (regResponse.statusCode != 201 && regResponse.statusCode != 200) {
        final errorData = jsonDecode(regResponse.body);
        _showSnackBar(errorData['message'] ?? "Gagal meregistrasi akun user.");
        return;
      }

      final regData = jsonDecode(regResponse.body);
      String token = regData['token'] ?? regData['data']['token'] ?? ''; 

      if (token.isEmpty) {
        _showSnackBar("Token tidak ditemukan, silahkan login manual.");
        return;
      }

      // LANGKAH 2: Kirim Request Admin + Upload File ke Laravel
      final reqAdminUrl = Uri.parse("${ApiConfig.baseUrl}/request-admin"); 
      var request = http.MultipartRequest('POST', reqAdminUrl);
      
      // Inject Header Bearer Token
      request.headers.addAll({
        "Authorization": "Bearer $token",
        "Accept": "application/json"
      });

      // Field Teks
      request.fields['request_type'] = 'admin_gunung';

      // Lampirkan Berkas Fisik Menggunakan bytes (Sangat aman untuk Flutter Android/iOS/Web)
      if (_selectedFile!.bytes != null) {
        request.files.add(http.MultipartFile.fromBytes(
          'documents[0]', // Menggunakan indeks [0] karena Laravel membaca array 'documents.*'
          _selectedFile!.bytes!,
          filename: _selectedFile!.name,
        ));
      } else if (_selectedFile!.path != null) {
        // Fallback jika membaca path lokal langsung (untuk Android/iOS)
        request.files.add(await http.MultipartFile.fromPath(
          'documents[0]',
          _selectedFile!.path!,
        ));
      }

      // Eksekusi pengiriman berkas multipart
      var responseStream = await request.send();
      var response = await http.Response.fromStream(responseStream);

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showSuccessDialog(isDark);
      } else {
        final errorReq = jsonDecode(response.body);
        _showSnackBar(errorReq['message'] ?? "Gagal mengunggah dokumen request admin.");
      }

    } catch (e) {
      _showSnackBar("Terjadi kesalahan sistem: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSnackBar(String pesan) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(pesan), backgroundColor: Colors.redAccent),
    );
  }

  void _showSuccessDialog(bool isDark) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Registrasi & Berkas Anda Berhasil Dikirim!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isDark ? Colors.white : const Color(0xFF2F4B7C),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Mohon tunggu tim administrator memvalidasi dokumen legalitas Anda.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[400] : Colors.grey[600]),
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
                      Navigator.pop(context); 
                      Navigator.pop(context); 
                      Navigator.pop(context); 
                    },
                    child: const Text("Selesai", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(
              "Undang Undang Perusahaan & Syarat Admin",
              style: TextStyle(
                fontWeight: FontWeight.bold, 
                fontSize: 16, 
                color: isDark ? Colors.grey[300] : const Color(0xFF2F4B7C),
              ),
            ),
            const SizedBox(height: 15),

            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[900] : Colors.grey[100],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    "Lorem ipsum dolor sit amet, consectetur adipiscing elit. " * 20,
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

            // ==================== AREA UPLOAD DOKUMEN ====================
            InkWell(
              onTap: _pilihDokumen,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[850] : Colors.blue[50]!.withOpacity(0.5),
                  border: Border.all(color: Colors.blue.withOpacity(0.4), style: BorderStyle.solid),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(Icons.cloud_upload_outlined, color: isDark ? Colors.blue[300] : const Color(0xFF2F4B7C)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedFile != null ? _selectedFile!.name : "Unggah Dokumen Legalitas (PDF/JPG/PNG)",
                            style: TextStyle(
                              fontSize: 12, 
                              fontWeight: FontWeight.bold,
                              color: _selectedFile != null ? Colors.green : (isDark ? Colors.grey[300] : Colors.black87)
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (_selectedFile == null)
                            Text("Maksimal ukuran file berkas 4MB", style: TextStyle(fontSize: 10, color: Colors.grey[500])),
                        ],
                      ),
                    ),
                    if (_selectedFile != null)
                      const Icon(Icons.check_circle, color: Colors.green, size: 20)
                  ],
                ),
              ),
            ),
            const SizedBox(height: 15),

            // Checkbox Persetujuan
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(isDark ? 0.15 : 0.1),
                border: Border.all(color: Colors.green.withOpacity(isDark ? 0.6 : 0.5)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Theme(
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
                      style: TextStyle(fontSize: 11, color: isDark ? Colors.grey[300] : Colors.black87),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Tombol Submit
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? const Color(0xFF3A5A98) : const Color(0xFF2F4B7C),
                  disabledBackgroundColor: isDark ? Colors.grey[800] : Colors.grey[300],
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: (_isAgreed && !_isLoading && _selectedFile != null) ? () => _prosesPendaftaranAdmin(isDark) : null, 
                child: _isLoading 
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text(
                      "Daftar & Kirim Berkas", 
                      style: TextStyle(
                        color: (_isAgreed && _selectedFile != null) ? Colors.white : (isDark ? Colors.grey[600] : Colors.grey[500]),
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