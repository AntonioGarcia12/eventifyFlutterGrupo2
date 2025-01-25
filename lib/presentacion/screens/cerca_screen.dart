import 'dart:async';
import 'package:eventify/infraestructuras/models/evento.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:open_route_service/open_route_service.dart';
import '../widgets/widgets.dart';
import '../providers/evento_provider.dart';

class CercaScreen extends ConsumerStatefulWidget {
  const CercaScreen({super.key});
  static const String name = 'cerca_screen';

  @override
  ConsumerState<CercaScreen> createState() => _CercaScreenState();
}

class _CercaScreenState extends ConsumerState<CercaScreen> {
  LatLng? _currentPosition;
  final double _radius = 2.0;
  final MapController _mapController = MapController();
  StreamSubscription<Position>? _positionStreamSubscription;

  List<LatLng> _routePoints = [];

  final Distance distance = const Distance();

  @override
  void initState() {
    super.initState();
    _startTrackingLocation();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchEventos();
    });
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    super.dispose();
  }

  Future<void> _startTrackingLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location services are disabled.')),
      );
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permissions are denied.')),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location permissions are permanently denied.'),
        ),
      );
      return;
    }

    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((Position position) {
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
      });
    });
  }

  Future<void> _fetchEventos() async {
    final eventoNotifier = ref.read(eventoProvider.notifier);
    await eventoNotifier.fetchEventos();
  }

  List<Marker> _getEventMarkers() {
    if (_currentPosition == null) return [];

    final eventoProviders = ref.watch(eventoProvider);
    final List<Evento> eventos = eventoProviders.eventos;

    final DateTime now = DateTime.now();

    return eventos.where((evento) {
      final DateTime eventStartTime = DateTime.parse(evento.star_time);

      final eventPosition = LatLng(evento.latitude, evento.longitude);
      return distance.as(
                LengthUnit.Kilometer,
                _currentPosition!,
                eventPosition,
              ) <=
              _radius &&
          eventStartTime.isAfter(now);
    }).map((evento) {
      return Marker(
        width: 80.0,
        height: 80.0,
        point: LatLng(evento.latitude, evento.longitude),
        child: GestureDetector(
          onTap: () => _showEventDetails(evento),
          child: const Icon(
            Icons.event_rounded,
            color: Colors.black,
            size: 40,
          ),
        ),
      );
    }).toList();
  }

  void _showEventDetails(Evento evento) {
    final DateFormat formatter = DateFormat('dd/MM/yyyy hh:mm');

    final String startTime = formatter.format(DateTime.parse(evento.star_time));
    final String endTime = formatter.format(DateTime.parse(evento.end_time));

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.0),
              color: Colors.white,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Imagen del evento
                ClipRRect(
                  borderRadius: BorderRadius.circular(16.0),
                  child: Image.network(
                    evento.image_url,
                    fit: BoxFit.cover,
                    height: 250,
                    width: double.infinity,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 250,
                      width: double.infinity,
                      color: Colors.grey.shade300,
                      child: const Icon(
                        Icons.image_not_supported,
                        color: Colors.grey,
                        size: 50,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),

                Text(
                  evento.title,
                  style: const TextStyle(
                    fontSize: 22.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12.0),

                Row(
                  children: [
                    const Icon(Icons.calendar_today,
                        size: 20, color: Colors.blue),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: Text(
                        "Inicio: $startTime",
                        style: const TextStyle(
                          fontSize: 16.0,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8.0),
                Row(
                  children: [
                    const Icon(Icons.calendar_today,
                        size: 20, color: Colors.red),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: Text(
                        "Fin: $endTime",
                        style: const TextStyle(
                          fontSize: 16.0,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12.0),

                Row(
                  children: [
                    const Icon(Icons.location_on,
                        size: 20, color: Colors.green),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: Text(
                        evento.location,
                        style: const TextStyle(
                          fontSize: 16.0,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20.0),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24.0,
                          vertical: 12.0,
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        _drawRoute(evento);
                      },
                      child: const Row(
                        children: [
                          Icon(Icons.directions, size: 20),
                          SizedBox(width: 8.0),
                          Text(
                            "Ir",
                            style: TextStyle(fontSize: 16.0),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade200,
                        foregroundColor: Colors.grey.shade800,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24.0,
                          vertical: 12.0,
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Row(
                        children: [
                          Icon(Icons.close, size: 20),
                          SizedBox(width: 8.0),
                          Text(
                            "Cerrar",
                            style: TextStyle(fontSize: 16.0),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _drawRoute(Evento evento) async {
    if (_currentPosition == null) return;

    final routeCoords = await _fetchRouteFromORS(
      start: _currentPosition!,
      end: LatLng(evento.latitude, evento.longitude),
    );

    if (routeCoords.isNotEmpty) {
      setState(() {
        _routePoints = routeCoords;
      });
      _mapController.move(routeCoords.first, 14);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo obtener la ruta.')),
      );
    }
  }

  Future<List<LatLng>> _fetchRouteFromORS({
    required LatLng start,
    required LatLng end,
  }) async {
    final openRouteService = OpenRouteService(
      apiKey: '5b3ce3597851110001cf62487d06b6f8f43f4fa4bbb7550dd937dea9',
    );

    try {
      final List<ORSCoordinate> coordinates =
          (await openRouteService.directionsRouteCoordsGet(
        startCoordinate:
            ORSCoordinate(latitude: start.latitude, longitude: start.longitude),
        endCoordinate:
            ORSCoordinate(latitude: end.latitude, longitude: end.longitude),
        profileOverride: ORSProfile.footWalking,
      ));

      final routePoints = coordinates
          .map(
              (coordinate) => LatLng(coordinate.latitude, coordinate.longitude))
          .toList();

      return routePoints;
    } catch (e) {
      debugPrint('Error al obtener la ruta a pie: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(eventoProvider).isLoading;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black87,
      body: Stack(
        children: [
          _currentPosition == null || isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _currentPosition ?? const LatLng(0, 0),
                    initialZoom: 13,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                      subdomains: const ['a', 'b', 'c'],
                    ),
                    MarkerClusterLayerWidget(
                      options: MarkerClusterLayerOptions(
                        maxClusterRadius: 120,
                        size: const Size(40, 40),
                        markers: _getEventMarkers(),
                        builder: (context, markers) {
                          return Container(
                            decoration: const BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                markers.length.toString(),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    MarkerLayer(
                      markers: [
                        if (_currentPosition != null)
                          Marker(
                            width: 40,
                            height: 40,
                            point: _currentPosition!,
                            child: const Icon(
                              Icons.location_on_outlined,
                              color: Colors.red,
                              size: 40,
                            ),
                          ),
                      ],
                    ),
                    if (_routePoints.isNotEmpty)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: _routePoints,
                            color: Colors.blue,
                            strokeWidth: 4.0,
                          ),
                        ],
                      ),
                  ],
                ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_currentPosition != null) {
            _mapController.move(_currentPosition!, 16);
          }
        },
        child: const Icon(Icons.my_location),
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(
        currentIndex: 3,
      ),
    );
  }
}
