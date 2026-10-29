import 'package:flutter/material.dart';

/// Tokens de cor do Rota.
///
/// Todos os componentes leem as cores daqui (via `context.rotaColors`),
/// nunca de valores soltos. O tema escuro troca só esta extensão.
@immutable
class RotaColors extends ThemeExtension<RotaColors> {
  const RotaColors({
    required this.bg,
    required this.surface,
    required this.surfaceMuted,
    required this.border,
    required this.borderStrong,
    required this.text,
    required this.textMuted,
    required this.textSubtle,
    required this.primary,
    required this.primaryHover,
    required this.primarySoft,
    required this.onPrimary,
    required this.accent,
    required this.accentSoft,
    required this.success,
    required this.successSoft,
    required this.warning,
    required this.warningSoft,
    required this.danger,
    required this.dangerHover,
    required this.dangerSoft,
    required this.info,
    required this.infoSoft,
    required this.overlay,
    required this.focusRing,
  });

  // Base
  final Color bg;
  final Color surface;
  final Color surfaceMuted;
  final Color border;
  final Color borderStrong;
  final Color text;
  final Color textMuted;
  final Color textSubtle;

  // Marca
  final Color primary;
  final Color primaryHover;
  final Color primarySoft;
  final Color onPrimary;
  final Color accent;
  final Color accentSoft;

  // Feedback
  final Color success;
  final Color successSoft;
  final Color warning;
  final Color warningSoft;
  final Color danger;
  final Color dangerHover;
  final Color dangerSoft;
  final Color info;
  final Color infoSoft;

  final Color overlay;
  final Color focusRing;

  static const light = RotaColors(
    bg: Color(0xFFF6F7F5),
    surface: Color(0xFFFFFFFF),
    surfaceMuted: Color(0xFFEEF1EE),
    border: Color(0xFFDDE2DE),
    borderStrong: Color(0xFFC3CBC5),
    text: Color(0xFF17201D),
    textMuted: Color(0xFF5B6863),
    textSubtle: Color(0xFF84908B),
    primary: Color(0xFF0D7A6F),
    primaryHover: Color(0xFF0A6359),
    primarySoft: Color(0xFFDCF1ED),
    onPrimary: Color(0xFFFFFFFF),
    accent: Color(0xFFFF8A65),
    accentSoft: Color(0xFFFFE8DF),
    success: Color(0xFF1F8A4C),
    successSoft: Color(0xFFDDF3E5),
    warning: Color(0xFFA86400),
    warningSoft: Color(0xFFFDF0D9),
    danger: Color(0xFFC4352B),
    dangerHover: Color(0xFFA52A21),
    dangerSoft: Color(0xFFFBE3E0),
    info: Color(0xFF2F62C4),
    infoSoft: Color(0xFFE1EAFB),
    overlay: Color(0x7A0A120F),
    focusRing: Color(0x590D7A6F),
  );

  static const dark = RotaColors(
    bg: Color(0xFF0F1513),
    surface: Color(0xFF171F1C),
    surfaceMuted: Color(0xFF1F2925),
    border: Color(0xFF2A3531),
    borderStrong: Color(0xFF3A4842),
    text: Color(0xFFEAF0ED),
    textMuted: Color(0xFFA3B0AA),
    textSubtle: Color(0xFF75837D),
    primary: Color(0xFF3CC9B7),
    primaryHover: Color(0xFF63D8C8),
    primarySoft: Color(0xFF133A35),
    onPrimary: Color(0xFF08201C),
    accent: Color(0xFFFF9C7A),
    accentSoft: Color(0xFF3D2219),
    success: Color(0xFF4CC581),
    successSoft: Color(0xFF14301F),
    warning: Color(0xFFF0B44C),
    warningSoft: Color(0xFF33270F),
    danger: Color(0xFFF0776C),
    dangerHover: Color(0xFFF5978E),
    dangerSoft: Color(0xFF3A1815),
    info: Color(0xFF7AA3F0),
    infoSoft: Color(0xFF18253D),
    overlay: Color(0x99000000),
    focusRing: Color(0x663CC9B7),
  );

  @override
  RotaColors copyWith({
    Color? bg,
    Color? surface,
    Color? surfaceMuted,
    Color? border,
    Color? borderStrong,
    Color? text,
    Color? textMuted,
    Color? textSubtle,
    Color? primary,
    Color? primaryHover,
    Color? primarySoft,
    Color? onPrimary,
    Color? accent,
    Color? accentSoft,
    Color? success,
    Color? successSoft,
    Color? warning,
    Color? warningSoft,
    Color? danger,
    Color? dangerHover,
    Color? dangerSoft,
    Color? info,
    Color? infoSoft,
    Color? overlay,
    Color? focusRing,
  }) {
    return RotaColors(
      bg: bg ?? this.bg,
      surface: surface ?? this.surface,
      surfaceMuted: surfaceMuted ?? this.surfaceMuted,
      border: border ?? this.border,
      borderStrong: borderStrong ?? this.borderStrong,
      text: text ?? this.text,
      textMuted: textMuted ?? this.textMuted,
      textSubtle: textSubtle ?? this.textSubtle,
      primary: primary ?? this.primary,
      primaryHover: primaryHover ?? this.primaryHover,
      primarySoft: primarySoft ?? this.primarySoft,
      onPrimary: onPrimary ?? this.onPrimary,
      accent: accent ?? this.accent,
      accentSoft: accentSoft ?? this.accentSoft,
      success: success ?? this.success,
      successSoft: successSoft ?? this.successSoft,
      warning: warning ?? this.warning,
      warningSoft: warningSoft ?? this.warningSoft,
      danger: danger ?? this.danger,
      dangerHover: dangerHover ?? this.dangerHover,
      dangerSoft: dangerSoft ?? this.dangerSoft,
      info: info ?? this.info,
      infoSoft: infoSoft ?? this.infoSoft,
      overlay: overlay ?? this.overlay,
      focusRing: focusRing ?? this.focusRing,
    );
  }

  @override
  RotaColors lerp(RotaColors? other, double t) {
    if (other == null) return this;
    Color mix(Color a, Color b) => Color.lerp(a, b, t)!;
    return RotaColors(
      bg: mix(bg, other.bg),
      surface: mix(surface, other.surface),
      surfaceMuted: mix(surfaceMuted, other.surfaceMuted),
      border: mix(border, other.border),
      borderStrong: mix(borderStrong, other.borderStrong),
      text: mix(text, other.text),
      textMuted: mix(textMuted, other.textMuted),
      textSubtle: mix(textSubtle, other.textSubtle),
      primary: mix(primary, other.primary),
      primaryHover: mix(primaryHover, other.primaryHover),
      primarySoft: mix(primarySoft, other.primarySoft),
      onPrimary: mix(onPrimary, other.onPrimary),
      accent: mix(accent, other.accent),
      accentSoft: mix(accentSoft, other.accentSoft),
      success: mix(success, other.success),
      successSoft: mix(successSoft, other.successSoft),
      warning: mix(warning, other.warning),
      warningSoft: mix(warningSoft, other.warningSoft),
      danger: mix(danger, other.danger),
      dangerHover: mix(dangerHover, other.dangerHover),
      dangerSoft: mix(dangerSoft, other.dangerSoft),
      info: mix(info, other.info),
      infoSoft: mix(infoSoft, other.infoSoft),
      overlay: mix(overlay, other.overlay),
      focusRing: mix(focusRing, other.focusRing),
    );
  }
}
