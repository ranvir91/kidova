import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/word_bank.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/bouncy_button.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/kid_card.dart';
import '../../../core/widgets/loading_view.dart';
import '../../../data/services/datamuse_service.dart';
import '../../../data/services/progress_provider.dart';

class _ScrambleRound {
  final String word;
  final String? hint;
  final List<String> scrambledLetters;

  _ScrambleRound({
    required this.word,
    required this.hint,
    required this.scrambledLetters,
  });
}

class WordScrambleGameScreen extends StatefulWidget {
  const WordScrambleGameScreen({super.key});

  @override
  State<WordScrambleGameScreen> createState() =>
      _WordScrambleGameScreenState();
}

class _WordScrambleGameScreenState extends State<WordScrambleGameScreen> {
  static const int _roundCount = 5;

  final DatamuseService _service = DatamuseService();
  final ConfettiController _confetti = ConfettiController(
    duration: const Duration(seconds: 1),
  );
  final Random _random = Random();

  late Future<List<_ScrambleRound>> _future;
  int _currentIndex = 0;
  int _score = 0;
  bool _finished = false;
  bool _showHint = false;
  List<int> _selectedLetterIndexes = [];
  bool? _wasCorrect;

  @override
  void initState() {
    super.initState();
    _future = _buildRounds();
  }

  @override
  void dispose() {
    _service.dispose();
    _confetti.dispose();
    super.dispose();
  }

  List<String> _scramble(String word) {
    final letters = word.split('')..shuffle(_random);
    if (letters.join() == word && word.length > 1) {
      letters.shuffle(_random);
    }
    return letters;
  }

  Future<List<_ScrambleRound>> _buildRounds() async {
    final words = List<String>.from(
      WordBank.words.where((w) => w.length >= 4 && w.length <= 9),
    )..shuffle();
    final candidates = words.take(_roundCount + 3).toList();

    final rounds = <_ScrambleRound>[];
    for (final word in candidates) {
      if (rounds.length >= _roundCount) break;
      try {
        final entry = await _service.lookupWord(word);
        rounds.add(
          _ScrambleRound(
            word: word,
            hint: entry.primaryDefinition,
            scrambledLetters: _scramble(word),
          ),
        );
      } catch (_) {
        // Skip words the API can't resolve.
      }
    }

    if (rounds.isEmpty) {
      throw WordLookupException(
        'Could not load a game right now. Please try again.',
      );
    }

    return rounds;
  }

  void _tapLetter(_ScrambleRound round, int letterIndex) {
    if (_wasCorrect == true) return;
    setState(() {
      _selectedLetterIndexes.add(letterIndex);
    });
    _checkCompletion(round);
  }

  void _removeSelected(int position) {
    if (_wasCorrect == true) return;
    setState(() {
      _selectedLetterIndexes.removeAt(position);
    });
  }

  void _checkCompletion(_ScrambleRound round) {
    if (_selectedLetterIndexes.length != round.word.length) return;
    final attempt = _selectedLetterIndexes
        .map((i) => round.scrambledLetters[i])
        .join();
    final correct = attempt == round.word;

    setState(() => _wasCorrect = correct);

    if (correct) {
      _score++;
      _confetti.play();
      Future.delayed(const Duration(milliseconds: 900), _nextRound);
    } else {
      Future.delayed(const Duration(milliseconds: 600), () {
        if (!mounted) return;
        setState(() {
          _selectedLetterIndexes = [];
          _wasCorrect = null;
        });
      });
    }
  }

  int _totalRounds = 0;

  void _nextRound() {
    if (!mounted) return;
    setState(() {
      _selectedLetterIndexes = [];
      _wasCorrect = null;
      _showHint = false;
      if (_currentIndex < _totalRounds - 1) {
        _currentIndex++;
      } else {
        _finished = true;
        context.read<ProgressProvider>().addStars(_score * 3);
      }
    });
  }

