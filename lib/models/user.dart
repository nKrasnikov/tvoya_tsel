class User {
  final int id;
  final String email;
  final String fullName;
  final String? telegramChatId;
  final String role;
  final bool isBlocked;

  User({
    required this.id,
    required this.email,
    required this.fullName,
    this.telegramChatId,
    required this.role,
    required this.isBlocked,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      fullName: json['full_name'] ?? '',
      telegramChatId: json['telegram_chat_id'],
      role: json['role'] ?? 'user',
      isBlocked: json['is_blocked'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'telegram_chat_id': telegramChatId,
      'role': role,
      'is_blocked': isBlocked,
    };
  }
}