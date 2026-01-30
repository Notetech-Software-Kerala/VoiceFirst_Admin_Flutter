import 'package:flutter/material.dart';
import '../../models/activity_filter_option.dart';

class _FilterButton extends StatelessWidget {
  final ValueChanged<ActivityFilterOption> onSelected;

  const _FilterButton({required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<ActivityFilterOption>(
      icon: const Icon(Icons.filter_alt_outlined),
      tooltip: 'Filter',
      onSelected: onSelected,
      itemBuilder: (_) => const [
        PopupMenuItem(
          value: ActivityFilterOption.all,
          child: Text('All'),
        ),
        PopupMenuItem(
          value: ActivityFilterOption.active,
          child: Text('Active'),
        ),
        PopupMenuItem(
          value: ActivityFilterOption.inactive,
          child: Text('Inactive'),
        ),
        PopupMenuItem(
          value: ActivityFilterOption.available,
          child: Text('Available'),
        ),
        PopupMenuItem(
          value: ActivityFilterOption.deleted,
          child: Text('Deleted'),
        ),
      ],
    );
  }
}
