import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/business_activity_provider.dart';
import '../widgets/custom_snackbar.dart';

class DeleteActivityDialog {
  static void show(
    BuildContext context,
    WidgetRef ref,
    int id,
    String name,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Activity?'),
        content: Text('Are you sure you want to delete "$name"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(businessActivityProvider.notifier).delete(id);
              Navigator.pop(context);
              CustomSnackbar.show(
                context,
                message: '$name deleted successfully',
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
