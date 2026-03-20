// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:voice_first_admin/core/widgets/delete_bottom_sheet.dart';
// import 'package:voice_first_admin/core/widgets/recovery_bottom_sheet.dart';
// import 'package:voice_first_admin/core/widgets/standard_detail_page_buttons.dart';
// import 'package:voice_first_admin/features/Business_activity/models/business_activity_model.dart';
// import 'package:voice_first_admin/features/Business_activity/presentation/pages/edit_activity_page.dart';
// import '../providers/business_activity_provider.dart';
// import '../../../../core/widgets/custom_snackbar.dart';

// class ActivityDetailPage extends ConsumerWidget {
//   final int activityId;

//   const ActivityDetailPage({super.key, required this.activityId});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final theme = Theme.of(context);
//     final cs = theme.colorScheme;

//     final activityAsync = ref.watch(businessActivityByIdProvider(activityId));

//     return activityAsync.when(
//       loading: () =>
//           const Scaffold(body: Center(child: CircularProgressIndicator())),
//       error: (err, stack) => Scaffold(
//         appBar: AppBar(title: const Text('Activity Details')),
//         body: Center(child: Text('Failed to load activity: $err')),
//       ),
//       data: (updatedActivity) {
//         final isDeleted = updatedActivity.isDeleted;
//         return Scaffold(
//           backgroundColor: theme.scaffoldBackgroundColor,
//           appBar: AppBar(
//             title: const Text('Activity Details'),
//             elevation: 0,
//             leading: const BackButton(),
//             toolbarHeight: kToolbarHeight,
//           ),
//           body: Stack(
//             children: [
//               ListView(
//                 padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
//                 children: [
//                   // PRIMARY INFO CARD
//                   Container(
//                     padding: const EdgeInsets.all(16),
//                     decoration: BoxDecoration(
//                       color: theme.cardColor,
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         // Activity Name Row
//                         Row(
//                           crossAxisAlignment: CrossAxisAlignment.center,
//                           children: [
//                             const Expanded(child: _Label('ACTIVITY NAME')),
//                             const SizedBox(width: 12),
//                             Text(
//                               updatedActivity.activityName,
//                               overflow: TextOverflow.ellipsis,
//                               style: const TextStyle(
//                                 fontSize: 20,
//                                 fontWeight: FontWeight.w700,
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 16),
//                         // Status Row
//                         Row(
//                           crossAxisAlignment: CrossAxisAlignment.center,
//                           children: [
//                             const Expanded(child: _Label('STATUS')),
//                             const SizedBox(width: 12),
//                             Text(
//                               isDeleted
//                                   ? 'Deleted'
//                                   : (updatedActivity.active
//                                         ? 'Active'
//                                         : 'Suspended'),
//                               style: TextStyle(
//                                 fontWeight: FontWeight.w700,
//                                 color: isDeleted
//                                     ? Colors.red
//                                     : (updatedActivity.active
//                                           ? const Color.fromARGB(255, 40, 21, 135)
//                                           : Colors.orange),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),

//                   const SizedBox(height: 20),

//                   /// CUSTOM FIELDS (only if exist)
//                   if ((updatedActivity.activityCustomFields ?? [])
//                       .isNotEmpty) ...[
//                     const SizedBox(height: 20),

//                     Container(
//                       padding: const EdgeInsets.all(16),
//                       decoration: BoxDecoration(
//                         color: theme.cardColor,
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const _Label('CUSTOM FIELDS'),
//                           const SizedBox(height: 12),

//                           Wrap(
//                             spacing: 8,
//                             runSpacing: 8,
//                             children: updatedActivity.activityCustomFields!
//                                 .where((f) => f.active)
//                                 .map((f) => Chip(label: Text(f.fieldName)))
//                                 .toList(),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],

//                   const SizedBox(height: 20),

//                   // HISTORY (Created/Modified [+ Deleted if deleted])
//                   _HistorySection(
//                     activity: updatedActivity,
//                     isDeleted: isDeleted,
//                     formatDate: _format,
//                   ),
//                 ],
//               ),

//               // STICKY FOOTER ACTIONS
//               Positioned(
//                 bottom: 0,
//                 left: 0,
//                 right: 0,
//                 child: Container(
//                   padding: const EdgeInsets.fromLTRB(16, 16, 16, 26),
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       begin: Alignment.bottomCenter,
//                       end: Alignment.topCenter,
//                       colors: [
//                         theme.scaffoldBackgroundColor,
//                         theme.scaffoldBackgroundColor.withAlpha(100),
//                         theme.scaffoldBackgroundColor.withAlpha(0),
//                       ],
//                     ),
//                   ),
//                   child: Row(
//                     children: [
//                       if (isDeleted)
//                         Expanded(
//                           child: StandardRecoveryButton(
//                             label: 'Recover',
//                             onPressed: () => showRecoveryBottomSheet(
//                               context: context,
//                               itemName: updatedActivity.activityName,
//                               onRecover: () async {
//                                 // final error = await ref
//                                 //     .read(businessActivityProvider.notifier)
//                                 //     .recover(updatedActivity.activityId);
//                                 final error = await ref
//                                     .read(businessActivityProvider.notifier)
//                                     .recover(updatedActivity.activityId);

