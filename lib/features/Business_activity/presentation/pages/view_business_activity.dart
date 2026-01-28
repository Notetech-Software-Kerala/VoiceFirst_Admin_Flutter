import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/core/widgets/pagination_controls.dart';
import 'package:voice_first_admin/features/Business_activity/models/business_activity_filter.dart';
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
  final ScrollController _scrollController = ScrollController();
  static const int _pageSize = 10;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(businessActivityProvider.notifier)
          .loadAll(
            filter: BusinessActivityFilter(pageNumber: 1, limit: _pageSize),
          );
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _goToPage(int page) {
    ref
        .read(businessActivityProvider.notifier)
        .loadAll(
          filter: BusinessActivityFilter(pageNumber: page, limit: _pageSize),
        );

    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(businessActivityProvider);
    final notifier = ref.read(businessActivityProvider.notifier);
    final primaryColor = const Color(0xFF0D7FF2);

    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        title: Text(
          style: TextStyle(color: Colors.white),
          state.isMultiSelect
              ? '${state.selectedIds.length} selected'
              : 'Business Activities',
        ),
        backgroundColor: primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          // onPressed: () => Navigator.pop(context),
          onPressed: () {
            if (state.isMultiSelect) {
              notifier.exitSelectionMode();
            } else {
              Navigator.pop(context);
            }
          },
        ),
        actions: [
          /// BEFORE long-press → Select
          if (!state.isMultiSelect)
            TextButton(
              onPressed: () => notifier.enterSelectionMode(),
              child: const Text(
                'Select',
                style: TextStyle(color: Colors.white),
              ),
            ),

          /// AFTER long-press → Select All / Clear All
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

          /// Bulk delete
          if (state.isMultiSelect)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.white),
              onPressed: () =>
                  BulkDeleteDialog.show(context, ref, state.selectedIds.length),
            ),
        ],
      ),
      body: Column(
        children: [
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
              onChanged: (value) {
                notifier.loadAll(
                  filter: BusinessActivityFilter(
                    searchText: value,
                    pageNumber: 1,
                  ),
                );
              },

              // onChanged: notifier.search,
              decoration: InputDecoration(
                hintText: 'Search activities...',
                prefixIcon: Icon(Icons.search, color: primaryColor),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: primaryColor.withAlpha(77)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: primaryColor, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
          Expanded(
            child: state.filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: primaryColor.withAlpha(26),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.inbox,
                            size: 40,
                            color: primaryColor.withAlpha(128),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No activities found',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap the + button to add a new activity',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  )
                : Stack(
                    children: [
                      ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.only(
                          left: 12,
                          right: 12,
                          top: 12,
                          bottom: 60, // Space for pagination controls
                        ),
                        itemCount: state.filtered.length,
                        itemBuilder: (_, i) {
                          final a = state.filtered[i];
                          final selected = state.selectedIds.contains(
                            a.activityId,
                          );

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12, top: 2),
                            child: Material(
                              color: Colors.transparent,
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(
                                    color: selected
                                        ? primaryColor.withAlpha(128)
                                        : Colors.grey.shade200,
                                    width: selected ? 2 : 1,
                                  ),
                                ),
                                tileColor: selected
                                    ? primaryColor.withAlpha(20)
                                    : Colors.white,

                                leading: state.isMultiSelect
                                    ? Checkbox(
                                        value: selected,
                                        onChanged: (_) => notifier
                                            .toggleSelection(a.activityId),
                                        activeColor: primaryColor,
                                      )
                                    : null,

                                title: Text(
                                  a.activityName,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: a.isDeleted
                                        ? Colors.red
                                        : Colors.grey.shade800,
                                  ),
                                ),

                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    /// detail view Eye
                                    IconButton(
                                      icon: Icon(
                                        Icons.remove_red_eye_outlined,
                                        color: primaryColor,
                                        // size: 27,
                                      ),
                                      iconSize: 27,
                                      onPressed: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              ActivityDetailPage(activity: a),
                                        ),
                                      ),
                                    ),

                                    if (!a.isDeleted) ...[
                                      /// Toggle
                                      Transform.scale(
                                        scale: 0.8,
                                        child: Switch(
                                          value: a.active,
                                          onChanged: (val) async {
                                            final error = await notifier.update(
                                              id: a.activityId,
                                              active: val,
                                            );
                                            if (!mounted) return;

                                            if (error != null) {
                                              CustomSnackbar.show(
                                                context,
                                                message: error,
                                                type: SnackBarType.error,
                                              );
                                            } else {
                                              CustomSnackbar.show(
                                                context,
                                                message:
                                                    '${a.activityName} ${val ? 'enabled' : 'disabled'}',
                                                type: SnackBarType.info,
                                              );
                                            }
                                          },
                                          activeThumbColor:
                                              Colors.green.shade600,
                                          inactiveThumbColor:
                                              Colors.grey.shade400,
                                          materialTapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                        ),
                                      ),

                                      ///  Delete
                                      IconButton(
                                        icon: Icon(
                                          Icons.delete_rounded,
                                          color: Colors.red.shade600,
                                          // size: 27,
                                        ),
                                        iconSize: 22,
                                        onPressed: () =>
                                            DeleteActivityDialog.show(
                                              context,
                                              ref,
                                              a.activityId,
                                              a.activityName,
                                            ),
                                      ),
                                    ],
                                  ],
                                ),

                                onLongPress: () =>
                                    notifier.toggleSelection(a.activityId),
                                // onTap: state.isMultiSelect ? null : () {},
                                onTap: () {
                                  if (state.isMultiSelect) {
                                    notifier.toggleSelection(a.activityId);
                                  }
                                },
                              ),
                            ),
                          );
                        },
                      ),
                      // Pagination controls
                      if (state.filtered.isNotEmpty)
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.shade300,
                                  blurRadius: 6,
                                  offset: const Offset(0, -2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Page info
                                Flexible(
                                  child: Builder(
                                    builder: (_) {
                                      final start =
                                          (state.currentPage - 1) * _pageSize +
                                          1;
                                      final end =
                                          start + state.filtered.length - 1;

                                      return Text(
                                        '$start-$end of ${state.totalCount}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey.shade700,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      );
                                    },
                                  ),
                                ),

                                // Page controls
                                PaginationControls(
                                  currentPage: state.currentPage,
                                  totalCount: state.totalCount,
                                  pageSize: _pageSize,
                                  isLoading: state.isLoading,
                                  hasMoreData: state.hasMoreData,
                                  onPageChanged: _goToPage,
                                  primaryColor: primaryColor,
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        heroTag: 'business_activity_fab', // <-- Add a unique tag here
        onPressed: () => AddActivityDialog.show(context, ref),
        backgroundColor: primaryColor,
        elevation: 4,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
