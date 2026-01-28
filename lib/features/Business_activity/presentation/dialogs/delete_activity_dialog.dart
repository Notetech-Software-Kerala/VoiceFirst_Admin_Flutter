import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/business_activity_provider.dart';
import '../widgets/custom_snackbar.dart';

class DeleteActivityDialog {
  static void show(BuildContext context, WidgetRef ref, int id, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Activity?'),
        content: Text('Are you sure you want to delete "$name"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(businessActivityProvider.notifier).delete(id);
              Navigator.pop(context);
              CustomSnackbar.show(
                context,
                message: '$name deleted successfully',
                type: SnackBarType.success,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// import 'package:flutter/cupertino.dart';

// Future<bool?> showCupertinoDeleteConfirmationDialog(
//   BuildContext context, {
//   required String title,
//   required String message,
// }) {
//   return showCupertinoDialog<bool>(
//     context: context,
//     barrierDismissible: false,
//     builder: (context) {
//       return CupertinoAlertDialog(
//         title: Text(title),
//         content: Text(message),
//         actions: [
//           CupertinoDialogAction(
//             onPressed: () => Navigator.of(context).pop(false),
//             isDefaultAction: true,
//             child: const Text('Cancel'),
//           ),
//           CupertinoDialogAction(
//             onPressed: () => Navigator.of(context).pop(true),
//             isDestructiveAction: true,
//             child: const Text('Delete'),
//           ),
//         ],
//       );
//     },
//   );
// }
