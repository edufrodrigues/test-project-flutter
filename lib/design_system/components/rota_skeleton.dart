import 'package:flutter/material.dart';

import '../tokens/tokens.dart';

enum RotaSkeletonShape { text, rect, circle }

/// Bloco pulsante que ocupa o lugar do conteúdo enquanto ele carrega.
class RotaSkeleton extends StatelessWidget {
  const RotaSkeleton({super.key, this.width, this.height, this.shape = RotaSkeletonShape.text});

  /// Sem largura, ocupa todo o espaço disponível.
  final double? width;
  final double? height;
  final RotaSkeletonShape shape;

  @override
  Widget build(BuildContext context) {
    final c = context.rotaColors;
    final radius = switch (shape) {
      RotaSkeletonShape.text => RotaRadius.sm,
      RotaSkeletonShape.rect => RotaRadius.lg,
      RotaSkeletonShape.circle => RotaRadius.full,
    };
    return _Pulse(
      child: Container(
        width: width ?? double.infinity,
        height: height ?? (shape == RotaSkeletonShape.text ? 14 : null),
        decoration: BoxDecoration(color: c.surfaceMuted, borderRadius: BorderRadius.circular(radius)),
      ),
    );
  }
}

/// Agrupa skeletons e avisa leitores de tela que o conteúdo está carregando.
class RotaLoadingRegion extends StatelessWidget {
  const RotaLoadingRegion({super.key, required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Semantics(label: label, liveRegion: true, child: ExcludeSemantics(child: child));
  }
}

class _Pulse extends StatefulWidget {
  const _Pulse({required this.child});

  final Widget child;

  @override
  State<_Pulse> createState() => _PulseState();
}

class _PulseState extends State<_Pulse> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Respeita a preferência do sistema por menos movimento.
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 1, end: 0.45).animate(_controller),
      child: widget.child,
    );
  }
}
