import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app/routes.dart';
import '../design_system/design_system.dart';
import '../features/layout/page_layout.dart';

class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    return RotaPageBody(
      child: RotaEmptyState(
        icon: Icons.wrong_location_outlined,
        title: 'Página não encontrada',
        description: 'Parece que essa rota não leva a lugar nenhum. Confira o endereço ou volte para o início.',
        actions: [RotaButton(label: 'Voltar para o início', onPressed: () => context.goNamed(AppRoutes.explore))],
      ),
    );
  }
}
