import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/features/Place_management/presentation/providers/add_place_provider.dart';

class ZipSelectionSummary extends ConsumerWidget {
  const ZipSelectionSummary({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(addPlaceFormProvider);
    final selectedIds = form.zipCodeIds;

    if (selectedIds.isEmpty) {
      return const SizedBox();
    }

    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Selected Zip Codes Summary",
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            "Total: ${selectedIds.length}",
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),

          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: selectedIds
                .map((id) => Chip(label: Text("ID: $id")))
                .toList(),
          ),
        ],
      ),
    );
  }
}
