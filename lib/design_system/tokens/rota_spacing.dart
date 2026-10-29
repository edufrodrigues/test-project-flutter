import 'package:flutter/animation.dart';

/// Espaçamento em escala de 4 px. O número segue o token do React (`--space-4` = 16).
abstract final class RotaSpacing {
  static const double s1 = 4;
  static const double s2 = 8;
  static const double s3 = 12;
  static const double s4 = 16;
  static const double s5 = 20;
  static const double s6 = 24;
  static const double s8 = 32;
  static const double s10 = 40;
  static const double s12 = 48;
  static const double s16 = 64;
}

/// Raios de borda.
abstract final class RotaRadius {
  static const double sm = 6;
  static const double md = 10;
  static const double lg = 16;
  static const double xl = 24;
  static const double full = 999;
}

/// Medidas de layout e pontos de quebra.
abstract final class RotaLayout {
  static const double containerWidth = 1160;
  static const double headerHeight = 64;

  /// A partir desta largura, telas com coluna lateral ficam lado a lado.
  static const double splitBreakpoint = 900;

  /// Abaixo desta largura, a navegação mostra só os ícones.
  static const double compactBreakpoint = 640;
}

/// Durações e curvas de animação.
abstract final class RotaMotion {
  static const Duration fast = Duration(milliseconds: 120);
  static const Duration normal = Duration(milliseconds: 200);
  static const Curve standard = Cubic(0.2, 0, 0, 1);
}
