import 'package:eventify/infraestructuras/models/eventsByOrganizador.dart';
import 'package:eventify/presentacion/providers/evento_by_organizador_provider.dart';
import 'package:eventify/presentacion/services/generic_event_card_services_organizador.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class GenericEventCardOrganizador extends StatefulWidget {
  final Eventsbyorganizador evento;
  final Color borderColor;
  final WidgetRef ref;

  const GenericEventCardOrganizador({
    required this.evento,
    required this.borderColor,
    required this.ref,
    super.key,
  });

  @override
  _GenericEventCardOrganizadorState createState() =>
      _GenericEventCardOrganizadorState();
}

class _GenericEventCardOrganizadorState
    extends State<GenericEventCardOrganizador> {
  late GenericEventCardServicesOrganizador eventCardServices;

  @override
  void initState() {
    super.initState();
    eventCardServices = GenericEventCardServicesOrganizador(ref: widget.ref);
  }

  Future<void> _handleBorrarEvento(Eventsbyorganizador evento) async {
    await eventCardServices.borrarEvento(evento);

    widget.ref.read(eventoByOrganizadorProvider).removeEvent(evento.id);

    if (!mounted) return;
    _showSnackBar('Evento eliminado correctamente.');
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    String formattedStart = _formatDateTime(widget.evento.start_time);
    String formattedEnd = _formatDateTime(widget.evento.end_time);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Card(
        shape: RoundedRectangleBorder(
          side: BorderSide(color: widget.borderColor, width: 2),
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 6,
        clipBehavior: Clip.antiAlias,
        shadowColor: Colors.black.withOpacity(0.5),
        child: SizedBox(
          height: 220,
          child: Row(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(10),
                ),
                child: Image.network(
                  widget.evento.image_url,
                  width: 130,
                  height: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Información del Evento
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.evento.title,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Inicio: $formattedStart',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            'Finalización: $formattedEnd',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      // Botones de Acción
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              context.go('/editar_eventos',
                                  extra: widget.evento.id);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              padding: const EdgeInsets.symmetric(
                                vertical: 6,
                                horizontal: 10,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Editar',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('Confirmar eliminación'),
                                    content: const Text(
                                        '¿Estás seguro de que deseas eliminar este evento?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(false),
                                        child: const Text('Cancelar'),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(true),
                                        child: const Text('Eliminar'),
                                      ),
                                    ],
                                  );
                                },
                              );

                              if (confirm == true) {
                                await _handleBorrarEvento(widget.evento);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              padding: const EdgeInsets.symmetric(
                                vertical: 6,
                                horizontal: 10,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Borrar',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDateTime(String dateTimeString, {bool includeTime = true}) {
    try {
      DateTime dateTime = DateTime.parse(dateTimeString);
      String formattedDate = DateFormat('dd/MM/yyyy').format(dateTime);
      if (includeTime) {
        String formattedTime = DateFormat('HH:mm').format(dateTime);
        return '$formattedDate - $formattedTime';
      } else {
        return formattedDate;
      }
    } catch (e) {
      return 'Fecha no disponible';
    }
  }
}
