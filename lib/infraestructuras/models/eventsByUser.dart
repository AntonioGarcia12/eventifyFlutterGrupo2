class Eventsbyuser {
  final int id;
  final String title;
  final String description;
  final int organizer_id;
  final int category_id;
  final String start_time;
  final String end_time;
  final String location;
  final String image_url;

  Eventsbyuser(
      {required this.id,
      required this.title,
      required this.description,
      required this.organizer_id,
      required this.category_id,
      required this.start_time,
      required this.end_time,
      required this.location,
      required this.image_url});

  factory Eventsbyuser.fromJson(Map<String, dynamic> eventData) {
    return Eventsbyuser(
      id: eventData['id'],
      title: eventData['title'] ?? 'Sin título',
      description: eventData['description'] ?? 'Sin descripción',
      organizer_id: eventData['organizer_id'] ?? 0,
      start_time: eventData['start_time'] ?? 'Sin hora de inicio',
      end_time: eventData['end_time'] ?? 'Sin hora de fin',
      image_url: eventData['image_url'] ?? '',
      location: eventData['location'] ?? 'Sin ubicación',
      category_id: eventData['category'] ?? 0,
    );
  }
}
