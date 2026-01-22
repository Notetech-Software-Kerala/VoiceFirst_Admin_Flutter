import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/features/Business_activity/presentation/widgets/custom_snackbar.dart';
import 'package:voice_first_admin/features/Program_Action/models/program_action_model.dart';
import '../providers/program_action_provider.dart';

class EditProgramActionDialog {
  static void show(
    BuildContext context,
    WidgetRef ref,
    ProgramActionModel action,
  ) {
    final nameController = TextEditingController(text: action.actionName);

    showDialog(
      context: context,
      useRootNavigator: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Edit Program Action'),
        content: TextField(
          controller: nameController,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Action Name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newName = nameController.text.trim();
              if (newName.isEmpty) {
                if (context.mounted) {
                  CustomSnackbar.show(
                    context,
                    message: 'Please enter action name',
                    type: SnackBarType.error,
                  );
                }
                return;
              }

              if (newName == action.actionName) {
                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                }
                return;
              }

              final error = await ref
                  .read(programActionProvider.notifier)
                  .update(action.actionId, newName);

              if (dialogContext.mounted) {
                Navigator.pop(dialogContext);
              }

              if (context.mounted) {
                if (error != null) {
                  CustomSnackbar.show(
                    context,
                    message: error,
                    type: SnackBarType.error,
                  );
                } else {
                  CustomSnackbar.show(
                    context,
                    message: 'Program action updated successfully',
                    type: SnackBarType.success,
                  );
                }
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
}
