import 'package:eventify/presentacion/widgets/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eventify/presentacion/providers/evento_provider.dart';
import 'package:eventify/presentacion/services/normal_service.dart';
import 'package:eventify/utils/event_sort.dart';
import 'dart:ui';

class NormalScreen extends ConsumerStatefulWidget {
  final bool isMyEvent;
  const NormalScreen({super.key, this.isMyEvent = false});
  static const String name = 'normal_screen';

  @override
  _NormalScreenState createState() => _NormalScreenState();
}

class _NormalScreenState extends ConsumerState<NormalScreen> {
  bool showFilterButtons = false;
  String selectedCategory = '';
  late NormalService normalService;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    normalService = ref.read(normalServiceProvider);
    normalService.loadUsername();
    Future.microtask(() async {
      try {
        final fetchedEventos = await normalService.fetchEventosNoRegistrados();
        ref.read(eventoProvider).setEventos(fetchedEventos);
      } finally {
        setState(() {
          isLoading = false;
        });
      }
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

    final eventosFiltrados = normalService.filterEventosByCategory(
      eventos,
      selectedCategory,
    );
    final eventosFuturos = EventSorter.filterFutureEvents(eventosFiltrados);
    final eventosOrdenados = EventSorter.sortEventsByDateAsc(eventosFuturos);

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
                'Eventify',
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
          Column(
            children: [
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : EventList(
                        isLoading: false,
                        eventos: eventosOrdenados,
                        ref: ref,
                      ),
              ),
            ],
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
        currentIndex: 0,
      ),
    );
  }
}
