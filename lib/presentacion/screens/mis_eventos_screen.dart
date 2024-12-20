import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui';
import 'package:eventify/presentacion/widgets/widgets.dart';
import 'package:eventify/presentacion/providers/evento_provider.dart';
import 'package:eventify/presentacion/services/normal_service.dart';
import 'package:eventify/presentacion/services/mis_eventos_services.dart';
import 'package:eventify/utils/event_sort.dart';

final registeredEventIdsProvider = FutureProvider<List<int>>((ref) async {
  final misEventosServices = MisEventosServices();
  return await misEventosServices.fetchRegisteredEventIds();
});

class MisEventosScreen extends ConsumerStatefulWidget {
  final bool isMyEvent;
  const MisEventosScreen({this.isMyEvent = true, super.key});
  static const String name = 'MisEventosScreen';

  @override
  _MisEventosScreenState createState() => _MisEventosScreenState();
}

class _MisEventosScreenState extends ConsumerState<MisEventosScreen> {
  bool showFilterButtons = false;
  String selectedCategory = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(eventoProvider.notifier).fetchEventos();
      ref.read(normalServiceProvider).loadUsername();
    });
  }

  void _toggleFilterButtons() {
    setState(() {
      showFilterButtons = !showFilterButtons;
    });
  }

  void _filterByCategory(String category) {
    setState(() {
      selectedCategory = category;
      showFilterButtons = false;
    });
  }

  void _resetFilters() {
    setState(() {
      selectedCategory = '';
      showFilterButtons = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final eventoProviderInstance = ref.watch(eventoProvider);
    final eventos = eventoProviderInstance.eventos;

    final registeredEventIdsAsync = ref.watch(registeredEventIdsProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black87,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.deepPurple.shade800,
                  Colors.purple.shade600,
                  Colors.pinkAccent.shade400,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: const Text(
                'Mis Eventos',
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          const BackgroundGradient(),
          registeredEventIdsAsync.when(
            data: (registeredEventIds) {
              if (eventos.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              final eventosRegistrados = eventos
                  .where((evento) => registeredEventIds.contains(evento.id))
                  .toList();

              if (eventosRegistrados.isEmpty) {
                return const Center(
                  child: Text(
                    'No estás registrado en ningún evento.',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                );
              }

              final eventosFiltrados =
                  ref.read(normalServiceProvider).filterEventosByCategory(
                        eventosRegistrados,
                        selectedCategory,
                      );
              final eventosFuturos =
                  EventSorter.filterFutureEvents(eventosFiltrados);
              final eventosOrdenados =
                  EventSorter.sortEventsByDateAsc(eventosFuturos);

              return Column(
                children: [
                  Expanded(
                    child: EventList(
                      isLoading: false,
                      eventos: eventosOrdenados,
                      ref: ref,
                      isMyEvent: true,
                    ),
                  ),
                ],
              );
            },
            loading: () {
              return const Center(child: CircularProgressIndicator());
            },
            error: (error, stack) {
              return Center(child: Text('Error: $error'));
            },
          ),
          if (showFilterButtons)
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                ),
              ),
            ),
          if (showFilterButtons)
            Positioned(
              bottom: 100,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  BuildFilter(
                    icon: Icons.event,
                    color: Colors.black,
                    label: 'Todos los eventos',
                    onPressed: _resetFilters,
                  ),
                  const SizedBox(height: 10),
                  BuildFilter(
                    icon: Icons.music_note,
                    color: Colors.purple.shade600,
                    label: 'Música',
                    onPressed: () => _filterByCategory('Music'),
                  ),
                  const SizedBox(height: 10),
                  BuildFilter(
                    icon: Icons.sports_soccer,
                    color: Colors.pinkAccent.shade400,
                    label: 'Deporte',
                    onPressed: () => _filterByCategory('Sport'),
                  ),
                  const SizedBox(height: 10),
                  BuildFilter(
                    icon: Icons.computer,
                    color: Colors.deepPurple.shade800,
                    label: 'Tecnología',
                    onPressed: () => _filterByCategory('Technology'),
                  ),
                  const SizedBox(height: 10),
                  BuildFilter(
                    icon: Icons.theater_comedy_rounded,
                    color: Colors.lightBlue,
                    label: 'Cultural',
                    onPressed: () => _filterByCategory('Cultural'),
                  ),
                ],
              ),
            ),
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              backgroundColor: Colors.pinkAccent.shade400,
              elevation: 0,
              onPressed: _toggleFilterButtons,
              shape: const CircleBorder(),
              child: Icon(showFilterButtons ? Icons.close : Icons.filter_list),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(
        currentIndex: 1,
      ),
    );
  }
}
