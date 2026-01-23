import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/division1_model.dart';
import '../providers/division_one_provider.dart';
import 'package:voice_first_admin/features/Business_activity/presentation/widgets/custom_snackbar.dart';

class AddDivision1Dialog {
  static void show({
    required BuildContext context,
    required WidgetRef ref,
    required String countryId,
    required String label,
  }) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Add $label'),
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
              if (controller.text.trim().isEmpty) return;

              ref
                  .read(divisionOneProvider(countryId))
                  .add(
                    DivisionOneModel(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      countryId: countryId,
                      name: controller.text.trim(),
                      status: true,
                    ),
                  );

              Navigator.pop(ctx);

              CustomSnackbar.show(
                context,
                message: '$label added successfully',
                type: SnackBarType.success,
              );
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