//                                 if (error == null) {
//                                   ref.invalidate(
//                                     businessActivityByIdProvider(activityId),
//                                   );
//                                 }
//                                 if (error == null) {
//                                   CustomSnackbar.show(
//                                     context,
//                                     message:
//                                         '${updatedActivity.activityName} recovered successfully',
//                                     type: SnackBarType.success,
//                                   );
//                                 } else {
//                                   CustomSnackbar.show(
//                                     context,
//                                     message: error,
//                                     type: SnackBarType.error,
//                                   );
//                                 }
//                               },
//                             ),
//                           ),
//                         )
//                       else ...[
//                         // Expanded(
//                         //   child: StandardEditButton(
//                         //     label: 'Edit',
//                         //     onPressed: () {
//                         //       Navigator.push(
//                         //         context,
//                         //         MaterialPageRoute(
//                         //           builder: (_) => EditActivityPage(
//                         //             activity: updatedActivity,
//                         //           ),
//                         //         ),
//                         //       );
//                         //     },
//                         //   ),
//                         // ),
//                         Expanded(
//                           child: StandardEditButton(
//                             label: 'Edit',
//                             onPressed: () async {
//                               await Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (_) => EditActivityPage(
//                                     activity: updatedActivity,
//                                   ),
//                                 ),
//                               );
//                               ref.invalidate(
//                                 businessActivityByIdProvider(activityId),
//                               );
//                             },
//                           ),
//                         ),
//                         const SizedBox(width: 12),
//                         Expanded(
//                           child: StandardDeleteButton(
//                             label: 'Delete',
//                             onPressed: () => showDeleteBottomSheet(
//                               context: context,
//                               itemName: updatedActivity.activityName,
//                               onDelete: () async {
//                                 // final error = await ref
//                                 //     .read(businessActivityProvider.notifier)
//                                 //     .delete(updatedActivity.activityId);
//                                 final error = await ref
//                                     .read(businessActivityProvider.notifier)
//                                     .delete(updatedActivity.activityId);

