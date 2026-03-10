import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/core/widgets/custom_snackbar.dart';
import 'package:voice_first_admin/features/issue_media_type/data/models/issue_media_type_model.dart';
import 'package:voice_first_admin/features/issue_media_type/presentation/providers/issue_media_type_provider.dart';

class EditIssueMediaTypeDialog {
  static Future<void> show(
    BuildContext context,
    WidgetRef ref,
    IssueMediaTypeModel mediaType,
  ) async {
    final TextEditingController controller = TextEditingController(
      text: mediaType.issueMediaType,
    );
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Media Type'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Media Type',
                hintText: 'Enter media type name',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a media type';
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
                    .read(issueMediaTypeProvider.notifier)
                    .update(
                      id: mediaType.issueMediaTypeId,
                      issueMediaType: name,
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

                ref.refresh(
                  issueMediaTypeDetailProvider(mediaType.issueMediaTypeId),
                );

                CustomSnackbar.show(
                  context,
                  message: 'Media type updated successfully',
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
