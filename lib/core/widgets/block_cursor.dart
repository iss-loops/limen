import 'package:flutter/material.dart';

/// Cursor de bloque parpadeante. Respeta `reduce motion`: si se pide, queda
/// sólido (sin parpadeo).
class BlockCursor extends StatefulWidget {
  final Color color;
  final double width;
  final double height;

  const BlockCursor({
    super.key,
    required this.color,
    this.width = 10,
    this.height = 20,
  });

  @override
  State<BlockCursor> createState() => _BlockCursorState();
}

class _BlockCursorState extends State<BlockCursor>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final block = Container(
      width: widget.width,
      height: widget.height,
      color: widget.color,
    );
    if (reduceMotion) return block;

    return FadeTransition(
      opacity: _Blink(_controller),
      child: block,
    );
  }
}

/// Parpadeo cuadrado (on/off duro), no senoidal: estética de terminal.
class _Blink extends Animation<double>
    with AnimationWithParentMixin<double> {
  final Animation<double> _parent;
  _Blink(this._parent);

  @override
  Animation<double> get parent => _parent;

  @override
  double get value => _parent.value < 0.5 ? 1 : 0;
}
