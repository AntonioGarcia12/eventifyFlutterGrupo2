import 'package:eventify/presentacion/screens/recuperar_password_screen.dart';
import 'package:eventify/presentacion/screens/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart'; // For animated background

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: Stack(
        children: [
          // Animated background
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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: _LoginView(),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginView extends StatelessWidget {
  _LoginView({super.key});

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        /*Image.asset(
          'assets/crypto_logo.png',
          height: 80,
          width: 80,
        ),*/
        const SizedBox(height: 16.0),
        const Text(
          'Eventify',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Text(
          '',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 14.0,
          ),
        ),
        const SizedBox(height: 32.0),
        TextField(
          controller: _emailController,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Correo electrónico',
            labelStyle: TextStyle(color: Colors.white70),
            filled: true,
            fillColor: Colors.black45,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide.none,
            ),
            prefixIcon: Icon(Icons.mail, color: Colors.white70),
          ),
        ),
        const SizedBox(height: 16.0),
        TextField(
          controller: _passwordController,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Contraseña',
            labelStyle: TextStyle(color: Colors.white70),
            filled: true,
            fillColor: Colors.black45,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide.none,
            ),
            prefixIcon: Icon(Icons.lock, color: Colors.white70),
            suffixIcon: Icon(Icons.visibility, color: Colors.white70),
          ),
          obscureText: true,
        ),
        const SizedBox(height: 24.0),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              // Acción para el botón de login
              String email = _emailController.text;
              String password = _passwordController.text;
              // Puedes agregar lógica para la validación o autenticación aquí
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Login attempt with email: $email')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pinkAccent,
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            child: const Text('Entrar', style: TextStyle(color: Colors.white)),
          ),
        ),
        const SizedBox(height: 16.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () {
                // Acción para el botón de registrarse
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const RegisterScreen()),
                );
              },
              child: const Text('Crear cuenta',
                  style: TextStyle(color: Colors.pinkAccent)),
            ),
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => RecuperarPasswordScreen()),
              ),
              child: const Text('¿Olvidaste la contraseña?',
                  style: TextStyle(color: Colors.pinkAccent)),
            ),
          ],
        ),
        const SizedBox(height: 24.0),
      ],
    );
  }
}
