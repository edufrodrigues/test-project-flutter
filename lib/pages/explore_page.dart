import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../api/fake_api.dart';
import '../api/models.dart';
import '../app/app_scope.dart';
import '../app/routes.dart';
import '../design_system/design_system.dart';
import '../features/experiences/experience_card.dart';
import '../features/layout/page_layout.dart';
import '../utils/async_loader.dart';
import '../utils/format.dart';
import '../utils/text.dart';

enum SortOrder {
  relevancia('relevancia', 'Mais populares'),
  menorPreco('menor-preco', 'Menor preço'),
  maiorPreco('maior-preco', 'Maior preço'),
  avaliacao('avaliacao', 'Melhor avaliação');

  const SortOrder(this.slug, this.label);

  final String slug;
  final String label;
}

/// Filtros da tela Explorar. Ficam na URL: `?q=paraty&categoria=natureza&ordem=menor-preco`.
class ExploreFilters {
  const ExploreFilters({this.query = '', this.category, this.order = SortOrder.relevancia});

  final String query;
  final Category? category;
  final SortOrder order;

  static const keys = ['q', 'categoria', 'ordem'];

  factory ExploreFilters.fromQuery(Map<String, String> params) {
    return ExploreFilters(
      query: params['q'] ?? '',
      category: Category.values.where((value) => value.name == params['categoria']).firstOrNull,
      order: SortOrder.values.where((value) => value.slug == params['ordem']).firstOrNull ?? SortOrder.relevancia,
    );
  }

  Map<String, String> toQuery() => {
    if (query.isNotEmpty) 'q': query,
    if (category != null) 'categoria': category!.name,
    if (order != SortOrder.relevancia) 'ordem': order.slug,
  };

  ExploreFilters copyWith({String? query, Category? Function()? category, SortOrder? order}) => ExploreFilters(
    query: query ?? this.query,
    category: category == null ? this.category : category(),
    order: order ?? this.order,
  );

