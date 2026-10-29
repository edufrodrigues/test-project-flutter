import 'package:flutter_test/flutter_test.dart';
import 'package:rota/api/scenario.dart';
import 'package:rota/design_system/design_system.dart';
import 'package:rota/features/experiences/experience_card.dart';

import 'helpers/pump_app.dart';

void main() {
  group('Explorar', () {
    testWidgets('mostra skeleton enquanto carrega e depois a lista', (tester) async {
      await pumpRotaApp(tester);

      expect(find.byType(ExperienceCardSkeleton), findsNWidgets(6));

      await tester.pumpAndSettle();
      expect(find.byType(ExperienceCardSkeleton), findsNothing);
      expect(find.text('9 experiências encontradas'), findsOneWidget);
      expect(find.byType(ExperienceCard), findsNWidgets(9));
    });

    testWidgets('mostra erro e tenta de novo', (tester) async {
      final services = await pumpRotaApp(tester, scenario: Scenario.erro);
      await tester.pumpAndSettle();

      expect(find.text('Não foi possível carregar as experiências'), findsOneWidget);
      expect(find.text('Falha simulada de conexão com o servidor.'), findsOneWidget);

      // "Tentar de novo" refaz a busca: volta ao loading e falha de novo.
      await tester.tap(find.text('Tentar de novo'));
      await tester.pump();
      expect(find.byType(ExperienceCardSkeleton), findsNWidgets(6));
      await tester.pumpAndSettle();
      expect(find.text('Não foi possível carregar as experiências'), findsOneWidget);

      // Trocar o cenário recarrega a tela sozinho.
      services.scenario.value = Scenario.normal;
      await tester.pumpAndSettle();
      expect(find.text('9 experiências encontradas'), findsOneWidget);
    });

    testWidgets('mostra estado vazio quando não há experiências', (tester) async {
      await pumpRotaApp(tester, scenario: Scenario.vazio);
      await tester.pumpAndSettle();

      expect(find.text('Nenhuma experiência disponível'), findsOneWidget);
      expect(find.byType(ExperienceCard), findsNothing);
    });

    testWidgets('mostra "Nada encontrado" e limpa os filtros', (tester) async {
      await pumpRotaApp(tester);
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(RotaTextField), 'xyzabc');
      await tester.pumpAndSettle();

      expect(find.text('Nada encontrado'), findsOneWidget);
      expect(
        find.text('Não achamos experiências para "xyzabc". Tente outro termo ou categoria.'),
        findsOneWidget,
      );

      await tester.tap(find.text('Limpar filtros'));
      await tester.pumpAndSettle();
      expect(find.text('9 experiências encontradas'), findsOneWidget);
    });

    testWidgets('busca ignora acentos e filtra por categoria', (tester) async {
      await pumpRotaApp(tester);
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(RotaTextField), 'lencois');
      await tester.pumpAndSettle();
      expect(find.text('1 experiência encontrada'), findsOneWidget);
      expect(find.text('Trilha ao Morro do Pai Inácio no pôr do sol'), findsOneWidget);

      await tester.enterText(find.byType(RotaTextField), '');
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(RotaChip, 'Gastronomia'));
      await tester.pumpAndSettle();
      expect(find.text('2 experiências encontradas'), findsOneWidget);
    });

    testWidgets('lê os filtros da URL', (tester) async {
      await pumpRotaApp(tester, location: '/?categoria=cultura');
      await tester.pumpAndSettle();

      expect(find.text('1 experiência encontrada'), findsOneWidget);
      expect(find.text('Caminhada histórica por Ouro Preto'), findsOneWidget);
    });
  });
}
