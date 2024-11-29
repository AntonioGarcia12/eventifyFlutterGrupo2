import 'package:eventify/presentacion/services/informe_services.dart';
import 'package:eventify/presentacion/widgets/widgets.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InformeScreen extends StatefulWidget {
  const InformeScreen({super.key});
  static const String name = 'informe-screen';

  @override
  _InformeScreenState createState() => _InformeScreenState();
}

class _InformeScreenState extends State<InformeScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _startDate;
  DateTime? _endDate;
  final List<String> _selectedCategories = [];
  final InformeServices _informeServices = InformeServices();
  String? _userEmail;
  String? _userName;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserDetails();
  }

  final Map<String, String> categoryMapping = {
    'Música': 'Music',
    'Deportes': 'Sport',
    'Tecnología': 'Technology',
  };

  Future<void> _loadUserDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userEmail = prefs.getString('userEmail') ?? 'user_email@example.com';
      _userName = prefs.getString('username') ?? 'Usuario';
    });
  }

  void _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Colors.deepPurple,
            colorScheme: ColorScheme.light(
              primary: Colors.deepPurple.shade800,
              onPrimary: Colors.white,
              surface: Colors.deepPurple.shade100,
              onSurface: Colors.deepPurple,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
        if (_endDate != null && _endDate!.isBefore(_startDate!)) {
          _endDate = null;
        }
      });
    }
  }

  void _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate != null
          ? _startDate!.add(const Duration(days: 1))
          : DateTime.now().add(const Duration(days: 1)),
      firstDate: _startDate ?? DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Colors.deepPurple,
            colorScheme: ColorScheme.light(
              primary: Colors.deepPurple.shade800,
              onPrimary: Colors.white,
              surface: Colors.deepPurple.shade100,
              onSurface: Colors.deepPurple,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _endDate) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  void _onCategoryChanged(String category, bool selected) {
    setState(() {
      final englishCategory = categoryMapping[category];
      if (englishCategory != null) {
        if (selected) {
          _selectedCategories.add(englishCategory);
        } else {
          _selectedCategories.remove(englishCategory);
        }
      }
    });
  }

  void _generarPdf() async {
    if (_startDate == null || _endDate == null || _selectedCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor completa todos los campos')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final events = await _informeServices.fetchFilteredEvents(
        startDate: _startDate!,
        endDate: _endDate!,
        selectedCategories: _selectedCategories,
      );

      if (events.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('No hay eventos para las categorías seleccionadas')),
        );
        return;
      }

      final savedPath = await _informeServices.generarPdf(
        events: events,
        userName: _userName ?? "Usuario",
      );

      if (savedPath != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Archivo descargado y guardado')),
        );

        final result = await OpenFile.open(savedPath);
        if (result.type != ResultType.done) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No se pudo abrir el PDF.')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al guardar el PDF.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al generar el PDF: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _enviarPDFEmail() async {
    if (_startDate == null || _endDate == null || _selectedCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor completa todos los campos')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final events = await _informeServices.fetchFilteredEvents(
        startDate: _startDate!,
        endDate: _endDate!,
        selectedCategories: _selectedCategories,
      );

      if (events.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('No hay eventos para las categorías seleccionadas')),
        );
        return;
      }

      await _informeServices.enviarPDFEmail(
        events: events,
        userName: _userName ?? "Usuario",
        userEmail: _userEmail ?? "user_email@example.com",
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PDF enviado correctamente por email')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al enviar el PDF: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
                'Informe',
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
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 110.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Seleccione el rango de fechas:'),
                  const SizedBox(height: 10),
                  _buildDateSelectionRow(),
                  const SizedBox(height: 20),
                  _buildSectionTitle('Seleccione las categorías:'),
                  const SizedBox(height: 5),
                  Expanded(child: _buildCategoryChips()),
                  _buildActionButtons(),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(
        currentIndex: 2,
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

  Widget _buildDateSelectionRow() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => _selectStartDate(context),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.pinkAccent.shade400),
            ),
            child: Text(
              _startDate == null
                  ? 'Fecha de inicio'
                  : DateFormat('dd/MM/yyyy').format(_startDate!),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: OutlinedButton(
            onPressed: () => _selectEndDate(context),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.pinkAccent.shade400),
            ),
            child: Text(
              _endDate == null
                  ? 'Fecha final'
                  : DateFormat('dd/MM/yyyy').format(_endDate!),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryChips() {
    return ListView(
      children: categoryMapping.keys.map((category) {
        final englishCategory = categoryMapping[category];
        return CheckboxListTile(
          title: Text(
            category,
            style: const TextStyle(color: Colors.white),
          ),
          value: _selectedCategories.contains(englishCategory),
          onChanged: (bool? selected) {
            _onCategoryChanged(category, selected ?? false);
          },
          activeColor: Colors.pinkAccent,
          checkColor: Colors.white,
        );
      }).toList(),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildGradientButton(
          onPressed: _generarPdf,
          text: 'Generar PDF',
        ),
        _buildGradientButton(
          onPressed: _enviarPDFEmail,
          text: 'Enviar PDF',
        ),
      ],
    );
  }

  Widget _buildGradientButton(
      {required VoidCallback onPressed, required String text}) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.deepPurple.shade800,
            Colors.purple.shade600,
            Colors.pinkAccent.shade400,
          ],
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            offset: Offset(2, 4),
            blurRadius: 6,
          ),
        ],
        borderRadius: BorderRadius.circular(12),
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
