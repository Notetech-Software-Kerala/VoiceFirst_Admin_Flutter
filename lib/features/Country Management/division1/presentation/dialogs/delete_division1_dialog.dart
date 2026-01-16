// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:voice_first_admin/features/Business_activity/presentation/widgets/custom_snackbar.dart';
// import '../providers/division1_provider.dart';

// class DeleteDivision1Dialog extends ConsumerWidget {
//   final String divisionId;
//   final String divisionName;

//   const DeleteDivision1Dialog({
//     super.key,
//     required this.divisionId,
//     required this.divisionName,
//   });

//   static void show(
//     BuildContext context,
//     WidgetRef ref,
//     String divisionId,
//     String divisionName,
//   ) {
//     showDialog(
//       context: context,
//       builder: (_) => DeleteDivision1Dialog(
//         divisionId: divisionId,
//         divisionName: divisionName,
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final primaryColor = const Color(0xFF0D7FF2);

//     return Dialog(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       child: Padding(
//         padding: const EdgeInsets.all(24),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             // ⚠️ Icon
//             Container(
//               width: 60,
//               height: 60,
//               decoration: BoxDecoration(
//                 color: Colors.red.withOpacity(0.1),
//                 shape: BoxShape.circle,
//               ),
//               child: const Icon(
//                 Icons.warning_rounded,
//                 color: Colors.red,
//                 size: 32,
//               ),
//             ),
//             const SizedBox(height: 24),

//             // Title
//             Text(
//               'Delete Division?',
//               style: Theme.of(
//                 context,
//               ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 12),

//             // Message
//             Text(
//               'Are you sure you want to delete "$divisionName"? This action cannot be undone.',
//               textAlign: TextAlign.center,
//               style: Theme.of(
//                 context,
//               ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
//             ),
//             const SizedBox(height: 32),

//             // Buttons
//             Row(
//               children: [
//                 Expanded(
//                   child: OutlinedButton(
//                     onPressed: () => Navigator.pop(context),
//                     style: OutlinedButton.styleFrom(
//                       padding: const EdgeInsets.symmetric(vertical: 12),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                     child: const Text('Cancel'),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: ElevatedButton(
//                     onPressed: () {
//                       ref
//                           .read(division1Provider.notifier)
//                           .deleteDivision(divisionId);

//                       Navigator.pop(context);
//                       Navigator.pop(context);

//                       CustomSnackbar.show(
//                         context,
//                         message: '$divisionName deleted successfully',
//                         type: SnackBarType.success,
//                       );
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.red.shade600,
//                       padding: const EdgeInsets.symmetric(vertical: 12),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                     child: const Text(
//                       'Delete',
//                       style: TextStyle(color: Colors.white),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:voice_first_admin/features/Business_activity/presentation/widgets/custom_snackbar.dart';
// import '../providers/division_one_provider.dart';

// class DeleteDivisionOneDialog {
//   static void show(
//     BuildContext context,
//     WidgetRef ref,
//     String countryId,
//     String id,
//     String name,
//   ) {
//     showDialog(
//       context: context,
//       builder: (dialogContext) => AlertDialog(
//         title: const Text('Delete Division?'),
//         content: Text('Are you sure you want to delete "$name"?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(dialogContext),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//             onPressed: () {
//               ref.read(divisionOneProvider(countryId).notifier).delete(id);

//               Navigator.pop(dialogContext);

//               CustomSnackbar.show(
//                 context,
//                 message: '$name deleted successfully',
//                 type: SnackBarType.success,
//               );
//             },
//             child: const Text('Delete'),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/division_one_provider.dart';
import 'package:voice_first_admin/features/Business_activity/presentation/widgets/custom_snackbar.dart';

class DeleteDivision1Dialog {
  static void show({
    required BuildContext context,
    required WidgetRef ref,
    required String id,
    required String name,
    required String countryId,
    required String label,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete $label?'),
        content: Text('Are you sure you want to delete "$name"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              ref
                  .read(divisionOneProvider(countryId).notifier)
                  .delete(id);

              Navigator.pop(ctx);

              CustomSnackbar.show(
                context,
                message: '$label deleted successfully',
                type: SnackBarType.success,
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

