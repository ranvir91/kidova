/// A curated bank of kid-friendly words used as the source pool for
/// vocabulary games.
///
/// Kept deliberately simple/short so lookups against the dictionary API
/// return kid-appropriate results.
class WordBank {
  WordBank._();

  static const List<String> words = [
    // Short (3-4 letter) words, mainly for easy-mode Word Scramble.
    'cat',
    'dog',
    'sun',
    'fox',
    'owl',
    'bee',
    'ant',
    'pig',
    'hen',
    'cow',
    'toy',
    'fun',
    'joy',
    'moon',
    'bird',
    'fish',
    'frog',
    'lion',
    'bear',
    'duck',
    'star',
    'leaf',
    'rain',
    'snow',
    'kite',
    'cake',
    'roar',
    'tiny',
    'zany',
    'cozy',
    'echo',
    // Medium and longer words.
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
    'silly',
    'unique',
    'vivid',
    'wander',
    'blossom',
    'dazzle',
    'feather',
  ];

  /// Words with a length in the inclusive range [minLength, maxLength].
  static List<String> wordsInRange(int minLength, int maxLength) {
    return words
        .where((w) => w.length >= minLength && w.length <= maxLength)
        .toList();
  }
}
