import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TentangAplikasiPage extends StatelessWidget {
  const TentangAplikasiPage({super.key});

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
          "Tentang Aplikasi",
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    )
                  ]
                ),
                child: Image.asset(
                  'assets/images/logosummitgo.png', 
                  height: 85, 
                  errorBuilder: (c, e, s) => Icon(
                    CupertinoIcons.compass, // Ganti ke Kompas petualangan yang valid di iOS
                    size: 80, 
                    color: isDark ? const Color(0xFF2F4B7C) : const Color(0xFF2F4B7C),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              Text(
                "SummitGo App", 
                style: TextStyle(
                  fontSize: 24, 
                  fontWeight: FontWeight.bold, 
                  color: isDark ? Colors.white : const Color(0xFF1C1C1E),
                  letterSpacing: -0.5
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Versi 1.0.0 (Production)", 
                style: TextStyle(color: Colors.grey[500], fontSize: 14, fontWeight: FontWeight.w400),
              ),
              
              const SizedBox(height: 30),
              
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "SummitGo adalah aplikasi platform booking online tiket pendakian gunung yang mempermudah para pendaki untuk melakukan registrasi basecamp, pengelolaan izin administrasi, dan sistem pembayaran digital secara aman dan efisien.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14, 
                    color: isDark ? Colors.grey[300] : const Color(0xFF3A3A3C), 
                    height: 1.6,
                  ),
                ),
              ),
              
              const Spacer(),
              
              Text(
                "© 2026 SummitGo Indonesia. All Rights Reserved.", 
                style: TextStyle(color: Colors.grey[600], fontSize: 12, letterSpacing: -0.1),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}