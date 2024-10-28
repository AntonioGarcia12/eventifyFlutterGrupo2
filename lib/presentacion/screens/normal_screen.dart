import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NormalScreen extends StatelessWidget {
  const NormalScreen({super.key});
  static const String name = 'normal_screen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        title: const Text('Normal'),
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
