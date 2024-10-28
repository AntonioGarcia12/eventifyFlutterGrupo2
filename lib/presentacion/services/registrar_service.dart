import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegistrarService extends StatefulWidget {
  @override
  State<RegistrarService> createState() => RegisterServiceFormState();
  static const String name = 'registrar_services';
  const RegistrarService({super.key});
}

class RegisterServiceFormState extends State<RegistrarService> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  String userType = 'u'; // 'u' para Usuario por defecto
  bool _passwordVisible = false;

  // Variables para almacenar mensajes de error
  String? _nameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;
  String? _userTypeError;

  Future<void> _registerUser() async {
    String name = _nameController.text.trim();
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();

    setState(() {
      // Validación local de los campos y actualización de mensajes de error
      _nameError = name.isEmpty ? 'El nombre es obligatorio' : null;
      _emailError =
          email.isEmpty ? 'El correo electrónico es obligatorio' : null;
      _passwordError = password.isEmpty ? 'La contraseña es obligatoria' : null;
      _confirmPasswordError = confirmPassword.isEmpty
          ? 'Confirmar la contraseña es obligatorio'
          : null;
      _userTypeError =
          userType.isEmpty ? 'El rol de usuario es obligatorio' : null;

      if (password.isNotEmpty &&
          confirmPassword.isNotEmpty &&
          password != confirmPassword) {
        _confirmPasswordError = 'Las contraseñas no coinciden';
      }
    });

    // Si hay algún error, no continuar con el registro
    if (_nameError != null ||
        _emailError != null ||
        _passwordError != null ||
        _confirmPasswordError != null ||
        _userTypeError != null) {
      return;
    }

    final url = Uri.parse('https://eventify.allsites.es/public/api/register');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'c_password': confirmPassword,
          'role': userType,
        }),
      );

      // Parsear la respuesta
      final responseData = jsonDecode(response.body);

      // Manejar la respuesta en función del código de estado
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (responseData['success'] == true) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Registro exitoso'),
              content: Text('Revisa tu correo para verificar la cuenta.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: Text('Aceptar'),
                ),
              ],
            ),
          );
        } else {
          String errorMessage = responseData['message'];
          _showErrorDialog('Error', errorMessage);
        }
      } else if (response.statusCode == 400) {
        // El servidor devuelve un 400 para errores de validación
        String errorMessage = responseData.containsKey('message')
            ? responseData['message']
            : 'Error desconocido';

        // Revisar si hay errores detallados
        if (responseData.containsKey('data')) {
          Map<String, dynamic> errors = responseData['data'];
          List<String> errorMessages = [];
          errors.forEach((key, value) {
            errorMessages.add("$key: ${value.join(', ')}");
          });
          errorMessage += "\n${errorMessages.join('\n')}";
        }

        _showErrorDialog('Error', errorMessage);
      } else {
        _showErrorDialog('Error',
            'Error: ${response.statusCode} - ${responseData['message']}');
      }
    } catch (e) {
      _showErrorDialog('Error', 'Hubo un error, intenta de nuevo más tarde');
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: 'Nombre Completo',
            labelStyle: const TextStyle(color: Colors.white),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            errorText: _nameError,
          ),
          style: const TextStyle(color: Colors.white),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: 'Correo Electrónico',
            labelStyle: const TextStyle(color: Colors.white),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            errorText: _emailError,
          ),
          style: const TextStyle(color: Colors.white),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _passwordController,
          obscureText: !_passwordVisible,
          decoration: InputDecoration(
            labelText: 'Contraseña',
            labelStyle: const TextStyle(color: Colors.white),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _passwordVisible ? Icons.visibility : Icons.visibility_off,
                color: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  _passwordVisible = !_passwordVisible;
                });
              },
            ),
            errorText: _passwordError,
          ),
          style: const TextStyle(color: Colors.white),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _confirmPasswordController,
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'Confirmar Contraseña',
            labelStyle: const TextStyle(color: Colors.white),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            errorText: _confirmPasswordError,
          ),
          style: TextStyle(color: Colors.white),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: userType,
          dropdownColor: Colors.black87,
          items: const [
            DropdownMenuItem(
              value: 'u',
              child: Text(
                'Normal',
                style: TextStyle(color: Colors.white),
              ),
            ),
            DropdownMenuItem(
              value: 'o',
              child: Text(
                'Organizador',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
          onChanged: (newValue) {
            setState(() {
              userType = newValue!;
            });
          },
          decoration: InputDecoration(
            labelText: 'Tipo de usuario',
            labelStyle: TextStyle(color: Colors.white),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            errorText: _userTypeError,
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _registerUser,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.pinkAccent,
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
          child:
              const Text('Registrarse', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
