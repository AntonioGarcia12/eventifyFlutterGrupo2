import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:eventify/infraestructuras/models/evento.dart';

class GenericEventCard extends StatelessWidget {
  final Evento evento;
  final Color borderColor;
  final bool isMyEvent;

  const GenericEventCard({
    required this.evento,
    required this.borderColor,
    this.isMyEvent = false,
    super.key,
  });

  void _desinscribirEvento(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Te has desinscrito del evento: ${evento.title}'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.redAccent.withOpacity(0.9),
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

  void _mostrarDetalles(BuildContext context) {
    String formattedStart = _formatDateTime(evento.star_time);
    String formattedEnd = _formatDateTime(evento.end_time);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            evento.title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.network(
                evento.image_url,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 10),
              Text('Inicio: $formattedStart'),
              Text('Finalización: $formattedEnd'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    String formattedStart = _formatDateTime(evento.star_time);
    String formattedEnd = _formatDateTime(evento.end_time);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Card(
        shape: RoundedRectangleBorder(
          side: BorderSide(color: borderColor, width: 2),
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 6,
        clipBehavior: Clip.antiAlias,
        shadowColor: Colors.black.withOpacity(0.5),
        child: SizedBox(
          height: 200,
          child: Row(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(10),
                ),
                child: Image.network(
                  evento.image_url,
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            evento.title,
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
                      Align(
                        alignment: Alignment.centerLeft,
                        child: isMyEvent
                            ? Row(
                                children: [
                                  ElevatedButton(
                                    onPressed: () =>
                                        _desinscribirEvento(context),
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
                                      'Desinscribirse',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    onPressed: () => _mostrarDetalles(context),
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
                                      'Detalles',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : ElevatedButton(
                                onPressed: () => _inscribirEvento(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      borderColor.withOpacity(0.85),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 6,
                                    horizontal: 10,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  'Inscribirse',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
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

  _inscribirEvento(BuildContext context) {}
}
