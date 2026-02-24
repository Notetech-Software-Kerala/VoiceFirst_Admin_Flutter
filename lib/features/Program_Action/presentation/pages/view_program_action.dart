import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/core/widgets/advanced_search_header.dart';
import 'package:voice_first_admin/core/widgets/custom_snackbar.dart';
import 'package:voice_first_admin/core/widgets/delete_bottom_sheet.dart';
import 'package:voice_first_admin/core/widgets/global_filter_bottom_sheet.dart';
import 'package:voice_first_admin/core/models/base_filter_model.dart';
import 'package:voice_first_admin/core/widgets/standard_icon_box.dart';
import 'package:voice_first_admin/core/widgets/standard_list_card.dart';
import 'package:voice_first_admin/core/widgets/standard_page_layout.dart';
import 'package:voice_first_admin/core/widgets/standard_pagination_controls.dart';
import 'package:voice_first_admin/features/Program_Action/models/program_action_filter.dart';
import 'package:voice_first_admin/features/Program_Action/presentation/providers/program_action_provider.dart';
import 'package:voice_first_admin/features/Program_Action/presentation/dialogs/add_program_action_dialog.dart';
import 'package:voice_first_admin/features/Program_Action/presentation/dialogs/edit_program_action_dialog.dart';
import 'program_action_detail_view.dart';

class ProgramActionView extends ConsumerStatefulWidget {
  const ProgramActionView({super.key});

  @override
  ConsumerState<ProgramActionView> createState() => _ProgramActionViewState();
}

class _ProgramActionViewState extends ConsumerState<ProgramActionView> {
  final ScrollController _scrollController = ScrollController();
  late final TextEditingController _searchController;
  static const int _pageSize = 10;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    Future.microtask(() {
      ref
          .read(programActionProvider.notifier)
          .loadAll(
            filter: const ProgramActionFilter(pageNumber: 1, pageSize: 10),
          );
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _goToPage(int page) {
    ref
        .read(programActionProvider.notifier)
        .loadAll(
          filter: ProgramActionFilter(pageNumber: page, pageSize: _pageSize),
        );

    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
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
        searchOptions: const {'name': 'Action Name', 'status': 'Status'},
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final state = ref.watch(programActionProvider);
    final notifier = ref.read(programActionProvider.notifier);

    if (_searchController.text != state.search) {
      _searchController.text = state.search;
    }

    final totalPages = (state.totalCount / _pageSize).ceil();
    final safeTotalPages = totalPages > 0 ? totalPages : 1;

    return StandardPageLayout(
      title: state.isMultiSelect
          ? '${state.selectedIds.length} selected'
          : 'Program Actions',
      scrollController: _scrollController,
      bottom: AdvancedSearchHeader(
        searchController: _searchController,
        hintText: 'Search program actions...',
        onSearchChanged: (value) {
          notifier.loadAll(
            filter: ProgramActionFilter(
              search: value,
              pageNumber: 1,
              pageSize: _pageSize,
            ),
          );
        },
        onFilterTap: _openFilterSheet,
        onRefresh: () => notifier.loadAll(
          filter: ProgramActionFilter(
            search: state.search.isEmpty ? null : state.search,
            pageNumber: state.currentPage,
            pageSize: _pageSize,
          ),
        ),
      ),
      actions: [
        if (!state.isMultiSelect)
          TextButton(
            onPressed: notifier.enterSelectionMode,
            child: const Text('Select'),
          ),
        if (state.isMultiSelect) ...[
          TextButton(
            onPressed: notifier.exitSelectionMode,
            child: const Text('Cancel'),
          ),
          if (state.selectedIds.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () async {
                final error = await notifier.deleteSelected();
                if (context.mounted) {
                  if (error != null) {
                    CustomSnackbar.show(
                      context,
                      message: error,
                      type: SnackBarType.error,
                    );
                  } else {
                    CustomSnackbar.show(
                      context,
                      message: 'Selected actions deleted',
                      type: SnackBarType.success,
                    );
                  }
                }
              },
            ),
        ],
      ],
      onRefresh: () async {
        await notifier.loadAll(
          filter: ProgramActionFilter(
            pageNumber: state.currentPage,
            pageSize: _pageSize,
            search: state.search.isEmpty ? null : state.search,
          ),
        );
      },
      floatingActionButton: state.isMultiSelect
          ? null
          : FloatingActionButton(
              heroTag: 'program_action_list_fab',
              backgroundColor: colorScheme.primary,
              onPressed: () => AddProgramActionDialog.show(context, ref),
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
          const SliverFillRemaining(
            child: Center(child: Text('No program actions found')),
          )
        else
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              16,
              8,
              16,
              kBottomNavigationBarHeight + 8,
            ),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final action = state.filtered[index];
                final isDeleted = action.deleted;
                final selected = state.selectedIds.contains(action.actionId);

                final leading = state.isMultiSelect
                    ? Checkbox(
                        value: selected,
                        onChanged: (_) =>
                            notifier.toggleSelection(action.actionId),
                      )
                    : const StandardIconBox(
                        icon: Icons.extension_rounded,
                        color: Colors.blue,
                      );

                final actions = <Widget>[];
                actions.add(
                  Transform.scale(
                    scale: 0.8,
                    child: Switch(
                      value: action.active,
                      activeThumbColor: Colors.green,
                      onChanged: isDeleted
                          ? null
                          : (val) async {
                              final error = await notifier.toggleStatus(
                                action.actionId,
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
                                      ? '${action.actionName} activated successfully'
                                      : '${action.actionName} deactivated successfully',
                                  type: SnackBarType.success,
                                );
                              }
                            },
                      inactiveThumbColor: isDeleted
                          ? Colors.grey.withAlpha(100)
                          : null,
                    ),
                  ),
                );
                actions.add(
                  StandardActionButton(
                    icon: Icons.edit,
                    color: isDeleted ? Colors.grey.withAlpha(100) : Colors.blue,
                    onTap: () {
                      if (isDeleted) return;
                      EditProgramActionDialog.show(context, ref, action);
                    },
                  ),
                );
                actions.add(
                  StandardActionButton(
                    icon: Icons.delete,
                    color: isDeleted ? Colors.red.withAlpha(100) : Colors.red,
                    onTap: () {
                      if (isDeleted) return;

                      showDeleteBottomSheet(
                        context: context,
                        itemName: action.actionName,
                        onDelete: () async {
                          final error = await notifier.delete(action.actionId);

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
                              message: 'Program action deleted successfully',
                              type: SnackBarType.success,
                            );
                          }
                        },
                      );
                    },
                  ),
                );
                return InkWell(
                  onTap: state.isMultiSelect
                      ? () => notifier.toggleSelection(action.actionId)
                      : () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ProgramActionDetailView(action: action),
                          ),
                        ),
                  onLongPress: isDeleted
                      ? null
                      : () => notifier.toggleSelection(action.actionId),
                  borderRadius: BorderRadius.circular(12),
                  child: StandardListCard(
                    title: action.actionName,
                    subtitle: '',
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
