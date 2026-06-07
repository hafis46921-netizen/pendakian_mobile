import 'package:flutter/material.dart';
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

      // wajib sesuai backend
      request.fields['request_type'] = selectedRole;

      // upload documents[]
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

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          /// HEADER
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
              Container(height: 200, color: Colors.black.withOpacity(0.4)),

              Positioned(
                top: 40,
                left: 10,
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Text(
                      "Ajukan Admin Gunung",
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

          /// BODY
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// INFO CARD
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[900] : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      "Pengajuan ini akan dikirim ke Super Admin untuk diverifikasi. "
                      "Pastikan dokumen yang diupload valid.",
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// ROLE INFO
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Role"),
                        Text(
                          selectedRole,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// UPLOAD BUTTON
                  ElevatedButton.icon(
                    onPressed: pickFiles,
                    icon: const Icon(Icons.upload_file),
                    label: const Text("Upload Dokumen"),
                  ),

                  const SizedBox(height: 10),

                  /// LIST FILE
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: selectedFiles.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: const Icon(Icons.insert_drive_file),
                        title: Text(selectedFiles[index].name),
                      );
                    },
                  ),

                  const SizedBox(height: 30),

                  /// SUBMIT BUTTON
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : submitRequest,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2F4B7C),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              "Kirim Pengajuan",
                              style: TextStyle(color: Colors.white),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
