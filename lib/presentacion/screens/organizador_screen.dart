import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OrganizadorScreen extends StatelessWidget {
  const OrganizadorScreen({super.key});
  static const String name = "organizador_screen";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        title: const Text('Organizador'),
        backgroundColor: Colors.pinkAccent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
          tooltip: 'Salir',
        ),
      ),
    );
  }
}
