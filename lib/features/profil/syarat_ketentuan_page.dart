import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
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
  PlatformFile? _selectedFile;

  Future<void> _pilihDokumen() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'png'],
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

  Future<void> _prosesPendaftaranAdmin(bool isDark) async {
    if (_selectedFile == null) {
      _showSnackBar("Silahkan unggah dokumen persyaratan terlebih dahulu!");
      return;
    }

    setState(() => _isLoading = true);

    try {
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

      final reqAdminUrl = Uri.parse("${ApiConfig.baseUrl}/request-admin"); 
      var request = http.MultipartRequest('POST', reqAdminUrl);
      
      request.headers.addAll({
        "Authorization": "Bearer $token",
        "Accept": "application/json"
      });

      request.fields['request_type'] = 'admin_gunung';

      if (_selectedFile!.bytes != null) {
        request.files.add(http.MultipartFile.fromBytes(
          'documents[0]',
          _selectedFile!.bytes!,
          filename: _selectedFile!.name,
        ));
      } else if (_selectedFile!.path != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'documents[0]',
          _selectedFile!.path!,
        ));
      }

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
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String pesan) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(pesan), backgroundColor: Colors.redAccent),
    );
  }

  void _showSuccessDialog(bool isDark) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text("Berhasil"),
          content: const Text("Registrasi & Berkas Anda Berhasil Dikirim!\n\nMohon tunggu tim administrator memvalidasi dokumen legalitas Anda."),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              child: const Text("Selesai"),
              onPressed: () {
                Navigator.pop(context); 
                Navigator.pop(context); 
                Navigator.pop(context); 
                Navigator.pop(context); 
              },
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final backgroundColor = isDark ? const Color(0xFF000000) : const Color(0xFFF2F2F7);
    final cardColor = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final dividerColor = isDark ? const Color(0xFF38383A) : const Color(0xFFE5E5EA);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: cardColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Syarat & Ketentuan",
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.chevron_back, size: 24, color: Color(0xFF2F4B7C)),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(color: dividerColor, height: 0.5),
        ),
      ),
      body: _isLoading
          ? const Center(child: CupertinoActivityIndicator(radius: 14))
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  _buildSectionHeader("DOKUMEN HUKUM & ATURAN"),
                  
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    constraints: const BoxConstraints(maxHeight: 250),
                    child: CupertinoScrollbar(
                      child: SingleChildScrollView(
                        child: Text(
                          "Lorem ipsum dolor sit amet, consectetur adipiscing elit. " * 20,
                          style: TextStyle(
                            fontSize: 14, 
                            color: isDark ? Colors.grey[300] : Colors.black87, 
                            height: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  _buildSectionHeader("UPLOAD DOKUMEN PENDUKUNG"),
                  
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: CupertinoButton(
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                      onPressed: _pilihDokumen,
                      child: Row(
                        children: [
                          Icon(
                            _selectedFile != null ? CupertinoIcons.doc_fill : CupertinoIcons.cloud_upload,
                            color: _selectedFile != null ? CupertinoColors.activeGreen : const Color(0xFF007AFF),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _selectedFile != null ? _selectedFile!.name : "Unggah Dokumen Legalitas (PDF/JPG/PNG)",
                                  style: TextStyle(
                                    fontSize: 15, 
                                    fontWeight: FontWeight.w500,
                                    color: _selectedFile != null 
                                        ? CupertinoColors.activeGreen 
                                        : (isDark ? Colors.white : Colors.black87)
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "Maksimal ukuran file berkas 4MB", 
                                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                                ),
                              ],
                            ),
                          ),
                          if (_selectedFile != null)
                            const Icon(CupertinoIcons.checkmark_circle_fill, color: CupertinoColors.activeGreen, size: 22)
                          else
                            const Icon(CupertinoIcons.chevron_forward, color: CupertinoColors.inactiveGray, size: 18),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                  
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        CupertinoSwitch(
                          value: _isAgreed,
                          activeColor: CupertinoColors.activeGreen,
                          onChanged: (value) {
                            setState(() {
                              _isAgreed = value;
                            });
                          },
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "Saya menyetujui seluruh syarat dan ketentuan undang-undang yang berlaku di perusahaan ini.",
                            style: TextStyle(fontSize: 13, color: isDark ? Colors.grey[300] : Colors.black87),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(
                      width: double.infinity,
                      child: CupertinoButton(
                        color: const Color(0xFF2F4B7C),
                        disabledColor: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFD1D1D6),
                        borderRadius: BorderRadius.circular(12),
                        onPressed: (_isAgreed && _selectedFile != null) ? () => _prosesPendaftaranAdmin(isDark) : null,
                        child: Text(
                          "Daftar & Kirim Berkas",
                          style: TextStyle(
                            fontWeight: FontWeight.w600, 
                            fontSize: 16, 
                            color: (_isAgreed && _selectedFile != null) ? Colors.white : Colors.grey[500]
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 32, bottom: 8, top: 8),
      child: Text(
        title,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: Colors.grey[500], letterSpacing: 0.4),
      ),
    );
  }
}