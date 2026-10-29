import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../api/fake_api.dart';
import '../api/models.dart';
import '../app/app_scope.dart';
import '../app/routes.dart';
import '../design_system/design_system.dart';
import '../features/experiences/experience_art.dart';
import '../features/layout/page_layout.dart';
import '../utils/async_loader.dart';
import '../utils/date.dart';
import '../utils/format.dart';

/// Abas de Minhas reservas. A aba fica na URL: `/reservas?aba=passadas`.
enum BookingsTab {
  proximas('Próximas', 'Nenhuma viagem marcada', 'Quando você reservar uma experiência, ela aparece aqui.'),
  passadas(
    'Passadas',
    'Nenhuma experiência no histórico',
    'As experiências que você já fez ficam guardadas nesta aba.',
  ),
  canceladas('Canceladas', 'Nenhuma reserva cancelada', 'Que bom! Nenhum plano foi desfeito por aqui.');

  const BookingsTab(this.label, this.emptyTitle, this.emptyDescription);

  final String label;
  final String emptyTitle;
  final String emptyDescription;

  static BookingsTab fromQuery(String? value) =>
      values.where((tab) => tab.name == value).firstOrNull ?? BookingsTab.proximas;
}

Map<BookingsTab, List<Booking>> groupBookings(List<Booking> bookings) {
  int byDate(Booking a, Booking b) => a.date.compareTo(b.date);
  final active = bookings.where((booking) => booking.status == BookingStatus.confirmada);
  return {
    BookingsTab.proximas: active.where((booking) => RotaDate.isUpcoming(booking.date)).toList()..sort(byDate),
    BookingsTab.passadas: active.where((booking) => !RotaDate.isUpcoming(booking.date)).toList()
      ..sort((a, b) => byDate(b, a)),
    BookingsTab.canceladas: bookings.where((booking) => booking.status == BookingStatus.cancelada).toList()
      ..sort(byDate),
  };
}

class BookingsPage extends StatefulWidget {
  const BookingsPage({super.key, required this.tab});

  final BookingsTab tab;

  @override
  State<BookingsPage> createState() => _BookingsPageState();
}

class _BookingsPageState extends State<BookingsPage> with AsyncLoader<BookingsPage, List<Booking>> {
  @override
  Future<List<Booking>> load(AppServices services) => services.api.listBookings();

  void _changeTab(BookingsTab tab) {
    final params = {
      ...GoRouterState.of(context).uri.queryParameters,
      'aba': tab.name,
    }..removeWhere((key, value) => key == 'aba' && tab == BookingsTab.proximas);
    Router.neglect(context, () => context.goNamed(AppRoutes.bookings, queryParameters: params));
  }

  Future<void> _confirmCancel(Booking booking) async {
    final updated = await showRotaDialog<Booking>(
      context: context,
      dismissible: false,
      builder: (_) => _CancelDialog(booking: booking, api: services.api),
    );
    if (updated == null || !mounted) return;
    final current = loadState;
    if (current is AsyncData<List<Booking>>) {
      setData([for (final item in current.data) item.id == updated.id ? updated : item]);
    }
    showRotaToast(
      context,
      title: 'Reserva cancelada',
      description: 'O reembolso de ${RotaFormat.currency(updated.total)} foi solicitado.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = loadState;
    final groups = state is AsyncData<List<Booking>> ? groupBookings(state.data) : null;
    final tab = widget.tab;

    return RotaPageBody(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const PageHeader(
            title: 'Minhas reservas',
            subtitle: 'Acompanhe suas próximas experiências e o histórico de viagens.',
          ),
          const SizedBox(height: RotaSpacing.s6),
          RotaTabs<BookingsTab>(
            value: tab,
            onChanged: _changeTab,
            items: [
              for (final item in BookingsTab.values)
                RotaTabItem(value: item, label: item.label, count: groups?[item]?.length),
            ],
          ),
          const SizedBox(height: RotaSpacing.s6),
          switch (state) {
            AsyncLoading() => RotaLoadingRegion(
              label: 'Carregando reservas',
              child: Column(
                children: [
                  for (var i = 0; i < 3; i++) ...[
                    if (i > 0) const SizedBox(height: RotaSpacing.s4),
                    const _BookingItemSkeleton(),
                  ],
                ],
              ),
            ),
            AsyncFailure(:final error) => RotaErrorState(
              title: 'Não foi possível carregar suas reservas',
              description: errorMessage(error),
              onRetry: reload,
            ),
            AsyncData() when groups![tab]!.isEmpty => RotaEmptyState(
              icon: Icons.event_busy_outlined,
              title: tab.emptyTitle,
              description: tab.emptyDescription,
              actions: [
                if (tab == BookingsTab.proximas)
                  RotaButton(label: 'Explorar experiências', onPressed: () => context.goNamed(AppRoutes.explore)),
              ],
            ),
            AsyncData() => Column(
              children: [
                for (final booking in groups![tab]!) ...[
                  _BookingItem(booking: booking, tab: tab, onCancel: () => _confirmCancel(booking)),
                  const SizedBox(height: RotaSpacing.s4),
                ],
              ],
            ),
          },
        ],
      ),
    );
  }
}

class _BookingItem extends StatelessWidget {
  const _BookingItem({required this.booking, required this.tab, required this.onCancel});

