import 'package:eventify/presentacion/screens/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LoginService extends StatefulWidget {
  const LoginService({super.key});
  static const String name = 'login_service';

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

    setState(() {
      _emailError = null;
      _passwordError = null;
      _generalError = null;
    });

    // Validar si los campos están vacíos
    if (email.isEmpty) {
      setState(() {
        _emailError = 'El correo es obligatorio';
      });
      return;
    }

    if (password.isEmpty) {
      setState(() {
        _passwordError = 'La contraseña es obligatoria';
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

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
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
            context.go('/organizador');
          } else {
            context.go('/normal');
          }
        } else {
          setState(() {
            _generalError = 'Error: Información de usuario incompleta';
          });
        }
      } else if (response.statusCode == 401) {
        // Manejo específico del error Unauthorized
        setState(() {
          _generalError = 'La contraseña o el gmail son incorrectos';
        });
      } else {
        String errorMessage = responseData.containsKey('message')
            ? responseData['message']
            : 'Error inesperado en el inicio de sesión.';

        if (responseData.containsKey('errors')) {
          if (responseData['errors'].containsKey('email')) {
            setState(() {
              _emailError = responseData['errors']['email'][0];
            });
          } else if (responseData['errors'].containsKey('password')) {
            setState(() {
              _passwordError = responseData['errors']['password'][0];
            });
          }
        } else {
          setState(() {
            _generalError = errorMessage;
          });
        }
      }
    } catch (e) {
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
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Correo electrónico',
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.8)),
            filled: true,
            fillColor: Colors.white.withOpacity(0.3),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(color: Colors.white),
            ),
            errorText: _emailError,
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _passwordController,
          obscureText: !_passwordVisible,
          style: TextStyle(color: Colors.white),
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
            errorText: _passwordError,
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _loginUser,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.pinkAccent,
            padding:
                const EdgeInsets.symmetric(vertical: 16.0, horizontal: 52.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
          child: const Text('Iniciar sesión',
              style: TextStyle(color: Colors.white)),
        ),
        const SizedBox(height: 16),
        if (_generalError != null)
          Text(
            _generalError!,
            style: TextStyle(color: Colors.redAccent),
          ),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => RegisterScreen()),
            );
          },
          child: const Text(
            'Registrar nueva cuenta',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}
