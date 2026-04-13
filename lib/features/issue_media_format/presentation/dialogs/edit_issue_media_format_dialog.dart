import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/core/widgets/custom_snackbar.dart';
import 'package:voice_first_admin/features/issue_media_format/data/models/issue_media_format_model.dart';
import 'package:voice_first_admin/features/issue_media_format/presentation/providers/issue_media_format_provider.dart';

class EditIssueMediaFormatDialog {
  static Future<void> show(
    BuildContext context,
    WidgetRef ref,
    IssueMediaFormatModel mediaFormat,
  ) async {
    final TextEditingController controller = TextEditingController(
      text: mediaFormat.issueMediaFormat,
    );
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Media Format'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Media Format',
                hintText: 'Enter media format name',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a media format';
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
                    .read(issueMediaFormatProvider.notifier)
                    .update(
                      id: mediaFormat.issueMediaFormatId,
                      issueMediaFormat: name,
                    );

                if (!context.mounted) return;

                if (result != null) {
                  // Non-null means error message from notifier
                  CustomSnackbar.show(
                    context,
                    message: result,
                    type: SnackBarType.error,
                  );
                  Navigator.of(context).pop();
                  return;
                }

                // Refresh detail view if open
                // ignore: unused_result
                ref.refresh(
                  issueMediaFormatDetailProvider(
                    mediaFormat.issueMediaFormatId,
                  ),
                );

                CustomSnackbar.show(
                  context,
                  message: 'Media format updated successfully',
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
