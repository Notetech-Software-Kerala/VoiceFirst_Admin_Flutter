import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/core/widgets/delete_bottom_sheet.dart';
import 'package:voice_first_admin/core/widgets/pagination_controls.dart';
import 'package:voice_first_admin/core/widgets/standard_icon_box.dart';
import 'package:voice_first_admin/core/widgets/standard_list_card.dart';
import 'package:voice_first_admin/core/widgets/standard_page_layout.dart';
import '../providers/business_activity_provider.dart';
import 'package:voice_first_admin/features/Business_activity/presentation/dialogs/add_activity_dialog.dart';
import 'package:voice_first_admin/features/Business_activity/presentation/dialogs/edit_activity_dialog.dart';
import 'package:voice_first_admin/features/Business_activity/presentation/widgets/activity_querybar.dart';
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(businessActivityProvider.notifier).load();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final state = ref.watch(businessActivityProvider);
    final notifier = ref.read(businessActivityProvider.notifier);

    return StandardPageLayout(
      title: state.isMultiSelect
          ? '${state.selectedIds.length} selected'
          : 'Business Activities',
      leading: InkWell(
        onTap: () {
          if (state.isMultiSelect) {
            notifier.exitSelectionMode();
          } else {
            Navigator.of(context).popUntil((r) => r.isFirst);
          }
        },
        borderRadius: BorderRadius.circular(50),
        child: Container(
          margin: const EdgeInsets.all(8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: theme.brightness == Brightness.dark
                ? Colors.white.withAlpha(13)
                : Colors.grey[100],
          ),
          child: const Icon(Icons.arrow_back_ios_new, size: 20),
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
      bottom: const ActivityQueryBar(),
      onRefresh: () async => notifier.load(),
      floatingActionButton: FloatingActionButton(
        heroTag: 'business_activity_list_fab',
        onPressed: () => AddActivityDialog.show(context, ref),
        backgroundColor: colorScheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: (state.isLoading || state.items.isEmpty)
          ? null
          : Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: theme.cardColor,
                border: Border(top: BorderSide(color: theme.dividerColor)),
              ),
              child: PaginationControls(
                currentPage: state.currentPage,
                totalCount: state.totalCount,
                pageSize: _pageSize,
                isLoading: state.isLoading,
                hasMoreData: state.hasMoreData,
                onPageChanged: (page) {
                  ref.read(businessActivityProvider.notifier).goToPage(page);
                },
                primaryColor: colorScheme.primary,
              ),
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

                // final statusChip = Container(
                //   padding: const EdgeInsets.symmetric(
                //     horizontal: 10,
                //     vertical: 4,
                //   ),
                //   decoration: BoxDecoration(
                //     color: a.isDeleted
                //         ? Colors.red.withAlpha(38)
                //         : a.active
                //         ? Colors.green.withAlpha(38)
                //         : Colors.orange.withAlpha(38),
                //     borderRadius: BorderRadius.circular(20),
                //   ),
                //   child: Text(
                //     a.isDeleted
                //         ? 'DELETED'
                //         : a.active
                //         ? 'ACTIVE'
                //         : 'INACTIVE',
                //     style: TextStyle(
                //       fontSize: 11,
                //       fontWeight: FontWeight.bold,
                //       color: a.isDeleted
                //           ? Colors.red
                //           : a.active
                //           ? Colors.green
                //           : Colors.orange,
                //     ),
                //   ),
                // );

                final actions = <Widget>[];
                if (!a.isDeleted) {
                  actions.add(
                    Transform.scale(
                      scale: 0.8,
                      child: Switch(
                        value: a.active,
                        onChanged: (val) async {
                          final error = await notifier.update(
                            id: a.activityId,
                            active: val,
                          );
                          if (context.mounted && error != null) {
                            CustomSnackbar.show(
                              context,
                              message: error,
                              type: SnackBarType.error,
                            );
                          }
                        },
                      ),
                    ),
                  );
                  actions.add(
                    StandardActionButton(
                      icon: Icons.edit,
                      color: Colors.grey,
                      onTap: () => EditActivityDialog.show(context, ref, a),
                    ),
                  );
                  actions.add(
                    StandardActionButton(
                      icon: Icons.delete,
                      color: Colors.red,
                      onTap: () {
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
                }

                return InkWell(
                  onTap: state.isMultiSelect
                      ? () => notifier.toggleSelection(a.activityId)
                      : () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ActivityDetailPage(activity: a),
                          ),
                        ),
                  onLongPress: a.isDeleted
                      ? null
                      : () => notifier.toggleSelection(a.activityId),
                  borderRadius: BorderRadius.circular(12),
                  child: StandardListCard(
                    title: a.activityName,
                    subtitle: a.isDeleted
                        ? 'Deleted'
                        : (a.active ? 'Active' : 'Inactive'),
                    leading: leading,
                    // trailing: statusChip,
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
