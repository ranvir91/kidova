/// A curated bank of kid-friendly words used for the Word of the Day
/// feature and as the source pool for vocabulary games.
///
/// Kept deliberately simple/short so lookups against the dictionary API
/// return kid-appropriate results.
class WordBank {
  WordBank._();

  static const List<String> words = [
    'brave',
    'giggle',
    'sparkle',
    'wonder',
    'gentle',
    'curious',
    'dancing',
    'friendship',
    'courage',
    'imagine',
    'rainbow',
    'adventure',
    'kindness',
    'giant',
    'whisper',
    'treasure',
    'magic',
    'bright',
    'explore',
    'happy',
    'dream',
    'puzzle',
    'gallop',
    'twinkle',
    'brilliant',
    'cheerful',
    'discover',
    'enormous',
    'fantastic',
    'glorious',
    'harmony',
    'journey',
    'laughter',
    'mystery',
    'nimble',
    'orbit',
    'playful',
    'quiet',
    'roar',
    'silly',
    'tiny',
    'unique',
    'vivid',
    'wander',
    'zany',
    'blossom',
    'cozy',
    'dazzle',
    'echo',
    'feather',
  ];

  /// Deterministically picks a word for a given [date] so every user sees
  /// the same "Word of the Day" and it stays stable if opened again later
  /// the same day.
  static String wordForDate(DateTime date) {
    final dayOfYear = int.parse(
      '${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}',
    );
    final index = dayOfYear % words.length;
    return words[index];
  }
}
