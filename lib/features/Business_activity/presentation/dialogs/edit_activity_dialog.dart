import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/features/Business_activity/models/business_activity_model.dart';
import '../providers/business_activity_provider.dart';
import '../widgets/business_activity_dialog.dart';
import '../widgets/custom_snackbar.dart';

// class EditActivityDialog {
//   static void show(
//     BuildContext context,
//     WidgetRef ref,
//     BusinessActivity activity,
//   ) {
//     showDialog(
//       context: context,
//       builder: (dialogContext) => BusinessActivityDialog(
//         activity: activity,
//         onSave: (updatedActivity) async {
//           final notifier = ref.read(businessActivityProvider.notifier);
//           notifier.update(updatedActivity.copyWith(id: activity.id));

//           // Only pop the dialog, NOT the detail page
//           if (context.mounted) {
//             Navigator.pop(context); // Closes only the dialog
//           }

//           CustomSnackbar.show(
//             context,
//             message: '${updatedActivity.activityName} updated successfully',
//             type: SnackBarType.success,
//           );
//         },
//       ),
//     );
//   }
// }

class EditActivityDialog {
  static void show(
    BuildContext context,
    WidgetRef ref,
    BusinessActivity activity,
  ) {
    showDialog(
      context: context,
      useRootNavigator: false, // ✅ ADD THIS
      builder: (dialogContext) => BusinessActivityDialog(
        activity: activity,
        onSave: (updatedActivity) {
          ref
              .read(businessActivityProvider.notifier)
              .update(updatedActivity.copyWith(id: activity.id));

          /// ✅ closes ONLY dialog
          Navigator.of(dialogContext).pop();

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
