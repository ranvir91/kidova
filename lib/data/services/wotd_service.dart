import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/config/app_config.dart';
import '../models/wotd_entry.dart';

class WotdServiceException implements Exception {
  final String message;
  WotdServiceException(this.message);

  @override
  String toString() => message;
}

/// Talks to the Word of the Day API (api.wotd.site).
///
/// Base URL comes from `.env` via [AppConfig] so it can be swapped without
/// touching code.
class WotdService {
  final http.Client _client;

  WotdService({http.Client? client}) : _client = client ?? http.Client();

  /// Fetches today's word. No `date` is sent so the server resolves
  /// "today" itself, avoiding a client/server timezone mismatch that
  /// could otherwise be rejected as a request for a future WOTD.
  Future<WotdEntry> getWordOfToday() async {
    final uri = Uri.parse('${AppConfig.wotdApiBaseUrl}/query');

    try {
      final response = await _client.get(uri).timeout(AppConfig.apiTimeout);

      if (response.statusCode != 200) {
        throw WotdServiceException(
          'Something went wrong (code ${response.statusCode}). Please try again.',
        );
      }

      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        return WotdEntry.fromJson(decoded);
      }

      throw WotdServiceException('Unexpected response from the word server.');
    } on WotdServiceException {
      rethrow;
    } catch (_) {
      throw WotdServiceException(
        "Could not reach today's word. Check your internet connection.",
      );
    }
  }

  void dispose() => _client.close();
}
