import 'dart:convert';
import 'package:eventify/infraestructuras/models/eventsByOrganizador.dart';
import 'package:eventify/presentacion/providers/categorias_provider.dart';
import 'package:eventify/presentacion/services/editar_eventos_services.dart';
import 'package:eventify/presentacion/widgets/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class EditarEventosScreen extends ConsumerStatefulWidget {
  final int eventId;

  const EditarEventosScreen({super.key, required this.eventId});
  static const String name = 'editar-eventos-screen';

  @override
  ConsumerState<EditarEventosScreen> createState() =>
      _EditarEventosScreenState();
}

class _EditarEventosScreenState extends ConsumerState<EditarEventosScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();

  bool _isLoading = true;
  int? _selectedCategoryId;
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;

  final Map<String, String> categoryTranslations = {
    'Music': 'Música',
    'Sport': 'Deporte',
    'Technology': 'Tecnología',
  };

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await ref.read(categoriaProvider).fetchCategorias();
      await _loadEventDetails();
    });

    _imageUrlController.addListener(() {
      setState(() {});
    });
  }

  Future<void> _loadEventDetails() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final id = prefs.getInt('id');
      if (id == null) throw Exception('ID del organizador no disponible.');

      final events = await _fetchEventDetails(id);
      final event = events.firstWhere((e) => e.id == widget.eventId,
          orElse: () => throw Exception('Evento no encontrado.'));

      final categorias = ref.read(categoriaProvider).categorias;

      final categoria = categorias.firstWhere(
        (cat) => cat.name.toLowerCase() == event.category_name.toLowerCase(),
        orElse: () => throw Exception('Categoría no encontrada.'),
      );

      // Parsear las fechas de cadena a DateTime
      DateTime parsedStartDate =
          DateTime.parse(event.start_time); // Asegúrate que el formato sea ISO
      DateTime parsedEndDate = DateTime.parse(event.end_time);

      setState(() {
        _titleController.text = event.title;
        _descriptionController.text = event.description;
        _selectedStartDate = parsedStartDate;
        _selectedEndDate = parsedEndDate;
        _startTimeController.text =
            DateFormat('dd/MM/yyyy HH:mm').format(parsedStartDate);
        _endTimeController.text =
            DateFormat('dd/MM/yyyy HH:mm').format(parsedEndDate);
        _locationController.text = event.location;
        _priceController.text = event.price.toString();
        _imageUrlController.text = event.image_url;
        _selectedCategoryId = categoria.id;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<List<Eventsbyorganizador>> _fetchEventDetails(int organizerId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      throw Exception('Token no disponible. Debes iniciar sesión nuevamente.');
    }

    final url =
        Uri.parse('https://eventify.allsites.es/public/api/eventsByOrganizer');
    final response = await http.post(
      url,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'id': organizerId,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        List<dynamic> eventsData = data['data'] ?? [];
        return eventsData.map((eventJson) {
          return Eventsbyorganizador(
            id: eventJson['id'],
            title: eventJson['title'],
            description: eventJson['description'],
            organizer_id: eventJson['organizer_id'],
            category_name: eventJson['category_name'],
            start_time: eventJson['start_time'],
            end_time: eventJson['end_time'],
            location: eventJson['location'],
            price: double.parse(eventJson['price'].toString()),
            image_url: eventJson['image_url'],
            deleted: eventJson['deleted'],
          );
        }).toList();
      } else {
        throw Exception(
            data['message'] ?? 'Error desconocido al obtener eventos');
      }
    } else {
      throw Exception(
          'Error ${response.statusCode}: No se pudo obtener eventos.');
    }
  }

  Future<void> _handleUpdateEvent() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona una categoría')),
      );
      return;
    }

    if (_selectedStartDate == null || _selectedEndDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Selecciona las fechas de inicio y finalización')),
      );
      return;
    }

    if (_selectedEndDate!.isBefore(_selectedStartDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'La fecha de finalización debe ser posterior a la de inicio')),
      );
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final organizerId = prefs.getInt('id') ?? 0;

    setState(() {
      _isLoading = true;
    });

    try {
      final editarEventoServices = EditarEventosServices();

      final startTime =
          DateFormat('yyyy-MM-dd HH:mm:ss').format(_selectedStartDate!);
      final endTime =
          DateFormat('yyyy-MM-dd HH:mm:ss').format(_selectedEndDate!);

      await editarEventoServices.updateEvent(
        eventId: widget.eventId,
        organizerId: organizerId,
        title: _titleController.text,
        description: _descriptionController.text,
        categoryId: _selectedCategoryId!,
        startTime: startTime,
        endTime: endTime,
        location: _locationController.text,
        latitude: "",
        longitude: "",
        max_attendees: "",
        price: double.parse(_priceController.text),
        imageUrl: _imageUrlController.text,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Evento actualizado correctamente.')),
      );

      if (!mounted) return;
      context.go('/organizador');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    _locationController.dispose();
    _priceController.dispose();
    _imageUrlController.removeListener(() {});
    _imageUrlController.dispose();
    super.dispose();
  }

  Widget _buildImagePreview() {
    final imageUrl = _imageUrlController.text;
    if (imageUrl.isEmpty) {
      return const SizedBox.shrink();
    }
    return Center(
      child: Container(
        width: 225,
        height: 225,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white24),
          borderRadius: BorderRadius.circular(12),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            imageUrl,
            width: 225,
            height: 225,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return const Center(
                child: Text(
                  'No se pudo cargar la imagen',
                  style: TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              );
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const Center(
                child: CircularProgressIndicator(),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoriasState = ref.watch(categoriaProvider);
    final categorias = categoriasState.categorias;

    Widget content;
    if (_isLoading) {
      content = const Center(child: CircularProgressIndicator());
    } else if (categorias.isEmpty) {
      content = const Center(child: Text('No hay categorías disponibles'));
    } else {
      content = Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSectionTitle('Editar Detalles del Evento'),
              const SizedBox(height: 8),
              _buildTextFormField(
                controller: _titleController,
                label: 'Título',
                validator: (value) =>
                    value == null || value.isEmpty ? 'Ingresa el título' : null,
              ),
              const SizedBox(height: 16),
              _buildTextFormField(
                controller: _descriptionController,
                label: 'Descripción',
                validator: (value) => value == null || value.isEmpty
                    ? 'Ingresa la descripción'
                    : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                  labelText: 'Categoría',
                  labelStyle: TextStyle(color: Colors.white),
                  filled: true,
                  fillColor: Colors.white24,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12.0)),
                    borderSide: BorderSide.none,
                  ),
                ),
                value: _selectedCategoryId,
                items: categorias.map((cat) {
                  return DropdownMenuItem<int>(
                    value: cat.id,
                    child: Text(categoryTranslations[cat.name] ?? cat.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategoryId = value;
                  });
                },
                validator: (value) =>
                    value == null ? 'Selecciona una categoría' : null,
              ),
              const SizedBox(height: 16),
              _buildDateTimePickerFormField(
                controller: _startTimeController,
                label: 'Inicio',
                isStartTime: true,
              ),
              const SizedBox(height: 16),
              _buildDateTimePickerFormField(
                controller: _endTimeController,
                label: 'Finalización',
                isStartTime: false,
              ),
              const SizedBox(height: 16),
              _buildTextFormField(
                controller: _locationController,
                label: 'Ubicación',
                validator: (value) => value == null || value.isEmpty
                    ? 'Ingresa la ubicación'
                    : null,
              ),
              const SizedBox(height: 16),
              _buildTextFormField(
                controller: _priceController,
                label: 'Precio',
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Ingresa el precio' : null,
              ),
              const SizedBox(height: 16),
              _buildTextFormField(
                controller: _imageUrlController,
                label: 'URL de la Imagen',
                keyboardType: TextInputType.url,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingresa la URL de la imagen';
                  }
                  final uri = Uri.tryParse(value);
                  if (uri == null || !(uri.isAbsolute)) {
                    return 'Ingresa una URL válida';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildImagePreview(),
              const SizedBox(height: 24),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Center(
                      child: GestureDetector(
                        onTap: _isLoading ? null : _handleUpdateEvent,
                        child: Container(
                          alignment: Alignment.center,
                          width: double.infinity,
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.purple.shade500,
                                Colors.pink.shade400,
                                Colors.orangeAccent.shade200,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                )
                              : const Text(
                                  'Guardar Cambios',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    )
            ],
          ),
        ),
      );
    }

    return Scaffold(
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
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.go('/organizador'),
              color: Colors.white,
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text(
              'Editar Evento',
              style: TextStyle(
                fontSize: 24,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            const BackgroundGradient(),
            Align(
              alignment: Alignment.topCenter,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 600,
                    ),
                    child: content,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    bool readOnly = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white),
        filled: true,
        fillColor: Colors.white24,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12.0)),
          borderSide: BorderSide.none,
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildDateTimePickerFormField({
    required TextEditingController controller,
    required String label,
    required bool isStartTime,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white),
        filled: true,
        fillColor: Colors.white24,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12.0)),
          borderSide: BorderSide.none,
        ),
      ),
      onTap: () async {
        try {
          DateTime now = DateTime.now();
          DateTime today = DateTime(now.year, now.month, now.day);

          DateTime initialDate = isStartTime
              ? (_selectedStartDate ?? today)
              : (_selectedEndDate ?? (_selectedStartDate ?? today));

          DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: initialDate.isBefore(today) ? today : initialDate,
            firstDate: today,
            lastDate: DateTime(2101),
            builder: (BuildContext context, Widget? child) {
              return Theme(
                data: ThemeData.light(),
                child: child!,
              );
            },
          );

          if (pickedDate != null) {
            TimeOfDay initialTime = TimeOfDay.now();

            if (isStartTime && _selectedStartDate != null) {
              initialTime = TimeOfDay.fromDateTime(_selectedStartDate!);
            } else if (!isStartTime && _selectedEndDate != null) {
              initialTime = TimeOfDay.fromDateTime(_selectedEndDate!);
            }

            TimeOfDay? pickedTime = await showTimePicker(
              context: context,
              initialTime: initialTime,
            );

            if (pickedTime != null) {
              DateTime finalDateTime = DateTime(
                pickedDate.year,
                pickedDate.month,
                pickedDate.day,
                pickedTime.hour,
                pickedTime.minute,
                0,
              );

              if (pickedDate.year == today.year &&
                  pickedDate.month == today.month &&
                  pickedDate.day == today.day) {
                if (finalDateTime.isBefore(now)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'La fecha y hora seleccionada no pueden ser anteriores a la actual.'),
                    ),
                  );
                  return;
                }
              }

              String formattedDateTime =
                  DateFormat('dd/MM/yyyy HH:mm').format(finalDateTime);
              controller.text = formattedDateTime;

              setState(() {
                if (isStartTime) {
                  _selectedStartDate = finalDateTime;
                } else {
                  _selectedEndDate = finalDateTime;
                }
              });
            }
          }
        } catch (e) {}
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Ingresa la fecha y hora';
        }
        return null;
      },
    );
  }
}
