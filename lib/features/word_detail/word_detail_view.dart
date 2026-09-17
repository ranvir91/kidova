import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/bouncy_button.dart';
import '../../core/widgets/kid_card.dart';
import '../../data/models/dictionary_entry.dart';
import '../../data/services/favorites_provider.dart';
import '../../data/services/progress_provider.dart';

/// Shared "word detail" presentation used by Word of the Day, Search
/// results, and the Word Jar (favorites) so every screen looks and behaves
/// the same way.
class WordDetailView extends StatefulWidget {
  final DictionaryEntry entry;

  const WordDetailView({super.key, required this.entry});

  @override
  State<WordDetailView> createState() => _WordDetailViewState();
}

class _WordDetailViewState extends State<WordDetailView> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playAudio(String url) async {
    try {
      setState(() => _isPlaying = true);
      await _audioPlayer.play(UrlSource(url));
      _audioPlayer.onPlayerComplete.first.then((_) {
        if (mounted) setState(() => _isPlaying = false);
      });
    } catch (_) {
      if (mounted) setState(() => _isPlaying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final entry = widget.entry;
    final favorites = context.watch<FavoritesProvider>();
    final progress = context.watch<ProgressProvider>();
    final isFavorite = favorites.isFavorite(entry.word);
    final hasLearned = progress.hasLearned(entry.word);
    final audioUrl = entry.audioUrl;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          KidCard(
            gradient: AppColors.funGradient,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.word,
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      if ((entry.phonetic ?? '').isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          entry.phonetic!,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (audioUrl != null)
                  BouncyButton(
                    onTap: _isPlaying ? null : () => _playAudio(audioUrl),
                    child: CircleAvatar(
                      radius: 26,
                      backgroundColor: Colors.white,
                      child: Icon(
                        _isPlaying ? Icons.volume_up : Icons.play_arrow,
                        color: AppColors.primary,
                        size: 28,
                      ),
                    ),
                  ),
                const SizedBox(width: 10),
                BouncyButton(
                  onTap: () => favorites.toggle(entry),
                  child: CircleAvatar(
                    radius: 26,
                    backgroundColor: Colors.white,
                    child: Icon(
                      isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
                      color: AppColors.accentYellow,
                      size: 28,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ...entry.meanings.map((meaning) => _MeaningSection(meaning: meaning)),
          const SizedBox(height: 8),
          Center(
            child: BouncyButton(
              onTap: hasLearned
                  ? null
                  : () async {
                      await progress.markWordLearned(entry.word);
                      await progress.addStars(5);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Awesome! +5 stars ⭐'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: hasLearned ? AppColors.accentGreen : AppColors.secondary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      hasLearned ? Icons.check_circle : Icons.emoji_events,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      hasLearned ? 'You learned this!' : 'I learned this!',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _MeaningSection extends StatelessWidget {
  final Meaning meaning;

  const _MeaningSection({required this.meaning});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: KidCard(
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.accentTeal.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                meaning.partOfSpeech,
                style: const TextStyle(
                  color: AppColors.accentTeal,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(height: 12),
            for (final def in meaning.definitions.take(3)) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(fontSize: 16)),
                  Expanded(
                    child: Text(
                      def.definition,
                      style: const TextStyle(fontSize: 15, height: 1.4),
                    ),
                  ),
                ],
              ),
              if ((def.example ?? '').isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(left: 16, top: 4, bottom: 8),
                  child: Text(
                    '"${def.example}"',
                    style: const TextStyle(
                      fontStyle: FontStyle.italic,
                      color: AppColors.textMuted,
                      fontSize: 14,
                    ),
                  ),
                )
              else
                const SizedBox(height: 8),
            ],
          ],
        ),
      ),
    );
  }
}
