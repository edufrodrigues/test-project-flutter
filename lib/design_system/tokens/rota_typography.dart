import 'package:flutter/widgets.dart';

/// Tipografia do Rota. A fonte Inter vem em `assets/fonts/inter`, sem download.
///
/// Os estilos não definem cor: cada componente aplica a cor do token certo.
abstract final class RotaTypography {
  static const String fontFamily = 'Inter';

  // Tamanhos
  static const double xs = 12;
  static const double sm = 14;
  static const double md = 16;
  static const double lg = 18;
  static const double xl = 22;
  static const double x2l = 28;
  static const double x3l = 36;

  // Pesos
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semibold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;

  // Entrelinhas
  static const double leadingTight = 1.2;
  static const double leadingNormal = 1.5;

  // Estilos prontos
  static const TextStyle display = TextStyle(
    fontFamily: fontFamily,
    fontSize: x3l,
    fontWeight: bold,
    height: leadingTight,
    letterSpacing: -0.5,
  );

  static const TextStyle title = TextStyle(
    fontFamily: fontFamily,
    fontSize: x2l,
    fontWeight: bold,
    height: leadingTight,
    letterSpacing: -0.3,
  );

  static const TextStyle sectionTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: lg,
    fontWeight: semibold,
    height: leadingTight,
  );

  static const TextStyle cardTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: md,
    fontWeight: semibold,
    height: leadingTight,
  );

  static const TextStyle body = TextStyle(
    fontFamily: fontFamily,
    fontSize: md,
    fontWeight: regular,
    height: leadingNormal,
  );

  static const TextStyle bodySm = TextStyle(
    fontFamily: fontFamily,
    fontSize: sm,
    fontWeight: regular,
    height: leadingNormal,
  );

  static const TextStyle label = TextStyle(
    fontFamily: fontFamily,
    fontSize: sm,
    fontWeight: medium,
    height: leadingTight,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: xs,
    fontWeight: regular,
    height: leadingNormal,
  );

  static const TextStyle eyebrow = TextStyle(
    fontFamily: fontFamily,
    fontSize: xs,
    fontWeight: semibold,
    height: leadingTight,
    letterSpacing: 1.2,
  );
}
