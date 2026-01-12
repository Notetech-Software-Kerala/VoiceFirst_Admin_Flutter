import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/business_activity_provider.dart';
import '../widgets/custom_snackbar.dart';

class BulkDeleteDialog {
  static void show(BuildContext context, WidgetRef ref, int count) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Selected Activities?'),
        content: Text(
          'Are you sure you want to delete $count activit${count > 1 ? 'ies' : 'y'}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(businessActivityProvider.notifier).deleteSelected();
              Navigator.pop(context);
              CustomSnackbar.show(
                context,
                message:
                    '$count activit${count > 1 ? 'ies' : 'y'} deleted successfully',
                type: SnackBarType.success,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
