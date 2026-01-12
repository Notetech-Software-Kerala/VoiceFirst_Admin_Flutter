import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/features/Business_activity/models/business_activity_model.dart';
import '../providers/business_activity_provider.dart';
import '../widgets/business_activity_dialog.dart';
import '../widgets/custom_snackbar.dart';

class AddActivityDialog {
  static void show(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => BusinessActivityDialog(
        activity: null,
        onSave: (newActivity) {
          final notifier = ref.read(businessActivityProvider.notifier);
          notifier.add(newActivity);
          CustomSnackbar.show(
            context,
            message: '${newActivity.activityName} added successfully',
            type: SnackBarType.success,
          );
        },
      ),
    );
  }
}
