import 'package:flutter_test/flutter_test.dart';
import 'package:rota/api/scenario.dart';
import 'package:rota/design_system/design_system.dart';
import 'package:rota/utils/format.dart';

import 'helpers/pump_app.dart';

void main() {
  group('Detalhe da experiência', () {
    testWidgets('mostra loading e depois os detalhes', (tester) async {
      await pumpRotaApp(tester, location: '/experiencias/balao-boituva');

      expect(find.byType(RotaSkeleton), findsWidgets);

      await tester.pumpAndSettle();
      expect(find.text('Voo de balão ao amanhecer'), findsWidgets);
      expect(find.text(RotaFormat.currency(899)), findsOneWidget);
      expect(find.text('Reservar agora'), findsOneWidget);
    });

    testWidgets('mostra "não encontrada" para um id inexistente', (tester) async {
      await pumpRotaApp(tester, location: '/experiencias/nao-existe');
      await tester.pumpAndSettle();

      expect(find.text('Experiência não encontrada'), findsOneWidget);
      expect(find.text('Voltar para explorar'), findsOneWidget);
    });

    testWidgets('mostra erro com "tentar de novo"', (tester) async {
      await pumpRotaApp(tester, location: '/experiencias/balao-boituva', scenario: Scenario.erro);
      await tester.pumpAndSettle();

      expect(find.text('Algo deu errado'), findsOneWidget);
      expect(find.text('Tentar de novo'), findsOneWidget);
    });

    testWidgets('mostra "não encontrada" no cenário vazio', (tester) async {
      await pumpRotaApp(tester, location: '/experiencias/balao-boituva', scenario: Scenario.vazio);
      await tester.pumpAndSettle();

      expect(find.text('Experiência não encontrada'), findsOneWidget);
    });
  });

  testWidgets('rota desconhecida mostra a página 404', (tester) async {
    await pumpRotaApp(tester, location: '/rota-que-nao-existe');
    await tester.pumpAndSettle();

    expect(find.text('Página não encontrada'), findsOneWidget);

    await tester.tap(find.text('Voltar para o início'));
    await tester.pumpAndSettle();
    expect(find.text('Viva o melhor de cada destino'), findsOneWidget);
  });
}
