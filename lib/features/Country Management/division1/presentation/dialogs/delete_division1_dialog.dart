import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/division_one_provider.dart';
import 'package:voice_first_admin/features/Business_activity/presentation/widgets/custom_snackbar.dart';

class DeleteDivision1Dialog {
  static void show({
    required BuildContext context,
    required WidgetRef ref,
    required String id,
    required String name,
    required String countryId,
    required String label,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete $label?'),
        content: Text('Are you sure you want to delete "$name"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              ref.read(divisionOneProvider(countryId)).delete(id);

              Navigator.pop(ctx);

              CustomSnackbar.show(
                context,
                message: '$label deleted successfully',
                type: SnackBarType.success,
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
