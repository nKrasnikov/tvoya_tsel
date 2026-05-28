class User {
  final int id;
  final String email;
  final String fullName;
  final String? telegramChatId;
  final String role;
  final bool isBlocked;
  final bool reminderEnabled;
  final String reminderTime;
  final DateTime? birthDate;      // новое
  final String? gender;           // новое (male/female/other)
  final String? city;             // новое
  final String? bio;              // новое
  final String? interests;        // новое

  User({
    required this.id,
    required this.email,
    required this.fullName,
    this.telegramChatId,
    required this.role,
    required this.isBlocked,
    required this.reminderEnabled,
    required this.reminderTime,
    this.birthDate,
    this.gender,
    this.city,
    this.bio,
    this.interests,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      fullName: json['full_name'] ?? '',
      telegramChatId: json['telegram_chat_id'],
      role: json['role'] ?? 'user',
      isBlocked: json['is_blocked'] ?? false,
      reminderEnabled: json['reminder_enabled'] ?? true,
      reminderTime: json['reminder_time'] ?? '09:00',
      birthDate: json['birth_date'] != null ? DateTime.parse(json['birth_date']) : null,
      gender: json['gender'],
      city: json['city'],
      bio: json['bio'],
      interests: json['interests'],
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
      'reminder_enabled': reminderEnabled,
      'reminder_time': reminderTime,
      'birth_date': birthDate?.toIso8601String().split('T').first,
      'gender': gender,
      'city': city,
      'bio': bio,
      'interests': interests,
    };
  }
}