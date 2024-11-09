import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  static const String name = "homeScreen";

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool showWelcomeText = false;
  bool showLoginButton = false;
  bool showRegisterButton = false;

  @override
  void initState() {
    super.initState();
    _showElementsWithDelay();
  }

  void _showElementsWithDelay() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      showWelcomeText = true;
    });

    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      showLoginButton = true;
    });

    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      showRegisterButton = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: Stack(
        children: [
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
              mainAxisAlignment: MainAxisAlignment.center,
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
                const SizedBox(height: 16),
                AnimatedOpacity(
                  opacity: showWelcomeText ? 1.0 : 0.0,
                  duration: const Duration(seconds: 1),
                  child: const Text(
                    'Bienvenido a Eventify',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                AnimatedOpacity(
                  opacity: showLoginButton ? 1.0 : 0.0,
                  duration: const Duration(seconds: 1),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 15,
                      ),
                      backgroundColor: Colors.pinkAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40),
                      ),
                    ),
                    onPressed: () {
                      context.go('/');
                    },
                    child: const Text(
                      'Iniciar sesión',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                AnimatedOpacity(
                  opacity: showRegisterButton ? 1.0 : 0.0,
                  duration: const Duration(seconds: 1),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 45,
                        vertical: 15,
                      ),
                      backgroundColor: Colors.pinkAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40),
                      ),
                    ),
                    onPressed: () {
                      context.go('/registrar');
                    },
                    child: const Text(
                      'Registrarse',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
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
