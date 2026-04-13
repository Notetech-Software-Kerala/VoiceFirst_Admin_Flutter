import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/core/widgets/custom_snackbar.dart';
import 'package:voice_first_admin/core/widgets/delete_bottom_sheet.dart';
import 'package:voice_first_admin/core/widgets/recovery_bottom_sheet.dart';
import 'package:voice_first_admin/features/business_activity/data/models/business_activity_model.dart';
import 'package:voice_first_admin/features/business_activity/presentation/pages/edit_activity_page.dart';
import 'package:voice_first_admin/features/business_activity/presentation/providers/business_activity_provider.dart';

const _emerald = Color(0xFF10B981);

String _formatAuditDate(DateTime dt) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
  final minute = dt.minute.toString().padLeft(2, '0');
  final period = dt.hour < 12 ? 'AM' : 'PM';
  return '${months[dt.month - 1]} ${dt.day}, ${dt.year} • $hour:$minute $period';
}

class ActivityDetailPage extends ConsumerWidget {
  final int activityId;

  const ActivityDetailPage({super.key, required this.activityId});

  AppBar _simpleAppBar(ThemeData theme) => AppBar(
    backgroundColor: theme.scaffoldBackgroundColor,
    elevation: 0,
    scrolledUnderElevation: 0,
    centerTitle: true,
    leading: const BackButton(),
    title: const Text(
      'Activity Details',
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    ),
    bottom: PreferredSize(
      preferredSize: const Size.fromHeight(1),
      child: Container(color: theme.dividerColor, height: 1),
    ),
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final activityAsync = ref.watch(businessActivityByIdProvider(activityId));

    return activityAsync.when(
      loading: () => Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: _simpleAppBar(theme),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (err, _) => Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: _simpleAppBar(theme),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Failed to load activity: $err'),
          ),
        ),
      ),
      data: (activity) {
        final isDeleted = activity.isDeleted;

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: theme.scaffoldBackgroundColor,
            elevation: 0,
            scrolledUnderElevation: 0,
            centerTitle: true,
            leading: const BackButton(),
            title: const Text(
              'Activity Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            actions: [
              IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
              const SizedBox(width: 8),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(color: theme.dividerColor, height: 1),
            ),
          ),
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 448),
              child: Stack(
                children: [
                  ListView(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 100),
                    children: [
                      _SectionHeader('Basic Information'),
                      const SizedBox(height: 12),
                      _BasicInfoCard(activity: activity, isDeleted: isDeleted),

                      if ((activity.activityCustomFields ?? []).isNotEmpty) ...[
                        const SizedBox(height: 32),
                        _SectionHeader('Custom Fields'),
                        const SizedBox(height: 12),
                        _CustomFieldsCard(activity: activity),
                      ],

                      const SizedBox(height: 32),
                      _SectionHeader('Audit Trail'),
                      const SizedBox(height: 12),
                      _AuditTrailCard(activity: activity, isDeleted: isDeleted),
                    ],
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: _FooterActions(
                      activity: activity,
                      isDeleted: isDeleted,
                      activityId: activityId,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── Section Header ─────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
          color: Colors.grey,
        ),
      ),
    );
  }
}

// ── Basic Info Card ────────────────────────────────────────────────────────────

class _BasicInfoCard extends StatelessWidget {
  final BusinessActivity activity;
  final bool isDeleted;

  const _BasicInfoCard({required this.activity, required this.isDeleted});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.primaryColor;

    final Color badgeColor;
    final String badgeText;
    final IconData badgeIcon;

