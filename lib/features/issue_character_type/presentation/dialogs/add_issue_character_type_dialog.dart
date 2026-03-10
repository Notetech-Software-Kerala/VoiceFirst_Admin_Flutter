import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/core/widgets/custom_snackbar.dart';
import 'package:voice_first_admin/features/issue_character_type/presentation/providers/issue_character_type_provider.dart';

class AddIssueCharacterTypeDialog {
  static void show(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();

    Future<void> handleAdd() async {
      final name = nameController.text.trim();

      if (name.isEmpty) {
        CustomSnackbar.show(
          context,
          message: 'Character type name is required',
          type: SnackBarType.error,
        );
        return;
      }

      final notifier = ref.read(issueCharacterTypeProvider.notifier);

      try {
        final message = await notifier.add(name);

        if (!context.mounted) return;

        CustomSnackbar.show(
          context,
          message: message,
          type: SnackBarType.success,
        );
        Navigator.pop(context);
      } catch (e) {
        if (!context.mounted) return;

        CustomSnackbar.show(
          context,
          message: e.toString().replaceFirst('Exception: ', ''),
          type: SnackBarType.error,
        );
        Navigator.pop(context);
      }
    }

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add Issue Character Type'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Character Type',
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
