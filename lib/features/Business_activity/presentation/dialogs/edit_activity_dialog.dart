import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/features/Business_activity/models/business_activity_model.dart';
import '../providers/business_activity_provider.dart';
import '../widgets/business_activity_dialog.dart';
import '../../../../core/widgets/custom_snackbar.dart';

class EditActivityDialog {
  static void show(
    BuildContext context,
    WidgetRef ref,
    BusinessActivity activity,
  ) {
    showDialog(
      context: context,
      useRootNavigator: false,
      builder: (dialogContext) => BusinessActivityDialog(
        activity: activity,
        onSave: (updatedActivity) async {
          final error = await ref
              .read(businessActivityProvider.notifier)
              .update(
                id: activity.activityId,
                activityName: updatedActivity.activityName,
              );

          if (error != null) {
            // Show error snackbar
            if (dialogContext.mounted) {
              CustomSnackbar.show(
                context,
                message: error,
                type: SnackBarType.error,
              );
            }
            return;
          }

          ///  closes ONLY dialog
          if (dialogContext.mounted) {
            Navigator.of(dialogContext).pop();
          }

          CustomSnackbar.show(
            context,
            message: '${updatedActivity.activityName} updated successfully',
            type: SnackBarType.success,
          );
        },
      ),
    );
  }
}