    if (isDeleted) {
      badgeColor = Colors.red;
      badgeText = 'DELETED';
      badgeIcon = Icons.cancel_outlined;
    } else if (activity.active) {
      badgeColor = _emerald;
      badgeText = 'ACTIVE';
      badgeIcon = Icons.check_circle;
    } else {
      badgeColor = Colors.orange;
      badgeText = 'INACTIVE';
      badgeIcon = Icons.pause_circle_outlined;
    }

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // ── Gradient Banner ──────────────────────────────────────────
          Container(
            width: double.infinity,
            height: 128,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  primary.withValues(alpha: 0.2),
                  primary.withValues(alpha: 0.05),
                ],
              ),
            ),
            child: Center(
              child: Icon(
                Icons.local_activity_outlined,
                size: 48,
                color: primary.withValues(alpha: 0.4),
              ),
            ),
          ),

          // ── Details ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ACTIVITY NAME',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[500],
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            activity.activityName,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              height: 1.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: badgeColor.withValues(alpha: 0.1),
                        border: Border.all(
                          color: badgeColor.withValues(alpha: 0.2),
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(badgeIcon, size: 14, color: badgeColor),
                          const SizedBox(width: 4),
                          Text(
                            badgeText,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: badgeColor,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Custom Fields Card ─────────────────────────────────────────────────────────

class _CustomFieldsCard extends StatelessWidget {
  final BusinessActivity activity;

  const _CustomFieldsCard({required this.activity});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fields = activity.activityCustomFields!;

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        children: [
          for (int i = 0; i < fields.length; i++) ...[
            if (i > 0) Divider(color: theme.dividerColor, height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.text_fields_outlined,
                      color: theme.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fields[i].fieldName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          fields[i].fieldDataType,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: fields[i].active
                          ? _emerald.withValues(alpha: 0.1)
                          : Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      fields[i].active ? 'Active' : 'Inactive',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: fields[i].active ? _emerald : Colors.orange,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Audit Trail Card ───────────────────────────────────────────────────────────

class _AuditTrailCard extends StatelessWidget {
  final BusinessActivity activity;
  final bool isDeleted;

  const _AuditTrailCard({required this.activity, required this.isDeleted});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.primaryColor;

    final hasModified =
        (activity.modifiedUser != null &&
            activity.modifiedUser!.trim().isNotEmpty) ||
        activity.modifiedDate != null;

    final hasDeletedInfo =
        isDeleted &&
        ((activity.deletedUser != null &&
                activity.deletedUser!.trim().isNotEmpty) ||
            activity.deletedDate != null);

    final rows = <Widget>[
      _AuditRow(
        title: 'Created By',
        name: activity.createdUser,
        date: _formatAuditDate(activity.createdDate),
        icon: Icons.person_add_outlined,
        iconColor: primary,
        trailingIcon: Icons.history,
      ),
    ];

    if (hasModified) {
      rows.add(Divider(color: theme.dividerColor, height: 1));
      rows.add(
        _AuditRow(
          title: 'Last Modified By',
          name: activity.modifiedUser ?? 'Unknown',
          date: activity.modifiedDate != null
              ? _formatAuditDate(activity.modifiedDate!)
              : 'N/A',
          icon: Icons.edit_note_outlined,
          iconColor: Colors.orange,
          trailingIcon: Icons.update,
        ),
      );
    }

    if (hasDeletedInfo) {
      rows.add(Divider(color: theme.dividerColor, height: 1));
      rows.add(
        _AuditRow(
          title: 'Deleted By',
          name: activity.deletedUser ?? 'Unknown',
          date: activity.deletedDate != null
              ? _formatAuditDate(activity.deletedDate!)
              : 'N/A',
          icon: Icons.delete_forever_outlined,
          iconColor: Colors.red,
          trailingIcon: Icons.cancel_outlined,
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(children: rows),
    );
  }
}

class _AuditRow extends StatelessWidget {
  final String title;
  final String name;
  final String date;
  final IconData icon;
  final Color iconColor;
  final IconData trailingIcon;

  const _AuditRow({
    required this.title,
    required this.name,
    required this.date,
    required this.icon,
    required this.iconColor,
    required this.trailingIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  date,
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
          ),
          Icon(trailingIcon, size: 16, color: Colors.grey[400]),
        ],
      ),
    );
  }
}

// ── Footer Actions ─────────────────────────────────────────────────────────────

class _FooterActions extends ConsumerWidget {
  final BusinessActivity activity;
  final bool isDeleted;
  final int activityId;

  const _FooterActions({
    required this.activity,
    required this.isDeleted,
    required this.activityId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final primary = theme.primaryColor;

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor.withValues(alpha: 0.8),
            border: Border(top: BorderSide(color: theme.dividerColor)),
          ),
          child: SafeArea(
            top: false,
            child: isDeleted
                ? ElevatedButton.icon(
                    onPressed: () => showRecoveryBottomSheet(
                      context: context,
                      itemName: activity.activityName,
                      onRecover: () async {
                        final error = await ref
                            .read(businessActivityProvider.notifier)
                            .recover(activity.activityId);
                        if (!context.mounted) return;
                        if (error == null) {
                          ref.invalidate(
                            businessActivityByIdProvider(activityId),
                          );
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
                    icon: const Icon(Icons.restore_outlined, size: 20),
                    label: const Text('Recover Activity'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _emerald,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 8,
                      shadowColor: _emerald.withValues(alpha: 0.3),
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  )
                : Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final updated = await Navigator.push<bool>(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    EditActivityPage(activity: activity),
                              ),
                            );
                            if (updated == true && context.mounted) {
                              ref.invalidate(
                                businessActivityByIdProvider(activityId),
                              );
                            }
                          },
                          icon: const Icon(Icons.edit_outlined, size: 20),
                          label: const Text('Edit Activity'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primary,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(0, 48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 8,
                            shadowColor: primary.withValues(alpha: 0.3),
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      InkWell(
                        onTap: () => showDeleteBottomSheet(
                          context: context,
                          itemName: activity.activityName,
                          onDelete: () async {
                            final error = await ref
                                .read(businessActivityProvider.notifier)
                                .delete(activity.activityId);
                            if (!context.mounted) return;
                            if (error == null) {
                              ref.invalidate(
                                businessActivityByIdProvider(activityId),
                              );
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
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.1),
                            border: Border.all(
                              color: Colors.red.withValues(alpha: 0.2),
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
