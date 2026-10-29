import 'package:flutter/material.dart';

import '../tokens/tokens.dart';
import 'rota_badge.dart';

/// Abre um diálogo modal no estilo do Rota.
///
/// `builder` monta o conteúdo; use [RotaDialog] para manter o layout padrão.
Future<T?> showRotaDialog<T>({required BuildContext context, required WidgetBuilder builder, bool dismissible = true}) {
  return showDialog<T>(context: context, barrierDismissible: dismissible, builder: builder);
}

/// Estrutura de diálogo: título, conteúdo e ações alinhadas à direita.
class RotaDialog extends StatelessWidget {
  const RotaDialog({super.key, required this.title, required this.content, this.actions = const []});

  final String title;
  final Widget content;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final c = context.rotaColors;
    return Dialog(
      insetPadding: const EdgeInsets.all(RotaSpacing.s4),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(RotaSpacing.s6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Semantics(
                header: true,
                child: Text(title, style: RotaTypography.sectionTitle.copyWith(color: c.text, fontSize: RotaTypography.xl)),
              ),
              const SizedBox(height: RotaSpacing.s3),
              DefaultTextStyle.merge(
                style: RotaTypography.body.copyWith(color: c.textMuted),
                child: content,
              ),
              if (actions.isNotEmpty) ...[
                const SizedBox(height: RotaSpacing.s6),
                Wrap(
                  alignment: WrapAlignment.end,
                  spacing: RotaSpacing.s3,
                  runSpacing: RotaSpacing.s3,
                  children: actions,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Mostra um aviso rápido (toast) no rodapé da tela, usando o SnackBar do Material.
void showRotaToast(BuildContext context, {required String title, String? description, RotaTone tone = RotaTone.success}) {
  final c = context.rotaColors;
  final (foreground, _) = tone.colors(c);
  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      duration: const Duration(seconds: 4),
      content: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(tone.icon, color: foreground, size: 20),
          const SizedBox(width: RotaSpacing.s3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: RotaTypography.label.copyWith(color: c.text, fontWeight: RotaTypography.semibold)),
                if (description != null) ...[
                  const SizedBox(height: 2),
                  Text(description, style: RotaTypography.bodySm.copyWith(color: c.textMuted)),
                ],
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
