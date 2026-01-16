// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:voice_first_admin/features/Country%20Management/country/models/country_model.dart';
// import 'package:voice_first_admin/features/Country%20Management/division1/models/division1_model.dart';
// import '../providers/division1_provider.dart';

// class EditDivision1Dialog extends ConsumerStatefulWidget {
//   final DivisionOneModel division;

//   const EditDivision1Dialog({super.key, required this.division});

//   static void show(
//     BuildContext context,
//     WidgetRef ref,
//     DivisionOneModel division,
//   ) {
//     showDialog(
//       context: context,
//       builder: (_) => EditDivision1Dialog(division: division),
//     );
//   }

//   @override
//   ConsumerState<EditDivision1Dialog> createState() =>
//       _EditDivision1DialogState();
// }

// class _EditDivision1DialogState extends ConsumerState<EditDivision1Dialog> {
//   late TextEditingController _d1Controller;
//   late TextEditingController _d2Controller;
//   late TextEditingController _d3Controller;
//   late bool _status;

//   @override
//   void initState() {
//     super.initState();
//     // _d1Controller = TextEditingController(
//     //   text: widget.division.divisionOneLabel ?? '',
//     // );
//     _d2Controller = TextEditingController(
//       text: widget.division.divisionTwoLabel ?? '',
//     );
//     // _d3Controller = TextEditingController(
//     //   text: widget.division.divisionThreeLabel ?? '',
//     // );
//     _status = widget.division.status;
//   }

//   @override
//   void dispose() {
//     _d1Controller.dispose();
//     _d2Controller.dispose();
//     _d3Controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final primaryColor = const Color(0xFF0D7FF2);

//     return Dialog(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       child: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(24),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Header
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     'Edit Division',
//                     style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   IconButton(
//                     icon: const Icon(Icons.close),
//                     onPressed: () => Navigator.pop(context),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 24),

//               // Division 1 Field
//               // TextFormField(
//               //   controller: _d1Controller,
//               //   decoration: InputDecoration(
//               //     labelText: widget.division.divisionOneLabel ?? 'Division 1',
//               //     border: OutlineInputBorder(
//               //       borderRadius: BorderRadius.circular(12),
//               //     ),
//               //     prefixIcon: const Icon(Icons.location_city),
//               //   ),
//               // ),
//               const SizedBox(height: 16),

//               // Division 2 Field
//               TextFormField(
//                 controller: _d2Controller,
//                 decoration: InputDecoration(
//                   labelText:
//                       widget.division.divisionTwoLabel ??
//                       'Division 2 (Optional)',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   prefixIcon: const Icon(Icons.location_city_outlined),
//                 ),
//               ),
//               const SizedBox(height: 16),

//               // Division 3 Field
//               // TextFormField(
//               //   controller: _d3Controller,
//               //   decoration: InputDecoration(
//               //     labelText:
//               //         widget.division.divisionThreeLabel ??
//               //         'Division 3 (Optional)',
//               //     border: OutlineInputBorder(
//               //       borderRadius: BorderRadius.circular(12),
//               //     ),
//               //     prefixIcon: const Icon(Icons.location_on_outlined),
//               //   ),
//               // ),
//               const SizedBox(height: 24),

//               // Status Toggle
//               Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: primaryColor.withOpacity(0.08),
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(color: primaryColor.withOpacity(0.2)),
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Text(
//                           'Status',
//                           style: TextStyle(
//                             fontWeight: FontWeight.w600,
//                             fontSize: 14,
//                           ),
//                         ),
//                         const SizedBox(height: 4),
//                         Text(
//                           _status ? 'Active' : 'Inactive',
//                           style: TextStyle(
//                             color: _status ? Colors.green : Colors.red,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ],
//                     ),
//                     Switch(
//                       value: _status,
//                       onChanged: (val) => setState(() => _status = val),
//                       activeColor: Colors.green,
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 32),

//               // Buttons
//               Row(
//                 children: [
//                   Expanded(
//                     child: OutlinedButton(
//                       onPressed: () => Navigator.pop(context),
//                       style: OutlinedButton.styleFrom(
//                         padding: const EdgeInsets.symmetric(vertical: 12),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                       ),
//                       child: const Text('Cancel'),
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: ElevatedButton(
//                       onPressed: () {
//                         // /

//                         // ref
//                         //     .read(division1Provider.notifier)
//                         //     .updateDivision(updated);

//                         Navigator.pop(context);
//                       },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: primaryColor,
//                         padding: const EdgeInsets.symmetric(vertical: 12),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                       ),
//                       child: const Text(
//                         'Update',
//                         style: TextStyle(color: Colors.white),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:voice_first_admin/features/Business_activity/presentation/widgets/custom_snackbar.dart';
// import 'package:voice_first_admin/features/Country%20Management/division1/models/division1_model.dart';
// import '../providers/division_one_provider.dart';

// class EditDivisionOneDialog {
//   static void show(
//     BuildContext context,
//     WidgetRef ref,
//     String countryId,
//     DivisionOneModel division,
//   ) {
//     final controller = TextEditingController(text: division.name);

//     showDialog(
//       context: context,
//       useRootNavigator: false, // ✅ same fix you used earlier
//       builder: (dialogContext) => AlertDialog(
//         title: const Text('Edit Division'),
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
//               final newName = controller.text.trim();
//               if (newName.isEmpty || newName == division.name) return;

//               ref
//                   .read(divisionOneProvider(countryId).notifier)
//                   .update(division.copyWith(name: newName));

//               /// ✅ close ONLY dialog
//               Navigator.pop(dialogContext);

//               CustomSnackbar.show(
//                 context,
//                 message: 'Division updated successfully',
//                 type: SnackBarType.success,
//               );
//             },
//             child: const Text('Update'),
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

class EditDivision1Dialog {
  static void show({
    required BuildContext context,
    required WidgetRef ref,
    required DivisionOneModel division,
    required String countryId,
    required String label,
  }) {
    final controller = TextEditingController(text: division.name);

    showDialog(
      context: context,
      useRootNavigator: false,
      builder: (ctx) => AlertDialog(
        title: Text('Edit $label'),
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
              final newName = controller.text.trim();
              if (newName.isEmpty || newName == division.name) return;

              ref
                  .read(divisionOneProvider(countryId).notifier)
                  .update(
                    division.copyWith(name: newName),
                  );

              Navigator.pop(ctx);

              CustomSnackbar.show(
                context,
                message: '$label updated successfully',
                type: SnackBarType.success,
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
