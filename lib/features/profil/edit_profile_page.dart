import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart'; // Tambahkan ini
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
  File? _imageFile; // Untuk menyimpan file foto yang dipilih
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
      _currentImageUrl = prefs.getString('foto'); // Ambil path foto dari prefs

      String? savedGender = prefs.getString('gender');
      if (genderOptions.contains(savedGender)) selectedGender = savedGender;

      String? savedAlamat = prefs.getString('alamat');
      if (alamatOptions.contains(savedAlamat)) selectedAlamat = savedAlamat;

      isLoading = false;
    });
  }

  // --- FUNGSI AMBIL FOTO DARI GALERI ---
  Future<void> _pickImage() async {
    final XFile? selected = await _picker.pickImage(source: ImageSource.gallery);
    if (selected != null) {
      setState(() {
        _imageFile = File(selected.path);
      });
      // Langsung upload foto saat dipilih
      _uploadPhoto(File(selected.path));
    }
  }

  // --- FUNGSI UPLOAD FOTO KE SERVER ---
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
      await prefs.setString('foto', data['data']['foto']); // Simpan path baru
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

  // --- UPDATE DATABASE (TEXT) ---
  Future<void> _updateDatabase() async {
    setState(() => isLoading = true);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    try {
      // Gunakan PUT dan JSON Encode agar sinkron dengan ProfileController
      final response = await http.put(
        Uri.parse("http://192.168.0.101/api/user/profile"), 
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
        print("Gagal: ${response.body}");
      }
    } catch (e) {
      print("Error: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F2F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2F4B7C),
        title: const Text("Ubah Profil", style: TextStyle(color: Colors.white, fontSize: 18)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoading 
        ? const Center(child: CircularProgressIndicator()) 
        : SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildProfilePictureSection(), // Widget foto yang sudah diupdate
                const SizedBox(height: 20),
                _buildSectionCard(
                  title: "Informasi Profil",
                  children: [
                    _buildInputField("Nama Lengkap", nameController),
                    _buildInputField("No Telp", phoneController, isPhone: true),
                    _buildDropdownField("Alamat", selectedAlamat, alamatOptions, (val) => setState(() => selectedAlamat = val)),
                    _buildDateField("Tanggal Lahir", dobController, () => _selectDate(context)),
                    _buildDropdownField("Jenis Kelamin", selectedGender, genderOptions, (val) => setState(() => selectedGender = val)),
                  ],
                ),
                const SizedBox(height: 20),
                _buildSectionCard(
                  title: "Email & Username",
                  children: [
                    _buildInputField("Email", emailController, enabled: false),
                    _buildInputField("Username", usernameController),
                  ],
                ),
                const SizedBox(height: 30),
                _buildSaveButton(),
              ],
            ),
          ),
    );
  }

  // --- PERBAIKAN WIDGET FOTO ---
  Widget _buildProfilePictureSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: const Color(0xFFE0E0E0),
            backgroundImage: _imageFile != null 
                ? FileImage(_imageFile!) 
                : (_currentImageUrl != null 
                    ? NetworkImage("http://192.168.0.101/storage/$_currentImageUrl") as ImageProvider
                    : null),
            child: (_imageFile == null && _currentImageUrl == null)
                ? const Icon(Icons.person, size: 60, color: Colors.white)
                : null,
          ),
          Positioned(
            bottom: 0,
            right: MediaQuery.of(context).size.width * 0.3,
            child: InkWell(
              onTap: _pickImage,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(color: Color(0xFF2F4B7C), shape: BoxShape.circle),
                child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET HELPERS ---

  Widget _buildProfilePicture() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: const CircleAvatar(
        radius: 50,
        backgroundColor: Color(0xFFE0E0E0),
        child: Icon(Icons.person, size: 60, color: Colors.white),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, {bool enabled = true, bool isPhone = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 5),
          TextField(
            controller: controller,
            enabled: enabled,
            keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
            inputFormatters: isPhone ? [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(13)] : [],
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFF1F2F6),
              contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              counterText: "", // Menghilangkan tulisan counter angka di bawah
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField(String label, String? value, List<String> items, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 5),
          DropdownButtonFormField<String>(
            value: value,
            items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 14)))).toList(),
            onChanged: onChanged,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFF1F2F6),
              contentPadding: const EdgeInsets.symmetric(horizontal: 15),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateField(String label, TextEditingController controller, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 5),
          TextField(
            controller: controller,
            readOnly: true, // Tidak bisa diketik manual
            onTap: onTap, // Muncul kalender saat di-tap
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFF1F2F6),
              suffixIcon: const Icon(Icons.calendar_month, color: Colors.grey, size: 20),
              contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({required String title, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Color(0xFF2F4B7C), fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2F4B7C),
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: _updateDatabase,
        child: const Text("Simpan Perubahan", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}