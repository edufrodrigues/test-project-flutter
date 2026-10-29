import 'package:flutter/material.dart';

import '../tokens/tokens.dart';
import 'rota_button.dart';

/// Estado vazio: ícone, título, descrição e ações opcionais.
class RotaEmptyState extends StatelessWidget {
  const RotaEmptyState({
    super.key,
    required this.title,
    this.description,
    this.icon = Icons.explore_outlined,
    this.actions = const [],
  });

  final String title;
  final String? description;
  final IconData icon;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final c = context.rotaColors;
    return _StateMessage(
      icon: icon,
      iconColor: c.primary,
      iconBackground: c.primarySoft,
      title: title,
      description: description,
      actions: actions,
    );
  }
}

/// Estado de erro, com botão "Tentar de novo" quando há `onRetry`.
class RotaErrorState extends StatelessWidget {
  const RotaErrorState({
    super.key,
    this.title = 'Algo deu errado',
    this.description = 'Não conseguimos carregar as informações. Verifique sua conexão e tente de novo.',
    this.onRetry,
    this.actions = const [],
  });

  final String title;
  final String description;
  final VoidCallback? onRetry;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final c = context.rotaColors;
    return Semantics(
      liveRegion: true,
      child: _StateMessage(
        icon: Icons.wifi_off_rounded,
        iconColor: c.danger,
        iconBackground: c.dangerSoft,
        title: title,
        description: description,
        actions: [
          if (onRetry != null) RotaButton(label: 'Tentar de novo', icon: Icons.refresh, onPressed: onRetry),
          ...actions,
        ],
      ),
    );
  }
}

class _StateMessage extends StatelessWidget {
  const _StateMessage({
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.title,
    required this.description,
    required this.actions,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String title;
  final String? description;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final c = context.rotaColors;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: RotaSpacing.s12, horizontal: RotaSpacing.s4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(color: iconBackground, shape: BoxShape.circle),
                child: Icon(icon, size: 28, color: iconColor),
              ),
              const SizedBox(height: RotaSpacing.s4),
              Semantics(
                header: true,
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: RotaTypography.sectionTitle.copyWith(color: c.text, fontSize: RotaTypography.xl),
                ),
              ),
              if (description != null) ...[
                const SizedBox(height: RotaSpacing.s2),
                Text(
                  description!,
                  textAlign: TextAlign.center,
                  style: RotaTypography.body.copyWith(color: c.textMuted),
                ),
              ],
              if (actions.isNotEmpty) ...[
                const SizedBox(height: RotaSpacing.s6),
                Wrap(
                  alignment: WrapAlignment.center,
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
