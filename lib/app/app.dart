import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';

import '../design_system/design_system.dart';
import 'app_scope.dart';
import 'routes.dart';

/// Raiz do app: serviços, tema e roteador.
class RotaApp extends StatefulWidget {
  const RotaApp({super.key, required this.services, this.initialLocation = '/'});

  final AppServices services;

  /// Rota inicial. Na web, a URL do navegador tem prioridade.
  final String initialLocation;

  @override
  State<RotaApp> createState() => _RotaAppState();
}

class _RotaAppState extends State<RotaApp> {
  late final GoRouter _router = createRouter(initialLocation: widget.initialLocation);

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.services.theme;
    return AppScope(
      services: widget.services,
      child: ListenableBuilder(
        listenable: theme,
        builder: (context, _) => MaterialApp.router(
          title: 'Rota',
          debugShowCheckedModeBanner: false,
          theme: RotaTheme.light,
          darkTheme: RotaTheme.dark,
          themeMode: theme.preference.mode,
          locale: const Locale('pt', 'BR'),
          supportedLocales: const [Locale('pt', 'BR')],
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          routerConfig: _router,
        ),
      ),
    );
  }
}
