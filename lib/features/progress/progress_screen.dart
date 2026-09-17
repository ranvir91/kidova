import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/kid_card.dart';
import '../../core/widgets/section_header.dart';
import '../../data/services/progress_provider.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('My Progress')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  emoji: '🔥',
                  label: 'Day Streak',
                  value: '${progress.currentStreak}',
                  gradient: AppColors.sunGradient,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _StatCard(
                  emoji: '⭐',
                  label: 'Stars Earned',
                  value: '${progress.stars}',
                  gradient: AppColors.funGradient,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  emoji: '📖',
                  label: 'Words Learned',
                  value: '${progress.learnedWordsCount}',
                  gradient: AppColors.leafGradient,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _StatCard(
                  emoji: '🏆',
                  label: 'Best Streak',
                  value: '${progress.longestStreak}',
                  gradient: AppColors.oceanGradient,
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          const SectionHeader(title: 'Badges', emoji: '🎖️'),
          const SizedBox(height: 12),
          _BadgeGrid(progress: progress),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String emoji;
  final String label;
  final String value;
  final List<Color> gradient;

  const _StatCard({
    required this.emoji,
    required this.label,
    required this.value,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return KidCard(
      gradient: gradient,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _BadgeGrid extends StatelessWidget {
  final ProgressProvider progress;

  const _BadgeGrid({required this.progress});

  @override
  Widget build(BuildContext context) {
    final badges = [
      (
        '🌱',
        'First Word',
        progress.learnedWordsCount >= 1,
      ),
      (
        '📚',
        '10 Words',
        progress.learnedWordsCount >= 10,
      ),
      (
        '🔥',
        '3 Day Streak',
        progress.longestStreak >= 3,
      ),
      (
        '🏅',
        '7 Day Streak',
        progress.longestStreak >= 7,
      ),
      (
        '💎',
        '50 Stars',
        progress.stars >= 50,
      ),
      (
        '👑',
        '100 Stars',
        progress.stars >= 100,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: badges.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.85,
      ),
      itemBuilder: (context, index) {
        final (emoji, label, unlocked) = badges[index];
        return Opacity(
          opacity: unlocked ? 1 : 0.35,
          child: KidCard(
            padding: const EdgeInsets.all(12),
            color: Colors.white,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(emoji, style: const TextStyle(fontSize: 32)),
                const SizedBox(height: 8),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
