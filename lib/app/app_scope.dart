import 'package:flutter/widgets.dart';

import '../api/fake_api.dart';
import '../api/scenario.dart';
import '../utils/storage.dart';
import 'theme_controller.dart';

/// Serviços globais do app: API falsa, cenário e tema.
class AppServices {
  AppServices({required this.api, required this.scenario, required this.theme})
    : dataChanges = Listenable.merge([scenario, api]);

  /// Monta os serviços a partir de um storage. Nos testes, use [MemoryStore].
  factory AppServices.create({
    required KeyValueStore store,
    Scenario initialScenario = Scenario.normal,
    Duration? latencyOverride,
  }) {
    final scenario = ScenarioController(initialScenario);
    return AppServices(
      api: FakeApi(store: store, scenario: scenario, latencyOverride: latencyOverride),
      scenario: scenario,
      theme: ThemeController(store),
    );
  }

  final FakeApi api;
  final ScenarioController scenario;
  final ThemeController theme;

  /// Dispara quando o cenário muda ou os dados são restaurados. As telas recarregam.
  final Listenable dataChanges;
}

class AppScope extends InheritedWidget {
  const AppScope({super.key, required this.services, required super.child});

  final AppServices services;

  static AppServices of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope não encontrado na árvore de widgets.');
    return scope!.services;
  }

  @override
  bool updateShouldNotify(AppScope oldWidget) => services != oldWidget.services;
}
