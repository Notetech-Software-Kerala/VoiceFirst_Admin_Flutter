import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/features/Business_activity/presentation/widgets/custom_snackbar.dart';
import 'package:voice_first_admin/features/Country%20Management/country/models/country_model.dart';
import 'package:voice_first_admin/features/Country%20Management/division1/models/division1_model.dart';
import 'package:voice_first_admin/features/Country%20Management/division2/models/DivisionTwoModel';
import 'package:voice_first_admin/features/Country%20Management/division3/presentation/providers/division_three_provider.dart';
import 'package:voice_first_admin/features/Country%20Management/division3/presentation/dialogs/delete_division3_dialog.dart';
import 'package:voice_first_admin/features/Country%20Management/division3/presentation/dialogs/edit_division3_dialog.dart';

class DivisionThreeView extends ConsumerWidget {
  final CountryModel country;
  final DivisionOneModel divisionOne;
  final DivisionTwoModel divisionTwo;

  const DivisionThreeView({
    super.key,
    required this.country,
    required this.divisionOne,
    required this.divisionTwo,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(divisionThreeProvider(divisionTwo.id));
    final notifier = ref.read(divisionThreeProvider(divisionTwo.id).notifier);

    final primaryColor = const Color(0xFF0D7FF2);

    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        title: Text(
          state.isMultiSelect
              ? '${state.selectedIds.length} selected'
              : (country.divisionThreeLabel ?? 'Division 3'),
          style: const TextStyle(color: Colors.white),
        ),
        leading: state.isMultiSelect
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: notifier.exitSelectionMode,
              )
            : IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
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

          /// Select All / Clear All
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

          /// Delete
          if (state.isMultiSelect)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.white),
              onPressed: () {
                notifier.deleteSelected();
                CustomSnackbar.show(
                  context,
                  message: 'Selected divisions deleted',
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
                hintText: 'Search divisions...',
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

          // 📋 List
          Expanded(
            child: state.filtered.isEmpty
                ? Center(
                    child: Text(
                      'No divisions found',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  )
                : ListView.builder(
                    itemCount: state.filtered.length,
                    itemBuilder: (context, index) {
                      final d = state.filtered[index];
                      final bool selected = state.selectedIds.contains(d.id);

                      return GestureDetector(
                        onLongPress: () => notifier.toggleSelection(d.id),
                        onTap: () {
                          if (state.isMultiSelect) {
                            notifier.toggleSelection(d.id);
                          } else {
                            // For division3, perhaps show detail or nothing
                            CustomSnackbar.show(
                              context,
                              message: 'View ${d.name}',
                              type: SnackBarType.info,
                            );
                          }
                        },
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
                                    onChanged: (_) =>
                                        notifier.toggleSelection(d.id),
                                    activeColor: primaryColor,
                                  ),

                                // 📄 Division info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        d.name,
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // 🔀 Status toggle
                                if (!state.isMultiSelect)
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Transform.scale(
                                        scale:
                                            0.75, // 👈 adjust between 0.6 – 0.8
                                        child: Switch(
                                          value: d.status,
                                          onChanged: (val) {
                                            notifier.toggleStatus(d.id, val);
                                            CustomSnackbar.show(
                                              context,
                                              message:
                                                  '${d.name} ${val ? 'enabled' : 'disabled'}',
                                              type: SnackBarType.info,
                                            );
                                          },
                                          activeThumbColor: Colors.green,
                                          materialTapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                        ),
                                      ),

                                      PopupMenuButton<String>(
                                        icon: const Icon(Icons.more_vert),
                                        onSelected: (value) {
                                          if (value == 'view') {
                                            CustomSnackbar.show(
                                              context,
                                              message: 'View ${d.name}',
                                              type: SnackBarType.info,
                                            );
                                          } else if (value == 'update') {
                                            EditDivisionThreeDialog.show(
                                              context,
                                              ref,
                                              divisionTwo.id,
                                              d,
                                            );
                                          } else if (value == 'delete') {
                                            DeleteDivisionThreeDialog.show(
                                              context,
                                              ref,
                                              divisionTwo.id,
                                              d.id,
                                              d.name,
                                            );
                                          }
                                        },
                                        itemBuilder: (context) => const [
                                          PopupMenuItem(
                                            value: 'view',
                                            child: Text('View Details'),
                                          ),
                                          PopupMenuItem(
                                            value: 'update',
                                            child: Text('Update'),
                                          ),
                                          PopupMenuItem(
                                            value: 'delete',
                                            child: Text('Delete'),
                                          ),
                                        ],
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        onPressed: () {
          CustomSnackbar.show(
            context,
            message: 'Add Division (mock)',
            type: SnackBarType.info,
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
