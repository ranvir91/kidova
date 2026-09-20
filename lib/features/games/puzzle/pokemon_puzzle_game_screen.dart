import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/bouncy_button.dart';
import '../../../core/widgets/kid_card.dart';
import '../../../data/services/progress_provider.dart';

class _PokemonCharacter {
  final String name;
  final String imageUrl;

  const _PokemonCharacter(this.name, this.imageUrl);
}

// Official artwork served by PokeAPI's public sprite repository
// (https://github.com/PokeAPI/sprites), used here for a personal/hobby
// puzzle game. Pokémon and these character images are trademarks and
// copyright of Nintendo/Game Freak/Creatures Inc. — fine for this kind of
// non-commercial fan use, but swap in original artwork before any
// commercial release.
const _characters = [
  _PokemonCharacter(
    'Bulbasaur',
    'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/1.png',
  ),
  _PokemonCharacter(
    'Charmander',
    'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/4.png',
  ),
  _PokemonCharacter(
    'Squirtle',
    'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/7.png',
  ),
  _PokemonCharacter(
    'Pikachu',
    'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/25.png',
  ),
  _PokemonCharacter(
    'Eevee',
    'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/133.png',
  ),
];

const int _gridSize = 3;
const int _pieceCount = _gridSize * _gridSize;

class PokemonPuzzleGameScreen extends StatefulWidget {
  const PokemonPuzzleGameScreen({super.key});

  @override
  State<PokemonPuzzleGameScreen> createState() =>
      _PokemonPuzzleGameScreenState();
}

class _PokemonPuzzleGameScreenState extends State<PokemonPuzzleGameScreen> {
  final ConfettiController _confetti = ConfettiController(
    duration: const Duration(seconds: 1),
  );
  final Random _random = Random();

  _PokemonCharacter? _character;
  late List<int> _order;
  int? _selectedSlot;
  bool _solved = false;

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  void _startPuzzle(_PokemonCharacter character) {
    setState(() {
      _character = character;
      _order = _shuffledOrder();
      _selectedSlot = null;
      _solved = false;
    });
  }

  List<int> _shuffledOrder() {
    final order = List.generate(_pieceCount, (i) => i);
    do {
      order.shuffle(_random);
    } while (_isSolved(order));
    return order;
  }

  bool _isSolved(List<int> order) {
    for (var i = 0; i < order.length; i++) {
      if (order[i] != i) return false;
    }
    return true;
  }

  void _changeCharacter() {
    setState(() => _character = null);
  }

  void _shuffleAgain() {
    setState(() {
      _order = _shuffledOrder();
      _selectedSlot = null;
      _solved = false;
    });
  }

  void _tapSlot(int slot) {
    if (_solved) return;
    setState(() {
      final selected = _selectedSlot;
      if (selected == null) {
        _selectedSlot = slot;
      } else if (selected == slot) {
        _selectedSlot = null;
      } else {
        final temp = _order[selected];
        _order[selected] = _order[slot];
        _order[slot] = temp;
        _selectedSlot = null;
        if (_isSolved(_order)) {
          _solved = true;
          _confetti.play();
          context.read<ProgressProvider>().addStars(10);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final character = _character;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pokémon Puzzle'),
        actions: [
          if (character != null)
            TextButton.icon(
              onPressed: _changeCharacter,
              icon: const Icon(Icons.grid_view_rounded, color: AppColors.primary),
              label: const Text(
                'Characters',
                style: TextStyle(color: AppColors.primary),
              ),
            ),
        ],
      ),
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          character == null
              ? _CharacterPicker(onSelect: _startPuzzle)
              : _PuzzleBoard(
                  character: character,
                  order: _order,
                  selectedSlot: _selectedSlot,
                  solved: _solved,
                  onTapSlot: _tapSlot,
                  onShuffleAgain: _shuffleAgain,
                  onChangeCharacter: _changeCharacter,
                ),
          ConfettiWidget(
            confettiController: _confetti,
            blastDirection: pi / 2,
            numberOfParticles: 24,
            maxBlastForce: 14,
            minBlastForce: 6,
            gravity: 0.3,
            colors: AppColors.cardPalette,
          ),
        ],
      ),
    );
  }
}

