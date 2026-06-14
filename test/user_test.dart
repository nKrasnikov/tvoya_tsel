import 'package:flutter_test/flutter_test.dart';
import 'package:tvoya_tsel/models/user.dart';

void main() {
  test('User fromJson creates correct object', () {
    final json = {
      'id': 1,
      'email': 'test@test.com',
      'full_name': 'Test User',
      'role': 'user',
      'is_blocked': false,
      'reminder_enabled': true,
      'reminder_time': '09:00',
      'birth_date': '2000-01-01',
      'gender': 'male',
      'city': 'Moscow',
      'bio': 'Developer',
      'interests': 'coding, music',
    };
    final user = User.fromJson(json);
    expect(user.id, 1);
    expect(user.email, 'test@test.com');
    expect(user.fullName, 'Test User');
    expect(user.birthDate, DateTime(2000, 1, 1));
    expect(user.gender, 'male');
    expect(user.city, 'Moscow');
    expect(user.bio, 'Developer');
    expect(user.interests, 'coding, music');
  });

  test('User toJson returns correct map', () {
    final user = User(
      id: 1,
      email: 'test@test.com',
      fullName: 'Test User',
      role: 'user',
      isBlocked: false,
      reminderEnabled: true,
      reminderTime: '09:00',
      birthDate: DateTime(2000, 1, 1),
      gender: 'male',
      city: 'Moscow',
      bio: 'Developer',
      interests: 'coding',
    );
    final json = user.toJson();
    expect(json['email'], 'test@test.com');
    expect(json['birth_date'], '2000-01-01');
  });
}
