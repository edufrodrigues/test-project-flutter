import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../api/data.dart';
import '../../app/routes.dart';
import '../../design_system/design_system.dart';
import 'scenario_panel.dart';

/// Estrutura comum das telas: cabeçalho, conteúdo e painel de cenários.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.location, required this.child});

  /// Caminho atual, usado para destacar o item ativo da navegação.
  final String location;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _Header(location: location),
      body: child,
      floatingActionButton: const ScenarioPanel(),
    );
  }
}

class _Header extends StatelessWidget implements PreferredSizeWidget {
  const _Header({required this.location});

  final String location;

  @override
  Size get preferredSize => const Size.fromHeight(RotaLayout.headerHeight);

  @override
  Widget build(BuildContext context) {
    final c = context.rotaColors;
    final compact = MediaQuery.sizeOf(context).width < RotaLayout.compactBreakpoint;
    return Material(
      color: c.surface,
      child: Container(
        height: RotaLayout.headerHeight + MediaQuery.paddingOf(context).top,
        padding: EdgeInsets.only(top: MediaQuery.paddingOf(context).top),
        decoration: BoxDecoration(border: Border(bottom: BorderSide(color: c.border))),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: RotaLayout.containerWidth + RotaSpacing.s6 * 2),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: compact ? RotaSpacing.s4 : RotaSpacing.s6),
              child: Row(
                children: [
                  Semantics(
                    label: 'Rota, página inicial',
                    button: true,
                    excludeSemantics: true,
                    child: InkWell(
                      onTap: () => context.goNamed(AppRoutes.explore),
                      borderRadius: BorderRadius.circular(RotaRadius.md),
                      child: Padding(
                        padding: const EdgeInsets.all(RotaSpacing.s1),
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(color: c.primary, borderRadius: BorderRadius.circular(RotaRadius.md)),
                              child: Icon(Icons.landscape_outlined, size: 18, color: c.onPrimary),
                            ),
                            const SizedBox(width: RotaSpacing.s2),
                            Text(
                              'Rota',
                              style: RotaTypography.sectionTitle.copyWith(color: c.text, fontWeight: RotaTypography.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  _NavLink(
                    icon: Icons.explore_outlined,
                    label: 'Explorar',
                    compact: compact,
                    active: location == '/',
                    onTap: () => context.goNamed(AppRoutes.explore),
                  ),
                  const SizedBox(width: RotaSpacing.s1),
                  _NavLink(
                    icon: Icons.event_available_outlined,
                    label: 'Minhas reservas',
                    compact: compact,
                    active: location.startsWith('/reservas'),
                    onTap: () => context.goNamed(AppRoutes.bookings),
                  ),
                  const SizedBox(width: RotaSpacing.s3),
                  Semantics(
                    label: 'Meu perfil',
                    button: true,
                    selected: location.startsWith('/perfil'),
                    excludeSemantics: true,
                    child: InkWell(
                      onTap: () => context.goNamed(AppRoutes.profile),
                      customBorder: const CircleBorder(),
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: location.startsWith('/perfil') ? c.primary : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: RotaAvatar(name: seedProfile.name, size: RotaAvatarSize.sm),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavLink extends StatelessWidget {
  const _NavLink({
    required this.icon,
    required this.label,
    required this.compact,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool compact;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.rotaColors;
    final color = active ? c.primary : c.textMuted;
    return Semantics(
      button: true,
      selected: active,
      label: label,
      excludeSemantics: true,
      child: Material(
        color: active ? c.primarySoft : Colors.transparent,
        borderRadius: BorderRadius.circular(RotaRadius.md),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(RotaRadius.md),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: RotaSpacing.s3, vertical: RotaSpacing.s2),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 18, color: color),
                if (!compact) ...[
                  const SizedBox(width: RotaSpacing.s2),
                  Text(label, style: RotaTypography.label.copyWith(color: color, fontWeight: RotaTypography.semibold)),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
