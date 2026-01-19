import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/features/Business_activity/models/business_activity_model.dart';
import '../providers/business_activity_provider.dart';
import '../dialogs/edit_activity_dialog.dart';
import '../dialogs/delete_activity_dialog.dart';
import '../widgets/custom_snackbar.dart';

class ActivityDetailPage extends ConsumerWidget {
  final BusinessActivity activity;

  const ActivityDetailPage({super.key, required this.activity});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final primaryColor = const Color(0xFF0D7FF2);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity Details'),
        backgroundColor: primaryColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => EditActivityDialog.show(context, ref, activity),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () async {
              DeleteActivityDialog.show(
                context,
                ref,
                activity.id,
                activity.activityName,
              );
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.08),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.business, size: 40, color: primaryColor),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activity.activityName,
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
                            color: activity.status
                                ? Colors.green.withOpacity(0.15)
                                : Colors.red.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            activity.status ? 'Active' : 'Inactive',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: activity.status
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
                    title: 'Settings',
                    primaryColor: primaryColor,
                    children: [
                      _DetailItem(
                        label: 'Activity ID',
                        value: activity.id,
                        primaryColor: primaryColor,
                      ),
                      _DetailItem(
                        label: 'Activity Name',
                        value: activity.activityName,
                        primaryColor: primaryColor,
                      ),
                      _DetailItem(
                        label: 'Status',
                        value: activity.status ? 'Active' : 'Inactive',
                        primaryColor: primaryColor,
                        valueColor: activity.status ? Colors.green : Colors.red,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _DetailSection(
                    title: 'Configuration',
                    primaryColor: primaryColor,
                    children: [
                      _ToggleItem(
                        label: 'For Company',
                        value: activity.isForCompany,
                      ),
                      _ToggleItem(
                        label: 'For Branch',
                        value: activity.isForBranch,
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          EditActivityDialog.show(context, ref, activity),
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit Activity'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
                  ? const Color(0xFF0D7FF2).withOpacity(0.15)
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
