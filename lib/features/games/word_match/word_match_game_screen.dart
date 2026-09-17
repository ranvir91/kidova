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

class _Round {
  final String word;
  final String correctDefinition;
  final List<String> options;

  _Round({
    required this.word,
    required this.correctDefinition,
    required this.options,
  });
}

class WordMatchGameScreen extends StatefulWidget {
  const WordMatchGameScreen({super.key});

  @override
  State<WordMatchGameScreen> createState() => _WordMatchGameScreenState();
}

class _WordMatchGameScreenState extends State<WordMatchGameScreen> {
  static const int _roundCount = 5;

  final DatamuseService _service = DatamuseService();
  final ConfettiController _confetti = ConfettiController(
    duration: const Duration(seconds: 1),
  );

  late Future<List<_Round>> _future;
  int _currentIndex = 0;
  int _score = 0;
  String? _selectedOption;
  bool? _wasCorrect;
  bool _finished = false;

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

  Future<List<_Round>> _buildRounds() async {
    final words = List<String>.from(WordBank.words)..shuffle();
    final candidates = words.take(_roundCount + 3).toList();

    final definitions = <String, String>{};
    for (final word in candidates) {
      if (definitions.length >= _roundCount) break;
      try {
        final entry = await _service.lookupWord(word);
        final def = entry.primaryDefinition;
        if (def != null && def.isNotEmpty) {
          definitions[word] = def;
        }
      } catch (_) {
        // Skip words the API can't resolve and try the next candidate.
      }
    }

    if (definitions.length < 2) {
      throw WordLookupException(
        'Not enough words loaded to play. Please try again.',
      );
    }

    final entries = definitions.entries.toList();
    final rounds = <_Round>[];
    final random = Random();

    for (final entry in entries) {
      final distractors = entries.where((e) => e.key != entry.key).toList()
        ..shuffle(random);
      final wrongDefs = distractors.take(3).map((e) => e.value).toList();
      final options = [entry.value, ...wrongDefs]..shuffle(random);
      rounds.add(
        _Round(
          word: entry.key,
          correctDefinition: entry.value,
          options: options,
        ),
      );
    }

    return rounds;
  }

  void _selectOption(_Round round, String option) {
    if (_selectedOption != null) return;
    final correct = option == round.correctDefinition;
    setState(() {
      _selectedOption = option;
      _wasCorrect = correct;
      if (correct) {
        _score++;
        _confetti.play();
      }
    });

    Future.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      setState(() {
        _selectedOption = null;
        _wasCorrect = null;
        if (_currentIndex < _lastRoundIndex) {
          _currentIndex++;
        } else {
          _finished = true;
        }
      });
      if (_finished) {
        context.read<ProgressProvider>().addStars(_score * 2);
      }
    });
  }

  int _lastRoundIndex = 0;

  void _restart() {
    setState(() {
      _currentIndex = 0;
      _score = 0;
      _selectedOption = null;
      _wasCorrect = null;
      _finished = false;
      _future = _buildRounds();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Match the Meaning')),
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          FutureBuilder<List<_Round>>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const LoadingView(message: 'Preparing your game...');
              }
              if (snapshot.hasError) {
                return ErrorView(
                  message: snapshot.error.toString(),
                  onRetry: _restart,
                );
              }
              final rounds = snapshot.data!;
              _lastRoundIndex = rounds.length - 1;

              if (_finished) {
                return _ResultView(
                  score: _score,
                  total: rounds.length,
                  onPlayAgain: _restart,
                );
              }

              final round = rounds[_currentIndex];
              return _RoundView(
                round: round,
                roundNumber: _currentIndex + 1,
                totalRounds: rounds.length,
                score: _score,
                selectedOption: _selectedOption,
                wasCorrect: _wasCorrect,
                onSelect: (option) => _selectOption(round, option),
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

class _RoundView extends StatelessWidget {
  final _Round round;
  final int roundNumber;
  final int totalRounds;
  final int score;
  final String? selectedOption;
  final bool? wasCorrect;
  final ValueChanged<String> onSelect;

  const _RoundView({
    required this.round,
    required this.roundNumber,
    required this.totalRounds,
    required this.score,
    required this.selectedOption,
    required this.wasCorrect,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Round $roundNumber / $totalRounds',
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
          KidCard(
            gradient: AppColors.funGradient,
            child: Center(
              child: Text(
                round.word,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'What does this word mean?',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              itemCount: round.options.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final option = round.options[index];
                Color color = Colors.white;
                if (selectedOption != null) {
                  if (option == round.correctDefinition) {
                    color = AppColors.accentGreen.withValues(alpha: 0.25);
                  } else if (option == selectedOption) {
                    color = AppColors.accentPink.withValues(alpha: 0.25);
                  }
                }
                return BouncyButton(
                  onTap: selectedOption == null ? () => onSelect(option) : null,
                  child: KidCard(
                    color: color,
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      option,
                      style: const TextStyle(fontSize: 15, height: 1.3),
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

class _ResultView extends StatelessWidget {
  final int score;
  final int total;
  final VoidCallback onPlayAgain;

  const _ResultView({
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
              'You scored $score / $total!',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '+${score * 2} stars earned',
              style: const TextStyle(color: AppColors.textMuted),
            ),
            const SizedBox(height: 24),
            BouncyButton(
              onTap: onPlayAgain,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Play Again',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
