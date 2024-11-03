import 'package:eventify/presentacion/screens/screens.dart';
import 'package:eventify/presentacion/services/services.dart';
import 'package:go_router/go_router.dart';

final appRouter = GoRouter(initialLocation: '/home', routes: [
  GoRoute(
      path: '/home',
      name: HomeScreen.name,
      builder: (context, state) => const HomeScreen()),
  GoRoute(
      path: '/',
      name: LoginScreen.name,
      builder: (context, state) => const LoginScreen()),
  GoRoute(
    path: '/registrar',
    name: RegisterScreen.name,
    builder: (context, state) => const RegisterScreen(),
  ),
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
  GoRoute(
    path: '/login',
    name: LoginService.name,
    builder: (context, state) => const LoginService(),
  ),
]);
