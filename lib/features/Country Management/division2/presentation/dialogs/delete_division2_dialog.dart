import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/features/Business_activity/presentation/widgets/custom_snackbar.dart';
import '../providers/division_two_provider.dart';

class DeleteDivisionTwoDialog {
  static void show(
    BuildContext context,
    WidgetRef ref,
    String divisionOneId,
    String id,
    String name,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Division?'),
        content: Text('Are you sure you want to delete "$name"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              ref.read(divisionTwoProvider(divisionOneId).notifier).delete(id);

              Navigator.pop(dialogContext);

              CustomSnackbar.show(
                context,
                message: '$name deleted successfully',
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
