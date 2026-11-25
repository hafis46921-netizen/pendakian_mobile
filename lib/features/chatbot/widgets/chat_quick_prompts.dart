import 'package:flutter/material.dart';

class ChatQuickPrompts extends StatelessWidget {
  final void Function(String prompt) onSelected;

  const ChatQuickPrompts({super.key, required this.onSelected});

  static const _prompts = [
    (
      icon: Icons.hiking_rounded,
      text: 'Persiapan naik gunung',
      prompt: 'Apa saja persiapan naik gunung untuk pemula?',
    ),
    (
      icon: Icons.confirmation_number_outlined,
      text: 'Cek status booking',
      prompt: 'Bagaimana cara cek status booking saya?',
    ),
    (
      icon: Icons.health_and_safety_outlined,
      text: 'Tips keselamatan',
      prompt: 'Tips keselamatan saat pendakian apa saja?',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: _prompts.map((p) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => onSelected(p.prompt),
            child: Ink(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? Colors.white10 : const Color(0xFFE3E8F2),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2F4B7C).withValues(alpha: isDark ? 0.22 : 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(p.icon, size: 20, color: const Color(0xFF2F4B7C)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      p.text,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : const Color(0xFF243B53),
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: isDark ? Colors.grey[500] : Colors.grey[400],
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
