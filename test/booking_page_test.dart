import 'package:flutter_test/flutter_test.dart';
import 'package:rota/api/scenario.dart';
import 'package:rota/utils/date.dart';
import 'package:rota/utils/format.dart';

import 'helpers/pump_app.dart';

const _bookingUrl = '/experiencias/mergulho-baia-do-sancho/reservar';

/// Primeira data disponível do mergulho (3 dias a partir de hoje, como em data.dart).
String _firstDateLabel() => RotaFormat.longDate(RotaDate.addDays(RotaDate.today(), 3));

Future<void> _fillValidForm(WidgetTester tester) async {
  await selectOption(tester, selectField('Data'), _firstDateLabel());
  await tester.enterText(textField('Nome completo'), 'Ana Souza');
  await tester.enterText(textField('E-mail'), 'ana@exemplo.com');
  await tester.enterText(textField('Telefone'), '21912345678');
  await scrollAndTap(tester, find.textContaining('Li e aceito a política de cancelamento'));
}

void main() {
  group('Reserva', () {
    testWidgets('mostra os erros de todos os campos ao enviar vazio', (tester) async {
      await pumpRotaApp(tester, location: _bookingUrl);
      await tester.pumpAndSettle();

      expect(find.text('Finalize sua reserva'), findsOneWidget);
      // Antes de enviar, nenhum erro aparece.
      expect(find.text('Informe seu nome completo.'), findsNothing);

      await scrollAndTap(tester, find.textContaining('Confirmar reserva de'));

      expect(find.text('Escolha uma data.'), findsOneWidget);
      expect(find.text('Informe seu nome completo.'), findsOneWidget);
      expect(find.text('Informe um e-mail válido.'), findsOneWidget);
      expect(find.text('Informe um telefone com DDD.'), findsOneWidget);
      expect(find.text('Você precisa aceitar a política de cancelamento.'), findsOneWidget);
    });

    testWidgets('mostra o erro de um campo só depois que a pessoa sai dele', (tester) async {
      await pumpRotaApp(tester, location: _bookingUrl);
      await tester.pumpAndSettle();

      await tester.enterText(textField('E-mail'), 'ana@');
      await tester.pump();
      expect(find.text('Informe um e-mail válido.'), findsNothing);

      // Sai do campo indo para o próximo.
      await tester.tap(textField('Telefone'));
      await tester.pumpAndSettle();
      expect(find.text('Informe um e-mail válido.'), findsOneWidget);
      expect(find.text('Informe seu nome completo.'), findsNothing);

      await tester.enterText(textField('E-mail'), 'ana@exemplo.com');
      await tester.pump();
      expect(find.text('Informe um e-mail válido.'), findsNothing);
    });

    testWidgets('aplica a máscara de telefone', (tester) async {
      await pumpRotaApp(tester, location: _bookingUrl);
      await tester.pumpAndSettle();

      await tester.enterText(textField('Telefone'), '11987654321');
      await tester.pump();
      expect(textOf(tester, 'Telefone'), '(11) 98765-4321');
    });

    testWidgets('atualiza o total quando muda o número de pessoas', (tester) async {
      await pumpRotaApp(tester, location: _bookingUrl);
      await tester.pumpAndSettle();

      expect(find.text('Confirmar reserva de ${RotaFormat.currency(978)}'), findsOneWidget);

      await selectOption(tester, selectField('Pessoas'), '3 pessoas');
      expect(find.text('Confirmar reserva de ${RotaFormat.currency(1467)}'), findsOneWidget);
    });

    testWidgets('mantém os dados quando o envio falha', (tester) async {
      await pumpRotaApp(tester, location: _bookingUrl, scenario: Scenario.erroEnvio);
      await tester.pumpAndSettle();

      await _fillValidForm(tester);
      await tester.ensureVisible(find.textContaining('Confirmar reserva de'));
      await tester.pumpAndSettle();
      await tester.tap(find.textContaining('Confirmar reserva de'));
      await tester.pump();

      expect(find.text('Confirmando…'), findsOneWidget);

      await tester.pumpAndSettle();
      expect(find.text('Não foi possível concluir sua reserva'), findsOneWidget);
      expect(find.text('Finalize sua reserva'), findsOneWidget);
      expect(textOf(tester, 'Nome completo'), 'Ana Souza');
      expect(textOf(tester, 'E-mail'), 'ana@exemplo.com');
      expect(textOf(tester, 'Telefone'), '(21) 91234-5678');
    });

    testWidgets('mostra "não encontrada" para experiência inexistente', (tester) async {
      await pumpRotaApp(tester, location: '/experiencias/nao-existe/reservar');
      await tester.pumpAndSettle();

      expect(find.text('Experiência não encontrada'), findsOneWidget);
      expect(find.text('Não é possível reservar uma experiência que não existe mais.'), findsOneWidget);
    });
  });
}
