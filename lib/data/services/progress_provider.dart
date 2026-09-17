import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Tracks the child's learning streak, words learned, and stars earned in
/// games. Everything is persisted locally so progress survives app restarts.
class ProgressProvider extends ChangeNotifier {
  static const _streakKey = 'kidova_streak';
  static const _longestStreakKey = 'kidova_longest_streak';
  static const _lastActiveKey = 'kidova_last_active';
  static const _learnedWordsKey = 'kidova_learned_words';
  static const _starsKey = 'kidova_stars';

  int _currentStreak = 0;
  int _longestStreak = 0;
  DateTime? _lastActiveDate;
  final Set<String> _learnedWords = {};
  int _stars = 0;
  bool _isLoaded = false;

  int get currentStreak => _currentStreak;
  int get longestStreak => _longestStreak;
  int get learnedWordsCount => _learnedWords.length;
  int get stars => _stars;
  bool get isLoaded => _isLoaded;

  bool hasLearned(String word) =>
      _learnedWords.contains(word.toLowerCase());

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _currentStreak = prefs.getInt(_streakKey) ?? 0;
    _longestStreak = prefs.getInt(_longestStreakKey) ?? 0;
    final lastActiveIso = prefs.getString(_lastActiveKey);
    _lastActiveDate = lastActiveIso != null
        ? DateTime.tryParse(lastActiveIso)
        : null;
    _learnedWords
      ..clear()
      ..addAll(prefs.getStringList(_learnedWordsKey) ?? []);
    _stars = prefs.getInt(_starsKey) ?? 0;
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> markWordLearned(String word) async {
    final key = word.toLowerCase();
    if (_learnedWords.contains(key)) return;
    _learnedWords.add(key);
    await _recordActivityToday();
    await _persist();
    notifyListeners();
  }

  Future<void> addStars(int amount) async {
    _stars += amount;
    await _recordActivityToday();
    await _persist();
    notifyListeners();
  }

  Future<void> _recordActivityToday() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (_lastActiveDate == null) {
      _currentStreak = 1;
    } else {
      final last = DateTime(
        _lastActiveDate!.year,
        _lastActiveDate!.month,
        _lastActiveDate!.day,
      );
      final daysDiff = today.difference(last).inDays;
      if (daysDiff == 0) {
        // Already active today, streak unchanged.
      } else if (daysDiff == 1) {
        _currentStreak += 1;
      } else {
        _currentStreak = 1;
      }
    }

    _lastActiveDate = today;
    if (_currentStreak > _longestStreak) {
      _longestStreak = _currentStreak;
    }
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_streakKey, _currentStreak);
    await prefs.setInt(_longestStreakKey, _longestStreak);
    if (_lastActiveDate != null) {
      await prefs.setString(
        _lastActiveKey,
        _lastActiveDate!.toIso8601String(),
      );
    }
    await prefs.setStringList(_learnedWordsKey, _learnedWords.toList());
    await prefs.setInt(_starsKey, _stars);
  }
}
