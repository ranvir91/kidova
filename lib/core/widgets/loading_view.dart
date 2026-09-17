import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// A friendly loading state with a bouncing emoji instead of a plain
/// spinner, to keep things playful while data loads.
class LoadingView extends StatefulWidget {
  final String message;

  const LoadingView({super.key, this.message = 'Loading fun stuff...'});

  @override
  State<LoadingView> createState() => _LoadingViewState();
}

class _LoadingViewState extends State<LoadingView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, -12 * _controller.value),
                child: child,
              );
            },
            child: const Text('📚', style: TextStyle(fontSize: 56)),
          ),
          const SizedBox(height: 16),
          Text(
            widget.message,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
