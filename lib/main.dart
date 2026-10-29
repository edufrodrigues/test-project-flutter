import 'package:flutter/foundation.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'api/scenario.dart';
import 'app/app.dart';
import 'app/app_scope.dart';
import 'utils/storage.dart';

/// Com `--dart-define=ROUTER=hash`, as URLs passam a usar `#` (`/#/reservas`).
/// Útil quando o app roda dentro de iframe ou em subpasta.
const _routerMode = String.fromEnvironment('ROUTER');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (_routerMode != 'hash') usePathUrlStrategy();
  // Na web, o Flutter só cria a árvore de acessibilidade no DOM depois de um
  // clique em "Enable accessibility". Ligando sempre, leitores de tela e
  // ferramentas que leem a página (testes, inspeção) enxergam os elementos.
  if (kIsWeb) SemanticsBinding.instance.ensureSemantics();
  await initializeDateFormatting('pt_BR');

  final store = await SharedPreferencesStore.open();
  final services = AppServices.create(store: store, initialScenario: Scenario.fromUri(Uri.base));

  runApp(RotaApp(services: services));
}
