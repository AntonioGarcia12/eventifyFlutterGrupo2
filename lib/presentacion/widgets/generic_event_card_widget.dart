import 'package:eventify/presentacion/services/services.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:eventify/infraestructuras/models/evento.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GenericEventCard extends StatefulWidget {
  final Evento evento;
  final Color borderColor;
  final bool isMyEvent;
  final WidgetRef ref;

  const GenericEventCard({
    required this.evento,
    required this.borderColor,
    this.isMyEvent = false,
    required this.ref,
    super.key,
  });

  @override
  _GenericEventCardState createState() => _GenericEventCardState();
}

class _GenericEventCardState extends State<GenericEventCard> {
  late BuildContext parentContext;
  late GenericEventCardServices eventCardServices;

  @override
  void initState() {
    super.initState();
    parentContext = context;
    eventCardServices =
        GenericEventCardServices(ref: widget.ref, context: parentContext);
  }

  @override
  Widget build(BuildContext context) {
    String formattedStart = _formatDateTime(widget.evento.star_time);
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
          height: 200,
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
                      Align(
                        alignment: Alignment.centerLeft,
                        child: widget.isMyEvent
                            ? Row(
                                children: [
                                  ElevatedButton(
                                    onPressed: () => eventCardServices
                                        .confirmarDesinscripcion(widget.evento),
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
                                    onPressed: () async {
                                      await eventCardServices
                                          .mostrarDetalles(widget.evento);
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
                            : Row(
                                children: [
                                  ElevatedButton(
                                    onPressed: () => eventCardServices
                                        .confirmarInscripcion(widget.evento),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          widget.borderColor.withOpacity(0.85),
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
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    onPressed: () async {
                                      await eventCardServices
                                          .mostrarDetalles(widget.evento);
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
                                      'Detalles',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
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
