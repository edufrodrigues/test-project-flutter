import 'package:flutter/material.dart';

import '../../api/scenario.dart';
import '../../app/app_scope.dart';
import '../../design_system/design_system.dart';

/// Botão flutuante para trocar o cenário da API falsa durante os testes.
class ScenarioPanel extends StatefulWidget {
  const ScenarioPanel({super.key});

  @override
  State<ScenarioPanel> createState() => _ScenarioPanelState();
}

class _ScenarioPanelState extends State<ScenarioPanel> {
  bool _open = false;

  Color _dotColor(RotaColors c, Scenario scenario) => switch (scenario) {
    Scenario.normal => c.success,
    Scenario.lento => c.warning,
    Scenario.erro => c.danger,
    Scenario.vazio => c.info,
    Scenario.erroEnvio => c.accent,
  };

  void _reset() {
    AppScope.of(context).api.reset();
    setState(() => _open = false);
    showRotaToast(context, title: 'Dados restaurados', description: 'Reservas e perfil voltaram ao exemplo inicial.');
  }

  @override
  Widget build(BuildContext context) {
    final c = context.rotaColors;
    final controller = AppScope.of(context).scenario;

    return ValueListenableBuilder<Scenario>(
      valueListenable: controller,
      builder: (context, scenario, _) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (_open) ...[
              _Panel(
                scenario: scenario,
                onChanged: (next) => controller.value = next,
                onReset: _reset,
              ),
              const SizedBox(height: RotaSpacing.s2),
            ],
            Semantics(
              button: true,
              expanded: _open,
              child: Material(
                color: c.text,
                shape: const StadiumBorder(),
                elevation: 4,
                child: InkWell(
                  customBorder: const StadiumBorder(),
                  onTap: () => setState(() => _open = !_open),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: RotaSpacing.s4, vertical: RotaSpacing.s3),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.science_outlined, size: 16, color: c.bg),
                        const SizedBox(width: RotaSpacing.s2),
                        Text(
                          'Cenário: ${scenario.label}',
                          style: RotaTypography.label.copyWith(color: c.bg, fontWeight: RotaTypography.semibold),
                        ),
                        const SizedBox(width: RotaSpacing.s2),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(color: _dotColor(c, scenario), shape: BoxShape.circle),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.scenario, required this.onChanged, required this.onReset});

  final Scenario scenario;
  final ValueChanged<Scenario> onChanged;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final c = context.rotaColors;
    return Container(
      width: 320,
      constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height - 160),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(RotaRadius.lg),
        border: Border.all(color: c.border),
        boxShadow: context.rotaShadows.lg,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(RotaSpacing.s4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Semantics(
                header: true,
                child: Text('Simular cenário', style: RotaTypography.cardTitle.copyWith(color: c.text)),
              ),
              const SizedBox(height: RotaSpacing.s1),
              Text(
                'Na web, também funciona pela URL, por exemplo ?cenario=erro.',
                style: RotaTypography.caption.copyWith(color: c.textMuted),
              ),
              const SizedBox(height: RotaSpacing.s3),
              RadioGroup<Scenario>(
                groupValue: scenario,
                onChanged: (next) {
                  if (next != null) onChanged(next);
                },
                child: Column(
                  children: [
                    for (final option in Scenario.values)
                      RadioListTile<Scenario>(
                        value: option,
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                        title: Text(option.label, style: RotaTypography.label.copyWith(color: c.text)),
                        subtitle: Text(option.description, style: RotaTypography.caption.copyWith(color: c.textMuted)),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: RotaSpacing.s2),
              Divider(color: c.border),
              const SizedBox(height: RotaSpacing.s2),
              RotaButton(
                label: 'Restaurar dados de exemplo',
                variant: RotaButtonVariant.ghost,
                size: RotaButtonSize.sm,
                icon: Icons.restart_alt,
                fullWidth: true,
                onPressed: onReset,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
