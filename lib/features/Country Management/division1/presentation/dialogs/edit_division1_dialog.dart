import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/division1_model.dart';
import '../providers/division_one_provider.dart';
import 'package:voice_first_admin/features/Business_activity/presentation/widgets/custom_snackbar.dart';

class EditDivision1Dialog {
  static void show({
    required BuildContext context,
    required WidgetRef ref,
    required DivisionOneModel division,
    required String countryId,
    required String label,
  }) {
    final controller = TextEditingController(text: division.name);

    showDialog(
      context: context,
      useRootNavigator: false,
      builder: (ctx) => AlertDialog(
        title: Text('Edit $label'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: '$label Name',
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newName = controller.text.trim();
              if (newName.isEmpty || newName == division.name) return;

              ref
                  .read(divisionOneProvider(countryId))
                  .update(division.copyWith(name: newName));

              Navigator.pop(ctx);

              CustomSnackbar.show(
                context,
                message: '$label updated successfully',
                type: SnackBarType.success,
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
