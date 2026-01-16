// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:voice_first_admin/features/Country%20Management/country/models/country_model.dart';
// import 'package:voice_first_admin/features/Country%20Management/division1/models/division1_model.dart';
// import '../../../country/presentation/providers/country_provider.dart';
// import '../../../country/presentation/dialogs/delete_country_dialog.dart';
// import '../../../country/presentation/dialogs/edit_country_dialog.dart';

// class Division1DetailPage extends ConsumerWidget {
//   final String divisionId;

//   const Division1DetailPage({super.key, required this.divisionId});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final state = ref.watch(countryProvider);
//     final primaryColor = const Color(0xFF0D7FF2);

//     // Get the division
//     final division = state.countries
//         .where((c) => c.id == divisionId)
//         .cast<DivisionOneModel?>()
//         .firstOrNull;

//     if (division == null) {
//       return Scaffold(
//         appBar: AppBar(
//           backgroundColor: primaryColor,
//           title: const Text(
//             'Division Details',
//             style: TextStyle(color: Colors.white),
//           ),
//         ),
//         body: const Center(child: Text('Division not found')),
//       );
//     }

//     // final d1 = (division.divisionOneLabel ?? '').trim();
//     final d2 = (division.divisionTwoLabel ?? '').trim();
//     // final d3 = (division.divisionThreeLabel ?? '').trim();

//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: primaryColor,
//         elevation: 0,
//         title: const Text(
//           'Division Details',
//           style: TextStyle(color: Colors.white),
//         ),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             // 📌 Header Section
//             Container(
//               padding: const EdgeInsets.all(24),
//               decoration: BoxDecoration(
//                 color: primaryColor.withValues(alpha: 0.08),
//                 borderRadius: const BorderRadius.only(
//                   bottomLeft: Radius.circular(24),
//                   bottomRight: Radius.circular(24),
//                 ),
//               ),
//               child: Row(
//                 children: [
//                   Container(
//                     width: 80,
//                     height: 80,
//                     decoration: BoxDecoration(
//                       color: primaryColor.withValues(alpha: 0.2),
//                       shape: BoxShape.circle,
//                     ),
//                     child: Icon(
//                       Icons.location_on,
//                       size: 40,
//                       color: primaryColor,
//                     ),
//                   ),
//                   const SizedBox(width: 20),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         // Text(
//                         //   d1,
//                         //   style: const TextStyle(
//                         //     color: Colors.black87,
//                         //     fontSize: 18,
//                         //     fontWeight: FontWeight.bold,
//                         //   ),
//                         // ),
//                         const SizedBox(height: 8),
//                         Container(
//                           padding: const EdgeInsets.symmetric(
//                             vertical: 6,
//                             horizontal: 12,
//                           ),
//                           decoration: BoxDecoration(
//                             color: division.status ?? false
//                                 ? Colors.green.withOpacity(0.2)
//                                 : Colors.red.withOpacity(0.2),
//                             borderRadius: BorderRadius.circular(20),
//                           ),
//                           child: Text(
//                             division.status ?? false ? 'Active' : 'Inactive',
//                             style: TextStyle(
//                               color: division.status ?? false
//                                   ? Colors.green
//                                   : Colors.red,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             // 📋 Details Section
//             Padding(
//               padding: const EdgeInsets.all(24),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // 🌍 Country Information
//                   _DetailSection(
//                     title: 'Country Information',
//                     primaryColor: primaryColor,
//                     children: [
//                       // _DetailItem(
//                       //   label: 'Country',
//                       //   value: division.country,
//                       //   primaryColor: primaryColor,
//                       // ),
//                       // _DetailItem(
//                       //   label: 'Country Code',
//                       //   value: division.countryCode,
//                       //   primaryColor: primaryColor,
//                       // ),
//                       // _DetailItem(
//                       //   label: 'ISO Code',
//                       //   value: division.countryIsoCode ?? 'N/A',
//                       //   primaryColor: primaryColor,
//                       // ),
//                     ],
//                   ),
//                   const SizedBox(height: 24),

//                   // 📍 Division Details
//                   _DetailSection(
//                     title: 'Division Information',
//                     primaryColor: primaryColor,
//                     children: [
//                       // _DetailItem(
//                       //   label: division.divisionOneLabel ?? 'Division 1',
//                       //   value: d1,
//                       //   primaryColor: primaryColor,
//                       // ),
//                       // if (d2.isNotEmpty) ...[
//                       //   _DetailItem(
//                       //     label: division.divisionTwoLabel ?? 'Division 2',
//                       //     value: d2,
//                       //     primaryColor: primaryColor,
//                       //   ),
//                       // ],
//                       // if (d3.isNotEmpty) ...[
//                       //   _DetailItem(
//                       //     label: division.divisionThreeLabel ?? 'Division 3',
//                       //     value: d3,
//                       //     primaryColor: primaryColor,
//                       //   ),
//                       // ],
//                     ],
//                   ),
//                   const SizedBox(height: 24),

