import 'package:eventify/presentacion/widgets/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eventify/presentacion/providers/evento_provider.dart';
import 'package:eventify/presentacion/services/normal_service.dart';
import 'package:eventify/utils/event_sort.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui'; // Import para el BackdropFilter

class NormalScreen extends ConsumerStatefulWidget {
  const NormalScreen({super.key});
  static const String name = 'normal_screen';

  @override
  _NormalScreenState createState() => _NormalScreenState();
}

class _NormalScreenState extends ConsumerState<NormalScreen> {
  bool showFilterButtons = false;
  String selectedCategory = '';
  late NormalService normalService;

  @override
  void initState() {
    super.initState();
    normalService = ref.read(normalServiceProvider);
    normalService.loadUsername();
    Future.microtask(() {
      normalService.fetchEventos();
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

  void _showProfileDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.deepPurple.shade800,
          title: const Text(
            'Usuario',
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                normalService.username,
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.go('/');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                ),
                child: const Text('Cerrar sesión'),
              ),
            ],
          ),
        );
      },
    );
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
              'Eventos',
              style: TextStyle(
                fontSize: 24,
                color: Colors.white,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.person, color: Colors.white),
                onPressed: () => _showProfileDialog(context),
                tooltip: 'Perfil',
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          const BackgroundGradient(),
          Column(
            children: [
              Expanded(
                child: EventList(
                  isLoading: eventoProviderInstance.isLoading,
                  eventos: eventosOrdenados,
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
    );
  }
}
