import 'package:flutter/material.dart';

class PlaceEmptyPlaces extends StatelessWidget {
  final ThemeData theme;

  const PlaceEmptyPlaces({super.key, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: theme.primaryColor.withAlpha(25),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.inbox,
              size: 40,
              color: theme.primaryColor.withAlpha(128),
            ),
          ),
          const SizedBox(height: 16),
          const Text('No places found'),
        ],
      ),
    );
  }
}
