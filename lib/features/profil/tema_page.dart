import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../main.dart';

class TemaPage extends StatefulWidget {
  const TemaPage({super.key});

  @override
  State<TemaPage> createState() => _TemaPageState();
}

class _TemaPageState extends State<TemaPage> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final backgroundColor = isDark ? const Color(0xFF000000) : const Color(0xFFF2F2F7);
    final cardColor = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final dividerColor = isDark ? const Color(0xFF38383A) : const Color(0xFFE5E5EA);
    
    String currentTheme = themeNotifier.isDarkMode ? "Gelap" : "Terang";

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: cardColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Pengaturan Tema",
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          _buildSectionHeader("PILIH TEMA APLIKASI"),
          
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildiOSSelectionRow(
                  title: "Mode Terang (Light Mode)",
                  isSelected: currentTheme == "Terang",
                  isDark: isDark,
                  onTap: () {
                    setState(() {
                      themeNotifier.toggleTheme(false);
                    });
                  },
                ),
                Container(margin: const EdgeInsets.only(left: 16), color: dividerColor, height: 0.5),
                _buildiOSSelectionRow(
                  title: "Mode Gelap (Dark Mode)",
                  isSelected: currentTheme == "Gelap",
                  isDark: isDark,
                  onTap: () {
                    setState(() {
                      themeNotifier.toggleTheme(true);
                    });
                  },
                ),
              ],
            ),
          ),
        ],
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

  Widget _buildiOSSelectionRow({
    required String title,
    required bool isSelected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            if (isSelected)
              const Icon(
                CupertinoIcons.check_mark,
                color: Color(0xFF2F4B7C),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}