import 'package:flutter/material.dart';

void main() {
  ReorderableListView(
    buildDefaultDragHandles: false,
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    onReorder: (int oldIndex, int newIndex) {},
    children: [Text("hi")],
  );
  print('ReorderableListView created successfully');
}
