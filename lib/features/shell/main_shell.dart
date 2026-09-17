import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../favorites/favorites_screen.dart';
import '../games/games_home_screen.dart';
import '../search/dictionary_search_screen.dart';
import '../word_of_day/word_of_day_screen.dart';

/// The app's bottom-navigation shell: keeps the four core modules a tap
/// away without overwhelming a young user with too many options.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  static const _screens = [
    WordOfDayScreen(),
    DictionarySearchScreen(),
    GamesHomeScreen(),
    FavoritesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.wb_sunny_rounded),
            label: 'Today',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_rounded),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.videogame_asset_rounded),
            label: 'Games',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.emoji_food_beverage_rounded),
            label: 'Word Jar',
          ),
        ],
        selectedItemColor: AppColors.primary,
      ),
    );
  }
}
