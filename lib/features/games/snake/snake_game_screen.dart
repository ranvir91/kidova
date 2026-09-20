import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/bouncy_button.dart';
import '../../../core/widgets/kid_card.dart';
import '../../../data/services/progress_provider.dart';

enum _GameStatus { ready, playing, gameOver }

enum _Direction { up, down, left, right }

extension on _Direction {
  Point<int> get offset {
    switch (this) {
      case _Direction.up:
        return const Point(0, -1);
      case _Direction.down:
        return const Point(0, 1);
      case _Direction.left:
        return const Point(-1, 0);
      case _Direction.right:
        return const Point(1, 0);
    }
  }

  bool isOpposite(_Direction other) {
    switch (this) {
      case _Direction.up:
        return other == _Direction.down;
      case _Direction.down:
        return other == _Direction.up;
      case _Direction.left:
        return other == _Direction.right;
      case _Direction.right:
        return other == _Direction.left;
    }
  }
}

const int _columns = 13;
const int _rows = 13;

class SnakeGameScreen extends StatefulWidget {
  const SnakeGameScreen({super.key});

  @override
  State<SnakeGameScreen> createState() => _SnakeGameScreenState();
}

class _SnakeGameScreenState extends State<SnakeGameScreen> {
  final Random _random = Random();
  Timer? _timer;

  _GameStatus _status = _GameStatus.ready;
  late List<Point<int>> _snake;
  late Point<int> _rat;
  _Direction _direction = _Direction.right;
  _Direction _pendingDirection = _Direction.right;
  int _score = 0;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startGame() {
    final centerX = _columns ~/ 2;
    final centerY = _rows ~/ 2;
    _snake = [
      Point(centerX, centerY),
      Point(centerX - 1, centerY),
      Point(centerX - 2, centerY),
    ];
    _direction = _Direction.right;
    _pendingDirection = _Direction.right;
    _score = 0;
    _rat = _randomEmptyCell();
    setState(() => _status = _GameStatus.playing);
    _scheduleNextTick();
  }

  Point<int> _randomEmptyCell() {
    Point<int> cell;
    do {
      cell = Point(_random.nextInt(_columns), _random.nextInt(_rows));
    } while (_snake.contains(cell));
    return cell;
  }

  Duration _tickDuration() =>
      Duration(milliseconds: max(90, 220 - _score * 4));

  void _scheduleNextTick() {
    _timer?.cancel();
    _timer = Timer(_tickDuration(), _tick);
  }

  void _tick() {
    if (_status != _GameStatus.playing) return;

    _direction = _pendingDirection;
    final head = _snake.first;
    final newHead = head + _direction.offset;

    final hitWall =
        newHead.x < 0 ||
        newHead.x >= _columns ||
        newHead.y < 0 ||
        newHead.y >= _rows;
    final hitSelf = _snake.contains(newHead);

    if (hitWall || hitSelf) {
      setState(() => _status = _GameStatus.gameOver);
      return;
    }

    setState(() {
      _snake.insert(0, newHead);
      if (newHead == _rat) {
        _score++;
        context.read<ProgressProvider>().addStars(1);
        _rat = _randomEmptyCell();
      } else {
        _snake.removeLast();
      }
    });

    _scheduleNextTick();
  }

  void _setDirection(_Direction direction) {
    if (_status != _GameStatus.playing) return;
    if (_direction.isOpposite(direction)) return;
    _pendingDirection = direction;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Snake')),
      body: switch (_status) {
        _GameStatus.ready => _ReadyView(onStart: _startGame),
        _GameStatus.playing || _GameStatus.gameOver => _PlayView(
          status: _status,
          snake: _snake,
          rat: _rat,
          score: _score,
          onDirection: _setDirection,
          onPlayAgain: _startGame,
        ),
      },
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
            const Text('🐍', style: TextStyle(fontSize: 72)),
            const SizedBox(height: 16),
            const Text(
              'Help the snake eat rats!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Every rat you eat earns 1 star. Don\'t hit the walls or yourself!',
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
  final _GameStatus status;
  final List<Point<int>> snake;
  final Point<int> rat;
  final int score;
  final ValueChanged<_Direction> onDirection;
  final VoidCallback onPlayAgain;

  const _PlayView({
    required this.status,
    required this.snake,
    required this.rat,
    required this.score,
    required this.onDirection,
    required this.onPlayAgain,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            '🐀 Rats eaten: $score',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final boardSize = min(constraints.maxWidth, 360.0);
              final cellSize = boardSize / _columns;
              return Container(
                width: boardSize,
                height: boardSize,
                decoration: BoxDecoration(
                  color: AppColors.leafGradient.first.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.accentGreen.withValues(alpha: 0.4),
                  ),
                ),
                child: Stack(
                  children: [
                    for (var i = 0; i < snake.length; i++)
                      Positioned(
                        left: snake[i].x * cellSize,
                        top: snake[i].y * cellSize,
                        width: cellSize,
                        height: cellSize,
                        child: Padding(
                          padding: const EdgeInsets.all(1),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: i == 0
                                  ? AppColors.primaryDark
                                  : AppColors.accentGreen,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    Positioned(
                      left: rat.x * cellSize,
                      top: rat.y * cellSize,
                      width: cellSize,
                      height: cellSize,
                      child: Center(
                        child: Text(
                          '🐀',
                          style: TextStyle(fontSize: cellSize * 0.8),
                        ),
                      ),
                    ),
                    if (status == _GameStatus.gameOver)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.45),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  '🏁',
                                  style: TextStyle(fontSize: 44),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Game Over!\n$score rats eaten',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          if (status == _GameStatus.gameOver)
            BouncyButton(
              onTap: onPlayAgain,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Play Again',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
            )
          else
            _DPad(onDirection: onDirection),
        ],
      ),
    );
  }
}

class _DPad extends StatelessWidget {
  final ValueChanged<_Direction> onDirection;

  const _DPad({required this.onDirection});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _DPadButton(
          icon: Icons.keyboard_arrow_up_rounded,
          onTap: () => onDirection(_Direction.up),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _DPadButton(
              icon: Icons.keyboard_arrow_left_rounded,
              onTap: () => onDirection(_Direction.left),
            ),
            const SizedBox(width: 56),
            _DPadButton(
              icon: Icons.keyboard_arrow_right_rounded,
              onTap: () => onDirection(_Direction.right),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _DPadButton(
          icon: Icons.keyboard_arrow_down_rounded,
          onTap: () => onDirection(_Direction.down),
        ),
      ],
    );
  }
}

class _DPadButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _DPadButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BouncyButton(
      onTap: onTap,
      child: KidCard(
        padding: const EdgeInsets.all(14),
        color: AppColors.surface,
        child: Icon(icon, color: AppColors.primary, size: 28),
      ),
    );
  }
}
