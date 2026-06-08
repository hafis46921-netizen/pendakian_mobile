import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; // Ditambahkan untuk ikon & indikator khas iOS
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../api_config.dart';

class PendaftaranAdminGunungPage extends StatefulWidget {
  const PendaftaranAdminGunungPage({super.key});

  @override
  State<PendaftaranAdminGunungPage> createState() =>
      _PendaftaranAdminGunungPageState();
}

class _PendaftaranAdminGunungPageState
    extends State<PendaftaranAdminGunungPage> {
  bool _isLoading = false;

  String selectedRole = "admin_gunung";
  List<PlatformFile> selectedFiles = [];

  /// PICK FILE
  Future<void> pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'png'],
    );

    if (result != null) {
      setState(() {
        selectedFiles = result.files;
      });
    }
  }

  /// SUBMIT REQUEST
  Future<void> submitRequest() async {
    if (selectedFiles.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Upload minimal 1 dokumen")));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final request = http.MultipartRequest(
        "POST",
        Uri.parse("${ApiConfig.baseUrl}/user/requests"),
      );

      request.headers['Accept'] = 'application/json';
      request.headers['Authorization'] = "Bearer $token";

      request.fields['request_type'] = selectedRole;

      for (var file in selectedFiles) {
        request.files.add(
          await http.MultipartFile.fromPath('documents[]', file.path!),
        );
      }

      final response = await request.send();
      final resBody = await http.Response.fromStream(response);
      final data = jsonDecode(resBody.body);

      debugPrint("STATUS: ${response.statusCode}");
      debugPrint("BODY: ${resBody.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          selectedFiles.clear();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? "Request berhasil dikirim"),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pushNamedAndRemoveUntil(
          context,
          '/history',
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? "Gagal mengirim request"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Desain token warna ala iOS System Backgrounds
    final iosBackgroundColor = isDark
        ? const Color(0xFF1C1C1E)
        : const Color(0xFFF2F2F7);
    final iosCardColor = isDark ? const Color(0xFF2C2C2E) : Colors.white;
    final iosSecondaryTextColor = isDark ? Colors.grey[400] : Colors.grey[600];

    return Scaffold(
      backgroundColor: iosBackgroundColor,
      body: Column(
        children: [
          /// HEADER (Premium blur gradient overlay)
          Stack(
            children: [
              Container(
                height: 180,
                width: double.infinity,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/puncak_ciremai.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Container(
                height: 180,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.5),
                      iosBackgroundColor.withOpacity(0.8),
                      iosBackgroundColor,
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 50,
                left: 8,
                right: 16,
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        CupertinoIcons.back,
                        color: Colors.white,
                        size: 28,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Expanded(
                      child: Text(
                        "Ajukan Admin Gunung",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          /// BODY CONTENT
          Expanded(
            child: SingleChildScrollView(
              physics:
                  const BouncingScrollPhysics(), // Efek scroll membal khas iPhone
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// SECTION 1: INFO PENGUMUMAN
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: iosCardColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          CupertinoIcons.info_circle,
                          color: Color(0xFF2F4B7C),
                          size: 22,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "Pengajuan ini akan dikirim ke Super Admin untuk diverifikasi. Pastikan dokumen yang diupload valid.",
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark
                                  ? Colors.grey[300]
                                  : Colors.grey[800],
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 22),
                  _buildSectionHeader("INFORMASI PERAN"),

                  /// SECTION 2: LIST GROUP UNTUK PERAN (ROLE)
                  Container(
                    decoration: BoxDecoration(
                      color: iosCardColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      title: const Text(
                        "Role Posisi",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            selectedRole == "admin_gunung"
                                ? "Admin Gunung"
                                : selectedRole,
                            style: TextStyle(
                              fontSize: 16,
                              color: iosSecondaryTextColor,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            CupertinoIcons.chevron_forward,
                            size: 16,
                            color: iosSecondaryTextColor,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),
                  _buildSectionHeader("VERIFIKASI BERKAS"),

                  /// SECTION 3: TOMBOL UPLOAD & LIST FILE (DIPADUKAN JADI SATU GROUP)
                  Container(
                    decoration: BoxDecoration(
                      color: iosCardColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        // Baris Tombol Pilih File
                        InkWell(
                          onTap: pickFiles,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(12),
                            topRight: const Radius.circular(12),
                            bottomLeft: Radius.circular(
                              selectedFiles.isEmpty ? 12 : 0,
                            ),
                            bottomRight: Radius.circular(
                              selectedFiles.isEmpty ? 12 : 0,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  CupertinoIcons.arrow_up_doc,
                                  color: Color(0xFF2F4B7C),
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  "Tambah Dokumen Pendukung",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF2F4B7C),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const Spacer(),
                                Icon(
                                  CupertinoIcons.plus,
                                  size: 18,
                                  color: Colors.grey[400],
                                ),
                              ],
                            ),
                          ),
                        ),

                        if (selectedFiles.isNotEmpty)
                          Divider(
                            height: 1,
                            thickness: 0.5,
                            color: Colors.grey[300],
                          ),

                        // List Dokumen Terpilih
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: selectedFiles.length,
                          separatorBuilder: (context, index) => Divider(
                            height: 1,
                            thickness: 0.5,
                            indent: 48, // Menyelaraskan garis pembatas ala iOS
                            color: Colors.grey[300],
                          ),
                          itemBuilder: (context, index) {
                            return ListTile(
                              leading: const Icon(
                                CupertinoIcons.doc,
                                color: Colors.grey,
                              ),
                              title: Text(
                                selectedFiles[index].name,
                                style: const TextStyle(fontSize: 14),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: IconButton(
                                icon: const Icon(
                                  CupertinoIcons.minus_circle_fill,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  setState(() {
                                    selectedFiles.removeAt(index);
                                  });
                                },
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  /// ACTION BUTTON
                  SizedBox(
                    width: double.infinity,
                    child: CupertinoButton(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      color: const Color(0xFF2F4B7C), // iOS Blue
                      disabledColor: const Color(0xFF2F4B7C).withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                      onPressed: _isLoading ? null : submitRequest,
                      child: _isLoading
                          ? const CupertinoActivityIndicator(
                              color: Colors.white,
                            )
                          : const Text(
                              "Kirim Pengajuan",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.3,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget untuk membuat teks header kategori ala iOS settings
  // Helper widget untuk membuat teks header kategori ala iOS settings
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 6),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w400,
          color: Colors.grey[500],
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
