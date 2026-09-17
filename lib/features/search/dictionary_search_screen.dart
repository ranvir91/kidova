import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/brand_mark.dart';
import '../../core/widgets/error_view.dart';
import '../../core/widgets/loading_view.dart';
import '../../data/models/dictionary_entry.dart';
import '../../data/services/datamuse_service.dart';
import '../word_detail/word_detail_view.dart';

enum _SearchStatus { idle, loading, success, error }

class DictionarySearchScreen extends StatefulWidget {
  const DictionarySearchScreen({super.key});

  @override
  State<DictionarySearchScreen> createState() =>
      _DictionarySearchScreenState();
}

class _DictionarySearchScreenState extends State<DictionarySearchScreen> {
  final DatamuseService _service = DatamuseService();
  final TextEditingController _controller = TextEditingController();

  _SearchStatus _status = _SearchStatus.idle;
  DictionaryEntry? _entry;
  String? _errorMessage;

  @override
  void dispose() {
    _service.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final word = _controller.text.trim();
    if (word.isEmpty) return;

    setState(() => _status = _SearchStatus.loading);
    try {
      final entry = await _service.lookupWord(word);
      setState(() {
        _entry = entry;
        _status = _SearchStatus.success;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _status = _SearchStatus.error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Padding(
          padding: EdgeInsets.all(10),
          child: BrandIconBadge(),
        ),
        title: const Text('Look Up a Word'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: TextField(
              controller: _controller,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _search(),
              style: const TextStyle(fontSize: 18),
              decoration: InputDecoration(
                hintText: 'Type a word, like "dancing"',
                prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.arrow_forward_rounded),
                  color: AppColors.primary,
                  onPressed: _search,
                ),
              ),
            ),
          ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_status) {
      case _SearchStatus.idle:
        return const ErrorView(
          emoji: '🔎',
          message: 'Search any word to discover its meaning!',
        );
      case _SearchStatus.loading:
        return const LoadingView(message: 'Searching the dictionary...');
      case _SearchStatus.error:
        return ErrorView(message: _errorMessage ?? 'Something went wrong.', onRetry: _search);
      case _SearchStatus.success:
        return WordDetailView(entry: _entry!);
    }
  }
}
