class AppConfig {
  static const bool useMockApi = false; // true - моки, false - реальный бэкенд
  static const String apiBaseUrl = 'http://localhost:8000/api/v1';  // Для разработки
  // static const String apiBaseUrl = 'https://api.tvoya-tsel.ru/api/v1'; // Для продакшена
}