import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/features/Business_activity/models/business_activity_model.dart';
import '../providers/business_activity_provider.dart';
import '../dialogs/add_activity_dialog.dart';
import '../dialogs/delete_activity_dialog.dart';
import '../dialogs/bulk_delete_dialog.dart';
import '../widgets/custom_snackbar.dart';
import 'activity_detail_page.dart';
import 'package:voice_first_admin/core/widgets/app_drawer.dart';

class ViewBusinessActivityPage extends ConsumerWidget {
  const ViewBusinessActivityPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(businessActivityProvider);
    final notifier = ref.read(businessActivityProvider.notifier);
    final primaryColor = const Color(0xFF0D7FF2);

    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        title: Text(
          style: TextStyle(color: Colors.white),
          state.isMultiSelect
              ? '${state.selectedIds.length} selected'
              : 'Business Activities',
        ),
        backgroundColor: primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          // onPressed: () => Navigator.pop(context),
          onPressed: () {
            if (state.isMultiSelect) {
              notifier.exitSelectionMode();
            } else {
              Navigator.pop(context);
            }
          },
        ),
        // actions: state.isMultiSelect
        //     ? [
        //         IconButton(
        //           icon: const Icon(Icons.delete),
        //           onPressed: () => BulkDeleteDialog.show(
        //             context,
        //             ref,
        //             state.selectedIds.length,
        //           ),
        //         ),
        //       ]
        //     : [],
        actions: [
          /// BEFORE long-press → Select
          if (!state.isMultiSelect)
            TextButton(
              onPressed: () => notifier.enterSelectionMode(),
              child: const Text(
                'Select',
                style: TextStyle(color: Colors.white),
              ),
            ),

          /// AFTER long-press → Select All / Clear All
          if (state.isMultiSelect)
            TextButton(
              onPressed: () => notifier.enterSelectionMode(
                selectAll: !notifier.allVisibleSelected,
              ),
              child: Text(
                notifier.allVisibleSelected ? 'Clear All' : 'Select All',
                style: const TextStyle(color: Colors.white),
              ),
            ),

          /// Bulk delete
          if (state.isMultiSelect)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.white),
              onPressed: () =>
                  BulkDeleteDialog.show(context, ref, state.selectedIds.length),
            ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.08),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: TextField(
              onChanged: notifier.search,
              decoration: InputDecoration(
                hintText: 'Search activities...',
                prefixIcon: Icon(Icons.search, color: primaryColor),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: primaryColor.withOpacity(0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: primaryColor, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
          Expanded(
            child: state.filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.inbox,
                            size: 40,
                            color: primaryColor.withOpacity(0.5),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No activities found',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap the + button to add a new activity',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    itemCount: state.filtered.length,
                    itemBuilder: (_, i) {
                      final a = state.filtered[i];
                      final selected = state.selectedIds.contains(a.id);

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Material(
                          color: Colors.transparent,
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: selected
                                    ? primaryColor.withOpacity(0.5)
                                    : Colors.grey.shade200,
                                width: selected ? 2 : 1,
                              ),
                            ),
                            tileColor: selected
                                ? primaryColor.withOpacity(0.08)
                                : Colors.white,

                            leading: state.isMultiSelect
                                ? Checkbox(
                                    value: selected,
                                    onChanged: (_) =>
                                        notifier.toggleSelection(a.id),
                                    activeColor: primaryColor,
                                  )
                                : null,

                            title: Text(
                              a.activityName,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade800,
                              ),
                            ),

                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                /// 👁 Eye
                                IconButton(
                                  icon: Icon(
                                    Icons.remove_red_eye_outlined,
                                    color: primaryColor,
                                    // size: 27,
                                  ),
                                  iconSize: 27,
                                  onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          ActivityDetailPage(activityId: a.id),
                                    ),
                                  ),
                                ),

                                /// 🔀 Toggle
                                Transform.scale(
                                  scale: 0.8,
                                  child: Switch(
                                    value: a.status,
                                    onChanged: (val) {
                                      notifier.toggleStatus(a.id, val);
                                      CustomSnackbar.show(
                                        context,
                                        message:
                                            '${a.activityName} ${val ? 'enabled' : 'disabled'}',
                                        type: SnackBarType.info,
                                      );
                                    },
                                    activeColor: Colors.green.shade600,
                                    inactiveThumbColor: Colors.grey.shade400,
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                ),

                                /// 🗑 Delete
                                IconButton(
                                  icon: Icon(
                                    Icons.delete_rounded,
                                    color: Colors.red.shade600,
                                    // size: 27,
                                  ),
                                  iconSize: 22,
                                  onPressed: () => DeleteActivityDialog.show(
                                    context,
                                    ref,
                                    a.id,
                                    a.activityName,
                                  ),
                                ),
                              ],
                            ),

                            onLongPress: () => notifier.toggleSelection(a.id),
                            // onTap: state.isMultiSelect ? null : () {},
                            onTap: () {
                              if (state.isMultiSelect) {
                                notifier.toggleSelection(a.id);
                              }
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => AddActivityDialog.show(context, ref),
        backgroundColor: primaryColor,
        elevation: 4,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
