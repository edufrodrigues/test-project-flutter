import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rota/api/scenario.dart';
import 'package:rota/app/theme_controller.dart';
import 'package:rota/design_system/design_system.dart';

import 'helpers/pump_app.dart';

void main() {
  group('Perfil', () {
    testWidgets('salva alterações e mostra o toast', (tester) async {
      await pumpRotaApp(tester, location: '/perfil');
      await tester.pumpAndSettle();

      expect(find.text('Marina Costa'), findsWidgets);
      RotaButton saveButton() => tester.widget<RotaButton>(find.widgetWithText(RotaButton, 'Salvar alterações'));
      expect(saveButton().onPressed, isNull, reason: 'Sem alterações, o botão fica desabilitado.');

      await tester.enterText(textField('Cidade'), 'Recife, PE');
      await tester.pump();
      expect(saveButton().onPressed, isNotNull);

      await scrollAndTap(tester, find.text('Salvar alterações'));
      expect(find.text('Perfil atualizado'), findsOneWidget);
      expect(find.text('Recife, PE'), findsWidgets);
    });

    testWidgets('mostra erro ao salvar no cenário erro-envio', (tester) async {
      await pumpRotaApp(tester, location: '/perfil', scenario: Scenario.erroEnvio);
      await tester.pumpAndSettle();

      await tester.enterText(textField('Nome'), 'Marina C.');
      await tester.pump();
      await scrollAndTap(tester, find.text('Salvar alterações'));

      expect(find.text('Não foi possível salvar'), findsOneWidget);
    });

    testWidgets('troca o tema', (tester) async {
      final services = await pumpRotaApp(tester, location: '/perfil');
      await tester.pumpAndSettle();

      await scrollAndTap(tester, find.text('Escuro'));
      expect(services.theme.preference, ThemePreference.escuro);
      final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(app.themeMode, ThemeMode.dark);
    });
  });

  group('Painel de cenários', () {
    testWidgets('troca o cenário pelo botão flutuante', (tester) async {
      await pumpRotaApp(tester);
      await tester.pumpAndSettle();
      expect(find.text('9 experiências encontradas'), findsOneWidget);

      await tester.tap(find.text('Cenário: Normal'));
      await tester.pumpAndSettle();
      expect(find.text('Simular cenário'), findsOneWidget);

      await tester.tap(find.text('Erro'));
      await tester.pumpAndSettle();
      expect(find.text('Cenário: Erro'), findsOneWidget);
      expect(find.text('Não foi possível carregar as experiências'), findsOneWidget);
    });

    test('lê o cenário da URL, com e sem hash', () {
      expect(Scenario.fromUri(Uri.parse('http://localhost:8080/?cenario=erro')), Scenario.erro);
      expect(Scenario.fromUri(Uri.parse('http://localhost:8080/reservas?cenario=erro-envio')), Scenario.erroEnvio);
      expect(Scenario.fromUri(Uri.parse('http://localhost:8080/#/reservas?cenario=vazio')), Scenario.vazio);
      expect(Scenario.fromUri(Uri.parse('http://localhost:8080/?cenario=invalido')), Scenario.normal);
    });
  });
}
