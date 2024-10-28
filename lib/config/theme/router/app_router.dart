import 'package:eventify/presentacion/screens/administrador_screen.dart';
import 'package:eventify/presentacion/screens/editar_screen.dart';
import 'package:eventify/presentacion/screens/login_screen.dart';
import 'package:eventify/presentacion/screens/normal_screen.dart';
import 'package:eventify/presentacion/screens/organizador_screen.dart';
import 'package:go_router/go_router.dart';

final appRouter = GoRouter(initialLocation: '/', routes: [
  GoRoute(
      path: '/',
      name: LoginScreen.name,
      builder: (context, state) => const LoginScreen()),
  GoRoute(
    path: '/admin',
    name: AdministradorScreen.name,
    builder: (context, state) => const AdministradorScreen(),
  ),
  GoRoute(
    path: '/editar',
    builder: (context, state) {
      final userId = state.extra as int;
      return EditarScreen(userId: userId);
    },
  ),
  GoRoute(
    path: '/normal',
    name: NormalScreen.name,
    builder: (context, state) => const NormalScreen(),
  ),
  GoRoute(
    path: '/organizador',
    name: OrganizadorScreen.name,
    builder: (context, state) => const OrganizadorScreen(),
  ),
]);
