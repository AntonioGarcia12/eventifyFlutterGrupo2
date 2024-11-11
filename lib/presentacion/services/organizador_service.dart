import 'package:eventify/infraestructuras/models/evento.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eventify/presentacion/providers/evento_provider.dart';

final organizadorServiceProvider = Provider((ref) => OrganizadorService(ref));

class OrganizadorService {
  // ignore: deprecated_member_use
  final ProviderRef ref;
  String username = 'Organizador';
  OrganizadorService(this.ref);

  Future<void> loadUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    username = prefs.getString('username') ?? 'Usuario';
  }

  Future<void> fetchEventos() async {
    await ref.read(eventoProvider).fetchEventos();
  }

  List<Evento> filterEventosByCategory(List<Evento> eventos, String category) {
    if (category.isEmpty) {
      return eventos;
    }
    return eventos
        .where(
            (evento) => evento.category.toLowerCase() == category.toLowerCase())
        .toList();
  }
}
