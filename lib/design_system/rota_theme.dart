import 'package:flutter/material.dart';

import 'tokens/tokens.dart';

/// Monta o ThemeData do Rota a partir dos tokens.
///
/// Os widgets Material (diálogo, snackbar, seletor de data) também seguem os
/// tokens, para nada destoar quando o tema muda.
abstract final class RotaTheme {
  static ThemeData get light => _build(Brightness.light, RotaColors.light, RotaShadows.light);
  static ThemeData get dark => _build(Brightness.dark, RotaColors.dark, RotaShadows.dark);

  static ThemeData _build(Brightness brightness, RotaColors c, RotaShadows shadows) {
    final scheme = ColorScheme(
      brightness: brightness,
      primary: c.primary,
      onPrimary: c.onPrimary,
      primaryContainer: c.primarySoft,
      onPrimaryContainer: c.primary,
      secondary: c.accent,
      onSecondary: c.text,
      secondaryContainer: c.accentSoft,
      onSecondaryContainer: c.text,
      error: c.danger,
      onError: c.onPrimary,
      errorContainer: c.dangerSoft,
      onErrorContainer: c.danger,
      surface: c.surface,
      onSurface: c.text,
      onSurfaceVariant: c.textMuted,
      surfaceContainerLowest: c.surface,
      surfaceContainerLow: c.surface,
      surfaceContainer: c.surface,
      surfaceContainerHigh: c.surface,
      surfaceContainerHighest: c.surfaceMuted,
      outline: c.borderStrong,
      outlineVariant: c.border,
      shadow: Colors.black,
      scrim: c.overlay,
      inverseSurface: c.text,
      onInverseSurface: c.bg,
      inversePrimary: c.primarySoft,
    );

    final textTheme = TextTheme(
      displaySmall: RotaTypography.display.copyWith(color: c.text),
      headlineMedium: RotaTypography.title.copyWith(color: c.text),
      titleLarge: RotaTypography.sectionTitle.copyWith(color: c.text),
      titleMedium: RotaTypography.cardTitle.copyWith(color: c.text),
      bodyLarge: RotaTypography.body.copyWith(color: c.text),
      bodyMedium: RotaTypography.bodySm.copyWith(color: c.text),
      bodySmall: RotaTypography.caption.copyWith(color: c.textMuted),
      labelLarge: RotaTypography.label.copyWith(color: c.text),
      labelMedium: RotaTypography.label.copyWith(color: c.textMuted),
      labelSmall: RotaTypography.caption.copyWith(color: c.textMuted),
    );

    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(RotaRadius.md),
      borderSide: BorderSide(color: c.borderStrong),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      fontFamily: RotaTypography.fontFamily,
      textTheme: textTheme,
      scaffoldBackgroundColor: c.bg,
      canvasColor: c.surface,
      dividerTheme: DividerThemeData(color: c.border, thickness: 1, space: 1),
      extensions: [c, shadows],
      splashFactory: InkSparkle.splashFactory,
      focusColor: c.focusRing,
      hoverColor: c.surfaceMuted,
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: c.primary,
        selectionColor: c.primarySoft,
        selectionHandleColor: c.primary,
      ),
      inputDecorationTheme: InputDecorationTheme(
        isDense: true,
        filled: true,
        fillColor: c.surface,
        hintStyle: RotaTypography.body.copyWith(color: c.textSubtle),
        contentPadding: const EdgeInsets.symmetric(horizontal: RotaSpacing.s3, vertical: RotaSpacing.s3),
        border: inputBorder,
        enabledBorder: inputBorder,
        disabledBorder: inputBorder.copyWith(borderSide: BorderSide(color: c.border)),
        focusedBorder: inputBorder.copyWith(borderSide: BorderSide(color: c.primary, width: 2)),
        errorBorder: inputBorder.copyWith(borderSide: BorderSide(color: c.danger)),
        focusedErrorBorder: inputBorder.copyWith(borderSide: BorderSide(color: c.danger, width: 2)),
        prefixIconColor: c.textSubtle,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: c.surface,
        surfaceTintColor: Colors.transparent,
        barrierColor: c.overlay,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(RotaRadius.lg)),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: c.surface,
        elevation: 0,
        width: 380,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(RotaRadius.md),
          side: BorderSide(color: c.border),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: c.primary),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? c.onPrimary : c.textSubtle,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? c.primary : c.surfaceMuted,
        ),
        trackOutlineColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? c.primary : c.borderStrong,
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(RotaRadius.sm / 1.5)),
        side: BorderSide(color: c.borderStrong, width: 1.5),
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? c.primary : c.surface,
        ),
        checkColor: WidgetStatePropertyAll(c.onPrimary),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(color: c.text, borderRadius: BorderRadius.circular(RotaRadius.sm)),
        textStyle: RotaTypography.caption.copyWith(color: c.bg),
      ),
    );
  }
}
