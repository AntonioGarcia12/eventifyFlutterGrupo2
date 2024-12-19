import 'package:eventify/infraestructuras/models/eventsByOrganizador.dart';
import 'package:eventify/presentacion/services/organizador_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GenericEventCardServicesOrganizador {
  final WidgetRef ref;

  GenericEventCardServicesOrganizador({required this.ref});

  Future<void> borrarEvento(Eventsbyorganizador evento) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    int? organizadorId = prefs.getInt('id');

    if (token == null || organizadorId == null) {
      throw Exception('Token o ID de organizador no disponible.');
    }

    try {
      final organizadorService = ref.read(organizadorServiceProvider);

      await organizadorService.deleteEvent(evento.id);
    } catch (e) {
      throw Exception('Error al eliminar el evento: $e');
    }
  }
}
