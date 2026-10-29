import 'package:flutter/foundation.dart';

/// Cenários do simulador da API falsa.
///
/// Troque pelo botão flutuante "Cenário" ou, na web, pela URL (`?cenario=erro`).
enum Scenario {
  normal('normal', 'Normal', 'Dados de exemplo com atraso de ~0,8 s.', Duration(milliseconds: 800)),
  lento('lento', 'Lento', 'Atraso de 4 s para observar os loadings.', Duration(seconds: 4)),
  erro('erro', 'Erro', 'Todas as chamadas falham.', Duration(milliseconds: 700)),
  vazio('vazio', 'Vazio', 'Listas sem itens e detalhes não encontrados.', Duration(milliseconds: 600)),
  erroEnvio(
    'erro-envio',
    'Erro no envio',
    'Telas carregam, mas salvar, reservar e cancelar falham.',
    Duration(milliseconds: 800),
  );

  const Scenario(this.slug, this.label, this.description, this.latency);

  /// Valor usado na URL (`?cenario=erro-envio`).
  final String slug;
  final String label;
  final String description;
  final Duration latency;

  static Scenario? fromSlug(String? slug) {
    for (final scenario in values) {
      if (scenario.slug == slug) return scenario;
    }
    return null;
  }

  /// Lê `?cenario=` da URL de abertura. Funciona com URLs normais e com hash (`/#/rota?cenario=`).
  static Scenario fromUri(Uri uri) {
    final fromQuery = fromSlug(uri.queryParameters['cenario']);
    if (fromQuery != null) return fromQuery;
    if (uri.fragment.isNotEmpty) {
      final fragment = Uri.tryParse(uri.fragment);
      final fromFragment = fromSlug(fragment?.queryParameters['cenario']);
      if (fromFragment != null) return fromFragment;
    }
    return Scenario.normal;
  }
}

/// Cenário ativo. Telas que carregam dados escutam este controller e refazem a busca.
class ScenarioController extends ValueNotifier<Scenario> {
  ScenarioController([super.value = Scenario.normal]);
}
