import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/core/widgets/advanced_search_header.dart';
import 'package:voice_first_admin/core/widgets/delete_bottom_sheet.dart';
import 'package:voice_first_admin/core/widgets/global_filter_bottom_sheet.dart';
import 'package:voice_first_admin/core/widgets/standard_icon_box.dart';
import 'package:voice_first_admin/core/widgets/standard_list_card.dart';
import 'package:voice_first_admin/core/widgets/standard_page_layout.dart';
import 'package:voice_first_admin/core/widgets/standard_pagination_controls.dart';
import 'package:voice_first_admin/features/Business_activity/presentation/pages/add_activity.dart';
import 'package:voice_first_admin/features/Business_activity/presentation/pages/edit_activity_page.dart';
import '../providers/business_activity_provider.dart';
import 'package:voice_first_admin/core/widgets/custom_snackbar.dart';
import 'activity_detail_page.dart';

class ViewBusinessActivityPage extends ConsumerStatefulWidget {
  const ViewBusinessActivityPage({super.key});

  @override
  ConsumerState<ViewBusinessActivityPage> createState() =>
      _ViewBusinessActivityPageState();
}

class _ViewBusinessActivityPageState
    extends ConsumerState<ViewBusinessActivityPage> {
  static const int _pageSize = 10;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  void _openFilterSheet() {
    final state = ref.read(businessActivityProvider);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => GlobalFilterBottomSheet(
        currentFilter: state.filter,
        searchOptions: const {
          'ActivityName': 'Activity Name',
          'CreatedUser': 'Created User',
          'ModifiedUser': 'Modified User',
          'DeletedUser': 'Deleted User',
        },
        sortOptions: const {
          'activityName': 'Activity Name',
          'createdDate': 'Created Date',
          'modifiedDate': 'Updated Date',
        },
        onApply: (filter) {
          ref
              .read(businessActivityProvider.notifier)
              .load(filter: filter, page: 1);
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(businessActivityProvider.notifier).load();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final state = ref.watch(businessActivityProvider);
    final notifier = ref.read(businessActivityProvider.notifier);

    final totalPages = (state.totalCount / _pageSize).ceil();
    final safeTotalPages = totalPages > 0 ? totalPages : 1;

    return StandardPageLayout(
      title: state.isMultiSelect
          ? '${state.selectedIds.length} selected'
          : 'Business Activities',
      bottom: AdvancedSearchHeader(
        searchController: _searchController,
        hintText: 'Search activities...',
        onSearchChanged: (value) {
          final currentFilter = state.filter;

          final newFilter = currentFilter.copyWith(
            searchText: value.isEmpty ? null : value,
            searchBy: value.isEmpty ? null : 'ActivityName',
          );

          notifier.load(filter: newFilter, page: 1);
        },
        onFilterTap: _openFilterSheet,
        onRefresh: () => notifier.load(),
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
                    message: 'Selected activities deleted',
                    type: SnackBarType.success,
                  );
                }
              }
            },
          ),
        ],
      ],
      onRefresh: () async => notifier.load(),
      floatingActionButton: FloatingActionButton(
        heroTag: 'business_activity_list_fab',
        // onPressed: () => AddActivityDialog.show(context, ref),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddActivityPage()),
          );
        },
        backgroundColor: colorScheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: (state.isLoading || state.items.isEmpty)
          ? null
          : StandardPaginationControls(
              currentPage: state.currentPage,
              totalPages: safeTotalPages,
              onPageChanged: (page) =>
                  ref.read(businessActivityProvider.notifier).load(page: page),
              // onPageChanged: (page) =>
              //     ref.read(businessActivityProvider.notifier).goToPage(page),
            ),
      slivers: [
        if (state.isLoading)
          const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          )
        else if (state.items.isEmpty)
          SliverFillRemaining(child: _EmptyState(theme: theme))
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final a = state.items[index];
                final selected = state.selectedIds.contains(a.activityId);

                final leading = state.isMultiSelect
                    ? Checkbox(
                        value: selected,
                        onChanged: (_) =>
                            notifier.toggleSelection(a.activityId),
                      )
                    : const StandardIconBox(
                        icon: Icons.work_outline,
                        color: Colors.blue,
                      );

                final actions = <Widget>[];
                actions.add(
                  Transform.scale(
                    scale: 0.8,
                    child: Switch(
                      value: a.active,
                      activeThumbColor: Colors.green,
                      onChanged: a.isDeleted
                          ? null
                          : (val) async {
                              final error = await notifier.update(
                                id: a.activityId,
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
                                CustomSnackbar.show(
                                  context,
                                  message: val
                                      ? '${a.activityName} activated Successfully'
                                      : '${a.activityName} deactivated Successfully',
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
                    color: a.isDeleted
                        ? Colors.grey.withAlpha((0.4 * 255).toInt())
                        : Colors.grey,
                    onTap: () {
                      if (a.isDeleted) return;

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditActivityPage(activity: a),
                        ),
                      );
                    },
                  ),
                );
                actions.add(
                  StandardActionButton(
                    icon: Icons.delete,
                    color: a.isDeleted
                        ? Colors.red.withAlpha((0.4 * 255).toInt())
                        : Colors.red,
                    onTap: () {
                      if (a.isDeleted) return;

                      showDeleteBottomSheet(
                        context: context,
                        itemName: a.activityName,
                        onDelete: () async {
                          final error = await notifier.delete(a.activityId);
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
                                message: 'Activity deleted successfully',
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
                      ? () => notifier.toggleSelection(a.activityId)
                      : () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ActivityDetailPage(activityId: a.activityId),
                          ),
                        ),
                  onLongPress: a.isDeleted
                      ? null
                      : () => notifier.toggleSelection(a.activityId),
                  borderRadius: BorderRadius.circular(12),
                  child: StandardListCard(
                    title: a.activityName,
                    leading: leading,
                    trailing: null,
                    actions: actions,
                    subtitle: '',
                  ),
                );
              }, childCount: state.items.length),
            ),
          ),
      ],
    );
  }
}

// ───────────────── EMPTY ─────────────────
class _EmptyState extends StatelessWidget {
  final ThemeData theme;
  const _EmptyState({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 64, color: theme.disabledColor),
          const SizedBox(height: 16),
          Text('No activities found', style: theme.textTheme.titleMedium),
          const SizedBox(height: 6),
          Text('Tap + to add a new activity', style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}
