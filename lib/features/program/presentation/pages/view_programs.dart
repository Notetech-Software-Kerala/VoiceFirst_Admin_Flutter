import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/core/widgets/advanced_search_header.dart';
import 'package:voice_first_admin/core/widgets/delete_bottom_sheet.dart';
import 'package:voice_first_admin/core/widgets/global_filter_bottom_sheet.dart';
import 'package:voice_first_admin/core/models/base_filter_model.dart';
import 'package:voice_first_admin/core/widgets/standard_icon_box.dart';
import 'package:voice_first_admin/core/widgets/standard_list_card.dart';
import 'package:voice_first_admin/core/widgets/standard_page_layout.dart';
import 'package:voice_first_admin/core/widgets/standard_pagination_controls.dart';
import 'package:voice_first_admin/core/widgets/custom_snackbar.dart';
import 'package:voice_first_admin/features/program/presentation/pages/add_program_page.dart';
import 'package:voice_first_admin/features/program/presentation/pages/program_detail_page.dart';
import 'package:voice_first_admin/features/program/presentation/providers/program_provider.dart';
import 'package:voice_first_admin/features/program/data/models/program_filter.dart';

class ProgramManagementView extends ConsumerStatefulWidget {
  const ProgramManagementView({super.key});

  @override
  ConsumerState<ProgramManagementView> createState() =>
      _ProgramManagementViewState();
}

class _ProgramManagementViewState extends ConsumerState<ProgramManagementView> {
  late final TextEditingController _searchController;
  static const int _pageSize = 10;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(programProvider.notifier)
          .loadAll(
            filter: const ProgramFilter(pageNumber: 1, limit: _pageSize),
          );
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _goToPage(int page) {
    final currentSearch = ref.read(programProvider).search;
    ref
        .read(programProvider.notifier)
        .loadAll(
          filter: ProgramFilter(
            pageNumber: page,
            limit: _pageSize,
            searchText: currentSearch.isEmpty ? null : currentSearch,
          ),
        );
  }

  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => GlobalFilterBottomSheet(
        currentFilter: const BaseFilterModel(),
        onApply: (filter) {
          // Apply filter logic here
          Navigator.pop(context);
        },
        searchOptions: const {'name': 'Program Name', 'status': 'Status'},
        sortOptions: const {
          'newest': 'Newest',
          'oldest': 'Oldest',
          'name_asc': 'Name (A-Z)',
          'name_desc': 'Name (Z-A)',
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ref = this.ref;
    final state = ref.watch(programProvider);
    final notifier = ref.read(programProvider.notifier);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final totalPages = (state.totalCount / _pageSize).ceil();
    final safeTotalPages = totalPages > 0 ? totalPages : 1;

    // Keep the search controller in sync with provider state
    if (_searchController.text != state.search) {
      _searchController.text = state.search;
    }

    return StandardPageLayout(
      title: state.isMultiSelect
          ? '${state.selectedIds.length} selected'
          : 'Program Management',
      bottom: AdvancedSearchHeader(
        searchController: _searchController,
        hintText: 'Search programs by name, label or route...',
        onSearchChanged: notifier.search,
        onFilterTap: _openFilterSheet,
        onRefresh: () => notifier.loadAll(
          filter: ProgramFilter(
            pageNumber: state.currentPage,
            limit: _pageSize,
            searchText: state.search.isEmpty ? null : state.search,
          ),
        ),
      ),
      actions: [
        if (!state.isMultiSelect)
          TextButton(
            onPressed: () => notifier.enterSelectionMode(),
            child: const Text('Select'),
          ),
        if (state.isMultiSelect) ...[
          TextButton(
            onPressed: () => notifier.exitSelectionMode(),
            child: const Text('Cancel'),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            tooltip: 'Delete Selected',
            onPressed: () async {
              await notifier.deleteSelected();
              if (context.mounted) {
                CustomSnackbar.show(
                  context,
                  message: 'Selected programs deleted',
                  type: SnackBarType.success,
                );
              }
            },
          ),
        ],
      ],
      onRefresh: () async {
        final currentSearch = state.search;
        await notifier.loadAll(
          filter: ProgramFilter(
            pageNumber: state.currentPage,
            limit: _pageSize,
            searchText: currentSearch.isEmpty ? null : currentSearch,
          ),
        );
      },
      floatingActionButton: state.isMultiSelect
          ? null
          : FloatingActionButton(
              heroTag: 'program_fab',
              backgroundColor: colorScheme.primary,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddProgramPage()),
                );
              },
              child: const Icon(Icons.add, color: Colors.white),
            ),
      bottomNavigationBar: (state.isLoading || state.filtered.isEmpty)
          ? null
          : StandardPaginationControls(
              currentPage: state.currentPage,
              totalPages: safeTotalPages,
              onPageChanged: _goToPage,
            ),
      slivers: [
        if (state.isLoading)
          const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          )
        else if (state.filtered.isEmpty)
          SliverFillRemaining(
            child: Center(
              child: Text(
                'No programs found',
                style: theme.textTheme.bodyMedium,
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final program = state.filtered[index];
                final id = program.sysProgramId;
                final isDeleted = program.deleted ?? false;
                final selected = id != null && state.selectedIds.contains(id);

                final leading = state.isMultiSelect && id != null
                    ? Checkbox(
                        value: selected,
                        onChanged: (_) => notifier.toggleSelection(id),
                      )
                    : StandardIconBox(
                        icon: Icons.apps,
                        color: colorScheme.primary,
                      );

                final actions = <Widget>[];
                if (id != null) {
                  actions.add(
                    Transform.scale(
                      scale: 0.75,
                      child: Switch(
                        value: program.active ?? true,
                        onChanged: isDeleted
                            ? null
                            : (val) async {
                                final error = await notifier.toggleStatus(
                                  id,
                                  val,
                                );
                                if (!context.mounted) return;
                                if (error != null) {
                                  CustomSnackbar.show(
                                    context,
                                    message: error,
                                    type: SnackBarType.error,
                                  );
                                } else {
                                  CustomSnackbar.show(
                                    context,
                                    message: val
                                        ? 'Program activated successfully'
                                        : 'Program deactivated successfully',
                                    type: SnackBarType.success,
                                  );
                                }
                              },
                        activeThumbColor: Colors.green,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        inactiveThumbColor: isDeleted
                            ? Colors.grey.withAlpha(102)
                            : null,
                      ),
                    ),
                  );
                  actions.add(
                    StandardActionButton(
                      icon: Icons.edit_outlined,
                      color: isDeleted
                          ? Colors.grey.withAlpha(102)
                          : colorScheme.primary,
                      onTap: () {
                        if (isDeleted) return;

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProgramDetailPage(
                              programId: program.sysProgramId!,
                              startInEditMode: true,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                  actions.add(
                    StandardActionButton(
                      icon: Icons.delete,
                      color: isDeleted ? Colors.red.withAlpha(102) : Colors.red,
                      onTap: () {
                        if (isDeleted) return;

                        showDeleteBottomSheet(
                          context: context,
                          itemName: program.programName,
                          onDelete: () async {
                            try {
                              await ref
                                  .read(programProvider.notifier)
                                  .delete(id);
                              if (context.mounted) {
                                CustomSnackbar.show(
                                  context,
                                  message: 'Program deleted successfully',
                                  type: SnackBarType.success,
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                CustomSnackbar.show(
                                  context,
                                  message: 'Failed to delete program',
                                  type: SnackBarType.error,
                                );
                              }
                            }
                          },
                        );
                      },
                    ),
                  );
                }

                return InkWell(
                  onTap: id == null
                      ? null
                      : state.isMultiSelect
                      ? () => notifier.toggleSelection(id)
                      : () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProgramDetailPage(
                              programId: program.sysProgramId!,
                              startInEditMode: false,
                            ),
                          ),
                        ),
                  onLongPress: id == null
                      ? null
                      : () => notifier.toggleSelection(id),
                  borderRadius: BorderRadius.circular(12),
                  child: StandardListCard(
                    title: program.programName,
                    subtitle: program.labelName,
                    leading: leading,
                    actions: actions,
                  ),
                );
              }, childCount: state.filtered.length),
            ),
          ),
      ],
    );
  }
}

