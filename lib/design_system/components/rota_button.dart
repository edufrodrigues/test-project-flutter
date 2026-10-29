import 'package:flutter/material.dart';

import '../tokens/tokens.dart';

enum RotaButtonVariant { primary, secondary, ghost, danger }

enum RotaButtonSize { sm, md, lg }

/// Botão do Rota, com variantes, tamanhos, ícone e estado de carregamento.
///
/// Sem `onPressed` ou com `loading: true`, o botão fica desabilitado.
class RotaButton extends StatefulWidget {
  const RotaButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = RotaButtonVariant.primary,
    this.size = RotaButtonSize.md,
    this.icon,
    this.loading = false,
    this.fullWidth = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final RotaButtonVariant variant;
  final RotaButtonSize size;
  final IconData? icon;
  final bool loading;
  final bool fullWidth;

  @override
  State<RotaButton> createState() => _RotaButtonState();
}

class _RotaButtonState extends State<RotaButton> {
  bool _hovered = false;

  bool get _enabled => widget.onPressed != null && !widget.loading;

  @override
  Widget build(BuildContext context) {
    final c = context.rotaColors;
    final palette = _palette(c);

    final (height, padding, fontSize, iconSize) = switch (widget.size) {
      RotaButtonSize.sm => (32.0, RotaSpacing.s3, RotaTypography.sm, 14.0),
      RotaButtonSize.md => (40.0, RotaSpacing.s4, RotaTypography.sm, 16.0),
      RotaButtonSize.lg => (48.0, RotaSpacing.s6, RotaTypography.md, 18.0),
    };

    final background = _hovered && _enabled ? palette.hoverBackground : palette.background;
    final foreground = _hovered && _enabled ? palette.hoverForeground : palette.foreground;

    final content = Row(
      mainAxisSize: widget.fullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.loading)
          SizedBox.square(
            dimension: iconSize,
            child: CircularProgressIndicator(strokeWidth: 2, color: foreground),
          )
        else if (widget.icon != null)
          Icon(widget.icon, size: iconSize, color: foreground),
        if (widget.loading || widget.icon != null) const SizedBox(width: RotaSpacing.s2),
        Flexible(
          child: Text(
            widget.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: RotaTypography.fontFamily,
              fontSize: fontSize,
              fontWeight: RotaTypography.semibold,
              height: 1,
              color: foreground,
            ),
          ),
        ),
      ],
    );

    return Semantics(
      button: true,
      enabled: _enabled,
      excludeSemantics: true,
      label: widget.label,
      onTap: _enabled ? widget.onPressed : null,
      child: Opacity(
        opacity: _enabled || widget.loading ? 1 : 0.55,
        child: MouseRegion(
          cursor: _enabled ? SystemMouseCursors.click : SystemMouseCursors.forbidden,
          onEnter: (_) => setState(() => _hovered = true),
          onExit: (_) => setState(() => _hovered = false),
          child: AnimatedContainer(
            duration: RotaMotion.fast,
            curve: RotaMotion.standard,
            height: height,
            width: widget.fullWidth ? double.infinity : null,
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(RotaRadius.md),
              border: Border.all(color: palette.border),
            ),
            child: Material(
              type: MaterialType.transparency,
              child: InkWell(
                onTap: _enabled ? widget.onPressed : null,
                borderRadius: BorderRadius.circular(RotaRadius.md),
                focusColor: c.focusRing,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: padding),
                  child: content,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  _ButtonPalette _palette(RotaColors c) {
    return switch (widget.variant) {
      RotaButtonVariant.primary => _ButtonPalette(
        background: c.primary,
        hoverBackground: c.primaryHover,
        foreground: c.onPrimary,
        border: Colors.transparent,
      ),
      RotaButtonVariant.secondary => _ButtonPalette(
        background: c.surface,
        hoverBackground: c.surfaceMuted,
        foreground: c.text,
        border: c.borderStrong,
      ),
      RotaButtonVariant.ghost => _ButtonPalette(
        background: Colors.transparent,
        hoverBackground: c.surfaceMuted,
        foreground: c.textMuted,
        hoverForeground: c.text,
        border: Colors.transparent,
      ),
      RotaButtonVariant.danger => _ButtonPalette(
        background: c.danger,
        hoverBackground: c.dangerHover,
        foreground: c.onPrimary,
        border: Colors.transparent,
      ),
    };
  }
}

class _ButtonPalette {
  _ButtonPalette({
    required this.background,
    required this.hoverBackground,
    required this.foreground,
    Color? hoverForeground,
    required this.border,
  }) : hoverForeground = hoverForeground ?? foreground;

  final Color background;
  final Color hoverBackground;
  final Color foreground;
  final Color hoverForeground;
  final Color border;
}
