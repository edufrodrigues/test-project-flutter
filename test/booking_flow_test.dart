import 'package:flutter_test/flutter_test.dart';
import 'package:rota/utils/date.dart';
import 'package:rota/utils/format.dart';

import 'helpers/pump_app.dart';

void main() {
  testWidgets('fluxo completo: Explorar → Detalhe → Reserva → Confirmação → Minhas reservas', (tester) async {
    await pumpRotaApp(tester);
    await tester.pumpAndSettle();

    // Explorar
    await scrollAndTap(tester, find.text('Mergulho guiado na Baía do Sancho'));

    // Detalhe
    expect(find.text('Reservar agora'), findsOneWidget);
    await scrollAndTap(tester, find.text('Reservar agora'));

    // Reserva: "Voltar" retorna ao detalhe, e dá para seguir de novo.
    expect(find.text('Finalize sua reserva'), findsOneWidget);
    await scrollAndTap(tester, find.text('Voltar'));
    expect(find.text('Reservar agora'), findsOneWidget);
    await scrollAndTap(tester, find.text('Reservar agora'));

    final date = RotaDate.addDays(RotaDate.today(), 3);
    await selectOption(tester, selectField('Data'), RotaFormat.longDate(date));
    await tester.enterText(textField('Nome completo'), 'Ana Souza');
    await tester.enterText(textField('E-mail'), 'ana@exemplo.com');
    await tester.enterText(textField('Telefone'), '21912345678');
    await scrollAndTap(tester, find.textContaining('Li e aceito a política de cancelamento'));
    await scrollAndTap(tester, find.text('Confirmar reserva de ${RotaFormat.currency(978)}'));

    // Confirmação
    expect(find.text('Reserva confirmada!'), findsOneWidget);
    expect(find.textContaining(RegExp(r'^RT-[A-Z2-9]{4}$')), findsOneWidget);
    expect(find.text(RotaFormat.currency(978)), findsOneWidget);
    expect(find.text(RotaFormat.longDate(date)), findsOneWidget);

    // Minhas reservas: a nova reserva aparece em "Próximas", junto com a de exemplo.
    await scrollAndTap(tester, find.text('Ver minhas reservas'));
    expect(find.text('Minhas reservas'), findsWidgets);
    expect(find.text('Mergulho guiado na Baía do Sancho'), findsOneWidget);
    expect(find.text('Passeio de saveiro pelas ilhas de Paraty'), findsOneWidget);
  });
}
