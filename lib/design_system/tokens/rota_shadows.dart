import 'package:flutter/material.dart';

/// Sombras do Rota. Variam entre os temas claro e escuro.
@immutable
class RotaShadows extends ThemeExtension<RotaShadows> {
  const RotaShadows({required this.sm, required this.md, required this.lg});

  final List<BoxShadow> sm;
  final List<BoxShadow> md;
  final List<BoxShadow> lg;

  static const light = RotaShadows(
    sm: [BoxShadow(color: Color(0x0F101814), offset: Offset(0, 1), blurRadius: 2)],
    md: [BoxShadow(color: Color(0x14101814), offset: Offset(0, 4), blurRadius: 12)],
    lg: [BoxShadow(color: Color(0x29101814), offset: Offset(0, 16), blurRadius: 40)],
  );

  static const dark = RotaShadows(
    sm: [BoxShadow(color: Color(0x4D000000), offset: Offset(0, 1), blurRadius: 2)],
    md: [BoxShadow(color: Color(0x59000000), offset: Offset(0, 4), blurRadius: 12)],
    lg: [BoxShadow(color: Color(0x80000000), offset: Offset(0, 16), blurRadius: 40)],
  );

  @override
  RotaShadows copyWith({List<BoxShadow>? sm, List<BoxShadow>? md, List<BoxShadow>? lg}) {
    return RotaShadows(sm: sm ?? this.sm, md: md ?? this.md, lg: lg ?? this.lg);
  }

  @override
  RotaShadows lerp(RotaShadows? other, double t) {
    if (other == null) return this;
    return RotaShadows(
      sm: BoxShadow.lerpList(sm, other.sm, t)!,
      md: BoxShadow.lerpList(md, other.md, t)!,
      lg: BoxShadow.lerpList(lg, other.lg, t)!,
    );
  }
}
