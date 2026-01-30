import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/core/widgets/pagination_controls.dart';
import 'package:voice_first_admin/features/Business_activity/models/activity_filter_option.dart';
import 'package:voice_first_admin/features/Business_activity/models/activity_searchby.dart';
import 'package:voice_first_admin/features/Business_activity/presentation/dialogs/edit_activity_dialog.dart';
import 'package:voice_first_admin/features/Business_activity/presentation/providers/business_activity_notifier.dart';
import 'package:voice_first_admin/features/Business_activity/presentation/widgets/activity_querybar.dart';
import '../providers/business_activity_provider.dart';
import '../dialogs/add_activity_dialog.dart';
import '../dialogs/delete_activity_dialog.dart';
import '../dialogs/bulk_delete_dialog.dart';
import '../widgets/custom_snackbar.dart';
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final state = ref.watch(businessActivityProvider);
    final notifier = ref.read(businessActivityProvider.notifier);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          Column(
            children: [
              // ───────── HEADER ─────────
              _Header(
                theme: theme,
                title: state.isMultiSelect
                    ? '${state.selectedIds.length} selected'
                    : 'Business Activities',
                onBack: () {
                  if (state.isMultiSelect) {
                    notifier.exitSelectionMode();
                  } else {
                    Navigator.of(context).popUntil((r) => r.isFirst);
                  }
                },

                onRefresh: () =>
                    ref.read(businessActivityProvider.notifier).load(),

                actions: [
                  if (!state.isMultiSelect)
                    TextButton(
                      onPressed: notifier.enterSelectionMode,
                      child: const Text('Select'),
                    ),
                  if (state.isMultiSelect)
                    TextButton(
                      onPressed: () => notifier.enterSelectionMode(
                        selectAll: !notifier.allVisibleSelected,
                      ),
                      child: Text(
                        notifier.allVisibleSelected
                            ? 'Clear All'
                            : 'Select All',
                      ),
                    ),
                  if (state.isMultiSelect)
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      color: colorScheme.error,
                      onPressed: () => BulkDeleteDialog.show(
                        context,
                        ref,
                        state.selectedIds.length,
                      ),
                    ),
                ],
              ),
              const ActivityQueryBar(),

              // ───────── LIST ─────────
              Expanded(
                child: state.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : state.items.isEmpty
                    ? _EmptyState(theme: theme)
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),

                        itemCount: state.items.length,
                        itemBuilder: (_, i) {
                          final a = state.items[i];
                          final selected = state.selectedIds.contains(
                            a.activityId,
                          );

                          return _ActivityCard(
                            activity: a,
                            selected: selected,
                            isMultiSelect: state.isMultiSelect,
                            onTap: state.isMultiSelect
                                ? () => notifier.toggleSelection(a.activityId)
                                : null,
                            onLongPress: () =>
                                notifier.toggleSelection(a.activityId),
                            onView: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ActivityDetailPage(activity: a),
                              ),
                            ),
                            onDelete: () async {
                              DeleteActivityDialog.show(
                                context,
                                ref,
                                a.activityId,
                                a.activityName,
                              );
                            },
                            onSwitch: (val) async {
                              final error = await notifier.update(
                                id: a.activityId,
                                active: val,
                              );

                              if (!mounted) return;

                              CustomSnackbar.show(
                                context,
                                message:
                                    error ??
                                    '${a.activityName} ${val ? 'enabled' : 'disabled'}',
                                type: error == null
                                    ? SnackBarType.info
                                    : SnackBarType.error,
                              );
                            },
                            onEdit: () {
                              EditActivityDialog.show(context, ref, a);
                            },
                          );
                        },
                      ),
              ),
            ],
          ),

          // ───────── FAB ─────────
          Positioned(
            bottom: 24,
            right: 16,
            child: FloatingActionButton(
              heroTag: 'business_activity_list_fab',
              onPressed: () => AddActivityDialog.show(context, ref),
              backgroundColor: colorScheme.primary,
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ),
        ],
      ),

      // ───────── PAGINATION ─────────
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
    );
  }
}

// ───────────────── HEADER ─────────────────
class _Header extends StatelessWidget {
  final ThemeData theme;
  final String title;
  final VoidCallback onBack;
  final VoidCallback onRefresh;
  final List<Widget> actions;

  const _Header({
    required this.theme,
    required this.title,
    required this.onBack,
    required this.onRefresh,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90 + MediaQuery.of(context).padding.top,
      padding: EdgeInsets.fromLTRB(
        16,
        MediaQuery.of(context).padding.top + 16,
        16,
        12,
      ),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor.withValues(alpha: 0.95),
        border: Border(bottom: BorderSide(color: theme.dividerColor)),
      ),
      child: Row(
        children: [
          _HeaderButton(icon: Icons.arrow_back_ios_new, onTap: onBack),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ...actions,
          const SizedBox(width: 8),
          _HeaderButton(icon: Icons.refresh, onTap: onRefresh),
        ],
      ),
    );
  }
}

class _HeaderButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _HeaderButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: theme.cardColor,
          border: Border.all(color: theme.dividerColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18),
      ),
    );
  }
}

// ───────────────── CARD ─────────────────
class _ActivityCard extends StatelessWidget {
  final activity;
  final bool selected;
  final bool isMultiSelect;
  final VoidCallback? onTap;
  final VoidCallback onLongPress;
  final VoidCallback onView;
  final VoidCallback onDelete;
  final ValueChanged<bool> onSwitch;
  final VoidCallback onEdit;

  const _ActivityCard({
    required this.activity,
    required this.selected,
    required this.isMultiSelect,
    required this.onTap,
    required this.onLongPress,
    required this.onView,
    required this.onDelete,
    required this.onSwitch,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: isMultiSelect ? null : onView,
      // onLongPress: onLongPress,
      onLongPress: activity.isDeleted ? null : onLongPress,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isMultiSelect)
              Checkbox(value: selected, onChanged: (_) => onTap?.call()),

            // else
            //   Container(
            //     width: 48,
            //     height: 48,
            //     decoration: BoxDecoration(
            //       color: colorScheme.primary.withValues(alpha: 0.1),
            //       borderRadius: BorderRadius.circular(8),
            //     ),
            //     // child: Icon(Icons.work_outline, color: colorScheme.primary),
            //   ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          activity.activityName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: activity.isDeleted
                                ? theme.colorScheme.error
                                : theme.textTheme.bodyLarge?.color,
                          ),
                        ),
                      ),
                      if (!activity.isDeleted)
                        Transform.scale(
                          scale: 0.7,
                          child: Switch(
                            value: activity.active,
                            onChanged: onSwitch,
                            activeThumbColor: Colors.green[600],
                            inactiveThumbColor: theme.disabledColor,
                            inactiveTrackColor: theme.dividerColor,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            if (!activity.isDeleted)
              Padding(
                padding: const EdgeInsets.only(left: 8, top: 4),
                child: Row(
                  children: [
                    InkWell(
                      onTap: onEdit,
                      borderRadius: BorderRadius.circular(99),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: theme.primaryColor.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.edit,
                          size: 18,
                          color: theme.primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: onDelete,
                      borderRadius: BorderRadius.circular(99),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.delete,
                          size: 18,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
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
