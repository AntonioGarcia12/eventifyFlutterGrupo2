class Eventsbyorganizador {
  final int id;
  final String title;
  final String description;
  final int organizer_id;
  final String category_name;
  final String start_time;
  final String end_time;
  final String location;
  final double price;
  final String image_url;
  final int deleted;

  Eventsbyorganizador(
      {required this.id,
      required this.title,
      required this.description,
      required this.organizer_id,
      required this.category_name,
      required this.start_time,
      required this.end_time,
      required this.location,
      required this.price,
      required this.image_url,
      required this.deleted});

  factory Eventsbyorganizador.fromJson(Map<String, dynamic> json) {
    return Eventsbyorganizador(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      organizer_id: json['organizer_id'],
      category_name: json['category_name'],
      start_time: json['start_time'],
      end_time: json['end_time'],
      location: json['location'],
      price: double.parse(json['price'].toString()),
      image_url: json['image_url'],
      deleted: json['deleted'],
    );
  }
}
