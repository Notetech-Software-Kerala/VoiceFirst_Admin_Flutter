import 'package:flutter/cupertino.dart';

Future<bool?> showCupertinoDeleteConfirmationDialog(
  BuildContext context, {
  required String title,
  required String message,
}) {
  return showCupertinoDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return CupertinoAlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(false),
            isDefaultAction: true,
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(true),
            isDestructiveAction: true,
            child: const Text('Delete'),
          ),
        ],
      );
    },
  );
}