//                   // ✅ Status Section
//                   _DetailSection(
//                     title: 'Status',
//                     primaryColor: primaryColor,
//                     children: [
//                       _DetailItem(
//                         label: 'Current Status',
//                         value: division.status ?? false ? 'Active' : 'Inactive',
//                         primaryColor: primaryColor,
//                         valueColor: division.status ?? false
//                             ? Colors.green
//                             : Colors.red,
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 32),

//                   // 🎯 Action Buttons
//                   Row(
//                     children: [
//                       // ✏️ Edit Button
//                       // Expanded(
//                       //   child: ElevatedButton.icon(
//                       //     onPressed: () =>
//                       //         // EditCountryDialog.show(context, ref, division),
//                       //     icon: const Icon(Icons.edit, color: Colors.white),
//                       //     label: const Text(
//                       //       'Edit Division',
//                       //       style: TextStyle(color: Colors.white),
//                       //     ),
//                       //     style: ElevatedButton.styleFrom(
//                       //       backgroundColor: primaryColor,
//                       //       padding: const EdgeInsets.symmetric(vertical: 14),
//                       //       shape: RoundedRectangleBorder(
//                       //         borderRadius: BorderRadius.circular(12),
//                       //       ),
//                       //     ),
//                       //   ),
//                       // ),
//                       const SizedBox(width: 12),

//                       // 🗑️ Delete Button
//                       // Expanded(
//                       //   child: ElevatedButton.icon(
//                       //     onPressed: () => DeleteCountryDialog.show(
//                       //       context,
//                       //       ref,
//                       //       division.id,
//                       //       d1,
//                       //     ),
//                       //     icon: const Icon(Icons.delete, color: Colors.white),
//                       //     label: const Text(
//                       //       'Delete Division',
//                       //       style: TextStyle(color: Colors.white),
//                       //     ),
//                       //     style: ElevatedButton.styleFrom(
//                       //       backgroundColor: Colors.red.shade600,
//                       //       padding: const EdgeInsets.symmetric(vertical: 14),
//                       //       shape: RoundedRectangleBorder(
//                       //         borderRadius: BorderRadius.circular(12),
//                       //       ),
//                       //     ),
//                       //   ),
//                       // ),
//                     ],
//                   ),
//                   const SizedBox(height: 24),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ═══════════════════════════════════════
// // 📌 Detail Section Widget
// // ═══════════════════════════════════════
// class _DetailSection extends StatelessWidget {
//   final String title;
//   final Color primaryColor;
//   final List<Widget> children;

//   const _DetailSection({
//     required this.title,
//     required this.primaryColor,
//     required this.children,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             Container(
//               width: 4,
//               height: 24,
//               decoration: BoxDecoration(
//                 color: primaryColor,
//                 borderRadius: BorderRadius.circular(2),
//               ),
//             ),
//             const SizedBox(width: 12),
//             Text(
//               title,
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w600,
//                 color: Colors.black87,
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 16),
//         Container(
//           decoration: BoxDecoration(
//             border: Border.all(color: Colors.grey.shade200),
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Column(
//             children: List.generate(
//               children.length,
//               (index) => Column(
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.all(16),
//                     child: children[index],
//                   ),
//                   if (index < children.length - 1)
//                     Divider(height: 1, color: Colors.grey.shade200),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

// // ═══════════════════════════════════════
// // 📝 Detail Item Widget
// // ═══════════════════════════════════════
// class _DetailItem extends StatelessWidget {
//   final String label;
//   final String value;
//   final Color primaryColor;
//   final Color? valueColor;

//   const _DetailItem({
//     required this.label,
//     required this.value,
//     required this.primaryColor,
//     this.valueColor,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       crossAxisAlignment: CrossAxisAlignment.center,
//       children: [
//         Expanded(
//           child: Text(
//             label,
//             style: const TextStyle(color: Colors.grey, fontSize: 14),
//           ),
//         ),
//         const SizedBox(width: 16),
//         Expanded(
//           child: Text(
//             value,
//             textAlign: TextAlign.right,
//             style: TextStyle(
//               color: valueColor ?? Colors.black87,
//               fontWeight: FontWeight.w600,
//               fontSize: 14,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
