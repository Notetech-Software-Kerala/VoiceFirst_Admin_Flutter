import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/core/widgets/custom_snackbar.dart';
import 'package:voice_first_admin/core/widgets/delete_bottom_sheet.dart';
import 'package:voice_first_admin/core/widgets/recovery_bottom_sheet.dart';
import 'package:voice_first_admin/features/issue_type/data/models/issue_type_model.dart';
import 'package:voice_first_admin/features/issue_type/presentation/pages/edit_issue_type_page.dart';
import 'package:voice_first_admin/features/issue_type/presentation/providers/issue_type_provider.dart';

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

class IssueTypeDetailPage extends ConsumerWidget {
  final int id;

  const IssueTypeDetailPage({super.key, required this.id});

  AppBar _simpleAppBar(ThemeData theme) => AppBar(
    backgroundColor: theme.scaffoldBackgroundColor,
    elevation: 0,
    scrolledUnderElevation: 0,
    centerTitle: true,
    leading: const BackButton(),
    title: const Text(
      'Type Details',
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
    final asyncValue = ref.watch(issueTypeDetailProvider(id));

    return asyncValue.when(
      loading: () => Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: _simpleAppBar(theme),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: _simpleAppBar(theme),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Failed to load details: $error'),
          ),
        ),
      ),
      data: (issueType) {
        final isDeleted = issueType.deleted;
        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: theme.scaffoldBackgroundColor,
            elevation: 0,
            scrolledUnderElevation: 0,
            centerTitle: true,
            leading: const BackButton(),
            title: const Text(
              'Type Details',
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
                      _BasicInfoCard(
                        issueType: issueType,
                        isDeleted: isDeleted,
                      ),
                      const SizedBox(height: 32),
                      _SectionHeader('Audit Trail'),
                      const SizedBox(height: 12),
                      _AuditTrailCard(
                        issueType: issueType,
                        isDeleted: isDeleted,
                      ),
                    ],
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: _FooterActions(
                      issueType: issueType,
                      isDeleted: isDeleted,
                      id: id,
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
  final IssueTypeModel issueType;
  final bool isDeleted;

  const _BasicInfoCard({required this.issueType, required this.isDeleted});

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
    } else if (issueType.active) {
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
                Icons.category_outlined,
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
                            'TYPE NAME',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[500],
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            issueType.issueType,
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

                // Description
                if (issueType.description != null &&
                    issueType.description!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      issueType.description!,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        height: 1.5,
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 16),
                Divider(color: theme.dividerColor, height: 1),
                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ISSUE TYPE ID',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[500],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${issueType.issueTypeId}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.fingerprint, color: primary, size: 24),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Audit Trail Card ───────────────────────────────────────────────────────────

class _AuditTrailCard extends StatelessWidget {
  final IssueTypeModel issueType;
  final bool isDeleted;

  const _AuditTrailCard({required this.issueType, required this.isDeleted});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.primaryColor;

    final hasModified =
        (issueType.modifiedUser != null &&
            issueType.modifiedUser!.trim().isNotEmpty) ||
        issueType.modifiedDate != null;

    final hasDeletedInfo =
        isDeleted &&
        ((issueType.deletedUser != null &&
                issueType.deletedUser!.trim().isNotEmpty) ||
            issueType.deletedDate != null);

    final rows = <Widget>[
      _AuditRow(
        title: 'Created By',
        name: issueType.createdUser ?? 'Unknown',
        date: issueType.createdDate != null
            ? _formatAuditDate(issueType.createdDate!)
            : 'N/A',
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
          name: issueType.modifiedUser ?? 'Unknown',
          date: issueType.modifiedDate != null
              ? _formatAuditDate(issueType.modifiedDate!)
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
          name: issueType.deletedUser ?? 'Unknown',
          date: issueType.deletedDate != null
              ? _formatAuditDate(issueType.deletedDate!)
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
  final IssueTypeModel issueType;
  final bool isDeleted;
  final int id;

  const _FooterActions({
    required this.issueType,
    required this.isDeleted,
    required this.id,
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
                      itemName: issueType.issueType,
                      onRecover: () async {
                        final error = await ref
                            .read(issueTypeProvider.notifier)
                            .recover(issueType.issueTypeId);
                        if (!context.mounted) return;
                        if (error == null) {
                          ref.invalidate(issueTypeDetailProvider(id));
                          CustomSnackbar.show(
                            context,
                            message:
                                '${issueType.issueType} recovered successfully',
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
                    label: const Text('Recover Type'),
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
                                    EditIssueTypePage(issueType: issueType),
                              ),
                            );
                            if (updated == true && context.mounted) {
                              ref.invalidate(issueTypeDetailProvider(id));
                            }
                          },
                          icon: const Icon(Icons.edit_outlined, size: 20),
                          label: const Text('Edit Type'),
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
                          itemName: issueType.issueType,
                          onDelete: () async {
                            final error = await ref
                                .read(issueTypeProvider.notifier)
                                .delete(issueType.issueTypeId);
                            if (!context.mounted) return;
                            if (error == null) {
                              ref.invalidate(issueTypeDetailProvider(id));
                              CustomSnackbar.show(
                                context,
                                message:
                                    '${issueType.issueType} deleted successfully',
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
