import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../api_config.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();

  // Controller Form Lengkap
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  File? _imageFile;
  String? _currentFotoUrl;
  bool _isLoading = false;
  bool _isDataChanged = false; // Flag untuk mendeteksi perubahan data

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _nameController.text = prefs.getString('name') ?? '';
      _usernameController.text = prefs.getString('username') ?? '';
      _emailController.text = prefs.getString('email') ?? '';
      _phoneController.text = prefs.getString('no_hp') ?? '';
      _addressController.text = prefs.getString('alamat') ?? '';
      _currentFotoUrl = prefs.getString('foto');
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        _isDataChanged = true;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.baseUrl}/profile/update'),
      );

      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      request.fields['name'] = _nameController.text;
      request.fields['username'] = _usernameController.text;
      request.fields['email'] = _emailController.text;
      request.fields['no_hp'] = _phoneController.text;
      request.fields['alamat'] = _addressController.text;

      if (_imageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath('foto', _imageFile!.path),
        );
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);

        // Simpan semua data baru ke local storage
        await prefs.setString('name', _nameController.text);
        await prefs.setString('username', _usernameController.text);
        await prefs.setString('email', _emailController.text);
        await prefs.setString('no_hp', _phoneController.text);
        await prefs.setString('alamat', _addressController.text);

        if (responseData['user'] != null &&
            responseData['user']['foto'] != null) {
          await prefs.setString('foto', responseData['user']['foto']);
        }

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil berhasil diperbarui!')),
        );

        _isDataChanged = true;
        // Keluar dengan aman membawa status true
        Navigator.pop(context, true);
      } else {
        throw Exception('Gagal memperbarui profil di server');
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Terjadi kesalahan: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // SOLUSI ERROR LAYER.DART: Menggunakan cara pop scope yang aman tanpa mematikan paksa 'canPop'
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop && _isDataChanged) {
          // Jika keluar lewat gesture back dan data telah berubah, state dikirim lewat callback sistem jika didukung
          return;
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: isDark
              ? const Color(0xFF1E1E1E)
              : const Color(0xFF2F4B7C),
          elevation: 0,
          title: const Text(
            "Ubah Profil",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            onPressed: () {
              // Jika user menekan tombol back di appbar, paksa kirim nilainya true agar profile langsung me-refresh
              Navigator.pop(context, true);
            },
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      // Jendela Foto Profil (Avatar)
                      Center(
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 55,
                              backgroundColor: isDark
                                  ? Colors.grey[800]
                                  : Colors.grey[200],
                              backgroundImage: _imageFile != null
                                  ? FileImage(_imageFile!) as ImageProvider
                                  : (_currentFotoUrl != null &&
                                        _currentFotoUrl!.isNotEmpty)
                                  ? NetworkImage(
                                          "${ApiConfig.baseUrl.replaceAll('/api', '')}/storage/$_currentFotoUrl",
                                        )
                                        as ImageProvider
                                  : null,
                              child:
                                  (_imageFile == null &&
                                      (_currentFotoUrl == null ||
                                          _currentFotoUrl!.isEmpty))
                                  ? Icon(
                                      Icons.person,
                                      size: 60,
                                      color: isDark
                                          ? Colors.grey[400]
                                          : const Color(0xFF2F4B7C),
                                    )
                                  : null,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: _pickImage,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF2F4B7C),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt_rounded,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Input Nama Lengkap
                      TextFormField(
                        controller: _nameController,
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black,
                        ),
                        decoration: _inputDecoration(
                          "Nama Lengkap",
                          Icons.person_outline,
                          isDark,
                        ),
                        onChanged: (_) => _isDataChanged = true,
                        validator: (value) => value == null || value.isEmpty
                            ? 'Nama lengkap tidak boleh kosong'
                            : null,
                      ),
                      const SizedBox(height: 16),

                      // Input Username
                      TextFormField(
                        controller: _usernameController,
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black,
                        ),
                        decoration: _inputDecoration(
                          "Username",
                          Icons.alternate_email_rounded,
                          isDark,
                        ),
                        onChanged: (_) => _isDataChanged = true,
                        validator: (value) => value == null || value.isEmpty
                            ? 'Username tidak boleh kosong'
                            : null,
                      ),
                      const SizedBox(height: 16),

                      // Input Email
                      TextFormField(
                        controller: _emailController,
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black,
                        ),
                        keyboardType: TextInputType.emailAddress,
                        decoration: _inputDecoration(
                          "Email",
                          Icons.email_outlined,
                          isDark,
                        ),
                        onChanged: (_) => _isDataChanged = true,
                        validator: (value) => value == null || value.isEmpty
                            ? 'Email tidak boleh kosong'
                            : null,
                      ),
                      const SizedBox(height: 16),

                      // Input No Telepon / HP
                      TextFormField(
                        controller: _phoneController,
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black,
                        ),
                        keyboardType: TextInputType.phone,
                        decoration: _inputDecoration(
                          "Nomor Telepon",
                          Icons.phone_android_rounded,
                          isDark,
                        ),
                        onChanged: (_) => _isDataChanged = true,
                        validator: (value) => value == null || value.isEmpty
                            ? 'Nomor telepon tidak boleh kosong'
                            : null,
                      ),
                      const SizedBox(height: 16),

                      // Input Alamat Tempat Tinggal
                      TextFormField(
                        controller: _addressController,
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black,
                        ),
                        maxLines: 3,
                        decoration: _inputDecoration(
                          "Alamat Tempat Tinggal",
                          Icons.home_outlined,
                          isDark,
                        ),
                        onChanged: (_) => _isDataChanged = true,
                        validator: (value) => value == null || value.isEmpty
                            ? 'Alamat tidak boleh kosong'
                            : null,
                      ),
                      const SizedBox(height: 35),

                      // Tombol Simpan Perubahan
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _saveProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2F4B7C),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            "Simpan Perubahan",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon, bool isDark) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: isDark ? Colors.grey[400] : Colors.grey[700],
        fontSize: 14,
      ),
      prefixIcon: Icon(icon, color: const Color(0xFF2F4B7C), size: 22),
      filled: true,
      fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.grey[50],
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: isDark
              ? (Colors.grey[800] ?? const Color(0xFF424242))
              : (Colors.grey[300] ?? const Color(0xFFE0E0E0)),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF2F4B7C), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }
}
