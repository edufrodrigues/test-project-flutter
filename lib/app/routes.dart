import 'package:go_router/go_router.dart';

import '../features/layout/app_shell.dart';
import '../pages/booking_page.dart';
import '../pages/bookings_page.dart';
import '../pages/confirmation_page.dart';
import '../pages/experience_page.dart';
import '../pages/explore_page.dart';
import '../pages/not_found_page.dart';
import '../pages/profile_page.dart';

/// Nomes das rotas. Navegue com `context.goNamed(AppRoutes.experience, pathParameters: {'id': ...})`.
abstract final class AppRoutes {
  static const explore = 'explore';
  static const experience = 'experience';
  static const booking = 'booking';
  static const confirmation = 'confirmation';
  static const bookings = 'bookings';
  static const profile = 'profile';
}

/// Cria o roteador.
///
/// As rotas ficam aninhadas em "/" para o botão voltar (do app, do navegador
/// ou do Android) sempre ter para onde ir: Explorar → Detalhe → Reserva.
GoRouter createRouter({String initialLocation = '/'}) {
  return GoRouter(
    initialLocation: initialLocation,
    errorBuilder: (context, state) => AppShell(location: state.uri.path, child: const NotFoundPage()),
    routes: [
      ShellRoute(
        builder: (context, state, child) => AppShell(location: state.uri.path, child: child),
        routes: [
          GoRoute(
            path: '/',
            name: AppRoutes.explore,
            builder: (context, state) => ExplorePage(filters: ExploreFilters.fromQuery(state.uri.queryParameters)),
            routes: [
              GoRoute(
                path: 'experiencias/:id',
                name: AppRoutes.experience,
                builder: (context, state) => ExperiencePage(experienceId: state.pathParameters['id']!),
                routes: [
                  GoRoute(
                    path: 'reservar',
                    name: AppRoutes.booking,
                    builder: (context, state) => BookingPage(experienceId: state.pathParameters['id']!),
                  ),
                ],
              ),
              GoRoute(
                path: 'reserva/:codigo/confirmada',
                name: AppRoutes.confirmation,
                builder: (context, state) => ConfirmationPage(bookingId: state.pathParameters['codigo']!),
              ),
              GoRoute(
                path: 'reservas',
                name: AppRoutes.bookings,
                builder: (context, state) => BookingsPage(tab: BookingsTab.fromQuery(state.uri.queryParameters['aba'])),
              ),
              GoRoute(path: 'perfil', name: AppRoutes.profile, builder: (context, state) => const ProfilePage()),
            ],
          ),
        ],
      ),
    ],
  );
}
