import 'package:flutter/material.dart';

import '../tokens/tokens.dart';

/// Tons de feedback usados por Badge, Alert e Toast.
enum RotaTone { neutral, primary, success, warning, danger, info }

extension RotaToneColors on RotaTone {
  /// Retorna (cor forte, cor suave) do tom.
  (Color, Color) colors(RotaColors c) => switch (this) {
    RotaTone.neutral => (c.textMuted, c.surfaceMuted),
    RotaTone.primary => (c.primary, c.primarySoft),
    RotaTone.success => (c.success, c.successSoft),
    RotaTone.warning => (c.warning, c.warningSoft),
    RotaTone.danger => (c.danger, c.dangerSoft),
    RotaTone.info => (c.info, c.infoSoft),
  };

  IconData get icon => switch (this) {
    RotaTone.success => Icons.check_circle_outline,
    RotaTone.warning => Icons.warning_amber_rounded,
    RotaTone.danger => Icons.error_outline,
    _ => Icons.info_outline,
  };
}

/// Etiqueta curta em formato de pílula.
class RotaBadge extends StatelessWidget {
  const RotaBadge({super.key, required this.label, this.tone = RotaTone.neutral, this.icon});

  final String label;
  final RotaTone tone;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final (foreground, background) = tone.colors(context.rotaColors);
    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: RotaSpacing.s2),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(RotaRadius.full)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: foreground),
            const SizedBox(width: RotaSpacing.s1),
          ],
          Text(
            label,
            style: RotaTypography.caption.copyWith(
              color: foreground,
              fontWeight: RotaTypography.semibold,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

/// Mensagem de destaque dentro da página, com título opcional.
class RotaAlert extends StatelessWidget {
  const RotaAlert({super.key, required this.message, this.title, this.tone = RotaTone.info});

  final String? title;
  final String message;
  final RotaTone tone;

  @override
  Widget build(BuildContext context) {
    final c = context.rotaColors;
    final (foreground, background) = tone.colors(c);
    return Semantics(
      liveRegion: true,
      container: true,
      child: Container(
        padding: const EdgeInsets.all(RotaSpacing.s4),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(RotaRadius.md),
          border: Border.all(color: foreground.withValues(alpha: 0.25)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(tone.icon, size: 20, color: foreground),
            const SizedBox(width: RotaSpacing.s3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (title != null) ...[
                    Text(title!, style: RotaTypography.label.copyWith(color: c.text, fontWeight: RotaTypography.semibold)),
                    const SizedBox(height: RotaSpacing.s1),
                  ],
                  Text(message, style: RotaTypography.bodySm.copyWith(color: c.textMuted)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
