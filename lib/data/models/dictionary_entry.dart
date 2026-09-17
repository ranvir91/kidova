class DictionaryEntry {
  final String word;
  final String? phonetic;
  final List<Phonetic> phonetics;
  final List<Meaning> meanings;
  final List<String> sourceUrls;

  const DictionaryEntry({
    required this.word,
    this.phonetic,
    this.phonetics = const [],
    this.meanings = const [],
    this.sourceUrls = const [],
  });

  factory DictionaryEntry.fromJson(Map<String, dynamic> json) {
    return DictionaryEntry(
      word: json['word'] as String? ?? '',
      phonetic: json['phonetic'] as String?,
      phonetics: (json['phonetics'] as List<dynamic>? ?? [])
          .map((e) => Phonetic.fromJson(e as Map<String, dynamic>))
          .toList(),
      meanings: (json['meanings'] as List<dynamic>? ?? [])
          .map((e) => Meaning.fromJson(e as Map<String, dynamic>))
          .toList(),
      sourceUrls: (json['sourceUrls'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'word': word,
    'phonetic': phonetic,
    'phonetics': phonetics.map((e) => e.toJson()).toList(),
    'meanings': meanings.map((e) => e.toJson()).toList(),
    'sourceUrls': sourceUrls,
  };

  /// First non-empty pronunciation audio URL, if any.
  String? get audioUrl {
    for (final p in phonetics) {
      if (p.audio != null && p.audio!.isNotEmpty) return p.audio;
    }
    return null;
  }

  /// A short, kid-friendly first definition to use as a preview/hint.
  String? get primaryDefinition {
    for (final m in meanings) {
      for (final d in m.definitions) {
        if (d.definition.isNotEmpty) return d.definition;
      }
    }
    return null;
  }
}

class Phonetic {
  final String? text;
  final String? audio;

  const Phonetic({this.text, this.audio});

  factory Phonetic.fromJson(Map<String, dynamic> json) => Phonetic(
    text: json['text'] as String?,
    audio: json['audio'] as String?,
  );

  Map<String, dynamic> toJson() => {'text': text, 'audio': audio};
}

class Meaning {
  final String partOfSpeech;
  final List<Definition> definitions;
  final List<String> synonyms;
  final List<String> antonyms;

  const Meaning({
    required this.partOfSpeech,
    this.definitions = const [],
    this.synonyms = const [],
    this.antonyms = const [],
  });

  factory Meaning.fromJson(Map<String, dynamic> json) => Meaning(
    partOfSpeech: json['partOfSpeech'] as String? ?? '',
    definitions: (json['definitions'] as List<dynamic>? ?? [])
        .map((e) => Definition.fromJson(e as Map<String, dynamic>))
        .toList(),
    synonyms: (json['synonyms'] as List<dynamic>? ?? [])
        .map((e) => e.toString())
        .toList(),
    antonyms: (json['antonyms'] as List<dynamic>? ?? [])
        .map((e) => e.toString())
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    'partOfSpeech': partOfSpeech,
    'definitions': definitions.map((e) => e.toJson()).toList(),
    'synonyms': synonyms,
    'antonyms': antonyms,
  };
}

class Definition {
  final String definition;
  final String? example;
  final List<String> synonyms;
  final List<String> antonyms;

  const Definition({
    required this.definition,
    this.example,
    this.synonyms = const [],
    this.antonyms = const [],
  });

  factory Definition.fromJson(Map<String, dynamic> json) => Definition(
    definition: json['definition'] as String? ?? '',
    example: json['example'] as String?,
    synonyms: (json['synonyms'] as List<dynamic>? ?? [])
        .map((e) => e.toString())
        .toList(),
    antonyms: (json['antonyms'] as List<dynamic>? ?? [])
        .map((e) => e.toString())
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    'definition': definition,
    'example': example,
    'synonyms': synonyms,
    'antonyms': antonyms,
  };
}
