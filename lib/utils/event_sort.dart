import 'package:eventify/infraestructuras/models/evento.dart';

class EventSorter {
  static List<Evento> sortEventsByDateAsc(List<Evento> eventos) {
    List<Evento> sortedEventos = List.from(eventos);

    sortedEventos.sort((a, b) {
      DateTime dateA;
      DateTime dateB;
      try {
        dateA = DateTime.parse(a.star_time);
      } catch (e) {
        dateA = DateTime(9999, 12, 31);
      }
      try {
        dateB = DateTime.parse(b.star_time);
      } catch (e) {
        dateB = DateTime(9999, 12, 31);
      }
      return dateA.compareTo(dateB);
    });
    return sortedEventos;
  }

  static List<Evento> filterFutureEvents(List<Evento> eventos) {
    List<Evento> futureEventos = eventos.where((evento) {
      try {
        DateTime eventDate = DateTime.parse(evento.star_time);
        return eventDate.isAfter(DateTime.now());
      } catch (e) {
        return false;
      }
    }).toList();

    return futureEventos;
  }
}
