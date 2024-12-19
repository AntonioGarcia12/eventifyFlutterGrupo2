import 'package:eventify/presentacion/providers/categorias_provider.dart';
import 'package:eventify/presentacion/providers/evento_by_organizador_provider.dart';
import 'package:eventify/presentacion/providers/evento_by_users_provider.dart';
import 'package:eventify/presentacion/providers/grafica_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:eventify/presentacion/widgets/custom_navigation_bar_organizador_widget.dart';
import 'package:eventify/presentacion/services/organizador_service.dart';
import 'package:eventify/presentacion/widgets/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GraficaOrganizadorScreen extends ConsumerStatefulWidget {
  const GraficaOrganizadorScreen({super.key});
  static const String name = 'Graficas';

  @override
  ConsumerState<GraficaOrganizadorScreen> createState() =>
      _GraficaOrganizadorScreenState();
}

class _GraficaOrganizadorScreenState
    extends ConsumerState<GraficaOrganizadorScreen> {
  String selectedCategory = '';
  late OrganizadorService organizadorService;
  bool isLoading = true;

  final Map<String, String> _categoriaTraducciones = {
    "Music": "Música",
    "Sport": "Deporte",
    "Technology": "Tecnología",
    "Cultural": "Cultural",
  };

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    if (token.isNotEmpty) {
      final id = prefs.getInt('id') ?? 0;

      try {
        await ref.read(eventoByUserProvider).fetchEventosForUsuarios();
        if (!mounted) return;

        await ref
            .read(eventoByOrganizadorProvider)
            .fetchEventosByOrganizador(id, token);
        if (!mounted) return;

        await ref.read(categoriaProvider).fetchCategorias();
        if (!mounted) return;

        await ref.read(graficaProvider.notifier).fetchGraficaData();
        if (!mounted) return;

        setState(() {
          isLoading = false;
        });
      } catch (e) {
        if (!mounted) return;
        setState(() {
          isLoading = false;
        });
      }
    } else {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

  String _traducirCategoria(String categoriaIngles) {
    return _categoriaTraducciones[categoriaIngles] ?? categoriaIngles;
  }

  @override
  Widget build(BuildContext context) {
    final categoriasState = ref.watch(categoriaProvider);
    final graficaState = ref.watch(graficaProvider);

    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;

    return Scaffold(
      extendBodyBehindAppBar: true,
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
              'Gráficas',
              style: TextStyle(
                fontSize: 24,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
      body: isLoading
          ? const Stack(
              children: [
                BackgroundGradient(),
                Center(
                  child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.pinkAccent),
                  ),
                ),
              ],
            )
          : Stack(
              children: [
                const BackgroundGradient(),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.04,
                    vertical: screenHeight * 0.1,
                  ),
                  child: Column(
                    children: [
                      categoriasState.isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : categoriasState.categorias.isEmpty
                              ? const Center(
                                  child: Text(
                                    "No hay categorías disponibles",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                )
                              : DropdownButton<String>(
                                  isExpanded: true,
                                  hint: const Text(
                                    "Seleccione una categoría",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  value: selectedCategory.isNotEmpty
                                      ? selectedCategory
                                      : null,
                                  dropdownColor: Colors.purple.shade700,
                                  iconEnabledColor: Colors.white,
                                  items: categoriasState.categorias
                                      .map<DropdownMenuItem<String>>(
                                        (cat) => DropdownMenuItem<String>(
                                          value: cat.name,
                                          child: Text(
                                            _traducirCategoria(cat.name),
                                            style: const TextStyle(
                                                color: Colors.white),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (newValue) {
                                    if (newValue != null) {
                                      setState(() {
                                        selectedCategory = newValue;
                                      });
                                      ref
                                          .read(graficaProvider.notifier)
                                          .fetchGraficaData(category: newValue);
                                    }
                                  },
                                ),
                      SizedBox(height: screenHeight * 0.02),
                      Expanded(
                        child: graficaState.when(
                          data: (data) {
                            final total = data.values.fold<int>(
                                0, (previous, current) => previous + current);

                            if (total == 0) {
                              return const Center(
                                child: Text(
                                  "Sin datos para la categoría seleccionada.",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              );
                            }

                            return buildBarChart(
                                data, screenWidth, screenHeight);
                          },
                          loading: () =>
                              const Center(child: CircularProgressIndicator()),
                          error: (e, st) => Center(
                            child: Text(
                              "Error: $e",
                              style: const TextStyle(
                                  color: Colors.red, fontSize: 16),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
      bottomNavigationBar: const CustomNavigationBarOrganizadorWidget(
        currentIndex: 1,
      ),
    );
  }

  Widget buildBarChart(
      Map<String, int> data, double screenWidth, double screenHeight) {
    final months = data.keys.toList().reversed.toList();
    final values = data.values.toList().reversed.toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        return Padding(
          padding: EdgeInsets.all(screenWidth * 0.02),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: (values.isEmpty
                            ? 0
                            : values.reduce((a, b) => a > b ? a : b))
                        .toDouble() +
                    5,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    tooltipRoundedRadius: 8,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '${months[group.x.toInt()]}: ${rod.toY}',
                        const TextStyle(color: Colors.white),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: screenWidth * 0.1,
                      interval: 5,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: TextStyle(
                              fontSize: screenWidth * 0.03,
                              color: Colors.white),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= months.length) {
                          return Container();
                        }
                        return Padding(
                          padding: EdgeInsets.only(top: screenHeight * 0.01),
                          child: Text(
                            months[index],
                            style: TextStyle(
                                fontSize: screenWidth * 0.035,
                                color: Colors.white),
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 5,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.white.withOpacity(0.2),
                      strokeWidth: 1,
                    );
                  },
                ),
                borderData: FlBorderData(
                  show: false,
                ),
                barGroups: List.generate(
                  months.length,
                  (index) => BarChartGroupData(
                    x: index,
                    barsSpace: 8,
                    barRods: [
                      BarChartRodData(
                        toY: values[index].toDouble(),
                        color: Colors.pinkAccent,
                        width: screenWidth * 0.05,
                        borderRadius: BorderRadius.circular(6),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: (values.isEmpty
                                      ? 0
                                      : values.reduce((a, b) => a > b ? a : b))
                                  .toDouble() +
                              5,
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
