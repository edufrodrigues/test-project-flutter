import 'dart:async';

import 'package:intl/date_symbol_data_local.dart';

/// Configuração carregada pelo flutter_test antes de cada arquivo de teste.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  await initializeDateFormatting('pt_BR');
  await testMain();
}
