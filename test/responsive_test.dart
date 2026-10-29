import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/pump_app.dart';

/// Abre cada tela em largura de celular e de tablet. Qualquer estouro de
/// layout (RenderFlex overflow) faz o teste falhar.
void main() {
  const routes = [
    '/',
    '/experiencias/estrelas-jalapao',
    '/experiencias/estrelas-jalapao/reservar',
    '/reserva/RT-7Q2K/confirmada',
    '/reservas',
    '/reservas?aba=passadas',
    '/perfil',
    '/nao-existe',
  ];

  for (final size in const [Size(375, 812), Size(768, 1024)]) {
    for (final route in routes) {
      testWidgets('$route cabe em ${size.width.toInt()} px', (tester) async {
        await pumpRotaApp(tester, location: route, size: size);
        await tester.pump();
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });
    }
  }
}
