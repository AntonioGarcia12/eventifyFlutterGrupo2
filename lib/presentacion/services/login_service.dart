import 'package:eventify/presentacion/screens/recuperar_password_screen.dart';
import 'package:eventify/presentacion/screens/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LoginService extends StatefulWidget {
  const LoginService({super.key});

  @override
  State<LoginService> createState() => LoginServiceState();
}

class LoginServiceState extends State<LoginService> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _passwordVisible = false;

  String? _emailError;
  String? _passwordError;
  String? _generalError;

  Future<void> _loginUser() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    // Limpiar los mensajes de error
    setState(() {
      _emailError = null;
      _passwordError = null;
      _generalError = null;
    });

    // Validar si los campos de correo y contraseña están vacíos
    if (email.isEmpty) {
      setState(() {
        _emailError = 'El campo de correo no puede estar vacío';
      });
      return;
    }

    if (password.isEmpty) {
      setState(() {
        _passwordError = 'El campo de contraseña no puede estar vacío';
      });
      return;
    }

    final url = Uri.parse('https://eventify.allsites.es/public/api/login');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      // Asegúrate de que la respuesta sea un JSON válido
      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        // Validar si data y role están presentes en la respuesta
        if (responseData['data'] != null &&
            responseData['data']['role'] != null) {
          String role = responseData['data']['role'];
          String token = responseData['data']['token'];

          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', token);

          // Navegar según el rol
          if (role == 'a') {
            context.go('/admin');
          } else if (role == 'o') {
            // Aquí podrías agregar la pantalla para el organizador
            setState(() {
              _generalError = 'Inicio de sesión como Organizador';
            });
          } else {
            // Aquí podrías agregar la pantalla para el usuario normal
            setState(() {
              _generalError = 'Inicio de sesión como Usuario';
            });
          }
        } else {
          setState(() {
            _generalError = 'Error: Información de usuario incompleta';
          });
        }
      } else {
        // Manejo de errores detallado desde la respuesta de la API
        String errorMessage = responseData.containsKey('message')
            ? responseData['message']
            : 'Error inesperado en el inicio de sesión.';

        if (responseData.containsKey('errors')) {
          if (responseData['errors'].containsKey('email')) {
            errorMessage = responseData['errors']['email'][0];
            setState(() {
              _emailError = errorMessage;
            });
          } else if (responseData['errors'].containsKey('password')) {
            errorMessage = responseData['errors']['password'][0];
            setState(() {
              _passwordError = errorMessage;
            });
          }
        } else {
          setState(() {
            _generalError = errorMessage;
          });
        }
      }
    } catch (e) {
      // Manejo de excepciones
      print('Exception: $e');
      setState(() {
        _generalError = 'Hubo un error, intenta de nuevo más tarde';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          style: TextStyle(color: Colors.white), // Color de texto normal
          decoration: InputDecoration(
            hintText: 'Correo electrónico',
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.8)),
            filled: true,
            fillColor: Colors.white.withOpacity(0.3),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(color: Colors.white),
            ),
            errorStyle: TextStyle(
                color: Colors.redAccent), // Mensajes de error en blanco
            errorText: _emailError,
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _passwordController,
          obscureText: !_passwordVisible,
          style: TextStyle(color: Colors.white), // Color de texto normal
          decoration: InputDecoration(
            hintText: 'Contraseña',
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.8)),
            filled: true,
            fillColor: Colors.white.withOpacity(0.3),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(color: Colors.white),
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
            errorStyle: TextStyle(
                color: Colors.redAccent), // Mensajes de error en blanco
            errorText: _passwordError,
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _loginUser,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.pinkAccent,
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
          child: const Text('Entrar', style: TextStyle(color: Colors.white)),
        ),
        const SizedBox(height: 16),
        if (_generalError != null)
          Text(
            _generalError!,
            style: TextStyle(color: Colors.white),
          ),
        TextButton(
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => RecuperarPasswordScreen()));
          },
          child: const Text('Olvidó su contraseña?',
              style: TextStyle(color: Colors.white)),
        ),
        TextButton(
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => RegisterScreen()));
          },
          child: const Text('Registrar nueva cuenta',
              style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