  void _restart() {
    setState(() {
      _currentIndex = 0;
      _score = 0;
      _finished = false;
      _showHint = false;
      _selectedLetterIndexes = [];
      _wasCorrect = null;
      _future = _buildRounds();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Word Scramble')),
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          FutureBuilder<List<_ScrambleRound>>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const LoadingView(message: 'Shuffling letters...');
              }
              if (snapshot.hasError) {
                return ErrorView(
                  message: snapshot.error.toString(),
                  onRetry: _restart,
                );
              }
              final rounds = snapshot.data!;
              _totalRounds = rounds.length;

              if (_finished) {
                return _ScrambleResultView(
                  score: _score,
                  total: rounds.length,
                  onPlayAgain: _restart,
                );
              }

              final round = rounds[_currentIndex];
              return _ScrambleRoundView(
                round: round,
                roundNumber: _currentIndex + 1,
                totalRounds: rounds.length,
                score: _score,
                selectedLetterIndexes: _selectedLetterIndexes,
                wasCorrect: _wasCorrect,
                showHint: _showHint,
                onToggleHint: () => setState(() => _showHint = !_showHint),
                onTapLetter: (i) => _tapLetter(round, i),
                onRemoveSelected: _removeSelected,
              );
            },
          ),
          ConfettiWidget(
            confettiController: _confetti,
            blastDirection: pi / 2,
            numberOfParticles: 20,
            maxBlastForce: 12,
            minBlastForce: 6,
            gravity: 0.3,
            colors: AppColors.cardPalette,
          ),
        ],
      ),
    );
  }
}

class _ScrambleRoundView extends StatelessWidget {
  final _ScrambleRound round;
  final int roundNumber;
  final int totalRounds;
  final int score;
  final List<int> selectedLetterIndexes;
  final bool? wasCorrect;
  final bool showHint;
  final VoidCallback onToggleHint;
  final ValueChanged<int> onTapLetter;
  final ValueChanged<int> onRemoveSelected;

  const _ScrambleRoundView({
    required this.round,
    required this.roundNumber,
    required this.totalRounds,
    required this.score,
    required this.selectedLetterIndexes,
    required this.wasCorrect,
    required this.showHint,
    required this.onToggleHint,
    required this.onTapLetter,
    required this.onRemoveSelected,
  });

  @override
  Widget build(BuildContext context) {
    final availableIndexes = List.generate(
      round.scrambledLetters.length,
      (i) => i,
    ).where((i) => !selectedLetterIndexes.contains(i)).toList();

    final feedbackColor = wasCorrect == null
        ? AppColors.primary.withValues(alpha: 0.08)
        : (wasCorrect!
              ? AppColors.accentGreen.withValues(alpha: 0.15)
              : AppColors.accentPink.withValues(alpha: 0.15));

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Word $roundNumber / $totalRounds',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textMuted,
                ),
              ),
              Text(
                '⭐ $score',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            height: 72,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: feedbackColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Wrap(
                spacing: 8,
                children: [
                  for (int pos = 0; pos < selectedLetterIndexes.length; pos++)
                    BouncyButton(
                      onTap: wasCorrect == true
                          ? null
                          : () => onRemoveSelected(pos),
                      child: _LetterTile(
                        letter: round
                            .scrambledLetters[selectedLetterIndexes[pos]],
                        filled: true,
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: [
              for (final i in availableIndexes)
                BouncyButton(
                  onTap: () => onTapLetter(i),
                  child: _LetterTile(letter: round.scrambledLetters[i]),
                ),
            ],
          ),
          const SizedBox(height: 20),
          if ((round.hint ?? '').isNotEmpty)
            Center(
              child: TextButton.icon(
                onPressed: onToggleHint,
                icon: const Icon(Icons.lightbulb, color: AppColors.accentYellow),
                label: Text(showHint ? 'Hide Hint' : 'Show Hint'),
              ),
            ),
          if (showHint && (round.hint ?? '').isNotEmpty)
            KidCard(
              color: AppColors.accentYellow.withValues(alpha: 0.15),
              child: Text(round.hint!, style: const TextStyle(fontSize: 14)),
            ),
        ],
      ),
    );
  }
}

class _LetterTile extends StatelessWidget {
  final String letter;
  final bool filled;

  const _LetterTile({required this.letter, this.filled = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 52,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: filled ? AppColors.primary : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        letter.toUpperCase(),
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: filled ? Colors.white : AppColors.textDark,
        ),
      ),
    );
  }
}

class _ScrambleResultView extends StatelessWidget {
  final int score;
  final int total;
  final VoidCallback onPlayAgain;

  const _ScrambleResultView({
    required this.score,
    required this.total,
    required this.onPlayAgain,
  });

  @override
  Widget build(BuildContext context) {
    final emoji = score == total ? '🏆' : (score >= total / 2 ? '🎉' : '💪');
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 72)),
            const SizedBox(height: 16),
            Text(
              'You unscrambled $score / $total words!',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '+${score * 3} stars earned',
              style: const TextStyle(color: AppColors.textMuted),
            ),
            const SizedBox(height: 24),
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
            ),
          ],
        ),
      ),
    );
  }
}
