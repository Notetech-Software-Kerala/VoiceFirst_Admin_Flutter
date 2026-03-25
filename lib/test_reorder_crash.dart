import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: Scaffold(
      body: ReorderableListView(
        buildDefaultDragHandles: false,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        onReorder: (i, j) {},
        children: [
          Container(key: ValueKey('1'), height: 50, color: Colors.red),
        ],
      ),
    ),
  ));
}
