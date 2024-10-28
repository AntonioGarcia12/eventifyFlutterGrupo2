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

  Future<void> _registerUser() async {
    String name = _nameController.text.trim();
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();

    // Validación local
    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Todos los campos son obligatorios')),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Las contraseñas no coinciden')),
      );
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'Registro exitoso. Revisa tu correo para verificar la cuenta.')),
          );
          Navigator.pop(context);
        } else {
          String errorMessage = responseData['message'];
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $errorMessage')),
          );
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

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $errorMessage')),
        );
      } else {
        // Otro tipo de error (500, 404, etc.)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Error: ${response.statusCode} - ${responseData['message']}')),
        );
      }
    } catch (e) {
      print('Exception: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hubo un error, intenta de nuevo más tarde')),
      );
    }
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
            labelStyle: TextStyle(color: Colors.white),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
          style: TextStyle(color: Colors.white),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: 'Correo Electrónico',
            labelStyle: TextStyle(color: Colors.white),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
          style: TextStyle(color: Colors.white),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _passwordController,
          obscureText: !_passwordVisible,
          decoration: InputDecoration(
            labelText: 'Contraseña',
            labelStyle: TextStyle(color: Colors.white),
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
          ),
          style: TextStyle(color: Colors.white),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _confirmPasswordController,
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'Confirmar Contraseña',
            labelStyle: TextStyle(color: Colors.white),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
          style: TextStyle(color: Colors.white),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: userType,
          dropdownColor: Colors.black87,
          items: [
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
            labelText: 'Rol de Usuario',
            labelStyle: TextStyle(color: Colors.white),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
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
