import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/core/widgets/advanced_search_header.dart';
import 'package:voice_first_admin/core/widgets/custom_snackbar.dart';
import 'package:voice_first_admin/core/widgets/delete_bottom_sheet.dart';
import 'package:voice_first_admin/core/widgets/global_filter_bottom_sheet.dart';
import 'package:voice_first_admin/core/widgets/standard_icon_box.dart';
import 'package:voice_first_admin/core/widgets/standard_list_card.dart';
import 'package:voice_first_admin/core/widgets/standard_page_layout.dart';
import 'package:voice_first_admin/core/widgets/standard_pagination_controls.dart';
import 'package:voice_first_admin/features/issue_character_type/data/models/issue_character_type_filter.dart';
import 'package:voice_first_admin/features/issue_character_type/presentation/dialogs/add_issue_character_type_dialog.dart';
import 'package:voice_first_admin/features/issue_character_type/presentation/dialogs/edit_issue_character_type_dialog.dart';
import 'package:voice_first_admin/features/issue_character_type/presentation/providers/issue_character_type_provider.dart';
import 'package:voice_first_admin/features/issue_character_type/presentation/pages/issue_character_type_detail_page.dart';

class ViewIssueCharacterTypePage extends ConsumerStatefulWidget {
  const ViewIssueCharacterTypePage({super.key});

  @override
  ConsumerState<ViewIssueCharacterTypePage> createState() =>
      _ViewIssueCharacterTypePageState();
}

