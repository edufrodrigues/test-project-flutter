import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rota/api/scenario.dart';
import 'package:rota/app/app.dart';
import 'package:rota/app/app_scope.dart';
import 'package:rota/design_system/design_system.dart';
import 'package:rota/utils/storage.dart';

/// Abre o app completo numa rota, com storage em memória e atraso curto na API.
///
/// Logo depois de chamar, a tela está em loading. Use `tester.pumpAndSettle()`
/// para esperar os dados.
Future<AppServices> pumpRotaApp(
  WidgetTester tester, {
  String location = '/',
  Scenario scenario = Scenario.normal,
  Size size = const Size(1280, 1000),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final services = AppServices.create(
    store: MemoryStore(),
    initialScenario: scenario,
    latencyOverride: const Duration(milliseconds: 50),
  );
  await tester.pumpWidget(RotaApp(services: services, initialLocation: location));
  return services;
}

/// Rola até o widget e toca nele.
Future<void> scrollAndTap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

/// Escolhe uma opção de um RotaSelect: abre a lista e toca no item.
Future<void> selectOption(WidgetTester tester, Finder select, String optionLabel) async {
  await scrollAndTap(
    tester,
    find.descendant(of: select, matching: find.byWidgetPredicate((widget) => widget is DropdownButton)),
  );
  await tester.tap(find.text(optionLabel).last);
  await tester.pumpAndSettle();
}

/// Campo de texto do Rota pelo rótulo.
Finder textField(String label) => find.byWidgetPredicate((widget) => widget is RotaTextField && widget.label == label);

/// Lista de opções do Rota pelo rótulo.
Finder selectField(String label) =>
    find.byWidgetPredicate((widget) => widget is RotaSelect && widget.label == label);

/// Texto digitado atualmente num campo do Rota.
String textOf(WidgetTester tester, String label) {
  final field = tester.widget<TextField>(find.descendant(of: textField(label), matching: find.byType(TextField)));
  return field.controller!.text;
}
