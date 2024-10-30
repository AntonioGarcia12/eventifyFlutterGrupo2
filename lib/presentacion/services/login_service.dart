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
          _showOverlayMessage('Error: Información de usuario incompleta');
        }
      } else {
        // Imprimir para depuración
        String errorMessage = 'Error inesperado en el inicio de sesión.';

        // Verificar si 'data' y 'error' están en responseData
        if (responseData.containsKey('data') &&
            responseData['data'].containsKey('error')) {
          String serverError = responseData['data']['error'];

          // Mapear el mensaje de error del servidor a mensajes amigables
          if (serverError == 'Unauthorized') {
            errorMessage =
                'El correo electrónico o la contraseña son incorrectos';
          } else if (serverError == "Email don't confirmed") {
            errorMessage =
                'Email no confirmado, revisa tu correo para confirmar';
          } else if (serverError == "User don't activated") {
            errorMessage =
                'Cuenta no activada, espera a que el administrador la active';
          } else if (serverError == 'User deleted') {
            errorMessage = 'Esta cuenta ha sido eliminada por el administrador';
          } else {
            // Si el mensaje no coincide, mostrar el mensaje del servidor
            errorMessage = serverError;
          }
        } else {
          // Si no hay 'data.error', usar 'message' o un mensaje genérico
          if (responseData.containsKey('message')) {
            errorMessage = responseData['message'];
          }
        }

        _showOverlayMessage(errorMessage);
      }
    } catch (e) {
      _showOverlayMessage('Hubo un error, intenta de nuevo más tarde');
    }
  }

  void _showOverlayMessage(String message) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).size.height * 0.1,
        left: MediaQuery.of(context).size.width * 0.1,
        right: MediaQuery.of(context).size.width * 0.1,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding:
                const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Text(
              message,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(const Duration(seconds: 3), () {
      overlayEntry.remove();
    });
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
