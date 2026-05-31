import 'package:flutter/material.dart';

/// Da feedback de pulsado: el hijo se encoge sutilmente (0.96) mientras está
/// presionado (regla `scale-feedback`, HIG/MD). Usa [Listener], que NO absorbe
/// el gesto, así el botón interno sigue recibiendo el tap. Respeta reduce motion.
class PressableScale extends StatefulWidget {
  final Widget child;
  const PressableScale({super.key, required this.child});

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale> {
  bool _down = false;

  void _set(bool v) {
    if (_down != v) setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (reduceMotion) return widget.child;

    return Listener(
      onPointerDown: (_) => _set(true),
      onPointerUp: (_) => _set(false),
      onPointerCancel: (_) => _set(false),
      child: AnimatedScale(
        scale: _down ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 90),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}
