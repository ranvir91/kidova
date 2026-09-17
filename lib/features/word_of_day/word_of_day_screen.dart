import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/brand_mark.dart';
import '../../core/widgets/error_view.dart';
import '../../core/widgets/loading_view.dart';
import '../../core/widgets/section_header.dart';
import '../../data/models/dictionary_entry.dart';
import '../../data/services/progress_provider.dart';
import '../../data/services/wotd_service.dart';
import '../progress/progress_screen.dart';
import '../word_detail/word_detail_view.dart';

class WordOfDayScreen extends StatefulWidget {
  const WordOfDayScreen({super.key});

  @override
  State<WordOfDayScreen> createState() => _WordOfDayScreenState();
}

class _WordOfDayScreenState extends State<WordOfDayScreen> {
  final WotdService _service = WotdService();
  late Future<DictionaryEntry> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<DictionaryEntry> _load() async {
    final entry = await _service.getWordOfToday();
    return entry.toDictionaryEntry();
  }

  void _retry() {
    setState(() => _future = _load());
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressProvider>();

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 64,
        title: const BrandLogoBanner(height: 44),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ProgressScreen()),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accentYellow.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Text('🔥', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 4),
                      Text(
                        '${progress.currentStreak}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: SectionHeader(title: 'Word of the Day', emoji: '🌞'),
            ),
          ),
          Expanded(
            child: FutureBuilder<DictionaryEntry>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LoadingView(message: "Finding today's word...");
                }
                if (snapshot.hasError) {
                  return ErrorView(
                    message: snapshot.error.toString(),
                    onRetry: _retry,
                  );
                }
                final entry = snapshot.data!;
                return WordDetailView(entry: entry);
              },
            ),
          ),
        ],
      ),
    );
  }
}
