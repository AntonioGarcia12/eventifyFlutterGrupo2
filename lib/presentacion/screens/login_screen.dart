import 'package:eventify/presentacion/screens/administrador_screen.dart';
import 'package:eventify/presentacion/screens/recuperar_password_screen.dart';
import 'package:eventify/presentacion/screens/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: Stack(
        children: [
          // Fondo animado
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
              child: Center(
                child: SpinKitRipple(
                  color: Colors.white.withOpacity(0.1),
                  size: 400,
                ),
              ),
            ),
          ),
          Center(
            child: Column(
              children: [
                const Spacer(),
                Flexible(
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 250,
                    height: 250,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: _LoginView(),
                ),
                const Spacer(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginView extends StatefulWidget {
  _LoginView({super.key});

  @override
  State<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _passwordVisible = false;

  Future<void> _loginUser() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    final url = Uri.parse('https://eventify.allsites.es/public/api/login');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      // Imprimir la respuesta para verificar qué está pasando
      print("Response Body: ${response.body}");

      // Asegúrate de que la respuesta sea un JSON válido
      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        // Validar si data y role están presentes en la respuesta
        if (responseData['data'] != null &&
            responseData['data']['role'] != null) {
          String role = responseData['data']['role'];

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Inicio de sesión exitoso')),
          );

          // Navegar según el rol
          if (role == 'a') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => AdministradorScreen()),
            );
          } else if (role == 'o') {
            // Aquí podrías agregar la pantalla para el organizador
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Inicio de sesión como Organizador')),
            );
          } else {
            // Aquí podrías agregar la pantalla para el usuario normal
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Inicio de sesión como Usuario')),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: Información de usuario incompleta')),
          );
        }
      } else {
        // Manejo de errores detallado
        String errorMessage = responseData.containsKey('message')
            ? responseData['message']
            : 'Error inesperado en el inicio de sesión.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $errorMessage')),
        );
      }
    } catch (e) {
      // Manejo de excepciones
      print('Exception: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hubo un error, intenta de nuevo más tarde')),
      );
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
          decoration: InputDecoration(
            hintText: 'Correo electrónico',
            filled: true,
            fillColor: Colors.white.withOpacity(0.9),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _passwordController,
          obscureText: !_passwordVisible,
          decoration: InputDecoration(
            hintText: 'Contraseña',
            filled: true,
            fillColor: Colors.white.withOpacity(0.9),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _passwordVisible ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: () {
                setState(() {
                  _passwordVisible = !_passwordVisible;
                });
              },
            ),
          ),
        ),
        const SizedBox(height: 24),
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
