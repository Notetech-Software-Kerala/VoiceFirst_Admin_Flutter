import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/features/Business_activity/presentation/widgets/custom_snackbar.dart';
import 'package:voice_first_admin/features/Program_Action/presentation/providers/program_action_provider.dart';
import 'package:voice_first_admin/features/Program_Action/presentation/dialogs/add_program_action_dialog.dart';
import 'package:voice_first_admin/features/Program_Action/presentation/dialogs/edit_program_action_dialog.dart';
import 'package:voice_first_admin/features/Program_Action/presentation/dialogs/delete_program_action_dialog.dart';

class ProgramActionView extends ConsumerWidget {
  const ProgramActionView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(programActionProvider);
    final notifier = ref.read(programActionProvider.notifier);

    final primaryColor = const Color(0xFF0D7FF2);

    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        title: Text(
          state.isMultiSelect
              ? '${state.selectedIds.length} selected'
              : 'Program Actions',
          style: const TextStyle(color: Colors.white),
        ),
        leading: state.isMultiSelect
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: notifier.exitSelectionMode,
              )
            : null, // Let the default menu icon show
        actions: [
          /// Select
          if (!state.isMultiSelect)
            TextButton(
              onPressed: notifier.enterSelectionMode,
              child: const Text(
                'Select',
                style: TextStyle(color: Colors.white),
              ),
            ),

          /// Cancel
          if (state.isMultiSelect)
            TextButton(
              onPressed: notifier.exitSelectionMode,
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white),
              ),
            ),

          /// Delete
          if (state.isMultiSelect && state.selectedIds.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.white),
              onPressed: () {
                notifier.deleteSelected();
                CustomSnackbar.show(
                  context,
                  message: 'Selected actions deleted',
                  type: SnackBarType.success,
                );
              },
            ),
        ],
      ),

      // ───────────────── Body ─────────────────
      body: Column(
        children: [
          // 🔍 Search
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
                hintText: 'Search program actions...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // ☑️ Select All/Deselect All Checkbox
          if (state.isMultiSelect)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Checkbox(
                    value: notifier.allVisibleSelected,
                    onChanged: (_) {
                      notifier.enterSelectionMode(
                        selectAll: !notifier.allVisibleSelected,
                      );
                    },
                    activeColor: primaryColor,
                  ),
                  Text(
                    notifier.allVisibleSelected ? 'Deselect All' : 'Select All',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

          // 📋 List
          Expanded(
            child: state.filtered.isEmpty
                ? Center(
                    child: Text(
                      'No program actions found',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  )
                : ListView.builder(
                    itemCount: state.filtered.length,
                    itemBuilder: (context, index) {
                      final action = state.filtered[index];
                      final bool selected = state.selectedIds.contains(
                        action.ProgramActionId,
                      );

                      return GestureDetector(
                        onLongPress: () =>
                            notifier.toggleSelection(action.ProgramActionId),
                        child: Card(
                          color: selected
                              ? primaryColor.withOpacity(0.2)
                              : Colors.white,
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: selected
                                ? BorderSide(color: primaryColor, width: 1.5)
                                : BorderSide.none,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                // ☐ Checkbox
                                if (state.isMultiSelect)
                                  Checkbox(
                                    value: selected,
                                    onChanged: (_) => notifier.toggleSelection(
                                      action.ProgramActionId,
                                    ),
                                    activeColor: primaryColor,
                                  ),

                                // 📄 Action info
                                Expanded(
                                  child: Text(
                                    action.programActionName,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),

                                // 🔀 Status toggle & Action buttons
                                if (!state.isMultiSelect)
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Transform.scale(
                                        scale: 0.75,
                                        child: Switch(
                                          value: action.isActive,
                                          onChanged: (val) {
                                            notifier.toggleStatus(
                                              action.ProgramActionId,
                                              val,
                                            );
                                            CustomSnackbar.show(
                                              context,
                                              message:
                                                  '${action.programActionName} ${val ? 'enabled' : 'disabled'}',
                                              type: SnackBarType.info,
                                            );
                                          },
                                          activeThumbColor: Colors.green,
                                          materialTapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                        ),
                                      ),
                                      const SizedBox(width: 8),

                                      // Edit button
                                      IconButton(
                                        icon: const Icon(
                                          Icons.edit,
                                          color: Colors.blue,
                                          size: 20,
                                        ),
                                        onPressed: () {
                                          EditProgramActionDialog.show(
                                            context,
                                            ref,
                                            action,
                                          );
                                        },
                                        tooltip: 'Edit',
                                      ),

                                      // Delete button
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                          size: 20,
                                        ),
                                        onPressed: () {
                                          DeleteProgramActionDialog.show(
                                            context,
                                            ref,
                                            action.ProgramActionId,
                                            action.programActionName,
                                          );
                                        },
                                        tooltip: 'Delete',
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),

      // ➕ FAB
      floatingActionButton: state.isMultiSelect
          ? null
          : FloatingActionButton(
              backgroundColor: primaryColor,
              onPressed: () {
                AddProgramActionDialog.show(context, ref);
              },
              child: const Icon(Icons.add, color: Colors.white),
            ),
    );
  }
}
