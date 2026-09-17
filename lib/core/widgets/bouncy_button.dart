import 'package:flutter/material.dart';

/// A button wrapper that gives a playful scale-down "bounce" on tap,
/// making interactions feel tactile and fun for young users.
class BouncyButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;

  const BouncyButton({super.key, required this.child, this.onTap});

  @override
  State<BouncyButton> createState() => _BouncyButtonState();
}

class _BouncyButtonState extends State<BouncyButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 120),
    lowerBound: 0.0,
    upperBound: 0.08,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onTap == null ? null : (_) => _controller.forward(),
      onTapCancel: widget.onTap == null ? null : () => _controller.reverse(),
      onTapUp: widget.onTap == null
          ? null
          : (_) {
              _controller.reverse();
              widget.onTap!.call();
            },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final scale = 1 - _controller.value;
          return Transform.scale(scale: scale, child: child);
        },
        child: widget.child,
      ),
    );
  }
}
