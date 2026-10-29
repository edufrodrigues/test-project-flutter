import 'package:flutter/material.dart';

import '../../api/models.dart';
import '../../design_system/design_system.dart';
import '../../utils/format.dart';
import 'experience_art.dart';

/// Card de experiência da lista Explorar.
class ExperienceCard extends StatelessWidget {
  const ExperienceCard({super.key, required this.experience, required this.onTap});

  final Experience experience;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.rotaColors;
    return RotaCard(
      padding: RotaCardPadding.none,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AspectRatio(
            aspectRatio: 16 / 10,
            child: Stack(
              fit: StackFit.expand,
              children: [
                ExperienceArt(art: experience.art),
                Positioned(
                  top: RotaSpacing.s3,
                  left: RotaSpacing.s3,
                  child: RotaBadge(label: RotaFormat.category(experience.category)),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(RotaSpacing.s4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.place_outlined, size: 12, color: c.textMuted),
                    const SizedBox(width: RotaSpacing.s1),
                    Flexible(
                      child: Text(
                        experience.location,
                        overflow: TextOverflow.ellipsis,
                        style: RotaTypography.caption.copyWith(color: c.textMuted, fontWeight: RotaTypography.medium),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: RotaSpacing.s2),
                Text(
                  experience.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: RotaTypography.cardTitle.copyWith(color: c.text, fontSize: RotaTypography.lg),
                ),
                const SizedBox(height: RotaSpacing.s2),
                Text(
                  experience.summary,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: RotaTypography.bodySm.copyWith(color: c.textMuted),
                ),
                const SizedBox(height: RotaSpacing.s4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('a partir de', style: RotaTypography.caption.copyWith(color: c.textMuted)),
                          Text(
                            RotaFormat.currency(experience.price),
                            style: RotaTypography.cardTitle.copyWith(color: c.text, fontSize: RotaTypography.lg),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        RotaRating(value: experience.rating, count: experience.reviewsCount),
                        const SizedBox(height: RotaSpacing.s1),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.schedule, size: 12, color: c.textMuted),
                            const SizedBox(width: RotaSpacing.s1),
                            Text(
                              RotaFormat.duration(experience.durationHours),
                              style: RotaTypography.caption.copyWith(color: c.textMuted),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Versão de carregamento do [ExperienceCard].
class ExperienceCardSkeleton extends StatelessWidget {
  const ExperienceCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const RotaCard(
      padding: RotaCardPadding.none,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AspectRatio(aspectRatio: 16 / 10, child: RotaSkeleton(shape: RotaSkeletonShape.rect)),
          Padding(
            padding: EdgeInsets.all(RotaSpacing.s4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FractionallySizedBox(widthFactor: 0.45, child: RotaSkeleton()),
                SizedBox(height: RotaSpacing.s3),
                FractionallySizedBox(widthFactor: 0.85, child: RotaSkeleton(height: 20)),
                SizedBox(height: RotaSpacing.s3),
                RotaSkeleton(),
                SizedBox(height: RotaSpacing.s2),
                FractionallySizedBox(widthFactor: 0.7, child: RotaSkeleton()),
                SizedBox(height: RotaSpacing.s4),
                Row(
                  children: [
                    Expanded(child: FractionallySizedBox(widthFactor: 0.6, alignment: Alignment.centerLeft, child: RotaSkeleton(height: 24))),
                    SizedBox(width: RotaSpacing.s4),
                    SizedBox(width: 70, child: RotaSkeleton(height: 24)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
