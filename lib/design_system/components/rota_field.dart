import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../tokens/tokens.dart';

/// Estrutura comum dos campos: rótulo, controle, dica e mensagem de erro.
class RotaFieldFrame extends StatelessWidget {
  const RotaFieldFrame({
    super.key,
    required this.label,
    required this.child,
    this.hint,
    this.error,
    this.required = false,
  });

  final String label;
  final Widget child;
  final String? hint;
  final String? error;
  final bool required;

  @override
  Widget build(BuildContext context) {
    final c = context.rotaColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text.rich(
          TextSpan(
            text: label,
            children: [
              if (required)
                TextSpan(text: ' *', style: TextStyle(color: c.danger)),
            ],
          ),
          style: RotaTypography.label.copyWith(color: c.text),
        ),
        const SizedBox(height: RotaSpacing.s2),
        child,
        if (error != null) ...[
          const SizedBox(height: RotaSpacing.s1),
          Semantics(
            liveRegion: true,
            child: Text(error!, style: RotaTypography.caption.copyWith(color: c.danger)),
          ),
        ] else if (hint != null) ...[
          const SizedBox(height: RotaSpacing.s1),
          Text(hint!, style: RotaTypography.caption.copyWith(color: c.textMuted)),
        ],
      ],
    );
  }
}

/// Campo de texto com rótulo, dica, erro e ícone opcional.
class RotaTextField extends StatelessWidget {
  const RotaTextField({
    super.key,
    required this.label,
    this.controller,
    this.focusNode,
    this.hint,
    this.error,
    this.placeholder,
    this.icon,
    this.required = false,
    this.enabled = true,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.autofillHints,
    this.maxLines = 1,
    this.maxLength,
    this.onChanged,
    this.onSubmitted,
  });

  final String label;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? hint;
  final String? error;
  final String? placeholder;
  final IconData? icon;
  final bool required;
  final bool enabled;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final Iterable<String>? autofillHints;
  final int maxLines;
  final int? maxLength;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final c = context.rotaColors;
    return RotaFieldFrame(
      label: label,
      hint: hint,
      error: error,
      required: required,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        enabled: enabled,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        inputFormatters: [
          if (maxLength != null) LengthLimitingTextInputFormatter(maxLength),
          ...?inputFormatters,
        ],
        autofillHints: autofillHints,
        maxLines: maxLines,
        minLines: maxLines > 1 ? 3 : null,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        style: RotaTypography.body.copyWith(color: enabled ? c.text : c.textMuted),
        decoration: InputDecoration(
          hintText: placeholder,
          prefixIcon: icon == null ? null : Icon(icon, size: 18),
          // Mantém o erro só no texto abaixo; aqui ele apenas pinta a borda.
          errorText: error == null ? null : '',
          errorStyle: const TextStyle(height: 0, fontSize: 0),
        ),
      ),
    );
  }
}

class RotaSelectOption<T> {
  const RotaSelectOption(this.value, this.label);

  final T value;
  final String label;
}

/// Lista de opções no estilo dos campos do Rota.
class RotaSelect<T> extends StatelessWidget {
  const RotaSelect({
    super.key,
    required this.label,
    required this.options,
    required this.value,
    required this.onChanged,
    this.placeholder,
    this.hint,
    this.error,
    this.required = false,
    this.enabled = true,
    this.focusNode,
  });

  final String label;
  final List<RotaSelectOption<T>> options;
  final T? value;
  final ValueChanged<T>? onChanged;
  final String? placeholder;
  final String? hint;
  final String? error;
  final bool required;
  final bool enabled;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    final c = context.rotaColors;
    final active = enabled && onChanged != null;
    return RotaFieldFrame(
      label: label,
      hint: hint,
      error: error,
      required: required,
      child: InputDecorator(
        isEmpty: value == null,
        decoration: InputDecoration(
          enabled: active,
          errorText: error == null ? null : '',
          errorStyle: const TextStyle(height: 0, fontSize: 0),
          // Mesma altura do RotaTextField.
          contentPadding: const EdgeInsets.symmetric(horizontal: RotaSpacing.s3, vertical: 9),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<T>(
            value: value,
            focusNode: focusNode,
            isExpanded: true,
            isDense: true,
            borderRadius: BorderRadius.circular(RotaRadius.md),
            dropdownColor: c.surface,
            icon: Icon(Icons.expand_more, color: c.textMuted),
            style: RotaTypography.body.copyWith(color: c.text),
            hint: placeholder == null
                ? null
                : Text(placeholder!, style: RotaTypography.body.copyWith(color: c.textSubtle)),
            onChanged: active ? (next) => next == null ? null : onChanged!(next) : null,
            items: [
              for (final option in options)
                DropdownMenuItem<T>(
                  value: option.value,
                  child: Text(option.label, overflow: TextOverflow.ellipsis),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
