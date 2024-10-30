import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eventify/presentacion/services/editar_services.dart';
import 'package:go_router/go_router.dart';

class EditarScreen extends ConsumerStatefulWidget {
  final int userId;

  const EditarScreen({super.key, required this.userId});

  @override
  _EditarScreenState createState() => _EditarScreenState();
}

class _EditarScreenState extends ConsumerState<EditarScreen> {
  final _formKey = GlobalKey<FormState>();
  late EditarServices _editarServices;

  String _nombre = '';
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _editarServices = EditarServices(ref);
    _cargarUsuario();
  }

  Future<void> _cargarUsuario() async {
    final usuario = await _editarServices.cargarUsuario(widget.userId);
    setState(() {
      _nombre = usuario['nombre'] ?? '';
    });
  }

  Future<void> _guardarCambios() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        final success = await _editarServices.guardarCambios(
          userId: widget.userId,
          nombre: _nombre,
        );

        if (success && mounted) {
          _mostrarConfirmacionDialog();
        }
      } catch (e) {
        _mostrarErrorDialog(
            'No se pudo guardar el usuario. Inténtalo de nuevo.');
      }
    }
  }

  void _mostrarErrorDialog(String mensaje) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(mensaje),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }

  void _mostrarConfirmacionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Usuario actualizado'),
          content: const Text('Los cambios se han guardado exitosamente.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Cerrar el diálogo
                context.go('/admin'); // Redirigir a AdministradorScreen
              },
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: Stack(
        children: [
          // Fondo animado similar al de LoginScreen
          Positioned.fill(
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
            ),
          ),
          Column(
            children: [
              // AppBar personalizado con degradado
              Container(
                padding:
                    const EdgeInsets.only(top: 40.0, left: 16.0, right: 16.0),
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
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => context.go('/admin'),
                      tooltip: 'Salir',
                    ),
                    const SizedBox(width: 16.0),
                    const Text(
                      'Editar Usuario',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      children: [
                        const Text(
                          'Nombre', // Aquí está el label
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        TextFormField(
                          initialValue: _nombre,
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Nombre',
                            hintStyle:
                                TextStyle(color: Colors.white.withOpacity(0.8)),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.3),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(color: Colors.white),
                            ),
                          ),
                          onSaved: (value) {
                            _nombre = value!;
                          },
                        ),
                        const SizedBox(height: 24.0),
                        ElevatedButton(
                          onPressed: _guardarCambios,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.pinkAccent,
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          child: const Text('Guardar Cambios',
                              style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
