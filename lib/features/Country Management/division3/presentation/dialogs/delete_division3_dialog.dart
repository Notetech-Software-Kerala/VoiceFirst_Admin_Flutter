import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/features/Business_activity/presentation/widgets/custom_snackbar.dart';
import '../providers/division_three_provider.dart';

class DeleteDivisionThreeDialog {
  static void show(
    BuildContext context,
    WidgetRef ref,
    String divisionTwoId,
    String id,
    String name,
  ) {
    showDialog(
      context: context,
      useRootNavigator: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Division'),
        content: Text('Are you sure you want to delete "$name"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref
                  .read(divisionThreeProvider(divisionTwoId).notifier)
                  .delete(id);

              Navigator.pop(dialogContext);

              CustomSnackbar.show(
                context,
                message: 'Division deleted successfully',
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
