import 'package:flutter/material.dart';

class PlaceFormLabel extends StatelessWidget {
  final String text;

  const PlaceFormLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }
}
