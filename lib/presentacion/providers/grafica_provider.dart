import 'package:eventify/presentacion/providers/evento_by_organizador_provider.dart';
import 'package:eventify/presentacion/providers/evento_by_users_provider.dart';
import 'package:eventify/presentacion/providers/user_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final graficaProvider =
    StateNotifierProvider<GraficaNotifier, AsyncValue<Map<String, int>>>((ref) {
  return GraficaNotifier(ref);
});

class GraficaNotifier extends StateNotifier<AsyncValue<Map<String, int>>> {
  GraficaNotifier(this.ref) : super(const AsyncValue.data({}));

  final Ref ref;

  Future<void> fetchGraficaData({String? category}) async {
    state = const AsyncValue.loading();
    try {
      final userServices = ref.read(userProvider.notifier);
      await userServices.fetchUsuario();

      await userServices.fetchUsuarios();

      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final organizerId = prefs.getInt('id');

      if (token == null || organizerId == null) {
        throw Exception('Faltan datos de usuario.');
      }

      await ref
          .read(eventoByOrganizadorProvider)
          .fetchEventosByOrganizador(organizerId, token);

      var eventosOrganizados = ref.read(eventoByOrganizadorProvider).eventos;

      if (category != null && category.isNotEmpty) {
        eventosOrganizados = eventosOrganizados
            .where(
                (e) => e.category_name.toLowerCase() == category.toLowerCase())
            .toList();
      }

      eventosOrganizados =
          eventosOrganizados.where((e) => e.deleted == 0).toList();

      final eventosOrganizadosIds =
          eventosOrganizados.map((e) => e.id).toList();

      final eventoByUserProviderInstance = ref.read(eventoByUserProvider);
      if (eventoByUserProviderInstance.eventos.isEmpty) {
        await eventoByUserProviderInstance.fetchEventosForUsuarios();
      }

      final usuariosInscritos = ref.read(eventoByUserProvider).eventos;

      final now = DateTime.now();
      Map<String, int> dataMap = {
        for (int i = 1; i <= 4; i++)
          _formatMonthYear(DateTime(now.year, now.month - i, 1)): 0,
      };

      for (var eventoInscrito in usuariosInscritos) {
        if (eventosOrganizadosIds.contains(eventoInscrito.id)) {
          final eventDate = DateTime.parse(eventoInscrito.start_time);
          final monthYear = _formatMonthYear(eventDate);

          if (dataMap.containsKey(monthYear)) {
            dataMap[monthYear] = dataMap[monthYear]! + 1;
          }
        }
      }

      state = AsyncValue.data(dataMap);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  String _formatMonthYear(DateTime date) {
    const months = [
      "Enero",
      "Febrero",
      "Marzo",
      "Abril",
      "Mayo",
      "Junio",
      "Julio",
      "Agosto",
      "Septiembre",
      "Octubre",
      "Noviembre",
      "Diciembre"
    ];
    return months[date.month - 1];
  }
}
