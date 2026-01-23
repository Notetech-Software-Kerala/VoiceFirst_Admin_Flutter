import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/features/Business_activity/presentation/widgets/custom_snackbar.dart';
import '../providers/program_action_provider.dart';

class RecoverProgramActionDialog {
  static void show(BuildContext context, WidgetRef ref, int id, String name) {
    showDialog(
      context: context,
      useRootNavigator: false,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.restore_rounded, color: Colors.green, size: 48),
        title: const Text(
          'Recover Program Action',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Are you sure you want to recover',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[700]),
            ),
            const SizedBox(height: 8),
            Text(
              '"$name"?',
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              final error = await ref
                  .read(programActionProvider.notifier)
                  .recover(id);

              if (dialogContext.mounted) {
                Navigator.pop(dialogContext);
              }

              if (context.mounted) {
                if (error != null) {
                  CustomSnackbar.show(
                    context,
                    message: error,
                    type: SnackBarType.error,
                  );
                } else {
                  CustomSnackbar.show(
                    context,
                    message: '$name recovered successfully',
                    type: SnackBarType.success,
                  );
                }
              }
            },
            child: const Text('Recover'),
          ),
        ],
      ),
    );
  }
}
