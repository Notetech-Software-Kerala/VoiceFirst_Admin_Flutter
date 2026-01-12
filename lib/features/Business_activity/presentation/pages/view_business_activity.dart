import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/features/Business_activity/models/business_activity_model.dart';
import '../providers/business_activity_provider.dart';
import '../widgets/business_activity_dialog.dart';

class ViewBusinessActivityPage extends ConsumerWidget {
  const ViewBusinessActivityPage({super.key});

  void _showDialog(
    BuildContext context,
    WidgetRef ref, {
    BusinessActivity? activity,
  }) {
    showDialog(
      context: context,
      builder: (context) => BusinessActivityDialog(
        activity: activity,
        onSave: (newActivity) {
          final notifier = ref.read(businessActivityProvider.notifier);
          if (activity != null) {
            notifier.update(newActivity);
          } else {
            notifier.add(newActivity);
          }
        },
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref, String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Activity?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(businessActivityProvider.notifier).delete(id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(businessActivityProvider);
    final notifier = ref.read(businessActivityProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          state.isMultiSelect
              ? '${state.selectedIds.length} selected'
              : 'Business Activities',
        ),
        actions: state.isMultiSelect
            ? [
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: notifier.deleteSelected,
                ),
              ]
            : [],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: notifier.search,
              decoration: const InputDecoration(
                hintText: 'Search',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: state.filtered.length,
              itemBuilder: (_, i) {
                final a = state.filtered[i];
                final selected = state.selectedIds.contains(a.id);

                return ListTile(
                  title: Text(a.activityName),
                  leading: state.isMultiSelect
                      ? Checkbox(
                          value: selected,
                          onChanged: (_) => notifier.toggleSelection(a.id),
                        )
                      : null,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey.shade200,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 56,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              child: Transform.scale(
                                scale: 0.85,
                                child: Switch(
                                  value: a.status,
                                  onChanged: (val) =>
                                      notifier.toggleStatus(a.id, val),
                                  activeColor: Colors.green.shade600,
                                  inactiveThumbColor: Colors.grey.shade400,
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                              ),
                            ),
                            Container(
                              width: 1.5,
                              height: 28,
                              color: Colors.grey.shade200,
                            ),
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.only(
                                  topRight: Radius.circular(11),
                                  bottomRight: Radius.circular(11),
                                ),
                                color: Colors.red.shade50,
                              ),
                              child: IconButton(
                                icon: Icon(
                                  Icons.delete_rounded,
                                  color: Colors.red.shade600,
                                  size: 20,
                                ),
                                padding: EdgeInsets.zero,
                                onPressed: () =>
                                    _showDeleteConfirmation(context, ref, a.id),
                                splashColor: Colors.red.withOpacity(0.2),
                                highlightColor: Colors.red.withOpacity(0.1),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  onLongPress: () => notifier.toggleSelection(a.id),
                  onTap: state.isMultiSelect
                      ? null
                      : () => _showDialog(context, ref, activity: a),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }
}
