import 'package:flutter/material.dart';

import '../../design_system/design_system.dart';

/// Corpo rolável de uma página: conteúdo centralizado e rodapé no fim.
class RotaPageBody extends StatelessWidget {
  const RotaPageBody({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final horizontal = width < RotaLayout.compactBreakpoint ? RotaSpacing.s4 : RotaSpacing.s6;
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: RotaLayout.containerWidth + RotaSpacing.s6 * 2),
              child: Padding(
                padding: EdgeInsets.fromLTRB(horizontal, RotaSpacing.s8, horizontal, RotaSpacing.s16),
                child: child,
              ),
            ),
          ),
        ),
        const SliverFillRemaining(
          hasScrollBody: false,
          child: Align(alignment: Alignment.bottomCenter, child: _Footer()),
        ),
      ],
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    final c = context.rotaColors;
    final style = RotaTypography.bodySm.copyWith(color: c.textMuted);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: c.surface,
        border: Border(top: BorderSide(color: c.border)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: RotaSpacing.s6, vertical: RotaSpacing.s6),
      child: Center(
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: RotaLayout.containerWidth),
          child: SizedBox(
            width: double.infinity,
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              spacing: RotaSpacing.s4,
              runSpacing: RotaSpacing.s2,
              children: [
                Text('Rota, projeto de demonstração com dados fictícios.', style: style),
                Text('Feito com Flutter e go_router.', style: style),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Título e subtítulo no topo das páginas.
class PageHeader extends StatelessWidget {
  const PageHeader({super.key, required this.title, this.subtitle, this.eyebrow, this.large = false});

  final String title;
  final String? subtitle;
  final String? eyebrow;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final c = context.rotaColors;
    final compact = MediaQuery.sizeOf(context).width < RotaLayout.compactBreakpoint;
    final titleStyle = large && !compact ? RotaTypography.display : RotaTypography.title;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (eyebrow != null) ...[
          Text(eyebrow!.toUpperCase(), style: RotaTypography.eyebrow.copyWith(color: c.primary)),
          const SizedBox(height: RotaSpacing.s2),
        ],
        Semantics(header: true, child: Text(title, style: titleStyle.copyWith(color: c.text))),
        if (subtitle != null) ...[
          const SizedBox(height: RotaSpacing.s2),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Text(subtitle!, style: RotaTypography.body.copyWith(color: c.textMuted, fontSize: RotaTypography.lg)),
          ),
        ],
      ],
    );
  }
}

/// Título de seção dentro de uma página.
class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      child: Text(text, style: RotaTypography.sectionTitle.copyWith(color: context.rotaColors.text)),
    );
  }
}

/// Conteúdo principal e coluna lateral. Em telas estreitas, a coluna vai para baixo.
class SplitLayout extends StatelessWidget {
  const SplitLayout({super.key, required this.main, required this.aside, this.asideWidth = 360});

  final Widget main;
  final Widget aside;
  final double asideWidth;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < RotaLayout.splitBreakpoint) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [main, const SizedBox(height: RotaSpacing.s6), aside],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: main),
            const SizedBox(width: RotaSpacing.s8),
            SizedBox(width: asideWidth, child: aside),
          ],
        );
      },
    );
  }
}

/// Grade responsiva: quantas colunas couberem com a largura mínima informada.
class ResponsiveGrid extends StatelessWidget {
  const ResponsiveGrid({super.key, required this.children, this.minItemWidth = 300});

  final List<Widget> children;
  final double minItemWidth;

  @override
  Widget build(BuildContext context) {
    const gap = RotaSpacing.s6;
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = ((constraints.maxWidth + gap) / (minItemWidth + gap)).floor().clamp(1, 3);
        final itemWidth = (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [for (final child in children) SizedBox(width: itemWidth, child: child)],
        );
      },
    );
  }
}

/// Duas colunas lado a lado quando há espaço; uma embaixo da outra quando não há.
class FieldRow extends StatelessWidget {
  const FieldRow({super.key, required this.children, this.breakpoint = 520});

  final List<Widget> children;
  final double breakpoint;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < breakpoint) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < children.length; i++) ...[
                if (i > 0) const SizedBox(height: RotaSpacing.s4),
                children[i],
              ],
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < children.length; i++) ...[
              if (i > 0) const SizedBox(width: RotaSpacing.s4),
              Expanded(child: children[i]),
            ],
          ],
        );
      },
    );
  }
}

/// Linha "rótulo ... valor" usada em resumos.
class DetailLine extends StatelessWidget {
  const DetailLine({super.key, required this.label, required this.value, this.emphasis = false});

  final String label;
  final String value;
  final bool emphasis;

  @override
  Widget build(BuildContext context) {
    final c = context.rotaColors;
    final labelStyle = emphasis
        ? RotaTypography.cardTitle.copyWith(color: c.text, fontSize: RotaTypography.lg)
        : RotaTypography.bodySm.copyWith(color: c.textMuted);
    final valueStyle = emphasis
        ? RotaTypography.cardTitle.copyWith(color: c.text, fontSize: RotaTypography.lg)
        : RotaTypography.bodySm.copyWith(color: c.text, fontWeight: RotaTypography.medium);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: RotaSpacing.s1),
      child: LayoutBuilder(
        builder: (context, constraints) => Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: Text(label, style: labelStyle)),
            const SizedBox(width: RotaSpacing.s4),
            // O valor ocupa só o necessário, até 60% da linha.
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: constraints.maxWidth * 0.6),
              child: Text(value, textAlign: TextAlign.right, style: valueStyle),
            ),
          ],
        ),
      ),
    );
  }
}

/// Item de lista com ícone (destaques, o que está incluso).
class IconListItem extends StatelessWidget {
  const IconListItem({super.key, required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final c = context.rotaColors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: RotaSpacing.s1),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: c.primary),
          const SizedBox(width: RotaSpacing.s3),
          Expanded(child: Text(text, style: RotaTypography.body.copyWith(color: c.text))),
        ],
      ),
    );
  }
}

/// Ícone pequeno seguido de texto, usado em metadados.
class MetaItem extends StatelessWidget {
  const MetaItem({super.key, required this.icon, required this.text, this.size = 16});

  final IconData icon;
  final String text;
  final double size;

  @override
  Widget build(BuildContext context) {
    final c = context.rotaColors;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: size, color: c.textMuted),
        const SizedBox(width: RotaSpacing.s1),
        Flexible(child: Text(text, style: RotaTypography.bodySm.copyWith(color: c.textMuted))),
      ],
    );
  }
}
