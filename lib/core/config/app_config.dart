import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Central place to read runtime configuration loaded from `.env`.
class AppConfig {
  AppConfig._();

  static String get appName => dotenv.env['APP_NAME'] ?? 'Kidova';

  static String get datamuseApiBaseUrl =>
      dotenv.env['DATAMUSE_API_BASE_URL'] ?? 'https://api.datamuse.com';

  static String get wotdApiBaseUrl =>
      dotenv.env['WOTD_API_BASE_URL'] ?? 'https://api.wotd.site';

  static Duration get apiTimeout => Duration(
    seconds: int.tryParse(dotenv.env['API_TIMEOUT_SECONDS'] ?? '') ?? 15,
  );
}
