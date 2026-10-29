import 'package:flutter/material.dart';

import '../tokens/tokens.dart';

enum RotaCardPadding { none, md, lg }

/// Superfície com borda e sombra. Com `onTap`, ganha estado de hover e clique.
class RotaCard extends StatefulWidget {
  const RotaCard({super.key, required this.child, this.padding = RotaCardPadding.md, this.onTap, this.semanticLabel});

  final Widget child;
  final RotaCardPadding padding;
  final VoidCallback? onTap;

  /// Rótulo lido por leitores de tela quando o card inteiro é clicável.
  final String? semanticLabel;

  @override
  State<RotaCard> createState() => _RotaCardState();
}

class _RotaCardState extends State<RotaCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final c = context.rotaColors;
    final shadows = context.rotaShadows;
    final interactive = widget.onTap != null;
    final padding = switch (widget.padding) {
      RotaCardPadding.none => EdgeInsets.zero,
      RotaCardPadding.md => const EdgeInsets.all(RotaSpacing.s4),
      RotaCardPadding.lg => const EdgeInsets.all(RotaSpacing.s6),
    };
    final radius = BorderRadius.circular(RotaRadius.lg);

    Widget content = Padding(padding: padding, child: widget.child);
    if (interactive) {
      content = Semantics(
        button: true,
        label: widget.semanticLabel,
        child: InkWell(
          onTap: widget.onTap,
          onHover: (value) => setState(() => _hovered = value),
          borderRadius: radius,
          child: content,
        ),
      );
    }

    return AnimatedContainer(
      duration: RotaMotion.normal,
      curve: RotaMotion.standard,
      transform: Matrix4.translationValues(0, _hovered ? -2 : 0, 0),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: radius,
        border: Border.all(color: _hovered ? c.borderStrong : c.border),
        boxShadow: _hovered ? shadows.md : shadows.sm,
      ),
      child: Material(
        type: MaterialType.transparency,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: content,
      ),
    );
  }
}
