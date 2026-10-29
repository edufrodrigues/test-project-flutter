import 'package:flutter/material.dart';

import '../tokens/tokens.dart';

class RotaBreadcrumbItem {
  const RotaBreadcrumbItem(this.label, {this.onTap});

  final String label;

  /// Sem `onTap`, o item é a página atual.
  final VoidCallback? onTap;
}

/// Trilha de navegação. O último item representa a página atual.
class RotaBreadcrumb extends StatelessWidget {
  const RotaBreadcrumb({super.key, required this.items});

  final List<RotaBreadcrumbItem> items;

  @override
  Widget build(BuildContext context) {
    final c = context.rotaColors;
    return Semantics(
      container: true,
      label: 'Você está em',
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: RotaSpacing.s1,
        runSpacing: RotaSpacing.s1,
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) Icon(Icons.chevron_right, size: 16, color: c.textSubtle),
            if (items[i].onTap != null)
              InkWell(
                onTap: items[i].onTap,
                borderRadius: BorderRadius.circular(RotaRadius.sm),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                  child: Text(items[i].label, style: RotaTypography.bodySm.copyWith(color: c.textMuted)),
                ),
              )
            else
              Text(
                items[i].label,
                overflow: TextOverflow.ellipsis,
                style: RotaTypography.bodySm.copyWith(color: c.text, fontWeight: RotaTypography.medium),
              ),
          ],
        ],
      ),
    );
  }
}

class RotaTabItem<T> {
  const RotaTabItem({required this.value, required this.label, this.count});

  final T value;
  final String label;
  final int? count;
}

/// Abas horizontais com contador opcional.
class RotaTabs<T> extends StatelessWidget {
  const RotaTabs({super.key, required this.items, required this.value, required this.onChanged});

  final List<RotaTabItem<T>> items;
  final T value;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = context.rotaColors;
    return DecoratedBox(
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: c.border))),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (final item in items) _Tab(item: item, selected: item.value == value, onTap: () => onChanged(item.value)),
          ],
        ),
      ),
    );
  }
}

class _Tab<T> extends StatelessWidget {
  const _Tab({required this.item, required this.selected, required this.onTap});

  final RotaTabItem<T> item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.rotaColors;
    final color = selected ? c.primary : c.textMuted;
    return Semantics(
      selected: selected,
      button: true,
      child: InkWell(
        onTap: onTap,
        child: AnimatedContainer(
          duration: RotaMotion.normal,
          padding: const EdgeInsets.symmetric(horizontal: RotaSpacing.s4, vertical: RotaSpacing.s3),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: selected ? c.primary : Colors.transparent, width: 2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(item.label, style: RotaTypography.label.copyWith(color: color, fontWeight: RotaTypography.semibold)),
              if (item.count != null) ...[
                const SizedBox(width: RotaSpacing.s2),
                Container(
                  constraints: const BoxConstraints(minWidth: 20),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: selected ? c.primarySoft : c.surfaceMuted,
                    borderRadius: BorderRadius.circular(RotaRadius.full),
                  ),
                  child: Text(
                    '${item.count}',
                    textAlign: TextAlign.center,
                    style: RotaTypography.caption.copyWith(color: color, fontWeight: RotaTypography.semibold, height: 1.2),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
