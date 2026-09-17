import 'dictionary_entry.dart';

/// Response shape returned by the Word of the Day API (api.wotd.site).
class WotdEntry {
  final String date;
  final String word;
  final String partOfSpeech;
  final String ipa;
  final String definition;

  const WotdEntry({
    required this.date,
    required this.word,
    required this.partOfSpeech,
    required this.ipa,
    required this.definition,
  });

  factory WotdEntry.fromJson(Map<String, dynamic> json) => WotdEntry(
    date: json['date'] as String? ?? '',
    word: json['word'] as String? ?? '',
    partOfSpeech: json['pos'] as String? ?? '',
    ipa: json['ipa'] as String? ?? '',
    definition: json['definition'] as String? ?? '',
  );

  /// Adapts the WOTD API's flat shape into the app's shared
  /// [DictionaryEntry] model so today's word can reuse the same detail
  /// UI (favorites, "I learned this", etc.) as search results.
  DictionaryEntry toDictionaryEntry() {
    return DictionaryEntry(
      word: word,
      phonetic: ipa.isNotEmpty ? ipa : null,
      meanings: [
        Meaning(
          partOfSpeech: partOfSpeech,
          definitions: [Definition(definition: definition)],
        ),
      ],
    );
  }
}