  final Booking booking;
  final BookingsTab tab;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final c = context.rotaColors;
    final badge = switch (tab) {
      BookingsTab.proximas => const RotaBadge(label: 'Confirmada', tone: RotaTone.success),
      BookingsTab.passadas => const RotaBadge(label: 'Concluída'),
      BookingsTab.canceladas => const RotaBadge(label: 'Cancelada', tone: RotaTone.danger),
    };

    final info = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: RotaSpacing.s2,
          runSpacing: RotaSpacing.s2,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Semantics(
              link: true,
              child: InkWell(
                onTap: () => context.goNamed(AppRoutes.experience, pathParameters: {'id': booking.experienceId}),
                child: Text(booking.experienceTitle, style: RotaTypography.cardTitle.copyWith(color: c.text)),
              ),
            ),
            badge,
          ],
        ),
        const SizedBox(height: RotaSpacing.s2),
        Wrap(
          spacing: RotaSpacing.s4,
          runSpacing: RotaSpacing.s1,
          children: [
            MetaItem(icon: Icons.calendar_today_outlined, text: RotaFormat.longDate(booking.date), size: 14),
            MetaItem(icon: Icons.place_outlined, text: booking.location, size: 14),
            MetaItem(icon: Icons.group_outlined, text: RotaFormat.guests(booking.guests), size: 14),
          ],
        ),
        const SizedBox(height: RotaSpacing.s2),
        Text('Código ${booking.id}', style: RotaTypography.caption.copyWith(color: c.textSubtle)),
      ],
    );

    final side = Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(RotaFormat.currency(booking.total), style: RotaTypography.cardTitle.copyWith(color: c.text)),
        if (tab == BookingsTab.proximas) ...[
          const SizedBox(height: RotaSpacing.s2),
          RotaButton(
            label: 'Cancelar',
            variant: RotaButtonVariant.secondary,
            size: RotaButtonSize.sm,
            onPressed: onCancel,
          ),
        ],
      ],
    );

    return RotaCard(
      padding: RotaCardPadding.none,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final art = ExperienceArt(art: booking.art);
          if (constraints.maxWidth < 560) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 120, child: art),
                Padding(
                  padding: const EdgeInsets.all(RotaSpacing.s4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [info, const SizedBox(height: RotaSpacing.s3), side],
                  ),
                ),
              ],
            );
          }
          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(width: 140, child: art),
                Expanded(
                  child: Padding(padding: const EdgeInsets.all(RotaSpacing.s4), child: info),
                ),
                Padding(
                  padding: const EdgeInsets.all(RotaSpacing.s4),
                  child: Center(child: side),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _BookingItemSkeleton extends StatelessWidget {
  const _BookingItemSkeleton();

  @override
  Widget build(BuildContext context) {
    return const RotaCard(
      padding: RotaCardPadding.md,
      child: Row(
        children: [
          RotaSkeleton(width: 108, height: 72, shape: RotaSkeletonShape.rect),
          SizedBox(width: RotaSpacing.s4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FractionallySizedBox(widthFactor: 0.6, child: RotaSkeleton(height: 18)),
                SizedBox(height: RotaSpacing.s3),
                FractionallySizedBox(widthFactor: 0.4, child: RotaSkeleton()),
              ],
            ),
          ),
          SizedBox(width: RotaSpacing.s4),
          RotaSkeleton(width: 90, height: 32, shape: RotaSkeletonShape.rect),
        ],
      ),
    );
  }
}

/// Diálogo de confirmação. Chama a API e só fecha quando o cancelamento dá certo.
class _CancelDialog extends StatefulWidget {
  const _CancelDialog({required this.booking, required this.api});

  final Booking booking;
  final FakeApi api;

  @override
  State<_CancelDialog> createState() => _CancelDialogState();
}

class _CancelDialogState extends State<_CancelDialog> {
  bool _cancelling = false;
  String? _error;

  Future<void> _confirm() async {
    setState(() {
      _cancelling = true;
      _error = null;
    });
    try {
      final updated = await widget.api.cancelBooking(widget.booking.id);
      if (mounted) Navigator.of(context).pop(updated);
    } catch (error) {
      if (mounted) {
        setState(() {
          _cancelling = false;
          _error = errorMessage(error);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.rotaColors;
    final booking = widget.booking;
    return PopScope(
      canPop: !_cancelling,
      child: RotaDialog(
        title: 'Cancelar esta reserva?',
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text.rich(
              TextSpan(
                children: [
                  const TextSpan(text: 'Você vai cancelar '),
                  TextSpan(
                    text: booking.experienceTitle,
                    style: TextStyle(color: c.text, fontWeight: RotaTypography.semibold),
                  ),
                  TextSpan(
                    text:
                        ' em ${RotaFormat.longDate(booking.date)}. O valor de ${RotaFormat.currency(booking.total)} será devolvido em até 7 dias úteis. Essa ação não pode ser desfeita.',
                  ),
                ],
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: RotaSpacing.s4),
              RotaAlert(tone: RotaTone.danger, title: 'Não foi possível cancelar', message: _error!),
            ],
          ],
        ),
        actions: [
          RotaButton(
            label: 'Manter reserva',
            variant: RotaButtonVariant.secondary,
            onPressed: _cancelling ? null : () => Navigator.of(context).pop(),
          ),
          RotaButton(
            label: 'Sim, cancelar',
            variant: RotaButtonVariant.danger,
            loading: _cancelling,
            onPressed: _confirm,
          ),
        ],
      ),
    );
  }
}
