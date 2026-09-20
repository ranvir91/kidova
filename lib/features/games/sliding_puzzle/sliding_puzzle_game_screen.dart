import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/bouncy_button.dart';
import '../../../data/services/progress_provider.dart';

enum _Status { ready, playing, solved }

const int _gridSize = 4;
const int _tileCount = _gridSize * _gridSize; // 16 cells, 15 tiles + 1 blank
const int _blank = 0;

class SlidingPuzzleGameScreen extends StatefulWidget {
  const SlidingPuzzleGameScreen({super.key});

  @override
  State<SlidingPuzzleGameScreen> createState() =>
      _SlidingPuzzleGameScreenState();
}

class _SlidingPuzzleGameScreenState extends State<SlidingPuzzleGameScreen> {
  final Random _random = Random();
  final ConfettiController _confetti = ConfettiController(
    duration: const Duration(seconds: 1),
  );

  _Status _status = _Status.ready;
  List<int> _tiles = List.generate(_tileCount - 1, (i) => i + 1)..add(_blank);
  int _moves = 0;

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  List<int> _neighborsOf(int index) {
    final row = index ~/ _gridSize;
    final col = index % _gridSize;
    return [
      if (row > 0) index - _gridSize,
      if (row < _gridSize - 1) index + _gridSize,
      if (col > 0) index - 1,
      if (col < _gridSize - 1) index + 1,
    ];
  }

  bool _isSolved(List<int> tiles) {
    for (var i = 0; i < _tileCount - 1; i++) {
      if (tiles[i] != i + 1) return false;
    }
    return tiles[_tileCount - 1] == _blank;
  }

  List<int> _shuffledTiles() {
    final tiles = List.generate(_tileCount - 1, (i) => i + 1)..add(_blank);
    var blankIndex = _tileCount - 1;
    var lastIndex = -1;

    // Shuffle by performing many random valid slides from the solved
    // state. This always yields a solvable board, unlike a plain random
    // permutation (only half of which are solvable for this puzzle).
    for (var i = 0; i < 300; i++) {
      final options = _neighborsOf(
        blankIndex,
      ).where((n) => n != lastIndex).toList();
      final next = options[_random.nextInt(options.length)];
      tiles[blankIndex] = tiles[next];
      tiles[next] = _blank;
      lastIndex = blankIndex;
      blankIndex = next;
    }

    return tiles;
  }

  void _startGame() {
    setState(() {
      _tiles = _shuffledTiles();
      _moves = 0;
      _status = _Status.playing;
    });
  }

  void _tapTile(int index) {
    if (_status != _Status.playing) return;
    final blankIndex = _tiles.indexOf(_blank);
    if (!_neighborsOf(blankIndex).contains(index)) return;

    setState(() {
      _tiles[blankIndex] = _tiles[index];
      _tiles[index] = _blank;
      _moves++;
      if (_isSolved(_tiles)) {
        _status = _Status.solved;
        _confetti.play();
        context.read<ProgressProvider>().addStars(15);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Number Slide')),
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          _status == _Status.ready
              ? _ReadyView(onStart: _startGame)
              : _PlayView(
                  tiles: _tiles,
                  status: _status,
                  moves: _moves,
                  onTapTile: _tapTile,
                  onPlayAgain: _startGame,
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

class _ReadyView extends StatelessWidget {
  final VoidCallback onStart;

  const _ReadyView({required this.onStart});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🔢', style: TextStyle(fontSize: 72)),
            const SizedBox(height: 16),
            const Text(
              'Put the numbers in order!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tap a tile next to the empty space to slide it. '
              'Line up 1 to 15 to win!',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textMuted),
            ),
            const SizedBox(height: 24),
            BouncyButton(
              onTap: onStart,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Start Game',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlayView extends StatelessWidget {
  final List<int> tiles;
  final _Status status;
  final int moves;
  final ValueChanged<int> onTapTile;
  final VoidCallback onPlayAgain;

  const _PlayView({
    required this.tiles,
    required this.status,
    required this.moves,
    required this.onTapTile,
    required this.onPlayAgain,
  });

  @override
  Widget build(BuildContext context) {
    final solved = status == _Status.solved;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            solved ? 'Solved! 🎉' : 'Moves: $moves',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              const boardPadding = 8.0;
              const tileSpacing = 6.0;
              final boardSize = min(constraints.maxWidth, 360.0);
              final innerSize = boardSize - boardPadding * 2;
              final tileSize =
                  (innerSize - (_gridSize - 1) * tileSpacing) / _gridSize;

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
                  mainAxisSpacing: tileSpacing,
                  crossAxisSpacing: tileSpacing,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    for (var index = 0; index < _tileCount; index++)
                      _NumberTile(
                        value: tiles[index],
                        size: tileSize,
                        onTap: () => onTapTile(index),
                      ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          if (solved) ...[
            const Text(
              '+15 stars earned',
              style: TextStyle(color: AppColors.textMuted),
            ),
            const SizedBox(height: 16),
          ],
          BouncyButton(
            onTap: onPlayAgain,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 28,
                vertical: 14,
              ),
              decoration: BoxDecoration(
                color: solved ? AppColors.primary : AppColors.secondary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                solved ? 'Play Again' : 'Shuffle Again',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NumberTile extends StatelessWidget {
  final int value;
  final double size;
  final VoidCallback onTap;

  const _NumberTile({
    required this.value,
    required this.size,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (value == _blank) {
      return SizedBox(width: size, height: size);
    }

    return BouncyButton(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          '$value',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 22,
          ),
        ),
      ),
    );
  }
}
