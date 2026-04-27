import 'package:intl/intl.dart';

class DateFormatter {
  static String formatDate(DateTime? date) {
    if (date == null) return 'Не указана';
    return DateFormat('dd.MM.yyyy').format(date);
  }

  static String formatDateTime(DateTime date) {
    return DateFormat('dd.MM.yyyy HH:mm').format(date);
  }

  static String formatRelative(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now);
    if (difference.inDays < 0) {
      return 'Просрочено на ${-difference.inDays} дн.';
    } else if (difference.inDays == 0) {
      return 'Сегодня';
    } else if (difference.inDays == 1) {
      return 'Завтра';
    } else {
      return 'Через ${difference.inDays} дн.';
    }
  }
}