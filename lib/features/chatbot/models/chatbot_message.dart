class ChatbotMessage {
  final int? id;
  final String role;
  final String content;
  final DateTime? createdAt;
  final bool isPending;
  final bool isError;

  const ChatbotMessage({
    this.id,
    required this.role,
    required this.content,
    this.createdAt,
    this.isPending = false,
    this.isError = false,
  });

  bool get isUser => role == 'user';

  factory ChatbotMessage.fromJson(Map<String, dynamic> json) {
    return ChatbotMessage(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}'),
      role: (json['role'] ?? 'assistant').toString(),
      content: (json['content'] ?? '').toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  ChatbotMessage copyWith({
    int? id,
    String? role,
    String? content,
    DateTime? createdAt,
    bool? isPending,
    bool? isError,
  }) {
    return ChatbotMessage(
      id: id ?? this.id,
      role: role ?? this.role,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      isPending: isPending ?? this.isPending,
      isError: isError ?? this.isError,
    );
  }
}
