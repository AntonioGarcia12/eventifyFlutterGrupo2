import 'package:eventify/presentacion/screens/buttons/buttons.dart';
import 'package:flutter/material.dart';

class BuildFilter extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onPressed;

  const BuildFilter({
    required this.icon,
    required this.color,
    required this.label,
    required this.onPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return _buildFilterButton(
      icon: icon,
      color: color,
      label: label,
      onPressed: onPressed,
    );
  }

  Widget _buildFilterButton({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          decoration: BoxDecoration(
            color: color.withOpacity(0.8),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ),
        const SizedBox(width: 8),
        IconFilterButton(
          icon: icon,
          color: color,
          onPressed: onPressed,
        ),
      ],
    );
  }
}
