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
import 'package:voice_first_admin/features/issue_media_type/presentation/dialogs/add_issue_media_type_dialog.dart';
import 'package:voice_first_admin/features/issue_media_type/presentation/dialogs/edit_issue_media_type_dialog.dart';
import 'package:voice_first_admin/features/issue_media_type/presentation/pages/issue_media_type_detail_page.dart';
import 'package:voice_first_admin/features/issue_media_type/presentation/providers/issue_media_type_provider.dart';

class ViewIssueMediaTypePage extends ConsumerStatefulWidget {
  const ViewIssueMediaTypePage({super.key});

  @override
  ConsumerState<ViewIssueMediaTypePage> createState() =>
      _ViewIssueMediaTypePageState();
}

class _ViewIssueMediaTypePageState
    extends ConsumerState<ViewIssueMediaTypePage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(issueMediaTypeProvider.notifier).loadAll();
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
      builder: (_) => GlobalFilterBottomSheet(
        currentFilter: ref.read(issueMediaTypeProvider).filter,
        onApply: (base) {
          Navigator.pop(context);

          final applied = ref
              .read(issueMediaTypeProvider)
              .filter
              .copyWith(
                pageNumber: 1,
                searchText: base.searchText,
                searchBy: base.searchBy,
                sortBy: base.sortBy,
                sortOrder: base.sortOrder,
                active: base.active,
                deleted: base.deleted,
                createdFromDate: base.createdFromDate,
                createdToDate: base.createdToDate,
                updatedFromDate: base.updatedFromDate,
                updatedToDate: base.updatedToDate,
                deletedFromDate: base.deletedFromDate,
                deletedToDate: base.deletedToDate,
              );

          ref
              .read(issueMediaTypeProvider.notifier)
              .loadAll(filter: applied, page: 1);
        },
        searchOptions: const {'name': 'Media Type', 'status': 'Status'},
        sortOptions: const {
          'newest': 'Newest',
          'oldest': 'Oldest',
          'name_asc': 'Name (A-Z)',
          'name_desc': 'Name (Z-A)',
        },
      ),
    );
  }

  void _goToPage(int page) {
    ref.read(issueMediaTypeProvider.notifier).goToPage(page);

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

    final state = ref.watch(issueMediaTypeProvider);
    final notifier = ref.read(issueMediaTypeProvider.notifier);

    if (_searchController.text != (state.filter.searchText ?? '')) {
      _searchController.text = state.filter.searchText ?? '';
    }

    final totalPagesFromCount = (state.totalCount / state.filter.pageSize)
        .ceil();
    final safeTotalPages = totalPagesFromCount > 0 ? totalPagesFromCount : 1;

    return StandardPageLayout(
      title: state.isMultiSelect
          ? '${state.selectedIds.length} selected'
          : 'Issue Media Types',
      scrollController: _scrollController,
      bottom: AdvancedSearchHeader(
        searchController: _searchController,
        hintText: 'Search media types...',
        onSearchChanged: notifier.search,
        onFilterTap: _openFilterSheet,
        onRefresh: () => notifier.loadAll(page: 1),
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
              heroTag: 'issue_media_type_fab',
              backgroundColor: colorScheme.primary,
              onPressed: () {
                AddIssueMediaTypeDialog.show(context, ref);
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
                'No issue media types found',
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
                  item.issueMediaTypeId,
                );

                final leading = state.isMultiSelect
                    ? Checkbox(
                        value: selected,
                        onChanged: (_) =>
                            notifier.toggleSelection(item.issueMediaTypeId),
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
                                id: item.issueMediaTypeId,
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
                                // ignore: unused_result
                                ref.refresh(
                                  issueMediaTypeDetailProvider(
                                    item.issueMediaTypeId,
                                  ),
                                );
                                CustomSnackbar.show(
                                  context,
                                  message: val
                                      ? '${item.issueMediaType} activated successfully'
                                      : '${item.issueMediaType} suspended successfully',
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

                      EditIssueMediaTypeDialog.show(context, ref, item);
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
                        itemName: item.issueMediaType,
                        onDelete: () async {
                          final error = await notifier.delete(
                            item.issueMediaTypeId,
                          );

                          if (context.mounted) {
                            if (error != null) {
                              CustomSnackbar.show(
                                context,
                                message: error,
                                type: SnackBarType.error,
                              );
                            } else {
                              // ignore: unused_result
                              ref.refresh(
                                issueMediaTypeDetailProvider(
                                  item.issueMediaTypeId,
                                ),
                              );
                              CustomSnackbar.show(
                                context,
                                message:
                                    'Issue media type deleted successfully',
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
                      ? () => notifier.toggleSelection(item.issueMediaTypeId)
                      : () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => IssueMediaTypeDetailPage(
                              id: item.issueMediaTypeId,
                            ),
                          ),
                        ),
                  onLongPress: isDeleted
                      ? null
                      : () => notifier.toggleSelection(item.issueMediaTypeId),
                  borderRadius: BorderRadius.circular(12),
                  child: StandardListCard(
                    leading: leading,
                    title: item.issueMediaType,
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
