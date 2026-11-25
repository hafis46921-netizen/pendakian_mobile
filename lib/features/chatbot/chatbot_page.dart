import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'chatbot_service.dart';
import 'models/chatbot_message.dart';
import 'widgets/chat_message_bubble.dart';
import 'widgets/chat_quick_prompts.dart';

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final ChatbotService _service = ChatbotService();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  final List<ChatbotMessage> _messages = [];
  bool _loading = true;
  bool _sending = false;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final messages = await _service.fetchMessages();
      if (!mounted) return;
      setState(() {
        _messages
          ..clear()
          ..addAll(messages);
        _loading = false;
      });
      _scrollToBottom(animated: false);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _loadError = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _send([String? preset]) async {
    final text = (preset ?? _controller.text).trim();
    if (text.isEmpty || _sending) return;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (!mounted) return;
    if (token == null || token.isEmpty) {
      Navigator.pushNamed(context, '/login');
      return;
    }

    _controller.clear();
    final userMessage = ChatbotMessage(role: 'user', content: text);
    final pendingAssistant = const ChatbotMessage(
      role: 'assistant',
      content: '',
      isPending: true,
    );

    setState(() {
      _sending = true;
      _messages.add(userMessage);
      _messages.add(pendingAssistant);
    });
    _scrollToBottom();

    try {
      final assistant = await _service.sendMessage(text);
      if (!mounted) return;
      setState(() {
        final idx = _messages.lastIndexWhere((m) => m.isPending);
        if (idx != -1) {
          _messages[idx] = assistant;
        } else {
          _messages.add(assistant);
        }
        _sending = false;
      });
      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString().replaceFirst('Exception: ', '');
      setState(() {
        final idx = _messages.lastIndexWhere((m) => m.isPending);
        if (idx != -1) {
          _messages[idx] = ChatbotMessage(
            role: 'assistant',
            content: msg,
            isError: true,
          );
        }
        _sending = false;
      });
      _scrollToBottom();
    }
  }

  Future<void> _clearHistory() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus riwayat chat?'),
        content: const Text('Riwayat percakapan chatbot akan dihapus dari akun Anda.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Hapus')),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await _service.clearMessages();
      if (!mounted) return;
      setState(() => _messages.clear());
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  void _scrollToBottom({bool animated = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      final target = _scrollController.position.maxScrollExtent;
      if (animated) {
        _scrollController.animateTo(
          target,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      } else {
        _scrollController.jumpTo(target);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF121212) : const Color(0xFFF4F7FA);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0.5,
        backgroundColor: isDark ? Colors.grey[900] : const Color(0xFF2F4B7C),
        foregroundColor: Colors.white,
        titleSpacing: 0,
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.16),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.support_agent_rounded, size: 22),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SummitGo Assistant',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: 1),
                  Text(
                    'Panduan pendakian & bantuan booking',
                    style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w400, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Hapus riwayat',
            onPressed: _messages.isEmpty ? null : _clearHistory,
            icon: const Icon(Icons.delete_outline_rounded),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          Expanded(child: _buildBody(isDark)),
          _buildInput(isDark),
        ],
      ),
    );
  }

  Widget _buildBody(bool isDark) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_loadError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.error_outline_rounded, size: 34, color: Colors.redAccent),
              ),
              const SizedBox(height: 14),
              Text(
                _loadError!,
                textAlign: TextAlign.center,
                style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[700], height: 1.4),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadMessages,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Coba lagi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2F4B7C),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      );
    }
    if (_messages.isEmpty) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
        children: [
          Center(
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF2F4B7C).withValues(alpha: isDark ? 0.28 : 0.16),
                    const Color(0xFF2F4B7C).withValues(alpha: isDark ? 0.14 : 0.06),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.support_agent_rounded, color: Color(0xFF2F4B7C), size: 38),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Halo! Saya SummitGo Assistant',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : const Color(0xFF1F2937),
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Saya bisa membantu persiapan pendakian, info gunung, dan kendala booking/transaksi Anda.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark ? Colors.grey[300] : Colors.grey[600],
              height: 1.5,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 28),
          Text(
            'Coba tanyakan',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 12),
          ChatQuickPrompts(onSelected: (p) => _send(p)),
        ],
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 14),
      itemCount: _messages.length,
      itemBuilder: (context, index) => ChatMessageBubble(message: _messages[index]),
    );
  }

  Widget _buildInput(bool isDark) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF181818) : Colors.white,
          border: Border(
            top: BorderSide(color: isDark ? Colors.white10 : const Color(0xFFE7EBF3)),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF242424) : const Color(0xFFF3F6FA),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDark ? Colors.white10 : const Color(0xFFE3E8F2),
                  ),
                ),
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  minLines: 1,
                  maxLines: 4,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _send(),
                  style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1F2937)),
                  decoration: InputDecoration(
                    hintText: 'Tulis pertanyaan Anda...',
                    hintStyle: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[500]),
                    filled: false,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              height: 46,
              width: 46,
              child: ElevatedButton(
                onPressed: _sending ? null : _send,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  shape: const CircleBorder(),
                  elevation: _sending ? 0 : 0,
                  backgroundColor: const Color(0xFF2F4B7C),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: isDark ? Colors.grey[700] : Colors.grey[400],
                ),
                child: _sending
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.arrow_upward_rounded, size: 22),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
