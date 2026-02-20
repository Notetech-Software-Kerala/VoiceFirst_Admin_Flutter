import 'package:flutter/material.dart';

class StandardIconBox extends StatelessWidget {
  final IconData icon;
  final Color color;

  const StandardIconBox({super.key, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: Icon(icon, color: color, size: 20),
    );
  }
}
