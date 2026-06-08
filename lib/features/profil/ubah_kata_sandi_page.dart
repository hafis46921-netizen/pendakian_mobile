// lib/features/profile/ubah_kata_sandi_page.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class UbahKataSandiPage extends StatefulWidget {
  const UbahKataSandiPage({super.key});

  @override
  State<UbahKataSandiPage> createState() => _UbahKataSandiPageState();
}

class _UbahKataSandiPageState extends State<UbahKataSandiPage> {
  final _formKey = GlobalKey<FormState>();
  final _sandiLamaController = TextEditingController();
  final _sandiBaruController = TextEditingController();
  final _konfirmasiSandiController = TextEditingController();

  bool _obscureLama = true;
  bool _obscureBaru = true;
  bool _obscureKonfirmasi = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final backgroundColor = isDark ? const Color(0xFF000000) : const Color(0xFFF2F2F7);
    final cardColor = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final dividerColor = isDark ? const Color(0xFF38383A) : const Color(0xFFE5E5EA);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Ubah Kata Sandi",
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black),
        ),
        backgroundColor: cardColor,
        elevation: 0,
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
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.only(left: 32, bottom: 8),
                child: Text(
                  "KREDENSI KEAMANAN",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: Colors.grey[500], letterSpacing: 0.4),
                ),
              ),
              
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _buildiOSPasswordField(
                      label: "Sandi Lama",
                      controller: _sandiLamaController,
                      obscureText: _obscureLama,
                      isDark: isDark,
                      onToggleVisibility: () => setState(() => _obscureLama = !_obscureLama),
                    ),
                    Container(margin: const EdgeInsets.only(left: 16), color: dividerColor, height: 0.5),
                    _buildiOSPasswordField(
                      label: "Sandi Baru",
                      controller: _sandiBaruController,
                      obscureText: _obscureBaru,
                      isDark: isDark,
                      onToggleVisibility: () => setState(() => _obscureBaru = !_obscureBaru),
                    ),
                    Container(margin: const EdgeInsets.only(left: 16), color: dividerColor, height: 0.5),
                    _buildiOSPasswordField(
                      label: "Konfirmasi",
                      controller: _konfirmasiSandiController,
                      obscureText: _obscureKonfirmasi,
                      isDark: isDark,
                      onToggleVisibility: () => setState(() => _obscureKonfirmasi = !_obscureKonfirmasi),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  "Pastikan kata sandi baru Anda terdiri dari minimal 8 karakter demi keamanan akun pendaftaran.",
                  style: TextStyle(fontSize: 13, color: Colors.grey[500], height: 1.3),
                ),
              ),
              
              const SizedBox(height: 35),
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: double.infinity,
                  child: CupertinoButton(
                    color: const Color(0xFF2F4B7C),
                    borderRadius: BorderRadius.circular(12),
                    onPressed: () {
                      if (_sandiBaruController.text != _konfirmasiSandiController.text) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Konfirmasi kata sandi tidak cocok!")),
                        );
                        return;
                      }
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Kata sandi berhasil diperbarui!")),
                      );
                      Navigator.pop(context);
                    },
                    child: const Text("Simpan Perubahan", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildiOSPasswordField({
    required String label,
    required TextEditingController controller,
    required bool obscureText,
    required bool isDark,
    required VoidCallback onToggleVisibility,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(fontWeight: FontWeight.w500, color: isDark ? Colors.grey[300] : Colors.black87, fontSize: 15),
            ),
          ),
          Expanded(
            child: TextFormField(
              controller: controller,
              obscureText: obscureText,
              style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 15),
              decoration: InputDecoration(
                hintText: "Wajib diisi",
                hintStyle: TextStyle(color: isDark ? Colors.grey[700] : Colors.grey[300], fontSize: 15),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: onToggleVisibility,
            child: Icon(
              obscureText ? CupertinoIcons.eye_slash : CupertinoIcons.eye,
              color: Colors.grey[500],
              size: 20,
          ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _sandiLamaController.dispose();
    _sandiBaruController.dispose();
    _konfirmasiSandiController.dispose();
    super.dispose();
  }
}