// ignore: unused_element
class _ProgramCard extends StatelessWidget {
  final String name;
  final String label;
  final bool isDeleted;
  final bool isActive;
  final bool selected;
  final bool showCheckbox;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final ValueChanged<bool>? onToggle;

  const _ProgramCard({
    required this.name,
    required this.label,
    required this.isDeleted,
    required this.isActive,
    required this.selected,
    required this.showCheckbox,
    // ignore: unused_element_parameter
    this.onTap,
    // ignore: unused_element_parameter
    this.onDelete,
    // ignore: unused_element_parameter
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF0D7FF2);
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? primaryColor.withAlpha(31) : theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: selected ? Border.all(color: primaryColor, width: 1.5) : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(8),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showCheckbox)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Checkbox(value: selected, onChanged: (_) {}),
              ),

            /// ICON
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: primaryColor.withAlpha(26),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.extension_rounded, color: primaryColor),
            ),

            const SizedBox(width: 16),

            /// TEXT CONTENT
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDeleted ? Colors.red : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                  const SizedBox(height: 8),

                  /// STATUS CHIP
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isDeleted
                          ? Colors.red.withAlpha(38)
                          : isActive
                          ? Colors.green.withAlpha(38)
                          : Colors.orange.withAlpha(38),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isDeleted
                          ? 'DELETED'
                          : isActive
                          ? 'ACTIVE'
                          : 'SUSPENDED',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isDeleted
                            ? Colors.red
                            : isActive
                            ? Colors.green
                            : Colors.orange,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            /// ACTIONS
            if (!isDeleted)
              Column(
                children: [
                  Transform.scale(
                    scale: 0.75,
                    child: Switch(
                      value: isActive,
                      onChanged: onToggle,
                      activeThumbColor: Colors.green,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                    onPressed: onDelete,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
