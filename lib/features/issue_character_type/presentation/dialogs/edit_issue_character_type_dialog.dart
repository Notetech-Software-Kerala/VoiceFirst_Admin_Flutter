import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/core/widgets/custom_snackbar.dart';
import 'package:voice_first_admin/features/issue_character_type/data/models/issue_charactertype_model.dart';
import 'package:voice_first_admin/features/issue_character_type/presentation/providers/issue_character_type_provider.dart';

class EditIssueCharacterTypeDialog {
  static void show(
    BuildContext context,
    WidgetRef ref,
    IssueCharacterTypeModel characterType,
  ) {
    final nameController = TextEditingController(
      text: characterType.issueCharacterType,
    );

    showDialog(
      context: context,
      builder: (dialogContext) {
        Future<void> handleSave() async {
          final name = nameController.text.trim();

          if (name.isEmpty) {
            CustomSnackbar.show(
              context,
              message: 'Character type name is required',
              type: SnackBarType.error,
            );
            return;
          }

          final result = await ref
              .read(issueCharacterTypeProvider.notifier)
              .update(
                id: characterType.issueCharacterTypeId,
                issueCharacterType: name,
              );

          if (result != null) {
            // Non-null means error message from notifier
            if (dialogContext.mounted) {
              CustomSnackbar.show(
                context,
                message: result,
                type: SnackBarType.error,
              );
              Navigator.of(dialogContext).pop();
            }
            return;
          }

          // Ensure detail pages using issueCharacterTypeDetailProvider
          // also see the latest data.
          // ignore: unused_result
          ref.refresh(
            issueCharacterTypeDetailProvider(
              characterType.issueCharacterTypeId,
            ),
          );

          if (dialogContext.mounted) {
            CustomSnackbar.show(
              context,
              message: 'Character type updated successfully',
              type: SnackBarType.success,
            );
            Navigator.of(dialogContext).pop();
          }
        }

        return AlertDialog(
          title: const Text('Edit Character Type'),
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
            ElevatedButton(onPressed: handleSave, child: const Text('Save')),
          ],
        );
      },
    );
  }
}
