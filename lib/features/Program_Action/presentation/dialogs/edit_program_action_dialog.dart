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
    final nameController = TextEditingController(
      text: action.programActionName,
    );

    showDialog(
      context: context,
      useRootNavigator: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Edit Program Action'),
        content: TextField(
          controller: nameController,
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
            onPressed: () {
              final newName = nameController.text.trim();
              if (newName.isEmpty) {
                CustomSnackbar.show(
                  context,
                  message: 'Please enter action name',
                  type: SnackBarType.error,
                );
                return;
              }

              if (newName == action.programActionName) {
                Navigator.pop(dialogContext);
                return;
              }

              final updatedAction = action.copyWith(programActionName: newName);
              ref.read(programActionProvider.notifier).update(updatedAction);

              Navigator.pop(dialogContext);

              CustomSnackbar.show(
                context,
                message: 'Program action updated successfully',
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
