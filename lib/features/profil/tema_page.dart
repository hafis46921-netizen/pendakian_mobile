// lib/features/profile/tema_page.dart
import 'package:flutter/material.dart';
import '../../main.dart'; // Pastikan path ke main.dart benar untuk mengambil themeNotifier
import 'theme_notifier.dart';

class TemaPage extends StatefulWidget {
  const TemaPage({super.key});

  @override
  State<TemaPage> createState() => _TemaPageState();
}

class _TemaPageState extends State<TemaPage> {
  @override
  Widget build(BuildContext context) {
    // Ambil status tema yang sedang aktif saat ini dari main.dart
    String currentTheme = themeNotifier.isDarkMode ? "Gelap" : "Terang";

    return Scaffold(
      // Background akan otomatis menyesuaikan tema jika scaffoldBackgroundColor di main.dart diatur
      appBar: AppBar(
        title: const Text("Pengaturan Tema", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF2F4B7C),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Container(
          decoration: BoxDecoration(
            // Jika dark mode, ganti background card jadi abu-abu gelap, jika tidak jadi putih
            color: themeNotifier.isDarkMode ? Colors.grey[900] : Colors.white, 
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                title: const Text("Mode Terang (Light Mode)", style: TextStyle(fontSize: 14)),
                value: "Terang",
                groupValue: currentTheme,
                activeColor: const Color(0xFF2F4B7C),
                onChanged: (value) {
                  setState(() {
                    themeNotifier.toggleTheme(false); // Matikan dark mode
                  });
                },
              ),
              const Divider(height: 1),
              RadioListTile<String>(
                title: const Text("Mode Gelap (Dark Mode)", style: TextStyle(fontSize: 14)),
                value: "Gelap",
                groupValue: currentTheme,
                activeColor: const Color(0xFF2F4B7C),
                onChanged: (value) {
                  setState(() {
                    themeNotifier.toggleTheme(true); // Hidupkan dark mode
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}