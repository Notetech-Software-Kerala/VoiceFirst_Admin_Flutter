import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/core/widgets/custom_snackbar.dart';
import 'package:voice_first_admin/features/issue_type/data/models/issue_type_model.dart';
import 'package:voice_first_admin/features/issue_type/presentation/providers/issue_type_provider.dart';

class EditIssueTypeDialog {
  static Future<void> show(
    BuildContext context,
    WidgetRef ref,
    IssueTypeModel issueType,
  ) async {
    final nameController = TextEditingController(text: issueType.issueType);
    final descController = TextEditingController(text: issueType.description ?? '');
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Issue Type'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Type Name',
                    hintText: 'Enter issue type name',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a type name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: descController,
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                    hintText: 'Enter a brief description',
                  ),
                  maxLines: 3,
                  minLines: 1,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;

                final name = nameController.text.trim();
                final desc = descController.text.trim();

                final result = await ref
                    .read(issueTypeProvider.notifier)
                    .update(
                      id: issueType.issueTypeId,
                      issueType: name,
                      description: desc,
                    );

                if (!context.mounted) return;

                if (result != null) {
                  CustomSnackbar.show(
                    context,
                    message: result,
                    type: SnackBarType.error,
                  );
                  Navigator.of(context).pop();
                  return;
                }

                ref.invalidate(issueTypeDetailProvider(issueType.issueTypeId));

                CustomSnackbar.show(
                  context,
                  message: 'Issue type updated successfully',
                  type: SnackBarType.success,
                );
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
