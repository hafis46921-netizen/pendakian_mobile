import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:io';
import '../../api_config.dart'; // Import konfigurasi API untuk URL dinamis

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();

  String? selectedGender; 
  String? selectedAlamat;
  File? _imageFile; 
  final ImagePicker _picker = ImagePicker();
  String? _currentImageUrl;

  final List<String> genderOptions = ["Laki-Laki", "Perempuan"];
  final List<String> alamatOptions = ["Indramayu", "Cirebon", "Majalengka", "Kuningan", "Lainnya"];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      nameController.text = prefs.getString('name') ?? "";
      emailController.text = prefs.getString('email') ?? "";
      phoneController.text = prefs.getString('phone') ?? "";
      dobController.text = prefs.getString('dob') ?? "";
      usernameController.text = prefs.getString('username') ?? "";
      _currentImageUrl = prefs.getString('foto'); 

      String? savedGender = prefs.getString('gender');
      if (genderOptions.contains(savedGender)) selectedGender = savedGender;

      String? savedAlamat = prefs.getString('alamat');
      if (alamatOptions.contains(savedAlamat)) selectedAlamat = savedAlamat;

      isLoading = false;
    });
  }

  Future<void> _pickImage() async {
    final XFile? selected = await _picker.pickImage(source: ImageSource.gallery);
    if (selected != null) {
      setState(() {
        _imageFile = File(selected.path);
      });
      _uploadPhoto(File(selected.path));
    }
  }

  Future<void> _uploadPhoto(File file) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    var request = http.MultipartRequest(
      'POST',
      Uri.parse("${ApiConfig.baseUrl}/user/profile/foto"),
    );

    request.headers.addAll({
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    });

    request.files.add(await http.MultipartFile.fromPath('foto', file.path));

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      await prefs.setString('foto', data['data']['foto']); 
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Foto berhasil diperbarui")));
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        dobController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  Future<void> _updateDatabase() async {
    setState(() => isLoading = true);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    try {
      // FIX: Mengganti IP static manual ke ApiConfig.baseUrl agar sinkron
      final response = await http.put(
        Uri.parse("${ApiConfig.baseUrl}/user/profile"), 
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "name": nameController.text,
          "email": emailController.text,
          "phone": phoneController.text,
          "alamat": selectedAlamat ?? "",
          "dob": dobController.text,
          "gender": selectedGender ?? "",
          "username": usernameController.text,
        }),
      );

      if (response.statusCode == 200) {
        await prefs.setString('name', nameController.text);
        await prefs.setString('phone', phoneController.text);
        await prefs.setString('alamat', selectedAlamat ?? "");
        await prefs.setString('gender', selectedGender ?? "");
        await prefs.setString('dob', dobController.text);
        await prefs.setString('username', usernameController.text);

        if (!mounted) return;
        Navigator.pop(context, true);
      } else {
        debugPrint("Gagal: ${response.body}");
      }
    } catch (e) {
      debugPrint("Error: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Deteksi status mode gelap global
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // FIX: Menghapus warna kaku 0xFFF1F2F6 agar mengikuti background canvas tema aktif
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        // FIX: Warna AppBar menyesuaikan mode malam (menggunakan warna surface gelap bawaan)
        backgroundColor: isDark ? Theme.of(context).cardColor : const Color(0xFF2F4B7C),
        title: const Text("Ubah Profil", style: TextStyle(color: Colors.white, fontSize: 18)),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: isLoading 
        ? const Center(child: CircularProgressIndicator()) 
        : SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildProfilePictureSection(isDark), 
                const SizedBox(height: 20),
                _buildSectionCard(
                  title: "Informasi Profil",
                  isDark: isDark,
                  children: [
                    _buildInputField("Nama Lengkap", nameController, isDark),
                    _buildInputField("No Telp", phoneController, isDark, isPhone: true),
                    _buildDropdownField("Alamat", selectedAlamat, alamatOptions, isDark, (val) => setState(() => selectedAlamat = val)),
                    _buildDateField("Tanggal Lahir", dobController, isDark, () => _selectDate(context)),
                    _buildDropdownField("Jenis Kelamin", selectedGender, genderOptions, isDark, (val) => setState(() => selectedGender = val)),
                  ],
                ),
                const SizedBox(height: 20),
                _buildSectionCard(
                  title: "Email & Username",
                  isDark: isDark,
                  children: [
                    _buildInputField("Email", emailController, isDark, enabled: false),
                    _buildInputField("Username", usernameController, isDark),
                  ],
                ),
                const SizedBox(height: 30),
                _buildSaveButton(isDark),
              ],
            ),
          ),
    );
  }

  // --- WIDGET FOTO ADAPTIF ---
  Widget _buildProfilePictureSection(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor, // FIX: Menggunakan warna card dinamis
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: isDark ? Colors.grey[800] : const Color(0xFFE0E0E0),
            backgroundImage: _imageFile != null 
                ? FileImage(_imageFile!) 
                : (_currentImageUrl != null 
                    // FIX: Menggunakan ApiConfig.baseUrl untuk memuat gambar dari storage
                    ? NetworkImage("${ApiConfig.baseUrl.replaceAll('/api', '')}/storage/$_currentImageUrl") as ImageProvider
                    : null),
            child: (_imageFile == null && _currentImageUrl == null)
                ? Icon(Icons.person, size: 60, color: isDark ? Colors.grey[400] : Colors.white)
                : null,
          ),
          Positioned(
            bottom: 0,
            right: MediaQuery.of(context).size.width * 0.3,
            child: InkWell(
              onTap: _pickImage,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF3A5A98) : const Color(0xFF2F4B7C), // FIX: Tombol kamera adaptif
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET FIELD ADAPTIF ---
  Widget _buildInputField(String label, TextEditingController controller, bool isDark, {bool enabled = true, bool isPhone = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[400] : Colors.grey[600])),
          const SizedBox(height: 5),
          TextField(
            controller: controller,
            enabled: enabled,
            keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
            inputFormatters: isPhone ? [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(13)] : [],
            // FIX: Mengatur warna teks agar kontras sesuai mode
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black87),
            decoration: InputDecoration(
              filled: true,
              // FIX: Menyesuaikan fill warna kolom input di mode gelap
              fillColor: isDark ? Colors.grey[850] : const Color(0xFFF1F2F6),
              contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              counterText: "", 
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField(String label, String? value, List<String> items, bool isDark, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[400] : Colors.grey[600])),
          const SizedBox(height: 5),
          DropdownButtonFormField<String>(
            initialValue: value,
            // FIX: Mengubah warna background pop-up dropdown menu saat di-klik
            dropdownColor: isDark ? Colors.grey[900] : Colors.white,
            style: TextStyle(fontSize: 14, color: isDark ? Colors.white : Colors.black87),
            items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: TextStyle(fontSize: 14, color: isDark ? Colors.white : Colors.black87)))).toList(),
            onChanged: onChanged,
            decoration: InputDecoration(
              filled: true,
              fillColor: isDark ? Colors.grey[850] : const Color(0xFFF1F2F6),
              contentPadding: const EdgeInsets.symmetric(horizontal: 15),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateField(String label, TextEditingController controller, bool isDark, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[400] : Colors.grey[600])),
          const SizedBox(height: 5),
          TextField(
            controller: controller,
            readOnly: true, 
            onTap: onTap, 
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black87),
            decoration: InputDecoration(
              filled: true,
              fillColor: isDark ? Colors.grey[850] : const Color(0xFFF1F2F6),
              suffixIcon: Icon(Icons.calendar_month, color: isDark ? Colors.grey[400] : Colors.grey, size: 20),
              contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET CARD SECTIONS ADAPTIF ---
  Widget _buildSectionCard({required String title, required List<Widget> children, required bool isDark}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor, // FIX: Menggunakan warna card dinamis
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title, 
            style: TextStyle(
              color: isDark ? Colors.grey[300] : const Color(0xFF2F4B7C), // FIX: Warna judul seksi adaptif
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          ...children,
        ],
      ),
    );
  }

  // --- WIDGET TOMBOL SIMPAN ADAPTIF ---
  Widget _buildSaveButton(bool isDark) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isDark ? const Color(0xFF3A5A98) : const Color(0xFF2F4B7C), // FIX: Warna biru adaptif
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: _updateDatabase,
        child: const Text("Simpan Perubahan", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}