class _CharacterPicker extends StatelessWidget {
  final ValueChanged<_PokemonCharacter> onSelect;

  const _CharacterPicker({required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Pick a Character',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Put the pieces back together!',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textMuted),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.95,
              ),
              itemCount: _characters.length,
              itemBuilder: (context, index) {
                final character = _characters[index];
                return BouncyButton(
                  onTap: () => onSelect(character),
                  child: KidCard(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.network(
                              character.imageUrl,
                              fit: BoxFit.contain,
                              loadingBuilder: (context, child, progress) {
                                if (progress == null) return child;
                                return const Center(
                                  child: CircularProgressIndicator(
                                    color: AppColors.primary,
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stack) =>
                                  const Icon(
                                    Icons.image_not_supported_rounded,
                                    color: AppColors.textMuted,
                                    size: 40,
                                  ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          character.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PuzzleBoard extends StatelessWidget {
  final _PokemonCharacter character;
  final List<int> order;
  final int? selectedSlot;
  final bool solved;
  final ValueChanged<int> onTapSlot;
  final VoidCallback onShuffleAgain;
  final VoidCallback onChangeCharacter;

  const _PuzzleBoard({
    required this.character,
    required this.order,
    required this.selectedSlot,
    required this.solved,
    required this.onTapSlot,
    required this.onShuffleAgain,
    required this.onChangeCharacter,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            character.name,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            solved
                ? 'You did it! 🎉'
                : 'Tap two pieces to swap them into place.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textMuted),
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              const boardPadding = 8.0;
              const pieceSpacing = 6.0;
              final boardSize = min(constraints.maxWidth, 360.0);
              final innerSize = boardSize - boardPadding * 2;
              final pieceSize =
                  (innerSize - (_gridSize - 1) * pieceSpacing) / _gridSize;
              return Container(
                width: boardSize,
                height: boardSize,
                padding: const EdgeInsets.all(boardPadding),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: GridView.count(
                  crossAxisCount: _gridSize,
                  mainAxisSpacing: pieceSpacing,
                  crossAxisSpacing: pieceSpacing,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    for (var slot = 0; slot < _pieceCount; slot++)
                      _PuzzlePiece(
                        imageUrl: character.imageUrl,
                        pieceIndex: order[slot],
                        size: pieceSize,
                        selected: selectedSlot == slot,
                        solved: solved,
                        onTap: () => onTapSlot(slot),
                      ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              BouncyButton(
                onTap: onShuffleAgain,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Shuffle Again',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              BouncyButton(
                onTap: onChangeCharacter,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Choose Another',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (solved) ...[
            const SizedBox(height: 12),
            const Text(
              '+10 stars earned',
              style: TextStyle(color: AppColors.textMuted),
            ),
          ],
        ],
      ),
    );
  }
}

class _PuzzlePiece extends StatelessWidget {
  final String imageUrl;
  final int pieceIndex;
  final double size;
  final bool selected;
  final bool solved;
  final VoidCallback onTap;

  const _PuzzlePiece({
    required this.imageUrl,
    required this.pieceIndex,
    required this.size,
    required this.selected,
    required this.solved,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final row = pieceIndex ~/ _gridSize;
    final col = pieceIndex % _gridSize;

    return BouncyButton(
      onTap: solved ? null : onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? AppColors.primary : Colors.white,
            width: selected ? 3 : 1,
          ),
          color: AppColors.background,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: OverflowBox(
            maxWidth: size * _gridSize,
            maxHeight: size * _gridSize,
            alignment: Alignment(-1 + col.toDouble(), -1 + row.toDouble()),
            child: Image.network(
              imageUrl,
              width: size * _gridSize,
              height: size * _gridSize,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return const ColoredBox(color: AppColors.background);
              },
              errorBuilder: (context, error, stack) =>
                  const ColoredBox(color: AppColors.background),
            ),
          ),
        ),
      ),
    );
  }
}
