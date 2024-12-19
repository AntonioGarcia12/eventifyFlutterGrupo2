import 'package:eventify/presentacion/providers/categorias_provider.dart';
import 'package:eventify/presentacion/services/services.dart';
import 'package:eventify/presentacion/widgets/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class CrearEventoScreen extends ConsumerStatefulWidget {
  const CrearEventoScreen({super.key});
  static const String name = "CrearEventoScreen";

  @override
  ConsumerState<CrearEventoScreen> createState() => _CrearEventoScreenState();
}

class _CrearEventoScreenState extends ConsumerState<CrearEventoScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();

  bool _isLoading = false;
  int? _selectedCategoryId;
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(categoriaProvider).fetchCategorias();
    });

    _imageUrlController.addListener(() {
      setState(() {});
    });
  }

  Future<void> _handleCreateEvent() async {
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

    final prefs = await SharedPreferences.getInstance();
    final organizerId = prefs.getInt('id') ?? 0;
    final title = _titleController.text;
    final description = _descriptionController.text;
    final categoryId = _selectedCategoryId!;

    final startTime =
        DateFormat('yyyy-MM-dd HH:mm:ss').format(_selectedStartDate!);
    final endTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(_selectedEndDate!);

    final location = _locationController.text;
    final price = double.tryParse(_priceController.text) ?? 0.0;
    final imageUrl = _imageUrlController.text;

    setState(() {
      _isLoading = true;
    });

    try {
      final crearEventoServices = CrearEventoServices();
      final response = await crearEventoServices.createEvent(
        organizerId: organizerId,
        title: title,
        description: description,
        categoryId: categoryId,
        startTime: startTime,
        endTime: endTime,
        location: location,
        price: price,
        imageUrl: imageUrl,
      );

      if (response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Evento creado con éxito')),
        );

        _formKey.currentState!.reset();
        setState(() {
          _selectedCategoryId = null;
          _selectedStartDate = null;
          _selectedEndDate = null;
          _startTimeController.text = '';
          _endTimeController.text = '';
        });

        await Future.delayed(const Duration(seconds: 1));
        context.go('/organizador');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
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
    if (categoriasState.isLoading) {
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
              _buildSectionTitle('Detalles del Evento'),
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
                    child: Text(_translateCategory(cat.name)),
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
                        onTap: _isLoading ? null : _handleCreateEvent,
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
                                  'Crear Evento',
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
              'Crear Evento',
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

  String _translateCategory(String category) {
    switch (category.toLowerCase()) {
      case 'sport':
        return 'Deporte';
      case 'music':
        return 'Música';
      case 'technology':
        return 'Tecnología';
      default:
        return category;
    }
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

          DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: isStartTime
                ? (_selectedStartDate ?? today)
                : (_selectedEndDate ?? (_selectedStartDate ?? today)),
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
                          'La hora seleccionada no puede ser anterior a la hora actual.'),
                    ),
                  );
                  return;
                }
              }

              String formattedDateTime =
                  DateFormat('dd/MM/yyyy HH:mm').format(finalDateTime);
              controller.text = formattedDateTime;

              if (isStartTime) {
                _selectedStartDate = finalDateTime;
              } else {
                _selectedEndDate = finalDateTime;
              }
            }
          }
          // ignore: empty_catches
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
