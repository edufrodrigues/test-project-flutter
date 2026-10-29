import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../api/fake_api.dart';
import '../api/models.dart';
import '../app/app_scope.dart';
import '../app/routes.dart';
import '../design_system/design_system.dart';
import '../features/layout/page_layout.dart';
import '../utils/async_loader.dart';
import '../utils/format.dart';

class ConfirmationPage extends StatefulWidget {
  const ConfirmationPage({super.key, required this.bookingId});

  final String bookingId;

  @override
  State<ConfirmationPage> createState() => _ConfirmationPageState();
}

class _ConfirmationPageState extends State<ConfirmationPage> with AsyncLoader<ConfirmationPage, Booking> {
  @override
  Future<Booking> load(AppServices services) => services.api.getBooking(widget.bookingId);

  @override
  void didUpdateWidget(ConfirmationPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.bookingId != widget.bookingId) reload();
  }

  @override
  Widget build(BuildContext context) {
    return RotaPageBody(
      child: switch (loadState) {
        AsyncLoading() => const _Centered(
          child: RotaLoadingRegion(
            label: 'Carregando confirmação',
            child: RotaCard(
              padding: RotaCardPadding.lg,
              child: Column(
                children: [
                  RotaSkeleton(width: 72, height: 72, shape: RotaSkeletonShape.circle),
                  SizedBox(height: RotaSpacing.s4),
                  FractionallySizedBox(widthFactor: 0.6, child: RotaSkeleton(height: 30)),
                  SizedBox(height: RotaSpacing.s3),
                  FractionallySizedBox(widthFactor: 0.8, child: RotaSkeleton()),
                  SizedBox(height: RotaSpacing.s6),
                  RotaSkeleton(height: 160, shape: RotaSkeletonShape.rect),
                ],
              ),
            ),
          ),
        ),
        AsyncFailure(:final error) when error is NotFoundException => RotaEmptyState(
          title: 'Reserva não encontrada',
          description: 'Confira o código da reserva ou veja a lista completa.',
          actions: [RotaButton(label: 'Ver minhas reservas', onPressed: () => context.goNamed(AppRoutes.bookings))],
        ),
        AsyncFailure(:final error) => RotaErrorState(description: errorMessage(error), onRetry: reload),
        AsyncData(:final data) => _Centered(child: _Confirmation(booking: data)),
      },
    );
  }
}

class _Centered extends StatelessWidget {
  const _Centered({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 560), child: child),
    );
  }
}

class _Confirmation extends StatelessWidget {
  const _Confirmation({required this.booking});

  final Booking booking;

  @override
  Widget build(BuildContext context) {
    final c = context.rotaColors;
    return RotaCard(
      padding: RotaCardPadding.lg,
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(color: c.successSoft, shape: BoxShape.circle),
            child: Icon(Icons.check_circle_outline, size: 40, color: c.success),
          ),
          const SizedBox(height: RotaSpacing.s4),
          Semantics(
            header: true,
            child: Text(
              'Reserva confirmada!',
              textAlign: TextAlign.center,
              style: RotaTypography.title.copyWith(color: c.text),
            ),
          ),
          const SizedBox(height: RotaSpacing.s2),
          Text.rich(
            TextSpan(
              children: [
                const TextSpan(text: 'Enviamos os detalhes para '),
                TextSpan(
                  text: booking.email,
                  style: TextStyle(color: c.text, fontWeight: RotaTypography.semibold),
                ),
                const TextSpan(text: '. Apresente o código abaixo no ponto de encontro.'),
              ],
            ),
            textAlign: TextAlign.center,
            style: RotaTypography.body.copyWith(color: c.textMuted),
          ),
          const SizedBox(height: RotaSpacing.s6),
          Semantics(
            label: 'Código da reserva ${booking.id}',
            excludeSemantics: true,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: RotaSpacing.s6, vertical: RotaSpacing.s3),
              decoration: BoxDecoration(
                color: c.primarySoft,
                borderRadius: BorderRadius.circular(RotaRadius.md),
                border: Border.all(color: c.primary.withValues(alpha: 0.3)),
              ),
              child: SelectableText(
                booking.id,
                style: RotaTypography.title.copyWith(color: c.primary, letterSpacing: 3),
              ),
            ),
          ),
          const SizedBox(height: RotaSpacing.s6),
          Container(
            padding: const EdgeInsets.all(RotaSpacing.s4),
            decoration: BoxDecoration(color: c.surfaceMuted, borderRadius: BorderRadius.circular(RotaRadius.md)),
            child: Column(
              children: [
                DetailLine(label: 'Experiência', value: booking.experienceTitle),
                DetailLine(label: 'Local', value: booking.location),
                DetailLine(label: 'Data', value: RotaFormat.longDate(booking.date)),
                DetailLine(label: 'Pessoas', value: RotaFormat.guests(booking.guests)),
                DetailLine(label: 'Total pago', value: RotaFormat.currency(booking.total)),
              ],
            ),
          ),
          const SizedBox(height: RotaSpacing.s6),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: RotaSpacing.s3,
            runSpacing: RotaSpacing.s3,
            children: [
              RotaButton(
                label: 'Ver minhas reservas',
                icon: Icons.event_available_outlined,
                onPressed: () => context.goNamed(AppRoutes.bookings),
              ),
              RotaButton(
                label: 'Explorar mais',
                icon: Icons.explore_outlined,
                variant: RotaButtonVariant.secondary,
                onPressed: () => context.goNamed(AppRoutes.explore),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
