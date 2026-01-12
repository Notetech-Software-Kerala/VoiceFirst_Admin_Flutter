import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/features/Business_activity/models/business_activity_model.dart';
import '../providers/business_activity_provider.dart';
import '../widgets/business_activity_dialog.dart';
import '../widgets/custom_snackbar.dart';

class EditActivityDialog {
  static void show(
    BuildContext context,
    WidgetRef ref,
    BusinessActivity activity,
  ) {
    showDialog(
      context: context,
      builder: (context) => BusinessActivityDialog(
        activity: activity,
        onSave: (updatedActivity) {
          final notifier = ref.read(businessActivityProvider.notifier);
          notifier.update(updatedActivity);
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
