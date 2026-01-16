import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/features/Business_activity/presentation/widgets/custom_snackbar.dart';
import 'package:voice_first_admin/features/Program_Action/models/program_action_model.dart';
import '../providers/program_action_provider.dart';

class AddProgramActionDialog {
  static void show(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();

    showDialog(
      context: context,
      useRootNavigator: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add Program Action'),
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
              final name = nameController.text.trim();
              if (name.isEmpty) {
                CustomSnackbar.show(
                  context,
                  message: 'Please enter action name',
                  type: SnackBarType.error,
                );
                return;
              }

              // Generate a new ID (in real app, this would come from backend)
              final state = ref.read(programActionProvider);
              final newId = state.all.isEmpty
                  ? 1
                  : state.all
                            .map((e) => e.ProgramActionId)
                            .reduce((a, b) => a > b ? a : b) +
                        1;

              final newAction = ProgramActionModel(
                ProgramActionId: newId,
                programActionName: name,
                isActive: true,
              );

              ref.read(programActionProvider.notifier).add(newAction);

              Navigator.pop(dialogContext);

              CustomSnackbar.show(
                context,
                message: 'Program action added successfully',
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
