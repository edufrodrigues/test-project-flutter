import 'package:flutter/material.dart';

import '../tokens/tokens.dart';

enum RotaAvatarSize { sm, md, lg }

/// Avatar com as iniciais do nome.
class RotaAvatar extends StatelessWidget {
  const RotaAvatar({super.key, required this.name, this.size = RotaAvatarSize.md});

  final String name;
  final RotaAvatarSize size;

  static String initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((part) => part.isNotEmpty).toList();
    if (parts.isEmpty) return '';
    final first = parts.first[0];
    final last = parts.length > 1 ? parts.last[0] : '';
    return (first + last).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.rotaColors;
    final (dimension, fontSize) = switch (size) {
      RotaAvatarSize.sm => (32.0, RotaTypography.xs),
      RotaAvatarSize.md => (40.0, RotaTypography.sm),
      RotaAvatarSize.lg => (80.0, RotaTypography.x2l),
    };
    return Tooltip(
      message: name,
      child: Semantics(
        label: name,
        excludeSemantics: true,
        child: Container(
          width: dimension,
          height: dimension,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: c.primarySoft, shape: BoxShape.circle),
          child: Text(
            initials(name),
            style: TextStyle(
              fontFamily: RotaTypography.fontFamily,
              fontSize: fontSize,
              fontWeight: RotaTypography.semibold,
              color: c.primary,
              height: 1,
            ),
          ),
        ),
      ),
    );
  }
}

/// Nota com estrela e número de avaliações. Ex.: "4,9 (312)".
class RotaRating extends StatelessWidget {
  const RotaRating({super.key, required this.value, this.count});

  final double value;
  final int? count;

  @override
  Widget build(BuildContext context) {
    final c = context.rotaColors;
    final formatted = value.toStringAsFixed(1).replaceAll('.', ',');
    return Semantics(
      label: 'Nota $formatted de 5${count != null ? ', $count avaliações' : ''}',
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_rounded, size: 16, color: c.accent),
          const SizedBox(width: 2),
          Text(formatted, style: RotaTypography.label.copyWith(color: c.text, fontWeight: RotaTypography.semibold)),
          if (count != null) ...[
            const SizedBox(width: RotaSpacing.s1),
            Text('($count)', style: RotaTypography.bodySm.copyWith(color: c.textMuted, height: 1.2)),
          ],
        ],
      ),
    );
  }
}
