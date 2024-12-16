import 'package:eventify/presentacion/widgets/custom_navigation_bar_organizador_widget.dart';
import 'package:eventify/presentacion/services/organizador_service.dart';
import 'package:eventify/presentacion/widgets/event_list_organizador_widget.dart';
import 'package:eventify/presentacion/widgets/widgets.dart';
import 'package:eventify/presentacion/providers/evento_by_organizador_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrganizadorScreen extends ConsumerStatefulWidget {
  const OrganizadorScreen({super.key});
  static const String name = 'organizador_screen';

  @override
  _OrganizadorScreenState createState() => _OrganizadorScreenState();
}

class _OrganizadorScreenState extends ConsumerState<OrganizadorScreen> {
  String selectedCategory = '';
  late OrganizadorService organizadorService;

  @override
  void initState() {
    super.initState();
    _initializeEvents();
  }

  Future<void> _initializeEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final organizerId = prefs.getInt('id') ?? 0;
    final token = prefs.getString('token') ?? '';

    if (organizerId > 0 && token.isNotEmpty) {
      await ref
          .read(eventoByOrganizadorProvider)
          .fetchEventosByOrganizador(organizerId, token);
    }
  }

  @override
  Widget build(BuildContext context) {
    final eventoProvider = ref.watch(eventoByOrganizadorProvider);

    eventoProvider.eventos.sort((a, b) {
      final dateA = DateTime.tryParse(a.start_time) ?? DateTime(9999, 12, 31);
      final dateB = DateTime.tryParse(b.start_time) ?? DateTime(9999, 12, 31);
      return dateA.compareTo(dateB);
    });

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
              'Mis eventos',
              style: TextStyle(
                fontSize: 24,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          const BackgroundGradient(),
          if (eventoProvider.isLoading)
            const Center(child: CircularProgressIndicator())
          else
            EventListByOrganizador(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.pinkAccent.shade400,
        elevation: 0,
        onPressed: () {
          context.go('/crearEvento');
        },
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: const CustomNavigationBarOrganizadorWidget(
        currentIndex: 0,
      ),
    );
  }
}
