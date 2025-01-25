class Evento {
  final int id;
  final String title;
  final String star_time;
  final String end_time;
  final String image_url;
  final String category;
  final String location;
  final double latitude;
  final double longitude;

  Evento({
    required this.id,
    required this.title,
    required this.star_time,
    required this.end_time,
    required this.image_url,
    required this.category,
    required this.location,
    required this.latitude,
    required this.longitude,
  });
}
