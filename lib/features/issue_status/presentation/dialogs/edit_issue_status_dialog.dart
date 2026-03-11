import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/core/widgets/custom_snackbar.dart';
import 'package:voice_first_admin/features/issue_status/data/models/issue_status_model.dart';
import 'package:voice_first_admin/features/issue_status/presentation/providers/issue_status_provider.dart';

class EditIssueStatusDialog {
  static Future<void> show(
    BuildContext context,
    WidgetRef ref,
    IssueStatusModel status,
  ) async {
    final TextEditingController controller = TextEditingController(
      text: status.issueStatus,
    );
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Issue Status'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Status',
                hintText: 'Enter issue status name',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a status name';
                }
                return null;
              },
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

                final name = controller.text.trim();
                final result = await ref
                    .read(issueStatusProvider.notifier)
                    .update(
                      id: status.issueStatusId,
                      issueStatus: name,
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

                ref.invalidate(issueStatusDetailProvider(status.issueStatusId));

                CustomSnackbar.show(
                  context,
                  message: 'Issue status updated successfully',
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
