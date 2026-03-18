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
    final cs = theme.colorScheme;

    final activityAsync = ref.watch(businessActivityByIdProvider(activityId));

    return activityAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) => Scaffold(
        appBar: AppBar(title: const Text('Activity Details')),
        body: Center(child: Text('Failed to load activity: $err')),
      ),
      data: (updatedActivity) {
        final isDeleted = updatedActivity.isDeleted;
        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            title: const Text('Activity Details'),
            elevation: 0,
            leading: const BackButton(),
            toolbarHeight: kToolbarHeight,
          ),
          body: Stack(
            children: [
              ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
                children: [
                  // PRIMARY INFO CARD
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Activity Name Row
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Expanded(child: _Label('ACTIVITY NAME')),
                            const SizedBox(width: 12),
                            Text(
                              updatedActivity.activityName,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Status Row
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Expanded(child: _Label('STATUS')),
                            const SizedBox(width: 12),
                            Text(
                              isDeleted
                                  ? 'Deleted'
                                  : (updatedActivity.active
                                        ? 'Active'
                                        : 'Suspended'),
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: isDeleted
                                    ? Colors.red
                                    : (updatedActivity.active
                                          ? const Color.fromARGB(255, 40, 21, 135)
                                          : Colors.orange),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// CUSTOM FIELDS (only if exist)
                  if ((updatedActivity.activityCustomFields ?? [])
                      .isNotEmpty) ...[
                    const SizedBox(height: 20),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _Label('CUSTOM FIELDS'),
                          const SizedBox(height: 12),

                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: updatedActivity.activityCustomFields!
                                .where((f) => f.active)
                                .map((f) => Chip(label: Text(f.fieldName)))
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),

                  // HISTORY (Created/Modified [+ Deleted if deleted])
                  _HistorySection(
                    activity: updatedActivity,
                    isDeleted: isDeleted,
                    formatDate: _format,
                  ),
                ],
              ),

              // STICKY FOOTER ACTIONS
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
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
                              itemName: updatedActivity.activityName,
                              onRecover: () async {
                                // final error = await ref
                                //     .read(businessActivityProvider.notifier)
                                //     .recover(updatedActivity.activityId);
                                final error = await ref
                                    .read(businessActivityProvider.notifier)
                                    .recover(updatedActivity.activityId);

                                if (error == null) {
                                  ref.invalidate(
                                    businessActivityByIdProvider(activityId),
                                  );
                                }
                                if (error == null) {
                                  CustomSnackbar.show(
                                    context,
                                    message:
                                        '${updatedActivity.activityName} recovered successfully',
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
                        // Expanded(
                        //   child: StandardEditButton(
                        //     label: 'Edit',
                        //     onPressed: () {
                        //       Navigator.push(
                        //         context,
                        //         MaterialPageRoute(
                        //           builder: (_) => EditActivityPage(
                        //             activity: updatedActivity,
                        //           ),
                        //         ),
                        //       );
                        //     },
                        //   ),
                        // ),
                        Expanded(
                          child: StandardEditButton(
                            label: 'Edit',
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => EditActivityPage(
                                    activity: updatedActivity,
                                  ),
                                ),
                              );
                              ref.invalidate(
                                businessActivityByIdProvider(activityId),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: StandardDeleteButton(
                            label: 'Delete',
                            onPressed: () => showDeleteBottomSheet(
                              context: context,
                              itemName: updatedActivity.activityName,
                              onDelete: () async {
                                // final error = await ref
                                //     .read(businessActivityProvider.notifier)
                                //     .delete(updatedActivity.activityId);
                                final error = await ref
                                    .read(businessActivityProvider.notifier)
                                    .delete(updatedActivity.activityId);

                                if (error == null) {
                                  ref.invalidate(
                                    businessActivityByIdProvider(activityId),
                                  );
                                }
                                if (error == null) {
                                  CustomSnackbar.show(
                                    context,
                                    message:
                                        '${updatedActivity.activityName} deleted successfully',
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
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _format(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

// ───────────────── UI HELPERS ─────────────────

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        letterSpacing: 1.2,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

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
    String formatUser(String? value, {String fallback = 'N/A'}) {
      if (value == null || value.trim().isEmpty) return fallback;
      return value;
    }

    String formatDateSafe(DateTime? value, {String fallback = 'N/A'}) {
      if (value == null) return fallback;
      return formatDate(value);
    }

    return Column(
      children: [
        _HistoryExpansionTile(
          icon: Icons.flag_circle_outlined,
          title: 'Created Info',
          subtitle:
              'Created by ${formatUser(activity.createdUser, fallback: 'Unknown')}',
          initiallyExpanded: true,
          entries: [
            _HistoryEntry(
              label: 'Created By',
              value: formatUser(activity.createdUser, fallback: 'Unknown'),
            ),
            _HistoryEntry(
              label: 'Created Date',
              value: formatDateSafe(activity.createdDate),
            ),
          ],
        ),
        if (activity.modifiedUser != null || activity.modifiedDate != null)
          _HistoryExpansionTile(
            icon: Icons.history,
            title: 'Modified Info',
            subtitle:
                'Modified by ${formatUser(activity.modifiedUser, fallback: 'Not modified')}',
            initiallyExpanded:
                !isDeleted &&
                (activity.modifiedUser != null ||
                    activity.modifiedDate != null),
            entries: [
              _HistoryEntry(
                label: 'Modified By',
                value: formatUser(
                  activity.modifiedUser,
                  fallback: 'Not modified',
                ),
              ),
              _HistoryEntry(
                label: 'Modified Date',
                value: formatDateSafe(
                  activity.modifiedDate,
                  fallback: 'Not modified',
                ),
              ),
            ],
          ),
        if (isDeleted)
          _HistoryExpansionTile(
            icon: Icons.delete_forever_outlined,
            title: 'Deleted Info',
            subtitle:
                'Deleted by ${formatUser(activity.deletedUser, fallback: 'Unknown')}',
            initiallyExpanded: true,
            entries: [
              _HistoryEntry(
                label: 'Deleted By',
                value: formatUser(activity.deletedUser, fallback: 'Unknown'),
              ),
              _HistoryEntry(
                label: 'Deleted Date',
                value: formatDateSafe(activity.deletedDate, fallback: 'N/A'),
              ),
            ],
          ),
      ],
    );
  }
}

class _HistoryExpansionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<_HistoryEntry> entries;
  final bool initiallyExpanded;

  const _HistoryExpansionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.entries,
    this.initiallyExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: Icon(icon, color: theme.colorScheme.primary),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(subtitle, style: theme.textTheme.bodySmall),
          children: [
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: entries.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 2.4,
              ),
              itemBuilder: (context, index) =>
                  _HistoryChip(entry: entries[index]),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryEntry {
  final String label;
  final String value;
  const _HistoryEntry({required this.label, required this.value});
}

class _HistoryChip extends StatelessWidget {
  final _HistoryEntry entry;
  const _HistoryChip({required this.entry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? theme.cardColor.withAlpha(153)
            : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.dividerColor.withAlpha(153)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            entry.label.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.6,
              color: theme.hintColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            entry.value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}



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
