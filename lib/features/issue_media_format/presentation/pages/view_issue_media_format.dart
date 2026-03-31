import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/core/models/base_filter_model.dart';
import 'package:voice_first_admin/core/widgets/advanced_search_header.dart';
import 'package:voice_first_admin/core/widgets/custom_snackbar.dart';
import 'package:voice_first_admin/core/widgets/delete_bottom_sheet.dart';
import 'package:voice_first_admin/core/widgets/global_filter_bottom_sheet.dart';
import 'package:voice_first_admin/core/widgets/standard_icon_box.dart';
import 'package:voice_first_admin/core/widgets/standard_list_card.dart';
import 'package:voice_first_admin/core/widgets/standard_page_layout.dart';
import 'package:voice_first_admin/core/widgets/standard_pagination_controls.dart';
import 'package:voice_first_admin/features/issue_media_format/data/models/issue_media_format_filter.dart';
import 'package:voice_first_admin/features/issue_media_format/presentation/dialogs/add_issue_media_format_dialog.dart';
import 'package:voice_first_admin/features/issue_media_format/presentation/dialogs/edit_issue_media_format_dialog.dart';
import 'package:voice_first_admin/features/issue_media_format/presentation/pages/issue_media_format_detail_page.dart';
import 'package:voice_first_admin/features/issue_media_format/presentation/providers/issue_media_format_provider.dart';

class ViewIssueMediaFormatPage extends ConsumerStatefulWidget {
  const ViewIssueMediaFormatPage({super.key});

  @override
  ConsumerState<ViewIssueMediaFormatPage> createState() =>
      _ViewIssueMediaFormatPageState();
}

class _ViewIssueMediaFormatPageState
    extends ConsumerState<ViewIssueMediaFormatPage> {
  static const int _pageSize = 10;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(issueMediaFormatProvider.notifier).loadAll();
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
      builder: (_) {
        final state = ref.read(issueMediaFormatProvider);
        final notifier = ref.read(issueMediaFormatProvider.notifier);
        return GlobalFilterBottomSheet(
          currentFilter: state.filter,
          onApply: (base) {
            Navigator.pop(context);
            try {
              if (base is! BaseFilterModel) return;
              final b = base;
              notifier.loadAll(
                filter: IssueMediaFormatFilter(
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
          searchOptions: const {'name': 'Media Format', 'status': 'Status'},
          sortOptions: const {
            'newest': 'Newest',
            'oldest': 'Oldest',
            'name_asc': 'Name (A-Z)',
            'name_desc': 'Name (Z-A)',
          },
        );
      },
    );
  }

  void _goToPage(int page) {
    ref.read(issueMediaFormatProvider.notifier).loadAll(page: page);

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

    final state = ref.watch(issueMediaFormatProvider);
    final notifier = ref.read(issueMediaFormatProvider.notifier);

    final searchText = state.filter.searchText ?? '';
    if (_searchController.text != searchText) {
      _searchController.text = searchText;
    }

    final safeTotalPages = state.totalPages > 0 ? state.totalPages : 1;

    return StandardPageLayout(
      title: state.isMultiSelect
          ? '${state.selectedIds.length} selected'
          : 'Issue Media Formats',
      scrollController: _scrollController,
      bottom: AdvancedSearchHeader(
        searchController: _searchController,
        hintText: 'Search media formats...',
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
              heroTag: 'issue_media_format_fab',
              backgroundColor: colorScheme.primary,
              onPressed: () {
                AddIssueMediaFormatDialog.show(context, ref);
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
                'No issue media formats found',
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
                  item.issueMediaFormatId,
                );

                final leading = state.isMultiSelect
                    ? Checkbox(
                        value: selected,
                        onChanged: (_) =>
                            notifier.toggleSelection(item.issueMediaFormatId),
                      )
                    : StandardIconBox(
                        icon: Icons.insert_drive_file_outlined,
                        color: colorScheme.primary,
                      );

                final isActive = item.active;
                final isDeleted = item.deleted;

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
                                id: item.issueMediaFormatId,
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
                                ref.refresh(
                                  issueMediaFormatDetailProvider(
                                    item.issueMediaFormatId,
                                  ),
                                );
                                CustomSnackbar.show(
                                  context,
                                  message: val
                                      ? '${item.issueMediaFormat} activated successfully'
                                      : '${item.issueMediaFormat} suspended successfully',
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

                      EditIssueMediaFormatDialog.show(context, ref, item);
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
                        itemName: item.issueMediaFormat,
                        onDelete: () async {
                          final error = await notifier.delete(
                            item.issueMediaFormatId,
                          );

                          if (context.mounted) {
                            if (error != null) {
                              CustomSnackbar.show(
                                context,
                                message: error,
                                type: SnackBarType.error,
                              );
                            } else {
                              ref.refresh(
                                issueMediaFormatDetailProvider(
                                  item.issueMediaFormatId,
                                ),
                              );
                              CustomSnackbar.show(
                                context,
                                message:
                                    'Issue media format deleted successfully',
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
                      ? () => notifier.toggleSelection(item.issueMediaFormatId)
                      : () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => IssueMediaFormatDetailPage(
                              id: item.issueMediaFormatId,
                            ),
                          ),
                        ),
                  onLongPress: isDeleted
                      ? null
                      : () => notifier.toggleSelection(item.issueMediaFormatId),
                  borderRadius: BorderRadius.circular(12),
                  child: StandardListCard(
                    leading: leading,
                    title: item.issueMediaFormat,
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
