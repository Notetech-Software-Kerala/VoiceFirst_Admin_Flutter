import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/features/Business_activity/models/business_activity_model.dart';
import '../providers/business_activity_provider.dart';
import '../dialogs/edit_activity_dialog.dart';
import '../dialogs/delete_activity_dialog.dart';

class ActivityDetailPage extends ConsumerWidget {
  final int activityId;
  // final BusinessActivity activity;

  const ActivityDetailPage({
    super.key,
    required this.activityId,
    // required this.activity,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final primaryColor = const Color(0xFF0D7FF2);

    final state = ref.watch(businessActivityProvider);

    final activity = state.activities
        .where((a) => a.id == activityId)
        .cast<BusinessActivity?>()
        .firstOrNull;

    // SAFETY GUARD
    if (activity == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Activity Details'),
          backgroundColor: primaryColor,
        ),
        body: const Center(child: Text('Activity not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Activity Details',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: primaryColor.withAlpha(20),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activity.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: activity.active
                                ? Colors.green.withAlpha(38)
                                : Colors.red.withAlpha(38),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            activity.active ? 'Active' : 'Inactive',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: activity.active
                                  ? Colors.green.shade700
                                  : Colors.red.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _DetailSection(
                    title: 'Basic Information',
                    primaryColor: primaryColor,
                    children: [
                      _DetailItem(
                        label: 'Activity Name',
                        value: activity.name,
                        primaryColor: primaryColor,
                      ),
                      _DetailItem(
                        label: 'Active Status',
                        value: activity.active ? 'Active' : 'Inactive',
                        primaryColor: primaryColor,
                        valueColor: activity.active ? Colors.green : Colors.red,
                      ),
                      _DetailItem(
                        label: 'Delete Status',
                        value: activity.isDeleted ? 'Deleted' : 'Not Deleted',
                        primaryColor: primaryColor,
                        valueColor: activity.isDeleted
                            ? Colors.red
                            : Colors.green,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _DetailSection(
                    title: 'Created Information',
                    primaryColor: primaryColor,
                    children: [
                      _DetailItem(
                        label: 'Created By',
                        value: activity.createdUser,
                        primaryColor: primaryColor,
                      ),
                      _DetailItem(
                        label: 'Created Date',
                        value: _formatDateTime(activity.createdDate),
                        primaryColor: primaryColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _DetailSection(
                    title: 'Modified Information',
                    primaryColor: primaryColor,
                    children: [
                      _DetailItem(
                        label: 'Modified By',
                        value: activity.modifiedUser ?? 'N/A',
                        primaryColor: primaryColor,
                      ),
                      _DetailItem(
                        label: 'Modified Date',
                        value: activity.modifiedDate != null
                            ? _formatDateTime(activity.modifiedDate!)
                            : 'Not modified',
                        primaryColor: primaryColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (activity.isDeleted) ...[
                    _DetailSection(
                      title: 'Deleted Information',
                      primaryColor: primaryColor,
                      children: [
                        _DetailItem(
                          label: 'Deleted By',
                          value: activity.deletedUser?.isEmpty ?? true
                              ? 'N/A'
                              : activity.deletedUser!,
                          primaryColor: primaryColor,
                        ),
                        _DetailItem(
                          label: 'Deleted Date',
                          value: activity.deletedDate != null
                              ? _formatDateTime(activity.deletedDate!)
                              : 'N/A',
                          primaryColor: primaryColor,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                  const SizedBox(height: 8),

                  Row(
                    children: [
                      /// ✏️ Edit Button
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () =>
                              EditActivityDialog.show(context, ref, activity),
                          icon: const Icon(Icons.edit, color: Colors.white),
                          label: const Text(
                            'Edit Activity',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      /// 🗑 Delete Button
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => DeleteActivityDialog.show(
                            context,
                            ref,
                            activity.id,
                            activity.name,
                          ),

                          icon: const Icon(Icons.delete, color: Colors.white),
                          label: const Text(
                            'Delete Activity',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade600,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/'
        '${dateTime.month.toString().padLeft(2, '0')}/'
        '${dateTime.year} '
        '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

class _DetailSection extends StatelessWidget {
  final String title;
  final Color primaryColor;
  final List<Widget> children;

  const _DetailSection({
    required this.title,
    required this.primaryColor,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              for (int i = 0; i < children.length; i++) ...[
                children[i],
                if (i < children.length - 1)
                  Divider(height: 0, color: Colors.grey.shade200),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _DetailItem extends StatelessWidget {
  final String label;
  final String value;
  final Color primaryColor;
  final Color? valueColor;

  const _DetailItem({
    required this.label,
    required this.value,
    required this.primaryColor,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: valueColor ?? Colors.grey.shade900,
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleItem extends StatelessWidget {
  final String label;
  final bool value;

  const _ToggleItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: value
                  ? const Color(0xFF0D7FF2).withAlpha(38)
                  : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              value ? 'Yes' : 'No',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: value ? const Color(0xFF0D7FF2) : Colors.grey.shade600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
