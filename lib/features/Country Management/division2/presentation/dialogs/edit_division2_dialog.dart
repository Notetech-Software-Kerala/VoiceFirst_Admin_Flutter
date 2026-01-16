import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/features/Business_activity/presentation/widgets/custom_snackbar.dart';
import 'package:voice_first_admin/features/Country%20Management/division2/models/DivisionTwoModel';
import '../providers/division_two_provider.dart';

class EditDivisionTwoDialog {
  static void show(
    BuildContext context,
    WidgetRef ref,
    String divisionOneId,
    DivisionTwoModel division,
  ) {
    final controller = TextEditingController(text: division.name);

    showDialog(
      context: context,
      useRootNavigator: false, // ✅ same fix you used earlier
      builder: (dialogContext) => AlertDialog(
        title: const Text('Edit Division'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Division Name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newName = controller.text.trim();
              if (newName.isEmpty || newName == division.name) return;

              ref
                  .read(divisionTwoProvider(divisionOneId).notifier)
                  .update(division.copyWith(name: newName));

              /// ✅ close ONLY dialog
              Navigator.pop(dialogContext);

              CustomSnackbar.show(
                context,
                message: 'Division updated successfully',
                type: SnackBarType.success,
              );
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
}
