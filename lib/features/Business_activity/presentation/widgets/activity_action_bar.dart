import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/business_activity_model.dart';
import '../providers/business_activity_provider.dart';

class ActivityActionBar extends ConsumerWidget {

  final BusinessActivity activity;
  final int activityId;

  const ActivityActionBar({
    super.key,
    required this.activity,
    required this.activityId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final notifier = ref.read(
      businessActivityProvider.notifier,
    );

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(16),

        child: Row(
          children: [

            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.edit),
                label: const Text("Edit"),
                onPressed: () {
                  /// your edit navigation
                },
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.delete),
                label: const Text("Delete"),

                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade50,
                  foregroundColor: Colors.red,
                ),

                onPressed: () async {

                  await notifier.delete(activityId);

                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}