//                                 if (error == null) {
//                                   ref.invalidate(
//                                     businessActivityByIdProvider(activityId),
//                                   );
//                                 }
//                                 if (error == null) {
//                                   CustomSnackbar.show(
//                                     context,
//                                     message:
//                                         '${updatedActivity.activityName} deleted successfully',
//                                     type: SnackBarType.success,
//                                   );
//                                 } else {
//                                   CustomSnackbar.show(
//                                     context,
//                                     message: error,
//                                     type: SnackBarType.error,
//                                   );
//                                 }
//                               },
//                             ),
//                           ),
//                         ),
//                       ],
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   String _format(DateTime dt) {
//     return '${dt.day.toString().padLeft(2, '0')}/'
//         '${dt.month.toString().padLeft(2, '0')}/'
//         '${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
//   }
// }

// // ───────────────── UI HELPERS ─────────────────

// class _Label extends StatelessWidget {
//   final String text;
//   const _Label(this.text);

//   @override
//   Widget build(BuildContext context) {
//     return Text(
//       text,
//       style: const TextStyle(
//         fontSize: 14,
//         letterSpacing: 1.2,
//         fontWeight: FontWeight.bold,
//       ),
//     );
//   }
// }

// class _HistorySection extends StatelessWidget {
//   final BusinessActivity activity;
//   final bool isDeleted;
//   final String Function(DateTime) formatDate;

//   const _HistorySection({
//     required this.activity,
//     required this.isDeleted,
//     required this.formatDate,
//   });

//   @override
//   Widget build(BuildContext context) {
//     String formatUser(String? value, {String fallback = 'N/A'}) {
//       if (value == null || value.trim().isEmpty) return fallback;
//       return value;
//     }

//     String formatDateSafe(DateTime? value, {String fallback = 'N/A'}) {
//       if (value == null) return fallback;
//       return formatDate(value);
//     }

//     return Column(
//       children: [
//         _HistoryExpansionTile(
//           icon: Icons.flag_circle_outlined,
//           title: 'Created Info',
//           subtitle:
//               'Created by ${formatUser(activity.createdUser, fallback: 'Unknown')}',
//           initiallyExpanded: true,
//           entries: [
//             _HistoryEntry(
//               label: 'Created By',
//               value: formatUser(activity.createdUser, fallback: 'Unknown'),
//             ),
//             _HistoryEntry(
//               label: 'Created Date',
//               value: formatDateSafe(activity.createdDate),
//             ),
//           ],
//         ),
//         if (activity.modifiedUser != null || activity.modifiedDate != null)
//           _HistoryExpansionTile(
//             icon: Icons.history,
//             title: 'Modified Info',
//             subtitle:
//                 'Modified by ${formatUser(activity.modifiedUser, fallback: 'Not modified')}',
//             initiallyExpanded:
//                 !isDeleted &&
//                 (activity.modifiedUser != null ||
//                     activity.modifiedDate != null),
//             entries: [
//               _HistoryEntry(
//                 label: 'Modified By',
//                 value: formatUser(
//                   activity.modifiedUser,
//                   fallback: 'Not modified',
//                 ),
//               ),
//               _HistoryEntry(
//                 label: 'Modified Date',
//                 value: formatDateSafe(
//                   activity.modifiedDate,
//                   fallback: 'Not modified',
//                 ),
//               ),
//             ],
//           ),
//         if (isDeleted)
//           _HistoryExpansionTile(
//             icon: Icons.delete_forever_outlined,
//             title: 'Deleted Info',
//             subtitle:
//                 'Deleted by ${formatUser(activity.deletedUser, fallback: 'Unknown')}',
//             initiallyExpanded: true,
//             entries: [
//               _HistoryEntry(
//                 label: 'Deleted By',
//                 value: formatUser(activity.deletedUser, fallback: 'Unknown'),
//               ),
//               _HistoryEntry(
//                 label: 'Deleted Date',
//                 value: formatDateSafe(activity.deletedDate, fallback: 'N/A'),
//               ),
//             ],
//           ),
//       ],
//     );
//   }
// }

// class _HistoryExpansionTile extends StatelessWidget {
//   final IconData icon;
//   final String title;
//   final String subtitle;
//   final List<_HistoryEntry> entries;
//   final bool initiallyExpanded;

//   const _HistoryExpansionTile({
//     required this.icon,
//     required this.title,
//     required this.subtitle,
//     required this.entries,
//     this.initiallyExpanded = false,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       decoration: BoxDecoration(
//         color: theme.cardColor,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: theme.dividerColor),
//       ),
//       child: Theme(
//         data: theme.copyWith(dividerColor: Colors.transparent),
//         child: ExpansionTile(
//           initiallyExpanded: initiallyExpanded,
//           tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
//           childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
//           leading: Icon(icon, color: theme.colorScheme.primary),
//           title: Text(
//             title,
//             style: const TextStyle(fontWeight: FontWeight.w600),
//           ),
//           subtitle: Text(subtitle, style: theme.textTheme.bodySmall),
//           children: [
//             GridView.builder(
//               shrinkWrap: true,
//               physics: const NeverScrollableScrollPhysics(),
//               itemCount: entries.length,
//               gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 2,
//                 mainAxisSpacing: 12,
//                 crossAxisSpacing: 12,
//                 childAspectRatio: 2.4,
//               ),
//               itemBuilder: (context, index) =>
//                   _HistoryChip(entry: entries[index]),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _HistoryEntry {
//   final String label;
//   final String value;
//   const _HistoryEntry({required this.label, required this.value});
// }

// class _HistoryChip extends StatelessWidget {
//   final _HistoryEntry entry;
//   const _HistoryChip({required this.entry});

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final isDark = theme.brightness == Brightness.dark;
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: isDark
//             ? theme.cardColor.withAlpha(153)
//             : const Color(0xFFF8FAFC),
//         borderRadius: BorderRadius.circular(10),
//         border: Border.all(color: theme.dividerColor.withAlpha(153)),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Text(
//             entry.label.toUpperCase(),
//             style: TextStyle(
//               fontSize: 10,
//               fontWeight: FontWeight.bold,
//               letterSpacing: 0.6,
//               color: theme.hintColor,
//             ),
//           ),
//           const SizedBox(height: 4),
//           Text(
//             entry.value,
//             maxLines: 2,
//             overflow: TextOverflow.ellipsis,
//             style: const TextStyle(fontWeight: FontWeight.w600),
//           ),
//         ],
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:voice_first_admin/core/widgets/delete_bottom_sheet.dart';
// import 'package:voice_first_admin/core/widgets/recovery_bottom_sheet.dart';
// import 'package:voice_first_admin/core/widgets/standard_detail_page_buttons.dart';
// import 'package:voice_first_admin/core/widgets/custom_snackbar.dart';
// import 'package:voice_first_admin/features/Business_activity/models/business_activity_model.dart';
// import 'package:voice_first_admin/features/Business_activity/presentation/providers/business_activity_provider.dart';
// import 'edit_activity_page.dart';

// class ActivityDetailPage extends ConsumerWidget {
//   final BusinessActivity activity;

//   const ActivityDetailPage({super.key, required this.activity});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final theme = Theme.of(context);

//     final state = ref.watch(businessActivityProvider);

//     final updatedActivity = state.items.firstWhere(
//       (a) => a.activityId == activity.activityId,
//       orElse: () => activity,
//     );

//     final isDeleted = updatedActivity.isDeleted;

//     final customFields =
//         updatedActivity.activityCustomFields?.where((f) => f.active).toList() ??
//             [];

//     return Scaffold(
//       backgroundColor: theme.scaffoldBackgroundColor,
//       appBar: AppBar(
//         title: const Text('Activity Details'),
//         elevation: 0,
//         leading: const BackButton(),
//       ),
//       body: Stack(
//         children: [
//           ListView(
//             padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
//             children: [
//               /// PRIMARY INFO CARD
//               Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: theme.cardColor,
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(color: theme.dividerColor),
//                 ),
//                 child: Column(
//                   children: [
//                     _infoRow("Activity Name", updatedActivity.activityName),

//                     const SizedBox(height: 12),

//                     _infoRow(
//                       "Status",
//                       isDeleted
//                           ? "Deleted"
//                           : (updatedActivity.active ? "Active" : "Suspended"),
//                       valueColor: isDeleted
//                           ? Colors.red
//                           : (updatedActivity.active
//                               ? Colors.green
//                               : Colors.orange),
//                     ),
//                   ],
//                 ),
//               ),

//               const SizedBox(height: 20),

//               /// CUSTOM FIELDS
//               if (customFields.isNotEmpty) ...[
//                 _sectionTitle(context, "CUSTOM FIELDS"),
//                 const SizedBox(height: 8),

//                 Container(
//                   padding: const EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     color: theme.cardColor,
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(color: theme.dividerColor),
//                   ),
//                   child: Wrap(
//                     spacing: 8,
//                     runSpacing: 8,
//                     children: customFields
//                         .map(
//                           (f) => Chip(
//                             label: Text(f.fieldName),
//                             backgroundColor:
//                                 theme.colorScheme.primary.withOpacity(0.1),
//                           ),
//                         )
//                         .toList(),
//                   ),
//                 ),

//                 const SizedBox(height: 20),
//               ],

//               /// HISTORY
//               _sectionTitle(context, "HISTORY"),

//               const SizedBox(height: 8),

//               _historyCard(
//                 context,
//                 icon: Icons.flag_circle_outlined,
//                 title: "Created",
//                 user: updatedActivity.createdUser,
//                 date: updatedActivity.createdDate,
//               ),

//               _historyCard(
//                 context,
//                 icon: Icons.history,
//                 title: "Modified",
//                 user: updatedActivity.modifiedUser,
//                 date: updatedActivity.modifiedDate,
//               ),

//               if (isDeleted)
//                 _historyCard(
//                   context,
//                   icon: Icons.delete_forever_outlined,
//                   title: "Deleted",
//                   user: updatedActivity.deletedUser,
//                   date: updatedActivity.deletedDate,
//                 ),
//             ],
//           ),

//           /// ACTION BUTTONS
//           Positioned(
//             bottom: 0,
//             left: 0,
//             right: 0,
//             child: Container(
//               padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
//               decoration: BoxDecoration(
//                 color: theme.scaffoldBackgroundColor,
//               ),
//               child: Row(
//                 children: [
//                   if (isDeleted)
//                     Expanded(
//                       child: StandardRecoveryButton(
//                         label: "Recover",
//                         onPressed: () => showRecoveryBottomSheet(
//                           context: context,
//                           itemName: updatedActivity.activityName,
//                           onRecover: () async {
//                             final error = await ref
//                                 .read(businessActivityProvider.notifier)
//                                 .recover(updatedActivity.activityId);

//                             if (error == null) {
//                               CustomSnackbar.show(
//                                 context,
//                                 message: "Activity recovered successfully",
//                                 type: SnackBarType.success,
//                               );
//                             }
//                           },
//                         ),
//                       ),
//                     )
//                   else ...[
//                     Expanded(
//                       child: StandardEditButton(
//                         label: "Edit",
//                         onPressed: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (_) =>
//                                   EditActivityPage(activity: updatedActivity),
//                             ),
//                           );
//                         },
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: StandardDeleteButton(
//                         label: "Delete",
//                         onPressed: () => showDeleteBottomSheet(
//                           context: context,
//                           itemName: updatedActivity.activityName,
//                           onDelete: () async {
//                             final error = await ref
//                                 .read(businessActivityProvider.notifier)
//                                 .delete(updatedActivity.activityId);

//                             if (error == null) {
//                               CustomSnackbar.show(
//                                 context,
//                                 message: "Activity deleted successfully",
//                                 type: SnackBarType.success,
//                               );
//                             }
//                           },
//                         ),
//                       ),
//                     ),
//                   ],
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _sectionTitle(BuildContext context, String text) {
//     final theme = Theme.of(context);

//     return Text(
//       text,
//       style: TextStyle(
//         fontSize: 12,
//         letterSpacing: 1.5,
//         fontWeight: FontWeight.bold,
//         color: theme.hintColor,
//       ),
//     );
//   }

//   Widget _infoRow(String label, String value, {Color? valueColor}) {
//     return Row(
//       children: [
//         Expanded(
//           child: Text(
//             label.toUpperCase(),
//             style: const TextStyle(
//               fontSize: 13,
//               fontWeight: FontWeight.bold,
//               letterSpacing: 1.2,
//             ),
//           ),
//         ),
//         Text(
//           value,
//           style: TextStyle(
//             fontWeight: FontWeight.w700,
//             color: valueColor,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _historyCard(
//     BuildContext context, {
//     required IconData icon,
//     required String title,
//     String? user,
//     DateTime? date,
//   }) {
//     final theme = Theme.of(context);

//     String formatDate(DateTime? dt) {
//       if (dt == null) return "N/A";
//       return "${dt.day.toString().padLeft(2, '0')}/"
//           "${dt.month.toString().padLeft(2, '0')}/"
//           "${dt.year}";
//     }

//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: theme.cardColor,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: theme.dividerColor),
//       ),
//       child: Row(
//         children: [
//           Icon(icon, color: theme.colorScheme.primary),

//           const SizedBox(width: 12),

//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
//                 const SizedBox(height: 4),
//                 Text(user?.trim().isEmpty ?? true ? "N/A" : user!),
//               ],
//             ),
//           ),

//           Text(formatDate(date)),
//         ],
//       ),
//     );
//   }
// }
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:voice_first_admin/core/widgets/delete_bottom_sheet.dart';
// import 'package:voice_first_admin/core/widgets/recovery_bottom_sheet.dart';
// import 'package:voice_first_admin/core/widgets/standard_detail_page_buttons.dart';
// import 'package:voice_first_admin/features/Business_activity/models/business_activity_model.dart';
// import 'package:voice_first_admin/features/Business_activity/presentation/pages/edit_activity_page.dart';
// import '../providers/business_activity_provider.dart';
// import '../../../../core/widgets/custom_snackbar.dart';

// class ActivityDetailPage extends ConsumerWidget {
//   final int activityId;

//   const ActivityDetailPage({super.key, required this.activityId});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final theme = Theme.of(context);

//     final activityAsync = ref.watch(businessActivityByIdProvider(activityId));

//     return activityAsync.when(
//       loading: () =>
//           const Scaffold(body: Center(child: CircularProgressIndicator())),
//       error: (err, stack) => Scaffold(
//         appBar: AppBar(title: const Text('Activity Details')),
//         body: Center(child: Text('Failed to load activity: $err')),
//       ),
//       data: (activity) {
//         final isDeleted = activity.isDeleted;

//         return Scaffold(
//           appBar: AppBar(
//             title: const Text("Activity Details"),
//             elevation: 0,
//             leading: const BackButton(),
//           ),
//           body: Stack(
//             children: [
//               ListView(
//                 padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
//                 children: [
//                   _Card(
//                     child: Column(
//                       children: [
//                         _PropertyRow(
//                           label: "Activity Name",
//                           value: activity.activityName,
//                           large: true,
//                         ),
//                         const Divider(),
//                         _PropertyRow(
//                           label: "Status",
//                           value: isDeleted
//                               ? "Deleted"
//                               : (activity.active ? "Active" : "Suspended"),
//                           valueColor: isDeleted
//                               ? Colors.red
//                               : (activity.active
//                                   ? Colors.green
//                                   : Colors.orange),
//                         ),
//                       ],
//                     ),
//                   ),

//                   const SizedBox(height: 16),

//                   /// CUSTOM FIELDS
//                   if ((activity.activityCustomFields ?? []).isNotEmpty)
//                     _Card(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const _SectionTitle("Custom Fields"),
//                           const SizedBox(height: 8),
//                           ...activity.activityCustomFields!
//                               .where((f) => f.active)
//                               .map(
//                                 (f) => _PropertyRow(
//                                   label: f.fieldName,
//                                   value: f.fieldDataType ?? "Text",
//                                 ),
//                               ),
//                         ],
//                       ),
//                     ),

//                   const SizedBox(height: 16),

//                   /// CREATED INFO
//                   _Card(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const _SectionTitle("Created Info"),
//                         const SizedBox(height: 8),
//                         _PropertyRow(
//                           label: "Created By",
//                           value: activity.createdUser ?? "Unknown",
//                         ),
//                         _PropertyRow(
//                           label: "Created Date",
//                           value: _format(activity.createdDate),
//                         ),
//                       ],
//                     ),
//                   ),

//                   const SizedBox(height: 16),

//                   /// MODIFIED INFO
//                   if (activity.modifiedUser != null ||
//                       activity.modifiedDate != null)
//                     _Card(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const _SectionTitle("Modified Info"),
//                           const SizedBox(height: 8),
//                           _PropertyRow(
//                             label: "Modified By",
//                             value: activity.modifiedUser ?? "Not Modified",
//                           ),
//                           _PropertyRow(
//                             label: "Modified Date",
//                             value: activity.modifiedDate != null
//                                 ? _format(activity.modifiedDate!)
//                                 : "Not Modified",
//                           ),
//                         ],
//                       ),
//                     ),

//                   const SizedBox(height: 16),

//                   /// DELETED INFO
//                   if (isDeleted)
//                     _Card(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const _SectionTitle("Deleted Info"),
//                           const SizedBox(height: 8),
//                           _PropertyRow(
//                             label: "Deleted By",
//                             value: activity.deletedUser ?? "Unknown",
//                           ),
//                           _PropertyRow(
//                             label: "Deleted Date",
//                             value: activity.deletedDate != null
//                                 ? _format(activity.deletedDate!)
//                                 : "N/A",
//                           ),
//                         ],
//                       ),
//                     ),
//                 ],
//               ),

//               /// STICKY FOOTER
//               Positioned(
//                 bottom: 0,
//                 left: 0,
//                 right: 0,
//                 child: Container(
//                   padding: const EdgeInsets.fromLTRB(16, 16, 16, 26),
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       begin: Alignment.bottomCenter,
//                       end: Alignment.topCenter,
//                       colors: [
//                         theme.scaffoldBackgroundColor,
//                         theme.scaffoldBackgroundColor.withAlpha(100),
//                         theme.scaffoldBackgroundColor.withAlpha(0),
//                       ],
//                     ),
//                   ),
//                   child: Row(
//                     children: [
//                       if (isDeleted)
//                         Expanded(
//                           child: StandardRecoveryButton(
//                             label: "Recover",
//                             onPressed: () => showRecoveryBottomSheet(
//                               context: context,
//                               itemName: activity.activityName,
//                               onRecover: () async {
//                                 final error = await ref
//                                     .read(businessActivityProvider.notifier)
//                                     .recover(activity.activityId);

//                                 if (error == null) {
//                                   ref.invalidate(
//                                       businessActivityByIdProvider(activityId));
//                                   CustomSnackbar.show(
//                                     context,
//                                     message:
//                                         "${activity.activityName} recovered successfully",
//                                     type: SnackBarType.success,
//                                   );
//                                 } else {
//                                   CustomSnackbar.show(
//                                     context,
//                                     message: error,
//                                     type: SnackBarType.error,
//                                   );
//                                 }
//                               },
//                             ),
//                           ),
//                         )
//                       else ...[
//                         Expanded(
//                           child: StandardEditButton(
//                             label: "Edit",
//                             onPressed: () async {
//                               await Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (_) =>
//                                       EditActivityPage(activity: activity),
//                                 ),
//                               );
//                               ref.invalidate(
//                                   businessActivityByIdProvider(activityId));
//                             },
//                           ),
//                         ),
//                         const SizedBox(width: 12),
//                         Expanded(
//                           child: StandardDeleteButton(
//                             label: "Delete",
//                             onPressed: () => showDeleteBottomSheet(
//                               context: context,
//                               itemName: activity.activityName,
//                               onDelete: () async {
//                                 final error = await ref
//                                     .read(businessActivityProvider.notifier)
//                                     .delete(activity.activityId);

//                                 if (error == null) {
//                                   ref.invalidate(
//                                       businessActivityByIdProvider(activityId));

//                                   CustomSnackbar.show(
//                                     context,
//                                     message:
//                                         "${activity.activityName} deleted successfully",
//                                     type: SnackBarType.success,
//                                   );
//                                 } else {
//                                   CustomSnackbar.show(
//                                     context,
//                                     message: error,
//                                     type: SnackBarType.error,
//                                   );
//                                 }
//                               },
//                             ),
//                           ),
//                         ),
//                       ],
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   static String _format(DateTime dt) {
//     return '${dt.day.toString().padLeft(2, '0')}/'
//         '${dt.month.toString().padLeft(2, '0')}/'
//         '${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
//   }
// }

// /// CARD

// class _Card extends StatelessWidget {
//   final Widget child;

//   const _Card({required this.child});

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: theme.cardColor,
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: child,
//     );
//   }
// }

// /// PROPERTY ROW (ENTERPRISE STYLE)

// class _PropertyRow extends StatelessWidget {
//   final String label;
//   final String value;
//   final bool large;
//   final Color? valueColor;

//   const _PropertyRow({
//     required this.label,
//     required this.value,
//     this.large = false,
//     this.valueColor,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       child: Row(
//         children: [
//           Expanded(
//             flex: 4,
//             child: Text(
//               label.toUpperCase(),
//               style: theme.textTheme.bodySmall?.copyWith(
//                 letterSpacing: 1,
//                 fontWeight: FontWeight.w600,
//                 color: theme.hintColor,
//               ),
//             ),
//           ),
//           Expanded(
//             flex: 6,
//             child: Text(
//               value,
//               textAlign: TextAlign.right,
//               style: TextStyle(
//                 fontSize: large ? 20 : 16,
//                 fontWeight: large ? FontWeight.w700 : FontWeight.w600,
//                 color: valueColor ?? theme.textTheme.bodyLarge?.color,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _SectionTitle extends StatelessWidget {
//   final String title;

//   const _SectionTitle(this.title);

//   @override
//   Widget build(BuildContext context) {
//     return Text(
//       title.toUpperCase(),
//       style: const TextStyle(
//         fontSize: 13,
//         letterSpacing: 1.2,
//         fontWeight: FontWeight.bold,
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/core/widgets/delete_bottom_sheet.dart';
import 'package:voice_first_admin/core/widgets/recovery_bottom_sheet.dart';
import 'package:voice_first_admin/core/widgets/standard_detail_page_buttons.dart';
import 'package:voice_first_admin/features/Business_activity/models/business_activity_model.dart';
import 'package:voice_first_admin/features/Business_activity/presentation/pages/edit_activity_page.dart';
import '../providers/business_activity_provider.dart';
import '../../../../core/widgets/custom_snackbar.dart';

class ActivityDetailPage extends ConsumerWidget {
  final int activityId;

  const ActivityDetailPage({super.key, required this.activityId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    final activityAsync = ref.watch(businessActivityByIdProvider(activityId));

    return activityAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) => Scaffold(
        appBar: AppBar(title: const Text('Activity Details')),
        body: Center(child: Text('Failed to load activity: $err')),
      ),
      data: (activity) {
        final isDeleted = activity.isDeleted;

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            title: const Text('Activity Details'),
            leading: const BackButton(),
            elevation: 0,
          ),
          body: Stack(
            children: [
              ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
                children: [
                  /// PRIMARY INFO CARD
                  _PrimaryInfoCard(activity: activity),

                  const SizedBox(height: 20),

                  /// CUSTOM FIELDS
                  if ((activity.activityCustomFields ?? []).isNotEmpty)
                    _CustomFieldsCard(activity: activity),

                  const SizedBox(height: 20),

                  /// HISTORY SECTION
                  _HistorySection(
                    activity: activity,
                    isDeleted: isDeleted,
                    formatDate: _format,
                  ),
                ],
              ),

              /// FOOTER ACTIONS
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _FooterActions(
                  activity: activity,
                  activityId: activityId,
                  ref: ref,
                  isDeleted: isDeleted,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static String _format(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

/// PRIMARY INFO
// class _PrimaryInfoCard extends StatelessWidget {
//   final BusinessActivity activity;

//   const _PrimaryInfoCard({required this.activity});

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     final status = activity.isDeleted
//         ? "Deleted"
//         : activity.active
//         ? "Active"
//         : "Suspended";

//     final statusColor = activity.isDeleted
//         ? Colors.red
//         : activity.active
//         ? Colors.green
//         : Colors.orange;

//     return Container(
//       padding: const EdgeInsets.all(18),
//       decoration: BoxDecoration(
//         color: theme.cardColor,
//         borderRadius: BorderRadius.circular(14),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const _SectionLabel("ACTIVITY NAME"),
//           const SizedBox(height: 8),
//           Text(
//             activity.activityName,
//             style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
//           ),
//           const SizedBox(height: 12),
//           Row(
//             children: [
//               const _SectionLabel("STATUS"),
//               const Spacer(),
//               Text(
//                 status,
//                 style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                   color: statusColor,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

/// PRIMARY INFO
class _PrimaryInfoCard extends StatelessWidget {
  final BusinessActivity activity;

  const _PrimaryInfoCard({required this.activity});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final status = activity.isDeleted
        ? "Deleted"
        : activity.active
        ? "Active"
        : "Suspended";

    final statusColor = activity.isDeleted
        ? Colors.red
        : activity.active
        ? Colors.green
        : Colors.orange;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          /// ACTIVITY NAME ROW
          Row(
            children: [
              const Expanded(child: _SectionLabel("Activity Name")),
              Text(
                activity.activityName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          Divider(height: 1),

          const SizedBox(height: 12),

          /// STATUS ROW
          Row(
            children: [
              const Expanded(child: _SectionLabel("Status")),
              Text(
                status,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: statusColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// CUSTOM FIELDS (Enterprise label/value layout)
class _CustomFieldsCard extends StatelessWidget {
  final BusinessActivity activity;

  const _CustomFieldsCard({required this.activity});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final fields = activity.activityCustomFields!
        .where((f) => f.active)
        .toList();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionLabel("Custom Fields"),
          const SizedBox(height: 16),
          Column(
            children: fields
                .map(
                  (f) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            f.fieldName,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: theme.textTheme.bodyLarge!.color,
                            ),
                          ),
                        ),
                        Text(
                          // ignore: dead_code
                          f.fieldDataType ?? "Text",
                          style: TextStyle(color: theme.hintColor),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

/// FOOTER BUTTONS
class _FooterActions extends StatelessWidget {
  final BusinessActivity activity;
  final int activityId;
  final WidgetRef ref;
  final bool isDeleted;

  const _FooterActions({
    required this.activity,
    required this.activityId,
    required this.ref,
    required this.isDeleted,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 26),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            theme.scaffoldBackgroundColor,
            theme.scaffoldBackgroundColor.withAlpha(100),
            theme.scaffoldBackgroundColor.withAlpha(0),
          ],
        ),
      ),
      child: Row(
        children: [
          if (isDeleted)
            Expanded(
              child: StandardRecoveryButton(
                label: 'Recover',
                onPressed: () => showRecoveryBottomSheet(
                  context: context,
                  itemName: activity.activityName,
                  onRecover: () async {
                    final error = await ref
                        .read(businessActivityProvider.notifier)
                        .recover(activity.activityId);
                    if (error == null) {
                      ref.invalidate(businessActivityByIdProvider(activityId));
                      CustomSnackbar.show(
                        context,
                        message:
                            '${activity.activityName} recovered successfully',
                        type: SnackBarType.success,
                      );
                    } else {
                      CustomSnackbar.show(
                        context,
                        message: error,
                        type: SnackBarType.error,
                      );
                    }
                  },
                ),
              ),
            )
          else ...[
            Expanded(
              child: StandardEditButton(
                label: 'Edit',
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditActivityPage(activity: activity),
                    ),
                  );

                  ref.invalidate(businessActivityByIdProvider(activityId));
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StandardDeleteButton(
                label: 'Delete',
                onPressed: () => showDeleteBottomSheet(
                  context: context,
                  itemName: activity.activityName,
                  onDelete: () async {
                    final error = await ref
                        .read(businessActivityProvider.notifier)
                        .delete(activity.activityId);
                    if (error == null) {
                      ref.invalidate(businessActivityByIdProvider(activityId));
                      CustomSnackbar.show(
                        context,
                        message:
                            '${activity.activityName} deleted successfully',
                        type: SnackBarType.success,
                      );
                    } else {
                      CustomSnackbar.show(
                        context,
                        message: error,
                        type: SnackBarType.error,
                      );
                    }
                  },
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// HISTORY SECTION (Expandable Cards)
class _HistorySection extends StatelessWidget {
  final BusinessActivity activity;
  final bool isDeleted;
  final String Function(DateTime) formatDate;

  const _HistorySection({
    required this.activity,
    required this.isDeleted,
    required this.formatDate,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _HistoryCard(
          icon: Icons.flag,
          title: "Created Info",
          entries: [
            _HistoryEntry("Created By", activity.createdUser ?? "Unknown"),
            _HistoryEntry("Created Date", formatDate(activity.createdDate)),
          ],
          expanded: true,
        ),
        if (activity.modifiedUser != null)
          _HistoryCard(
            icon: Icons.edit,
            title: "Modified Info",
            entries: [
              _HistoryEntry("Modified By", activity.modifiedUser ?? "Unknown"),
              _HistoryEntry(
                "Modified Date",
                formatDate(activity.modifiedDate!),
              ),
            ],
          ),
        if (isDeleted)
          _HistoryCard(
            icon: Icons.delete,
            title: "Deleted Info",
            entries: [
              _HistoryEntry("Deleted By", activity.deletedUser ?? "Unknown"),
              _HistoryEntry("Deleted Date", formatDate(activity.deletedDate!)),
            ],
          ),
      ],
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<_HistoryEntry> entries;
  final bool expanded;

  const _HistoryCard({
    required this.icon,
    required this.title,
    required this.entries,
    this.expanded = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: ExpansionTile(
        initiallyExpanded: expanded,
        leading: Icon(icon, color: theme.colorScheme.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        children: entries.map((e) {
          final bool highlightValues =
              title == "Created Info" ||
              title == "Modified Info" ||
              title == "Deleted Info";

          final TextStyle defaultValueStyle = TextStyle(color: theme.hintColor);
          final TextStyle highlightedStyle =
              theme.textTheme.bodyLarge?.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ) ??
              const TextStyle(fontSize: 14, fontWeight: FontWeight.w700);

          return ListTile(
            title: Text(
              e.label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            trailing: Text(
              e.value,
              style: highlightValues ? highlightedStyle : defaultValueStyle,
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _HistoryEntry {
  final String label;
  final String value;

  _HistoryEntry(this.label, this.value);
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Text(
      text,
      style: TextStyle(
        fontSize: 15,
        letterSpacing: 1.2,
        fontWeight: FontWeight.bold,
        color: theme.hintColor,
      ),
    );
  }
}
