/// Shared server used by login and MD2. Override with --dart-define.
class AppConfig {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://quiz-mobile-backend.onrender.com',
  );
}
