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
import '../utils/format.dart';

class ExperiencePage extends StatefulWidget {
  const ExperiencePage({super.key, required this.experienceId});

  final String experienceId;

  @override
  State<ExperiencePage> createState() => _ExperiencePageState();
}

class _ExperiencePageState extends State<ExperiencePage> with AsyncLoader<ExperiencePage, Experience> {
  @override
  Future<Experience> load(AppServices services) => services.api.getExperience(widget.experienceId);

  @override
  void didUpdateWidget(ExperiencePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.experienceId != widget.experienceId) reload();
  }

  @override
  Widget build(BuildContext context) {
    return RotaPageBody(
      child: switch (loadState) {
        AsyncLoading() => const _ExperienceSkeleton(),
        AsyncFailure(:final error) when error is NotFoundException => RotaEmptyState(
          title: 'Experiência não encontrada',
          description: 'Ela pode ter sido removida ou o link está incorreto.',
          actions: [
            RotaButton(
              label: 'Voltar para explorar',
              icon: Icons.arrow_back,
              variant: RotaButtonVariant.secondary,
              onPressed: () => context.goNamed(AppRoutes.explore),
            ),
          ],
        ),
        AsyncFailure(:final error) => RotaErrorState(description: errorMessage(error), onRetry: reload),
        AsyncData(:final data) => _ExperienceDetails(experience: data),
      },
    );
  }
}

class _ExperienceDetails extends StatelessWidget {
  const _ExperienceDetails({required this.experience});

  final Experience experience;

  @override
  Widget build(BuildContext context) {
    final c = context.rotaColors;
    final compact = MediaQuery.sizeOf(context).width < RotaLayout.compactBreakpoint;

    final details = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RotaBadge(label: RotaFormat.category(experience.category), tone: RotaTone.primary),
        const SizedBox(height: RotaSpacing.s3),
        Semantics(
          header: true,
          child: Text(experience.title, style: RotaTypography.title.copyWith(color: c.text)),
        ),
        const SizedBox(height: RotaSpacing.s3),
        Wrap(
          spacing: RotaSpacing.s4,
          runSpacing: RotaSpacing.s2,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            RotaRating(value: experience.rating, count: experience.reviewsCount),
            MetaItem(icon: Icons.place_outlined, text: experience.location),
            MetaItem(icon: Icons.schedule, text: RotaFormat.duration(experience.durationHours)),
            MetaItem(icon: Icons.group_outlined, text: 'Até ${experience.maxGuests} pessoas'),
          ],
        ),
        const SizedBox(height: RotaSpacing.s6),
        Text(experience.description, style: RotaTypography.body.copyWith(color: c.text, fontSize: RotaTypography.lg)),
        const SizedBox(height: RotaSpacing.s6),
        const Divider(),
        const SizedBox(height: RotaSpacing.s6),
        FieldRow(
          breakpoint: 560,
          children: [
            _ListSection(title: 'Destaques', icon: Icons.auto_awesome_outlined, items: experience.highlights),
            _ListSection(title: 'O que está incluso', icon: Icons.check, items: experience.includes),
          ],
        ),
        const SizedBox(height: RotaSpacing.s6),
        const Divider(),
        const SizedBox(height: RotaSpacing.s6),
        const SectionTitle('Ponto de encontro'),
        const SizedBox(height: RotaSpacing.s2),
        Text(experience.meetingPoint, style: RotaTypography.body.copyWith(color: c.textMuted)),
      ],
    );

    final bookingCard = RotaCard(
      padding: RotaCardPadding.lg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.end,
            spacing: RotaSpacing.s2,
            children: [
              Text(
                RotaFormat.currency(experience.price),
                style: RotaTypography.title.copyWith(color: c.text),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text('por pessoa', style: RotaTypography.bodySm.copyWith(color: c.textMuted)),
              ),
            ],
          ),
          const SizedBox(height: RotaSpacing.s5),
          Text('Próximas datas', style: RotaTypography.bodySm.copyWith(color: c.textMuted)),
          const SizedBox(height: RotaSpacing.s2),
          Wrap(
            spacing: RotaSpacing.s2,
            runSpacing: RotaSpacing.s2,
            children: [
              for (final date in experience.availableDates.take(4)) RotaBadge(label: RotaFormat.shortDate(date)),
            ],
          ),
          const SizedBox(height: RotaSpacing.s5),
          RotaButton(
            label: 'Reservar agora',
            size: RotaButtonSize.lg,
            fullWidth: true,
            onPressed: () => context.goNamed(AppRoutes.booking, pathParameters: {'id': experience.id}),
          ),
          const SizedBox(height: RotaSpacing.s4),
          Row(
            children: [
              Icon(Icons.verified_user_outlined, size: 16, color: c.success),
              const SizedBox(width: RotaSpacing.s2),
              Expanded(
                child: Text(
                  'Cancelamento grátis até 48 horas antes.',
                  style: RotaTypography.bodySm.copyWith(color: c.textMuted),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        RotaBreadcrumb(
          items: [
            RotaBreadcrumbItem('Explorar', onTap: () => context.goNamed(AppRoutes.explore)),
            RotaBreadcrumbItem(experience.title),
          ],
        ),
        const SizedBox(height: RotaSpacing.s6),
        ClipRRect(
          borderRadius: BorderRadius.circular(RotaRadius.xl),
          child: SizedBox(
            height: compact ? 220 : 360,
            child: ExperienceArt(art: experience.art, label: 'Ilustração de ${experience.city}'),
          ),
        ),
        const SizedBox(height: RotaSpacing.s8),
        SplitLayout(main: details, aside: bookingCard),
      ],
    );
  }
}

class _ListSection extends StatelessWidget {
  const _ListSection({required this.title, required this.icon, required this.items});

  final String title;
  final IconData icon;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(title),
        const SizedBox(height: RotaSpacing.s3),
        for (final item in items) IconListItem(icon: icon, text: item),
      ],
    );
  }
}

class _ExperienceSkeleton extends StatelessWidget {
  const _ExperienceSkeleton();

  @override
  Widget build(BuildContext context) {
    return const RotaLoadingRegion(
      label: 'Carregando experiência',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RotaSkeleton(width: 220),
          SizedBox(height: RotaSpacing.s6),
          RotaSkeleton(height: 320, shape: RotaSkeletonShape.rect),
          SizedBox(height: RotaSpacing.s8),
          SplitLayout(
            main: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RotaSkeleton(width: 90, height: 24, shape: RotaSkeletonShape.circle),
                SizedBox(height: RotaSpacing.s3),
                FractionallySizedBox(widthFactor: 0.7, child: RotaSkeleton(height: 34)),
                SizedBox(height: RotaSpacing.s3),
                FractionallySizedBox(widthFactor: 0.5, child: RotaSkeleton()),
                SizedBox(height: RotaSpacing.s6),
                RotaSkeleton(),
                SizedBox(height: RotaSpacing.s2),
                RotaSkeleton(),
                SizedBox(height: RotaSpacing.s2),
                FractionallySizedBox(widthFactor: 0.8, child: RotaSkeleton()),
              ],
            ),
            aside: RotaSkeleton(height: 280, shape: RotaSkeletonShape.rect),
          ),
        ],
      ),
    );
  }
}
