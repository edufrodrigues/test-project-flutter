import 'package:flutter/material.dart';

import '../tokens/tokens.dart';

/// Caixa de seleção com rótulo clicável e mensagem de erro.
class RotaCheckbox extends StatelessWidget {
  const RotaCheckbox({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.error,
    this.focusNode,
  });

  final String label;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? error;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    final c = context.rotaColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        MergeSemantics(
          child: InkWell(
            onTap: onChanged == null ? null : () => onChanged!(!value),
            borderRadius: BorderRadius.circular(RotaRadius.sm),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: RotaSpacing.s1),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: value,
                      focusNode: focusNode,
                      onChanged: onChanged == null ? null : (next) => onChanged!(next ?? false),
                      side: BorderSide(color: error != null ? c.danger : c.borderStrong, width: 1.5),
                    ),
                  ),
                  const SizedBox(width: RotaSpacing.s3),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(label, style: RotaTypography.bodySm.copyWith(color: c.text)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(left: 36, top: RotaSpacing.s1),
            child: Semantics(
              liveRegion: true,
              child: Text(error!, style: RotaTypography.caption.copyWith(color: c.danger)),
            ),
          ),
      ],
    );
  }
}

/// Interruptor com rótulo e descrição.
class RotaSwitch extends StatelessWidget {
  const RotaSwitch({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.description,
  });

  final String label;
  final String? description;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final c = context.rotaColors;
    return MergeSemantics(
      child: InkWell(
        onTap: onChanged == null ? null : () => onChanged!(!value),
        borderRadius: BorderRadius.circular(RotaRadius.sm),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: RotaSpacing.s1),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: RotaTypography.label.copyWith(color: c.text)),
                    if (description != null) ...[
                      const SizedBox(height: RotaSpacing.s1),
                      Text(description!, style: RotaTypography.bodySm.copyWith(color: c.textMuted)),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: RotaSpacing.s4),
              Switch(value: value, onChanged: onChanged),
            ],
          ),
        ),
      ),
    );
  }
}

/// Chip de filtro que alterna entre selecionado e não selecionado.
class RotaChip extends StatelessWidget {
  const RotaChip({super.key, required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.rotaColors;
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: selected ? c.primary : c.surface,
        shape: StadiumBorder(side: BorderSide(color: selected ? c.primary : c.border)),
        child: InkWell(
          onTap: onTap,
          customBorder: const StadiumBorder(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: RotaSpacing.s4, vertical: RotaSpacing.s2),
            child: Text(
              label,
              style: RotaTypography.label.copyWith(color: selected ? c.onPrimary : c.textMuted),
            ),
          ),
        ),
      ),
    );
  }
}
