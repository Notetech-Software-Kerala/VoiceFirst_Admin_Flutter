import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/core/widgets/custom_snackbar.dart';
import 'package:voice_first_admin/features/issue_media_type/presentation/providers/issue_media_type_provider.dart';

class AddIssueMediaTypeDialog {
  static Future<void> show(BuildContext context, WidgetRef ref) async {
    final TextEditingController controller = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Media Type'),
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
                try {
                  final message = await ref
                      .read(issueMediaTypeProvider.notifier)
                      .add(name);

                  if (!context.mounted) return;

                  CustomSnackbar.show(
                    context,
                    message: message,
                    type: SnackBarType.success,
                  );
                  Navigator.of(context).pop();
                } catch (e) {
                  if (!context.mounted) return;

                  CustomSnackbar.show(
                    context,
                    message: e.toString().replaceFirst('Exception: ', ''),
                    type: SnackBarType.error,
                  );
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}
