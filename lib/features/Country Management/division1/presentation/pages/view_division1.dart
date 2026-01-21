import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/features/Business_activity/presentation/widgets/custom_snackbar.dart';
import 'package:voice_first_admin/features/Country%20Management/country/models/country_model.dart';
import 'package:voice_first_admin/features/Country%20Management/division1/models/division1_model.dart';
import 'package:voice_first_admin/features/Country%20Management/division1/presentation/dialogs/add_division_one.dart';
import 'package:voice_first_admin/features/Country%20Management/division1/presentation/dialogs/delete_division1_dialog.dart';
import 'package:voice_first_admin/features/Country%20Management/division1/presentation/dialogs/edit_division1_dialog.dart';
import 'package:voice_first_admin/features/Country%20Management/division1/presentation/providers/division_one_provider.dart';
import 'package:voice_first_admin/features/Country%20Management/division1/presentation/providers/division_one_state.dart';
import 'package:voice_first_admin/features/Country%20Management/division2/presentation/pages/view_division2.dart';

class DivisionOneView extends ConsumerWidget {
  final CountryModel country;

  const DivisionOneView({super.key, required this.country});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.watch(divisionOneProvider(country.id));
    final state = notifier.state;

    final primaryColor = const Color(0xFF0D7FF2);
    final label = country.divisionOneLabel ?? 'Division';

    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        title: Text(
          state.isMultiSelect ? '${state.selectedIds.length} selected' : label,
          style: const TextStyle(color: Colors.white),
        ),
        leading: state.isMultiSelect
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: notifier.exitSelectionMode,
              )
            : null,
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

          /// Delete
          if (state.isMultiSelect)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.white),
              onPressed: () {
                notifier.deleteSelected();
                CustomSnackbar.show(
                  context,
                  message: 'Selected $label deleted',
                  type: SnackBarType.success,
                );
              },
            ),

          /// Cancel (Exit Selection Mode)
          if (state.isMultiSelect)
            IconButton(
              onPressed: notifier.exitSelectionMode,
              icon: const Icon(Icons.close, color: Colors.white),
            ),
        ],
      ),

      // ───────────────── Body ─────────────────
      body: Column(
        children: [
          //  Search
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: primaryColor.withAlpha(20),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: TextField(
              onChanged: notifier.search,
              decoration: InputDecoration(
                hintText: 'Search $label...',
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

          // /// Select All / Clear All
          // if (state.isMultiSelect)
          //   TextButton(
          //     onPressed: () => notifier.enterSelectionMode(
          //       selectAll: !notifier.allVisibleSelected,
          //     ),
          //     child: Text(
          //       notifier.allVisibleSelected ? 'Clear All' : 'Select All',
          //       style: const TextStyle(color: Colors.white),
          //     ),
          //   ),
          // ✅ Select All / Clear All row under search bar
          if (state.isMultiSelect)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Checkbox(
                    value: notifier.allVisibleSelected,
                    activeColor: primaryColor,
                    onChanged: (val) {
                      notifier.enterSelectionMode(selectAll: val ?? false);
                    },
                  ),
                  Text(
                    notifier.allVisibleSelected ? 'Deselect All' : 'Select All',
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
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
                      'No $label found',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  )
                : ListView.builder(
                    itemCount: state.filtered.length,
                    itemBuilder: (context, index) {
                      final DivisionOneModel d = state.filtered[index];
                      final bool selected = state.selectedIds.contains(d.id);

                      return GestureDetector(
                        onLongPress: () => notifier.toggleSelection(d.id),
                        onTap: () {
                          if (state.isMultiSelect) {
                            notifier.toggleSelection(d.id);
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DivisionTwoView(
                                  country: country,
                                  divisionOne: d,
                                ),
                              ),
                            );
                          }
                        },
                        child: Card(
                          color: selected
                              ? primaryColor.withAlpha(20)
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
                                  child: Text(
                                    d.name,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),

                                // 🔀 Status toggle
                                // if (!state.isMultiSelect)
                                //   Transform.scale(
                                //     scale: 0.75,
                                //     child: Switch(
                                //       value: d.status,
                                //       onChanged: (val) {
                                //         notifier.toggleStatus(d.id, val);
                                //         CustomSnackbar.show(
                                //           context,
                                //           message:
                                //               '${d.name} ${val ? 'enabled' : 'disabled'}',
                                //           type: SnackBarType.info,
                                //         );
                                //       },
                                //       activeThumbColor: Colors.green,
                                //       materialTapTargetSize:
                                //           MaterialTapTargetSize.shrinkWrap,
                                //     ),
                                //   ),
                                if (!state.isMultiSelect)
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Transform.scale(
                                        scale: 0.75,

                                        child: Switch(
                                          value: d.status,
                                          activeThumbColor: Colors.green,
                                          onChanged: (val) {
                                            notifier.toggleStatus(d.id, val);
                                            CustomSnackbar.show(
                                              context,
                                              message:
                                                  '${d.name} ${val ? 'enabled' : 'disabled'}',
                                              type: SnackBarType.info,
                                            );
                                          },
                                        ),
                                      ),

                                      PopupMenuButton<String>(
                                        icon: const Icon(Icons.more_vert),
                                        onSelected: (value) {
                                          if (value == 'edit') {
                                            EditDivision1Dialog.show(
                                              context: context,
                                              ref: ref,
                                              division: d,
                                              countryId: country.id,
                                              label: label,
                                            );
                                          } else if (value == 'delete') {
                                            DeleteDivision1Dialog.show(
                                              context: context,
                                              ref: ref,
                                              id: d.id,
                                              name: d.name,
                                              countryId: country.id,
                                              label: label,
                                            );
                                          }
                                        },
                                        itemBuilder: (context) => const [
                                          PopupMenuItem(
                                            value: 'edit',
                                            child: Text('Edit'),
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
          AddDivision1Dialog.show(
            context: context,
            ref: ref,
            countryId: country.id,
            label: label,
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
