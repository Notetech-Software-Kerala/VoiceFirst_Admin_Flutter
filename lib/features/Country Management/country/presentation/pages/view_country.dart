import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/features/Business_activity/presentation/widgets/custom_snackbar.dart';
import 'package:voice_first_admin/features/Country%20Management/country/models/country_model.dart';
import 'package:voice_first_admin/features/Country%20Management/division1/presentation/pages/view_division1.dart';
import '../providers/country_provider.dart';
import '../dialogs/delete_country_dialog.dart';
import '../dialogs/edit_country_dialog.dart';
import 'country_detail_view.dart';

class CountryView extends ConsumerWidget {
  const CountryView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(countryProvider);
    final notifier = ref.read(countryProvider.notifier);

    final primaryColor = const Color(0xFF0D7FF2);

    return Scaffold(
      backgroundColor: Colors.white,

      // ───────────────── AppBar ─────────────────
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        title: Text(
          state.isMultiSelect
              ? '${state.selectedIds.length} selected'
              : 'Countries',
          style: const TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (state.isMultiSelect) {
              notifier.exitSelectionMode();
            } else {
              Navigator.pop(context);
            }
          },
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
                  message: 'Selected countries deleted',
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
              color: primaryColor.withAlpha(20),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: TextField(
              onChanged: notifier.search,
              decoration: InputDecoration(
                hintText: 'Search countries...',
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
                      'No countries found',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  )
                : ListView.builder(
                    itemCount: state.filtered.length,
                    itemBuilder: (context, index) {
                      final CountryModel c = state.filtered[index];
                      final bool selected = state.selectedIds.contains(c.id);

                      // Division labels
                      final d1 = (c.divisionOneLabel ?? '').trim();
                      final d2 = (c.divisionTwoLabel ?? '').trim();
                      final d3 = (c.divisionThreeLabel ?? '').trim();

                      String divisions = '';
                      if (d1.isNotEmpty) divisions = d1;
                      if (d2.isNotEmpty) {
                        divisions += (divisions.isEmpty ? '' : ' > ') + d2;
                      }
                      if (d3.isNotEmpty) {
                        divisions += (divisions.isEmpty ? '' : ' > ') + d3;
                      }

                      return GestureDetector(
                        onLongPress: () => notifier.toggleSelection(c.id),
                        onTap: () {
                          if (state.isMultiSelect) {
                            notifier.toggleSelection(c.id);
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DivisionOneView(country: c),
                              ),
                            );
                          }
                        },
                        child: Card(
                          color: selected
                              ? primaryColor.withAlpha(51)
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
                                        notifier.toggleSelection(c.id),
                                    activeColor: primaryColor,
                                  ),

                                // 📄 Country info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        c.country,
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      if (divisions.isNotEmpty) ...[
                                        const SizedBox(height: 6),
                                        Text(
                                          divisions,
                                          style: const TextStyle(
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
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
                                          value: c.status ?? false,
                                          onChanged: (val) {
                                            notifier.toggleStatus(c.id, val);
                                            CustomSnackbar.show(
                                              context,
                                              message:
                                                  '${c.country} ${val ? 'enabled' : 'disabled'}',
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
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    CountryDetailPage(
                                                      countryId: c.id,
                                                    ),
                                              ),
                                            );
                                          } else if (value == 'update') {
                                            EditCountryDialog.show(
                                              context,
                                              ref,
                                              c,
                                            );
                                          } else if (value == 'delete') {
                                            DeleteCountryDialog.show(
                                              context,
                                              ref,
                                              c.id,
                                              c.country,
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
            message: 'Add Country (mock)',
            type: SnackBarType.info,
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
