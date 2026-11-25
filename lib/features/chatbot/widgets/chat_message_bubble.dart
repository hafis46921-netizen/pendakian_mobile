import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../models/chatbot_message.dart';

class ChatMessageBubble extends StatelessWidget {
  final ChatbotMessage message;

  const ChatMessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isUser = message.isUser;
    final bgColor = isUser
        ? const Color(0xFF2F4B7C)
        : (isDark ? const Color(0xFF1E1E1E) : Colors.white);
    final fgColor = isUser
        ? Colors.white
        : (isDark ? Colors.white : const Color(0xFF1F2937));
    final align = isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final radius = BorderRadius.only(
      topLeft: const Radius.circular(20),
      topRight: const Radius.circular(20),
      bottomLeft: Radius.circular(isUser ? 20 : 6),
      bottomRight: Radius.circular(isUser ? 6 : 20),
    );

    final bubble = Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.74,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
        border: isUser
            ? null
            : Border.all(
                color: isDark ? Colors.white10 : const Color(0xFFE7EBF3),
              ),
      ),
      child: message.isPending
          ? _TypingIndicator(color: fgColor.withValues(alpha: 0.7))
          : message.isUser || message.isError
              ? Text(
                  message.content,
                  style: TextStyle(
                    color: message.isError ? Colors.red.shade300 : fgColor,
                    fontSize: 14.5,
                    height: 1.45,
                  ),
                )
              : MarkdownBody(
                  data: message.content,
                  selectable: true,
                  styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                    p: TextStyle(color: fgColor, fontSize: 14.5, height: 1.45),
                    strong: TextStyle(color: fgColor, fontWeight: FontWeight.w700),
                    em: TextStyle(color: fgColor, fontStyle: FontStyle.italic),
                    listBullet: TextStyle(color: fgColor, fontSize: 14.5, height: 1.45),
                    h1: TextStyle(color: fgColor, fontSize: 20, fontWeight: FontWeight.w700),
                    h2: TextStyle(color: fgColor, fontSize: 18, fontWeight: FontWeight.w700),
                    h3: TextStyle(color: fgColor, fontSize: 16, fontWeight: FontWeight.w700),
                    blockquote: TextStyle(color: fgColor.withValues(alpha: 0.85), fontSize: 14.5, height: 1.45),
                    code: TextStyle(
                      color: fgColor,
                      backgroundColor: isDark ? Colors.white10 : const Color(0xFFF3F4F6),
                      fontSize: 13.5,
                    ),
                    codeblockDecoration: BoxDecoration(
                      color: isDark ? Colors.white10 : const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
    );

    final time = _formatTime(message.createdAt);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      child: Column(
        crossAxisAlignment: align,
        children: [
          Row(
            mainAxisAlignment:
                isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isUser) ...[
                _AssistantAvatar(isDark: isDark),
                const SizedBox(width: 8),
              ],
              Flexible(child: bubble),
              if (isUser) const SizedBox(width: 2),
            ],
          ),
          if (time != null)
            Padding(
              padding: EdgeInsets.only(
                top: 4,
                left: isUser ? 0 : 42,
                right: isUser ? 4 : 0,
              ),
              child: Text(
                time,
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? Colors.grey[500] : Colors.grey[500],
                ),
              ),
            ),
        ],
      ),
    );
  }

  String? _formatTime(DateTime? dt) {
    if (dt == null) return null;
    final local = dt.toLocal();
    final h = local.hour.toString().padLeft(2, '0');
    final m = local.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

class _AssistantAvatar extends StatelessWidget {
  final bool isDark;
  const _AssistantAvatar({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: const Color(0xFF2F4B7C).withValues(alpha: isDark ? 0.25 : 0.12),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.support_agent_rounded,
        size: 18,
        color: Color(0xFF2F4B7C),
      ),
    );
  }
}

class _TypingIndicator extends StatefulWidget {
  final Color color;
  const _TypingIndicator({required this.color});

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final t = (_controller.value + (i * 0.2)) % 1.0;
            final scale = 0.45 + (0.55 * (1 - (2 * (t - 0.5)).abs()).clamp(0.0, 1.0));
            final opacity = 0.35 + (0.65 * scale);
            return Container(
              margin: EdgeInsets.only(right: i < 2 ? 5 : 0),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: widget.color.withValues(alpha: opacity),
                shape: BoxShape.circle,
              ),
            );
          }),
        );
      },
    );
  }
}
