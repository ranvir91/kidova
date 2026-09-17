import 'dictionary_entry.dart';

/// A word a child has saved to their "Word Jar", with a cached copy of its
/// dictionary entry so it can be reopened without another network call.
class FavoriteWord {
  final DictionaryEntry entry;
  final DateTime savedAt;

  const FavoriteWord({required this.entry, required this.savedAt});

  String get word => entry.word;

  factory FavoriteWord.fromJson(Map<String, dynamic> json) => FavoriteWord(
    entry: DictionaryEntry.fromJson(json['entry'] as Map<String, dynamic>),
    savedAt: DateTime.tryParse(json['savedAt'] as String? ?? '') ?? DateTime.now(),
  );

  Map<String, dynamic> toJson() => {
    'entry': entry.toJson(),
    'savedAt': savedAt.toIso8601String(),
  };
}
