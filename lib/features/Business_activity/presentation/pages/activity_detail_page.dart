import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/features/Business_activity/models/business_activity_model.dart';
import '../providers/business_activity_provider.dart';
import '../dialogs/edit_activity_dialog.dart';
import '../dialogs/delete_activity_dialog.dart';
import '../dialogs/recover_activity_dialog.dart';

class ActivityDetailPage extends ConsumerWidget {
  final BusinessActivity activity;

  const ActivityDetailPage({super.key, required this.activity});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final state = ref.watch(businessActivityProvider);

    final updatedActivity = state.items.firstWhere(
      (a) => a.activityId == activity.activityId,
      orElse: () => activity,
    );

    final isDeleted = updatedActivity.isDeleted;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          updatedActivity.activityName,
          style: theme.textTheme.titleLarge?.copyWith(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: cs.primary,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),

            _SectionCard(
              title: 'Basic Information',
              children: [
                _RowItem(
                  label: 'Activity Name',
                  value: updatedActivity.activityName,
                ),
                _RowItem(
                  label: 'Status',
                  value: isDeleted
                      ? 'Deleted'
                      : (updatedActivity.active ? 'Active' : 'Inactive'),
                  valueColor: isDeleted
                      ? cs.error
                      : (updatedActivity.active ? Colors.green : cs.error),
                ),
              ],
            ),

            const SizedBox(height: 20),

            _SectionCard(
              title: 'Created Information',
              children: [
                _RowItem(
                  label: 'Created By',
                  value: updatedActivity.createdUser,
                ),
                _RowItem(
                  label: 'Created Date',
                  value: _format(updatedActivity.createdDate),
                ),
              ],
            ),

            const SizedBox(height: 20),

            _SectionCard(
              title: 'Modified Information',
              children: [
                _RowItem(
                  label: 'Modified By',
                  value: updatedActivity.modifiedUser ?? 'N/A',
                ),
                _RowItem(
                  label: 'Modified Date',
                  value: updatedActivity.modifiedDate != null
                      ? _format(updatedActivity.modifiedDate!)
                      : 'Not modified',
                ),
              ],
            ),

            if (isDeleted) ...[
              const SizedBox(height: 20),
              _SectionCard(
                title: 'Deleted Information',
                children: [
                  _RowItem(
                    label: 'Deleted By',
                    value: updatedActivity.deletedUser ?? 'N/A',
                  ),
                  _RowItem(
                    label: 'Deleted Date',
                    value: updatedActivity.deletedDate != null
                        ? _format(updatedActivity.deletedDate!)
                        : 'N/A',
                  ),
                ],
              ),
            ],

            const SizedBox(height: 32),

            // ───── ACTIONS ─────
            Row(
              children: [
                if (isDeleted)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => RecoverActivityDialog.show(
                        context,
                        ref,
                        updatedActivity.activityId,
                        updatedActivity.activityName,
                      ),
                      icon: const Icon(Icons.restore, color: Colors.white),
                      label: const Text(
                        'Recover',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(
                          255,
                          56,
                          126,
                          218,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  )
                else ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => EditActivityDialog.show(
                        context,
                        ref,
                        updatedActivity,
                      ),
                      icon: const Icon(Icons.edit, color: Colors.white),
                      label: const Text(
                        'Edit',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: cs.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => DeleteActivityDialog.show(
                        context,
                        ref,
                        updatedActivity.activityId,
                        updatedActivity.activityName,
                      ),
                      icon: const Icon(Icons.delete, color: Colors.white),
                      label: const Text(
                        'Delete',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _format(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

// ───────────────── UI HELPERS ─────────────────

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _RowItem extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _RowItem({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final isLight = theme.brightness == Brightness.light;
    final isActivityName = label == 'Activity Name';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isLight ? Colors.black : Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            value,
            style: isActivityName
                ? theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: valueColor ?? theme.textTheme.bodyMedium?.color,
                  )
                : theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: valueColor ?? theme.textTheme.bodyMedium?.color,
                  ),
          ),
        ],
      ),
    );
  }
}
