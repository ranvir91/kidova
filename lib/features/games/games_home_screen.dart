import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/bouncy_button.dart';
import '../../core/widgets/brand_mark.dart';
import '../../core/widgets/kid_card.dart';
import 'puzzle/pokemon_puzzle_game_screen.dart';
import 'sliding_puzzle/sliding_puzzle_game_screen.dart';
import 'snake/snake_game_screen.dart';
import 'word_match/word_match_game_screen.dart';
import 'word_scramble/word_scramble_game_screen.dart';

class GamesHomeScreen extends StatelessWidget {
  const GamesHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Padding(
          padding: EdgeInsets.all(10),
          child: BrandIconBadge(),
        ),
        title: const Text('Word Games'),
      ),
      body: GridView(
        padding: const EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.8,
        ),
        children: [
          _GameTile(
            emoji: '🧩',
            title: 'Match the\nMeaning',
            gradient: AppColors.funGradient,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const WordMatchGameScreen()),
            ),
          ),
          _GameTile(
            emoji: '🔤',
            title: 'Word\nScramble',
            gradient: AppColors.sunGradient,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const WordScrambleGameScreen(),
              ),
            ),
          ),
          _GameTile(
            emoji: '🧸',
            title: 'Pokémon\nPuzzle',
            gradient: AppColors.oceanGradient,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const PokemonPuzzleGameScreen(),
              ),
            ),
          ),
          _GameTile(
            emoji: '🐍',
            title: 'Snake',
            gradient: AppColors.leafGradient,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SnakeGameScreen()),
            ),
          ),
          _GameTile(
            emoji: '🔢',
            title: 'Number\nSlide',
            gradient: AppColors.berryGradient,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const SlidingPuzzleGameScreen(),
              ),
            ),
          ),
          _GameTile(
            emoji: '✨',
            title: 'More Games\nComing Soon',
            gradient: const [AppColors.textMuted, AppColors.textMuted],
            onTap: null,
          ),
        ],
      ),
    );
  }
}

class _GameTile extends StatelessWidget {
  final String emoji;
  final String title;
  final List<Color> gradient;
  final VoidCallback? onTap;

  const _GameTile({
    required this.emoji,
    required this.title,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BouncyButton(
      onTap: onTap,
      child: KidCard(
        gradient: gradient,
        padding: const EdgeInsets.all(10),
        borderRadius: 20,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 30)),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 12,
                height: 1.25,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
