import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/dictionary_entry.dart';
import '../models/favorite_word.dart';

/// Persists the child's saved "Word Jar" (favorite words) to local storage.
class FavoritesProvider extends ChangeNotifier {
  static const _storageKey = 'kidova_favorites';

  final List<FavoriteWord> _favorites = [];
  bool _isLoaded = false;

  List<FavoriteWord> get favorites => List.unmodifiable(
    _favorites..sort((a, b) => b.savedAt.compareTo(a.savedAt)),
  );

  bool get isLoaded => _isLoaded;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_storageKey) ?? [];
    _favorites
      ..clear()
      ..addAll(
        raw.map(
          (e) => FavoriteWord.fromJson(jsonDecode(e) as Map<String, dynamic>),
        ),
      );
    _isLoaded = true;
    notifyListeners();
  }

  bool isFavorite(String word) =>
      _favorites.any((f) => f.word.toLowerCase() == word.toLowerCase());

  Future<void> toggle(DictionaryEntry entry) async {
    if (isFavorite(entry.word)) {
      await remove(entry.word);
    } else {
      await _add(entry);
    }
  }

  Future<void> _add(DictionaryEntry entry) async {
    _favorites.add(FavoriteWord(entry: entry, savedAt: DateTime.now()));
    await _persist();
    notifyListeners();
  }

  Future<void> remove(String word) async {
    _favorites.removeWhere((f) => f.word.toLowerCase() == word.toLowerCase());
    await _persist();
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _storageKey,
      _favorites.map((f) => jsonEncode(f.toJson())).toList(),
    );
  }
}
