import 'package:eventify/infraestructuras/models/eventsByOrganizador.dart';
import 'package:eventify/presentacion/providers/evento_by_organizador_provider.dart';
import 'package:eventify/presentacion/widgets/generic_event_card_organizador.dart';
import 'package:eventify/presentacion/widgets/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EventListByOrganizador extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = ref.watch(eventoByOrganizadorProvider);
    final eventos = provider.eventos;
    final isLoading = provider.isLoading;

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (eventos.isEmpty) {
      return const Center(
        child: Text(
          'No hay eventos disponibles.',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      );
    } else {
      return ListView.builder(
        itemCount: eventos.length,
        itemBuilder: (context, index) {
          final evento = eventos[index];
          return _getEventCard(evento, ref);
        },
      );
    }
  }

  Widget _getEventCard(Eventsbyorganizador evento, WidgetRef ref) {
    Color borderColor;
    switch (evento.category_name.toLowerCase()) {
      case 'music':
        borderColor = const Color(0xFFFFD700);
        break;
      case 'sport':
        borderColor = const Color(0xFFFF4500);
        break;
      case 'technology':
        borderColor = const Color(0xFF4CAF50);
        break;
      case 'cultural':
        borderColor = const Color(0xFF9C27B0);
        break;
      default:
        borderColor = Colors.grey;
    }

    return GenericEventCardOrganizador(
      evento: evento,
      borderColor: borderColor,
      ref: ref,
    );
  }
}