class _ViewIssueCharacterTypePageState
    extends ConsumerState<ViewIssueCharacterTypePage> {
  static const int _pageSize = 10;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(issueCharacterTypeProvider.notifier).loadAll();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Builder(
        builder: (ctx) {
          final state = ref.read(issueCharacterTypeProvider);
          final notifier = ref.read(issueCharacterTypeProvider.notifier);
          return GlobalFilterBottomSheet(
            currentFilter: state.filter,
            onApply: (base) {
              Navigator.pop(ctx);
              try {
                final b = base;
                notifier.loadAll(
                  filter: IssueCharacterTypeFilter(
                    pageNumber: 1,
                    pageSize: _pageSize,
                    searchText: b.searchText,
                    searchBy: b.searchBy,
                    sortBy: b.sortBy,
                    sortOrder: b.sortOrder,
                    active: b.active,
                    deleted: b.deleted,
                    createdFromDate: b.createdFromDate,
                    createdToDate: b.createdToDate,
                    updatedFromDate: b.updatedFromDate,
                    updatedToDate: b.updatedToDate,
                    deletedFromDate: b.deletedFromDate,
                    deletedToDate: b.deletedToDate,
                  ),
                );
              } catch (_) {}
            },
            searchOptions: const {'name': 'Character Type', 'status': 'Status'},
            sortOptions: const {
              'newest': 'Newest',
              'oldest': 'Oldest',
              'name_asc': 'Name (A-Z)',
              'name_desc': 'Name (Z-A)',
            },
          );
        },
      ),
    );
  }

  void _goToPage(int page) {
    ref.read(issueCharacterTypeProvider.notifier).loadAll(page: page);

    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final state = ref.watch(issueCharacterTypeProvider);
    final notifier = ref.read(issueCharacterTypeProvider.notifier);

    final searchText = state.filter.searchText ?? '';
    if (_searchController.text != searchText) {
      _searchController.text = searchText;
    }

    final safeTotalPages = state.totalPages > 0 ? state.totalPages : 1;

    return StandardPageLayout(
      title: state.isMultiSelect
          ? '${state.selectedIds.length} selected'
          : 'Issue Character Types',
      scrollController: _scrollController,
      bottom: AdvancedSearchHeader(
        searchController: _searchController,
        hintText: 'Search character types...',
        onSearchChanged: notifier.search,
        onFilterTap: _openFilterSheet,
        onRefresh: () => notifier.loadAll(),
      ),
      actions: [
        if (!state.isMultiSelect)
          TextButton(
            onPressed: notifier.enterSelectionMode,
            child: const Text('Select'),
          ),
        if (state.isMultiSelect)
          TextButton(
            onPressed: notifier.exitSelectionMode,
            child: const Text('Cancel'),
          ),
      ],
      onRefresh: () async => notifier.loadAll(),
      floatingActionButton: state.isMultiSelect
          ? null
          : FloatingActionButton(
              heroTag: 'issue_character_type_fab',
              backgroundColor: colorScheme.primary,
              onPressed: () {
                AddIssueCharacterTypeDialog.show(context, ref);
              },
              child: const Icon(Icons.add, color: Colors.white),
            ),
      bottomNavigationBar: (state.isLoading || state.items.isEmpty)
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
        else if (state.items.isEmpty)
          SliverFillRemaining(
            child: Center(
              child: Text(
                'No issue character types found',
                style: theme.textTheme.bodyMedium,
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final item = state.items[index];
                final selected = state.selectedIds.contains(
                  item.issueCharacterTypeId,
                );

                final leading = state.isMultiSelect
                    ? Checkbox(
                        value: selected,
                        onChanged: (_) =>
                            notifier.toggleSelection(item.issueCharacterTypeId),
                      )
                    : StandardIconBox(
                        icon: Icons.label_outline,
                        color: colorScheme.primary,
                      );

                final isActive = item.active;
                final isDeleted = item.deleted;

                // Row actions similar to Business Activity view
                final actions = <Widget>[];
                actions.add(
                  Transform.scale(
                    scale: 0.8,
                    child: Switch(
                      value: isActive,
                      activeThumbColor: Colors.green,
                      onChanged: isDeleted
                          ? null
                          : (val) async {
                              final error = await notifier.update(
                                id: item.issueCharacterTypeId,
                                active: val,
                              );

                              if (!context.mounted) return;

                              if (error != null) {
                                CustomSnackbar.show(
                                  context,
                                  message: error,
                                  type: SnackBarType.error,
                                );
                              } else {
                                // Also refresh detail provider for this id
                                // so an open detail page updates.
                                // ignore: unused_result
                                ref.refresh(
                                  issueCharacterTypeDetailProvider(
                                    item.issueCharacterTypeId,
                                  ),
                                );
                                CustomSnackbar.show(
                                  context,
                                  message: val
                                      ? '${item.issueCharacterType} activated successfully'
                                      : '${item.issueCharacterType} deactivated successfully',
                                  type: SnackBarType.success,
                                );
                              }
                            },
                    ),
                  ),
                );
                actions.add(
                  StandardActionButton(
                    icon: Icons.edit,
                    color: isDeleted
                        ? Colors.grey.withAlpha((0.4 * 255).toInt())
                        : Colors.grey,
                    onTap: () {
                      if (isDeleted) return;

                      EditIssueCharacterTypeDialog.show(context, ref, item);
                    },
                  ),
                );
                actions.add(
                  StandardActionButton(
                    icon: Icons.delete,
                    color: isDeleted
                        ? Colors.red.withAlpha((0.4 * 255).toInt())
                        : Colors.red,
                    onTap: () {
                      if (isDeleted) return;

                      showDeleteBottomSheet(
                        context: context,
                        itemName: item.issueCharacterType,
                        onDelete: () async {
                          final error = await notifier.delete(
                            item.issueCharacterTypeId,
                          );

                          if (context.mounted) {
                            if (error != null) {
                              CustomSnackbar.show(
                                context,
                                message: error,
                                type: SnackBarType.error,
                              );
                            } else {
                              // Keep any open detail page in sync
                              // ignore: unused_result
                              ref.refresh(
                                issueCharacterTypeDetailProvider(
                                  item.issueCharacterTypeId,
                                ),
                              );
                              CustomSnackbar.show(
                                context,
                                message:
                                    'Issue character type deleted successfully',
                                type: SnackBarType.success,
                              );
                            }
                          }
                        },
                      );
                    },
                  ),
                );

                return InkWell(
                  onTap: state.isMultiSelect
                      ? () =>
                            notifier.toggleSelection(item.issueCharacterTypeId)
                      : () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => IssueCharacterTypeDetailPage(
                              id: item.issueCharacterTypeId,
                            ),
                          ),
                        ),
                  onLongPress: isDeleted
                      ? null
                      : () =>
                            notifier.toggleSelection(item.issueCharacterTypeId),
                  borderRadius: BorderRadius.circular(12),
                  child: StandardListCard(
                    leading: leading,
                    title: item.issueCharacterType,
                    subtitle: null,
                    trailing: null,
                    actions: actions,
                  ),
                );
              }, childCount: state.items.length),
            ),
          ),
      ],
    );
  }
}
