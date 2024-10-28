import 'package:eventify/presentacion/screens/administrador_screen.dart';
import 'package:eventify/presentacion/screens/login_screen.dart';
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
]);