  List<Experience> apply(List<Experience> items) {
    final term = normalizeForSearch(query.trim());
    final filtered = items.where((item) {
      if (category != null && item.category != category) return false;
      if (term.isEmpty) return true;
      return normalizeForSearch('${item.title} ${item.city} ${item.state} ${item.summary}').contains(term);
    }).toList();

    int Function(Experience, Experience) sorter = switch (order) {
      SortOrder.relevancia => (a, b) => b.reviewsCount.compareTo(a.reviewsCount),
      SortOrder.menorPreco => (a, b) => a.price.compareTo(b.price),
      SortOrder.maiorPreco => (a, b) => b.price.compareTo(a.price),
      SortOrder.avaliacao => (a, b) {
        final byRating = b.rating.compareTo(a.rating);
        return byRating != 0 ? byRating : b.reviewsCount.compareTo(a.reviewsCount);
      },
    };
    return filtered..sort(sorter);
  }
}

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key, required this.filters});

  final ExploreFilters filters;

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> with AsyncLoader<ExplorePage, List<Experience>> {
  late final _search = TextEditingController(text: widget.filters.query);

  @override
  Future<List<Experience>> load(AppServices services) => services.api.listExperiences();

  @override
  void didUpdateWidget(ExplorePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Mantém o campo em sincronia quando a URL muda por fora (ex.: "Limpar filtros").
    if (widget.filters.query != _search.text) _search.text = widget.filters.query;
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  /// Atualiza os filtros na URL, preservando os outros parâmetros (como `?cenario`).
  /// `Router.neglect` evita criar uma entrada no histórico a cada tecla.
  void _updateFilters(ExploreFilters next) {
    final current = GoRouterState.of(context).uri.queryParameters;
    final params = {
      for (final entry in current.entries)
        if (!ExploreFilters.keys.contains(entry.key)) entry.key: entry.value,
      ...next.toQuery(),
    };
    Router.neglect(context, () => context.goNamed(AppRoutes.explore, queryParameters: params));
  }

  @override
  Widget build(BuildContext context) {
    final filters = widget.filters;
    return RotaPageBody(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const PageHeader(
            eyebrow: 'Experiências pelo Brasil',
            title: 'Viva o melhor de cada destino',
            subtitle: 'Passeios, trilhas e sabores escolhidos a dedo, com guias locais e grupos pequenos.',
            large: true,
          ),
          const SizedBox(height: RotaSpacing.s8),
          _Toolbar(
            search: _search,
            order: filters.order,
            onQueryChanged: (value) => _updateFilters(filters.copyWith(query: value)),
            onOrderChanged: (value) => _updateFilters(filters.copyWith(order: value)),
          ),
          const SizedBox(height: RotaSpacing.s4),
          Semantics(
            container: true,
            label: 'Filtrar por categoria',
            child: Wrap(
              spacing: RotaSpacing.s2,
              runSpacing: RotaSpacing.s2,
              children: [
                RotaChip(
                  label: 'Todas',
                  selected: filters.category == null,
                  onTap: () => _updateFilters(filters.copyWith(category: () => null)),
                ),
                for (final category in Category.values)
                  RotaChip(
                    label: RotaFormat.category(category),
                    selected: filters.category == category,
                    onTap: () => _updateFilters(filters.copyWith(category: () => category)),
                  ),
              ],
            ),
          ),
          const SizedBox(height: RotaSpacing.s6),
          _buildResults(context),
        ],
      ),
    );
  }

  Widget _buildResults(BuildContext context) {
    final filters = widget.filters;
    switch (loadState) {
      case AsyncLoading():
        return RotaLoadingRegion(
          label: 'Carregando experiências',
          child: ResponsiveGrid(children: List.generate(6, (_) => const ExperienceCardSkeleton())),
        );
      case AsyncFailure(:final error):
        return RotaErrorState(
          title: 'Não foi possível carregar as experiências',
          description: errorMessage(error),
          onRetry: reload,
        );
      case AsyncData(:final data) when data.isEmpty:
        return const RotaEmptyState(
          title: 'Nenhuma experiência disponível',
          description: 'Ainda não temos experiências cadastradas. Volte em breve para conferir as novidades.',
        );
      case AsyncData(:final data):
        final results = filters.apply(data);
        if (results.isEmpty) {
          return RotaEmptyState(
            icon: Icons.search_off,
            title: 'Nada encontrado',
            description: filters.query.isNotEmpty
                ? 'Não achamos experiências para "${filters.query}". Tente outro termo ou categoria.'
                : 'Nenhuma experiência nesta categoria.',
            actions: [
              RotaButton(
                label: 'Limpar filtros',
                variant: RotaButtonVariant.secondary,
                onPressed: () => _updateFilters(const ExploreFilters()),
              ),
            ],
          );
        }
        final c = context.rotaColors;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              liveRegion: true,
              child: Text(
                results.length == 1 ? '1 experiência encontrada' : '${results.length} experiências encontradas',
                style: RotaTypography.bodySm.copyWith(color: c.textMuted),
              ),
            ),
            const SizedBox(height: RotaSpacing.s4),
            ResponsiveGrid(
              children: [
                for (final experience in results)
                  ExperienceCard(
                    experience: experience,
                    onTap: () => context.goNamed(AppRoutes.experience, pathParameters: {'id': experience.id}),
                  ),
              ],
            ),
          ],
        );
    }
  }
}

class _Toolbar extends StatelessWidget {
  const _Toolbar({
    required this.search,
    required this.order,
    required this.onQueryChanged,
    required this.onOrderChanged,
  });

  final TextEditingController search;
  final SortOrder order;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<SortOrder> onOrderChanged;

  @override
  Widget build(BuildContext context) {
    final searchField = RotaTextField(
      label: 'Buscar experiência',
      placeholder: 'Destino, cidade ou atividade',
      icon: Icons.search,
      controller: search,
      textInputAction: TextInputAction.search,
      onChanged: onQueryChanged,
    );
    final sortField = RotaSelect<SortOrder>(
      label: 'Ordenar por',
      value: order,
      options: [for (final option in SortOrder.values) RotaSelectOption(option, option.label)],
      onChanged: onOrderChanged,
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < RotaLayout.compactBreakpoint) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [searchField, const SizedBox(height: RotaSpacing.s4), sortField],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: searchField),
            const SizedBox(width: RotaSpacing.s4),
            SizedBox(width: 240, child: sortField),
          ],
        );
      },
    );
  }
}
