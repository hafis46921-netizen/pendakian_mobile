import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../api_config.dart';
import 'package:flutter/services.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  File? _imageFile;
  String? _currentFotoUrl;
  bool _isLoading = false;
  bool _isDataChanged = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _nameController.text = prefs.getString('name') ?? '';

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

    setState(() => _isLoading = true);

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.baseUrl}/user/profile'),
      );

      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      request.fields['_method'] = 'PUT';

      request.fields['name'] = _nameController.text;

      request.fields['email'] = _emailController.text;
      request.fields['phone'] = _phoneController.text;
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

        await prefs.setString('name', _nameController.text);
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
        Navigator.pop(context, true);
      } else {
        print("STATUS : ${response.statusCode}");
        print("BODY : ${response.body}");

        throw Exception(response.body);
        throw Exception('Gagal memperbarui profil di server');
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Terjadi kesalahan: $e')));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // iOS Theme Colors
    final backgroundColor = isDark
        ? const Color(0xFF000000)
        : const Color(0xFFF2F2F7);
    final cardColor = isDark
        ? const Color(0xFF1C1C1E)
        : Colors.white; // Fixed: Added '?'
    final dividerColor = isDark
        ? const Color(0xFF38383A)
        : const Color(0xFFE5E5EA);

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop && _isDataChanged) return;
      },
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: cardColor,
          elevation: 0,
          centerTitle: true,
          title: Text(
            "Ubah Profil",
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          leading: CupertinoButton(
            padding: EdgeInsets.zero,
            child: const Icon(
              CupertinoIcons.chevron_back,
              size: 24,
              color: Color(0xFF007AFF),
            ),
            onPressed: () => Navigator.pop(context, true),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(0.5),
            child: Container(color: dividerColor, height: 0.5),
          ),
        ),
        body: _isLoading
            ? const Center(child: CupertinoActivityIndicator(radius: 14))
            : SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),

                      // Avatar Section
                      Center(
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: _pickImage,
                              child: Stack(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: cardColor,
                                        width: 3,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.06),
                                          blurRadius: 12,
                                        ),
                                      ],
                                    ),
                                    child: CircleAvatar(
                                      radius: 50,
                                      backgroundColor: isDark
                                          ? Colors.grey[800]
                                          : Colors.grey[300],
                                      backgroundImage: _imageFile != null
                                          ? FileImage(_imageFile!)
                                          : (_currentFotoUrl != null &&
                                                _currentFotoUrl!.isNotEmpty)
                                          ? NetworkImage(
                                              "${ApiConfig.baseUrl.replaceAll('/api', '')}/storage/$_currentFotoUrl",
                                            )
                                          : null, // Fixed: Removed redundant casting
                                      child:
                                          (_imageFile == null &&
                                              (_currentFotoUrl == null ||
                                                  _currentFotoUrl!.isEmpty))
                                          ? Icon(
                                              CupertinoIcons.person_fill,
                                              size: 50,
                                              color: Colors.grey[500],
                                            )
                                          : null,
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF2F4B7C),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        CupertinoIcons.camera_fill,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            CupertinoButton(
                              padding: EdgeInsets.zero,
                              onPressed: _pickImage,
                              child: const Text(
                                "Edit Foto",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF007AFF),
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 15),
                      _buildSectionHeader("INFORMASI PENGGUNA"),

                      // Grouped Form Fields (iOS Style)
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            _buildiOSField(
                              label: "Nama",
                              controller: _nameController,
                              placeholder: "Masukkan nama lengkap",
                              isDark: isDark,
                              validator: (v) => v == null || v.isEmpty
                                  ? 'Nama tidak boleh kosong'
                                  : null,
                            ),
                            Container(
                              margin: const EdgeInsets.only(left: 16),
                              color: dividerColor,
                              height: 0.5,
                            ), // Fixed: margin changed to only(left: 16)
                            Container(
                              margin: const EdgeInsets.only(left: 16),
                              color: dividerColor,
                              height: 0.5,
                            ), // Fixed: margin changed to only(left: 16)
                            _buildiOSField(
                              label: "Email",
                              controller: _emailController,
                              placeholder: "alamat@email.com",
                              keyboardType: TextInputType.emailAddress,
                              isDark: isDark,
                              validator: (v) => v == null || v.isEmpty
                                  ? 'Email tidak boleh kosong'
                                  : null,
                            ),
                            Container(
                              margin: const EdgeInsets.only(left: 16),
                              color: dividerColor,
                              height: 0.5,
                            ), // Fixed: margin changed to only(left: 16)
                            _buildiOSField(
                              label: "Telepon",
                              controller: _phoneController,
                              placeholder: "08xxxxxxxxxx",
                              keyboardType: TextInputType.phone,
                              isDark: isDark,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(13),
                              ],
                              validator: (v) {
                                if (v == null || v.isEmpty) {
                                  return 'Nomor telepon tidak boleh kosong';
                                }

                                if (v.length < 10 || v.length > 13) {
                                  return 'Nomor telepon harus 10-13 digit';
                                }

                                return null;
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 22),
                      _buildSectionHeader("ALAMAT"),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: _buildiOSField(
                          label: "Alamat",
                          controller: _addressController,
                          placeholder: "Tulis alamat lengkap rumah Anda",
                          maxLines: 3,
                          isDark: isDark,
                          validator: (v) => v == null || v.isEmpty
                              ? 'Alamat tidak boleh kosong'
                              : null,
                        ),
                      ),

                      const SizedBox(height: 40),

                      // iOS Call To Action Button
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: SizedBox(
                          width: double.infinity,
                          child: CupertinoButton(
                            color: const Color(0xFF2F4B7C),
                            borderRadius: BorderRadius.circular(12),
                            onPressed: _saveProfile,
                            child: const Text(
                              "Simpan Perubahan",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 32, bottom: 8, top: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: Colors.grey[500],
          letterSpacing: 0.4,
        ),
      ),
    );
  }

  Widget _buildiOSField({
    required String label,
    required TextEditingController controller,
    required String placeholder,
    required bool isDark,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        inputFormatters: inputFormatters,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black,
          fontSize: 15,
        ),
        onChanged: (_) => _isDataChanged = true,
        validator: validator,
        decoration: InputDecoration(
          alignLabelWithHint: true,
          labelText: label,
          labelStyle: TextStyle(
            color: isDark ? Colors.grey[400] : Colors.grey[600],
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          hintText: placeholder,
          hintStyle: TextStyle(
            color: isDark ? Colors.grey[700] : Colors.grey[400],
            fontSize: 15,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }
}
