import 'package:flutter/material.dart';

class IconFilterButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const IconFilterButton({
    required this.icon,
    required this.color,
    required this.onPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: color,
      onPressed: onPressed,
      shape: const CircleBorder(),
      heroTag: icon.toString(),
      child: Icon(
        icon,
        color: Colors.white,
        size: 30,
      ),
    );
  }
}
