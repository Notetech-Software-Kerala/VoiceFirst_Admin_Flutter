import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/business_activity_provider.dart';
import '../../../../core/widgets/custom_snackbar.dart';

class AddActivityDialog {
  static void show(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();

    Future<void> handleAdd() async {
      final name = nameController.text.trim();
      debugPrint('\n Add button clicked');
      debugPrint(' Activity name: "$name"');

      if (name.isEmpty) {
        debugPrint('Validation failed: Name is empty');
        CustomSnackbar.show(
          context,
          message: 'Activity name is required',
          type: SnackBarType.error,
        );
        return;
      }

      // Call API in the background
      debugPrint('Calling notifier.add()...');
      final notifier = ref.read(businessActivityProvider.notifier);
      final error = await notifier.add(name);

      if (error == null) {
        Navigator.pop(context);
        debugPrint('Success! Showing success snackbar');
        CustomSnackbar.show(
          context,
          message: '$name added successfully',
          type: SnackBarType.success,
        );
      } else {
        debugPrint('Error occurred: $error');
        CustomSnackbar.show(context, message: error, type: SnackBarType.error);
      }
    }

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add New Activity'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Activity Name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(onPressed: handleAdd, child: const Text('Add')),
        ],
      ),
    );
  }
}
