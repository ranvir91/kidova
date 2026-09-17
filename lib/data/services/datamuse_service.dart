import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/config/app_config.dart';
import '../models/dictionary_entry.dart';

class WordNotFoundException implements Exception {
  final String word;
  WordNotFoundException(this.word);

  @override
  String toString() =>
      'Hmm, we could not find "$word" in the dictionary yet.';
}

class WordLookupException implements Exception {
  final String message;
  WordLookupException(this.message);

  @override
  String toString() => message;
}

/// Looks up words using the Datamuse API (api.datamuse.com).
///
/// Base URL comes from `.env` via [AppConfig] so it can be swapped without
/// touching code.
class DatamuseService {
  final http.Client _client;

  DatamuseService({http.Client? client}) : _client = client ?? http.Client();

  /// Looks up a single word and adapts Datamuse's response into the app's
  /// shared [DictionaryEntry] model so it works with the existing word
  /// detail UI, favorites, and games.
  ///
  /// Uses `sp` (spelled-like) with `qe=sp` (query echo) so the first
  /// result is guaranteed to describe the exact word requested, per
  /// Datamuse's documented pattern for metadata lookups.
  Future<DictionaryEntry> lookupWord(String word) async {
    final trimmed = word.trim().toLowerCase();
    if (trimmed.isEmpty) {
      throw WordLookupException('Please type a word to look up.');
    }

    final uri = Uri.parse('${AppConfig.datamuseApiBaseUrl}/words').replace(
      queryParameters: {
        'sp': trimmed,
        'qe': 'sp',
        'md': 'dpr',
        'ipa': '1',
        'max': '1',
      },
    );

    try {
      final response = await _client.get(uri).timeout(AppConfig.apiTimeout);

      if (response.statusCode != 200) {
        throw WordLookupException(
          'Something went wrong (code ${response.statusCode}). Please try again.',
        );
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! List || decoded.isEmpty) {
        throw WordNotFoundException(trimmed);
      }

      final result = decoded.first as Map<String, dynamic>;
      final defs = (result['defs'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList();

      if (defs.isEmpty) {
        throw WordNotFoundException(trimmed);
      }

      final tags = (result['tags'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList();

      return _toDictionaryEntry(
        word: result['word'] as String? ?? trimmed,
        defs: defs,
        tags: tags,
      );
    } on WordNotFoundException {
      rethrow;
    } on WordLookupException {
      rethrow;
    } catch (_) {
      throw WordLookupException(
        'Could not reach the dictionary. Check your internet connection.',
      );
    }
  }

  DictionaryEntry _toDictionaryEntry({
    required String word,
    required List<String> defs,
    required List<String> tags,
  }) {
    // Datamuse groups definitions as "pos\tdefinition" strings, e.g.
    // "n\tThe activity of taking part in a dance.". Group them back into
    // per-part-of-speech buckets so they render like dictionary meanings.
    final grouped = <String, List<String>>{};
    for (final entry in defs.take(15)) {
      final tabIndex = entry.indexOf('\t');
      if (tabIndex == -1) continue;
      final posCode = entry.substring(0, tabIndex);
      final definition = entry.substring(tabIndex + 1).trim();
      if (definition.isEmpty) continue;
      final bucket = grouped.putIfAbsent(posCode, () => []);
      if (bucket.length < 3) bucket.add(definition);
    }

    final meanings = grouped.entries
        .map(
          (e) => Meaning(
            partOfSpeech: _posLabel(e.key),
            definitions: e.value
                .map((d) => Definition(definition: d))
                .toList(),
          ),
        )
        .toList();

    return DictionaryEntry(
      word: word,
      phonetic: _extractPhonetic(tags),
      meanings: meanings,
    );
  }

  String? _extractPhonetic(List<String> tags) {
    for (final tag in tags) {
      if (tag.startsWith('ipa_pron:')) {
        final ipa = tag.substring('ipa_pron:'.length).trim();
        return ipa.isEmpty ? null : '/$ipa/';
      }
    }
    return null;
  }

  String _posLabel(String code) {
    switch (code) {
      case 'n':
        return 'Noun';
      case 'v':
        return 'Verb';
      case 'adj':
        return 'Adjective';
      case 'adv':
        return 'Adverb';
      default:
        return 'Other';
    }
  }

  void dispose() => _client.close();
}
