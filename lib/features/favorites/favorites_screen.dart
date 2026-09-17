import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/bouncy_button.dart';
import '../../core/widgets/brand_mark.dart';
import '../../core/widgets/error_view.dart';
import '../../core/widgets/kid_card.dart';
import '../../data/services/favorites_provider.dart';
import '../word_detail/word_detail_view.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<FavoritesProvider>();

    return Scaffold(
      appBar: AppBar(
        leading: const Padding(
          padding: EdgeInsets.all(10),
          child: BrandIconBadge(),
        ),
        title: const Text('My Word Jar'),
      ),
      body: favorites.favorites.isEmpty
          ? const ErrorView(
              emoji: '🍯',
              message: 'Your word jar is empty.\nTap the star on any word to save it here!',
            )
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: favorites.favorites.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final fav = favorites.favorites[index];
                final color = AppColors.cardPalette[index % AppColors.cardPalette.length];
                return BouncyButton(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => Scaffold(
                        appBar: AppBar(title: Text(fav.word)),
                        body: WordDetailView(entry: fav.entry),
                      ),
                    ),
                  ),
                  child: KidCard(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 18,
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: color.withValues(alpha: 0.15),
                          child: Text(
                            fav.word.isNotEmpty ? fav.word[0].toUpperCase() : '?',
                            style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                fav.word,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textDark,
                                ),
                              ),
                              if (fav.entry.primaryDefinition != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Text(
                                    fav.entry.primaryDefinition!,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: AppColors.textMuted,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
                          onPressed: () => favorites.remove(fav.word),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
