// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:voice_first_admin/features/Business_activity/presentation/widgets/custom_snackbar.dart';
// import 'package:voice_first_admin/features/Country%20Management/division1/models/division1_model.dart';
// import '../providers/division_one_provider.dart';

// class AddDivisionOneDialog {
//   static void show(BuildContext context, WidgetRef ref, String countryId) {
//     final controller = TextEditingController();

//     showDialog(
//       context: context,
//       builder: (dialogContext) => AlertDialog(
//         title: const Text('Add Division'),
//         content: TextField(
//           controller: controller,
//           decoration: const InputDecoration(
//             labelText: 'Division Name',
//             border: OutlineInputBorder(),
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(dialogContext),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               if (controller.text.trim().isEmpty) return;

//               ref
//                   .read(divisionOneProvider(countryId).notifier)
//                   .add(
//                     DivisionOneModel(
//                       id: DateTime.now().millisecondsSinceEpoch.toString(),
//                       name: controller.text.trim(),
//                       countryId: countryId,
//                       status: true,
//                     ),
//                   );

//               Navigator.pop(dialogContext);

//               CustomSnackbar.show(
//                 context,
//                 message: 'Division added successfully',
//                 type: SnackBarType.success,
//               );
//             },
//             child: const Text('Add'),
//           ),
//         ],
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/division1_model.dart';
import '../providers/division_one_provider.dart';
import 'package:voice_first_admin/features/Business_activity/presentation/widgets/custom_snackbar.dart';

class AddDivision1Dialog {
  static void show({
    required BuildContext context,
    required WidgetRef ref,
    required String countryId,
    required String label,
  }) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Add $label'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: '$label Name',
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isEmpty) return;

              ref.read(divisionOneProvider(countryId).notifier).add(
                    DivisionOneModel(
                      id: DateTime.now()
                          .millisecondsSinceEpoch
                          .toString(),
                      countryId: countryId,
                      name: controller.text.trim(),
                      status: true,
                    ),
                  );

              Navigator.pop(ctx);

              CustomSnackbar.show(
                context,
                message: '$label added successfully',
                type: SnackBarType.success,
              );
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
