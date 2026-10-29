import 'package:flutter_test/flutter_test.dart';
import 'package:rota/api/scenario.dart';
import 'package:rota/design_system/design_system.dart';
import 'package:rota/utils/format.dart';

import 'helpers/pump_app.dart';

void main() {
  group('Minhas reservas', () {
    testWidgets('separa as reservas por aba', (tester) async {
      await pumpRotaApp(tester, location: '/reservas');
      expect(find.byType(RotaSkeleton), findsWidgets);
      await tester.pumpAndSettle();

      expect(find.text('Passeio de saveiro pelas ilhas de Paraty'), findsOneWidget);
      expect(find.text('Confirmada'), findsOneWidget);

      await tester.tap(find.text('Passadas'));
      await tester.pumpAndSettle();
      expect(find.text('Caminhada histórica por Ouro Preto'), findsOneWidget);
      expect(find.text('Concluída'), findsOneWidget);

      await tester.tap(find.text('Canceladas'));
      await tester.pumpAndSettle();
      expect(find.text('Degustação de vinhos no Vale dos Vinhedos'), findsOneWidget);
    });

    testWidgets('abre a aba pela URL', (tester) async {
      await pumpRotaApp(tester, location: '/reservas?aba=canceladas');
      await tester.pumpAndSettle();

      expect(find.text('Degustação de vinhos no Vale dos Vinhedos'), findsOneWidget);
      expect(find.text('Passeio de saveiro pelas ilhas de Paraty'), findsNothing);
    });

    testWidgets('mostra o estado vazio de cada aba', (tester) async {
      await pumpRotaApp(tester, location: '/reservas', scenario: Scenario.vazio);
      await tester.pumpAndSettle();

      expect(find.text('Nenhuma viagem marcada'), findsOneWidget);
      expect(find.text('Explorar experiências'), findsOneWidget);

      await tester.tap(find.text('Passadas'));
      await tester.pumpAndSettle();
      expect(find.text('Nenhuma experiência no histórico'), findsOneWidget);

      await tester.tap(find.text('Canceladas'));
      await tester.pumpAndSettle();
      expect(find.text('Nenhuma reserva cancelada'), findsOneWidget);
    });

    testWidgets('mostra erro ao carregar', (tester) async {
      await pumpRotaApp(tester, location: '/reservas', scenario: Scenario.erro);
      await tester.pumpAndSettle();

      expect(find.text('Não foi possível carregar suas reservas'), findsOneWidget);
      expect(find.text('Tentar de novo'), findsOneWidget);
    });

    testWidgets('cancela com diálogo de confirmação e mostra o toast', (tester) async {
      await pumpRotaApp(tester, location: '/reservas');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();
      expect(find.text('Cancelar esta reserva?'), findsOneWidget);

      // "Manter reserva" fecha sem cancelar.
      await tester.tap(find.text('Manter reserva'));
      await tester.pumpAndSettle();
      expect(find.text('Cancelar esta reserva?'), findsNothing);
      expect(find.text('Passeio de saveiro pelas ilhas de Paraty'), findsOneWidget);

      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sim, cancelar'));
      await tester.pumpAndSettle();

      expect(find.text('Cancelar esta reserva?'), findsNothing);
      expect(find.text('Reserva cancelada'), findsOneWidget);
      expect(find.text('O reembolso de ${RotaFormat.currency(318)} foi solicitado.'), findsOneWidget);
      expect(find.text('Nenhuma viagem marcada'), findsOneWidget);

      await tester.tap(find.text('Canceladas'));
      await tester.pumpAndSettle();
      expect(find.text('Passeio de saveiro pelas ilhas de Paraty'), findsOneWidget);
    });

    testWidgets('mantém o diálogo aberto quando o cancelamento falha', (tester) async {
      await pumpRotaApp(tester, location: '/reservas', scenario: Scenario.erroEnvio);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sim, cancelar'));
      await tester.pumpAndSettle();

      expect(find.text('Cancelar esta reserva?'), findsOneWidget);
      expect(find.text('Não foi possível cancelar'), findsOneWidget);
    });
  });
}
