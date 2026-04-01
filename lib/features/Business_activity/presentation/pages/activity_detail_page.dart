import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/core/widgets/custom_snackbar.dart';
import 'package:voice_first_admin/core/widgets/delete_bottom_sheet.dart';
import 'package:voice_first_admin/core/widgets/recovery_bottom_sheet.dart';
import 'package:voice_first_admin/core/widgets/standard_detail_page_buttons.dart';
import 'package:voice_first_admin/features/business_activity/data/models/business_activity_model.dart';
import 'package:voice_first_admin/features/business_activity/presentation/pages/edit_activity_page.dart';
import 'package:voice_first_admin/features/business_activity/presentation/providers/business_activity_provider.dart';

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
                          f.fieldDataType,
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
                        // ignore: use_build_context_synchronously
                        context,
                        message:
                            '${activity.activityName} recovered successfully',
                        type: SnackBarType.success,
                      );
                    } else {
                      CustomSnackbar.show(
                        // ignore: use_build_context_synchronously
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
                        // ignore: use_build_context_synchronously
                        context,
                        message:
                            '${activity.activityName} deleted successfully',
                        type: SnackBarType.success,
                      );
                    } else {
                      CustomSnackbar.show(
                        // ignore: use_build_context_synchronously
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
            _HistoryEntry("Created By", activity.createdUser),
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
