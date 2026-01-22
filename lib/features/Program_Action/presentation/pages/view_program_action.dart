import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/features/Business_activity/presentation/widgets/custom_snackbar.dart';
import 'package:voice_first_admin/features/Program_Action/models/program_action_filter.dart';
import 'package:voice_first_admin/features/Program_Action/presentation/providers/program_action_provider.dart';
import 'package:voice_first_admin/features/Program_Action/presentation/dialogs/add_program_action_dialog.dart';
import 'package:voice_first_admin/features/Program_Action/presentation/dialogs/edit_program_action_dialog.dart';
import 'package:voice_first_admin/features/Program_Action/presentation/dialogs/delete_program_action_dialog.dart';
import 'program_action_detail_view.dart';

class ProgramActionView extends ConsumerStatefulWidget {
  const ProgramActionView({super.key});

  @override
  ConsumerState<ProgramActionView> createState() => _ProgramActionViewState();
}

class _ProgramActionViewState extends ConsumerState<ProgramActionView> {
  final ScrollController _scrollController = ScrollController();
  static const int _pageSize = 10;

  @override
  void initState() {
    super.initState();
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
    _scrollController.dispose();
    super.dispose();
  }

  void _goToPage(int page) {
    ref
        .read(programActionProvider.notifier)
        .loadAll(
          filter: ProgramActionFilter(pageNumber: page, pageSize: _pageSize),
        );

    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(programActionProvider);
    final notifier = ref.read(programActionProvider.notifier);

    final primaryColor = const Color(0xFF0D7FF2);

    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        title: Text(
          state.isMultiSelect
              ? '${state.selectedIds.length} selected'
              : 'Program Actions',
          style: const TextStyle(color: Colors.white),
        ),
        leading: state.isMultiSelect
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: notifier.exitSelectionMode,
              )
            : null, // Let the default menu icon show
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

          /// Cancel
          if (state.isMultiSelect)
            TextButton(
              onPressed: notifier.exitSelectionMode,
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white),
              ),
            ),

          /// Delete
          if (state.isMultiSelect && state.selectedIds.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.white),
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
      ),

      // ───────────────── Body ─────────────────
      body: Column(
        children: [
          // 🔍 Search
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.08),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: TextField(
              onChanged: (value) {
                ref
                    .read(programActionProvider.notifier)
                    .loadAll(
                      filter: ProgramActionFilter(
                        search: value,
                        pageNumber: 1,
                        pageSize: _pageSize,
                      ),
                    );
              },
              decoration: InputDecoration(
                hintText: 'Search program actions...',
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

          // ☑️ Select All/Deselect All Checkbox
          if (state.isMultiSelect)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Checkbox(
                    value: notifier.allVisibleSelected,
                    onChanged: (_) {
                      notifier.enterSelectionMode(
                        selectAll: !notifier.allVisibleSelected,
                      );
                    },
                    activeColor: primaryColor,
                  ),
                  Text(
                    notifier.allVisibleSelected ? 'Deselect All' : 'Select All',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

          // 📋 List
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
                            color: primaryColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.inbox,
                            size: 40,
                            color: primaryColor.withOpacity(0.5),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No program actions found',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap the + button to add a new action',
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
                        itemBuilder: (context, index) {
                          final action = state.filtered[index];
                          final bool isDeleted = action.deleted;
                          final bool selected = state.selectedIds.contains(
                            action.actionId,
                          );

                          return GestureDetector(
                            onLongPress: () =>
                                notifier.toggleSelection(action.actionId),
                            child: Card(
                              color: selected
                                  ? primaryColor.withOpacity(0.2)
                                  : Colors.white,
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: selected
                                    ? BorderSide(
                                        color: primaryColor,
                                        width: 1.5,
                                      )
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
                                        onChanged: (_) => notifier
                                            .toggleSelection(action.actionId),
                                        activeColor: primaryColor,
                                      ),

                                    // 📄 Action info
                                    Expanded(
                                      child: Text(
                                        action.actionName,
                                        style: TextStyle(
                                          color: isDeleted
                                              ? Colors.red
                                              : Colors.black,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),

                                    // 🔀 Status toggle & Action buttons
                                    if (!state.isMultiSelect)
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          if (!isDeleted) ...[
                                            Transform.scale(
                                              scale: 0.75,
                                              child: Switch(
                                                value: action.active,
                                                onChanged: (val) async {
                                                  final error = await notifier
                                                      .toggleStatus(
                                                        action.actionId,
                                                        val,
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
                                                          '${action.actionName} ${val ? 'enabled' : 'disabled'}',
                                                      type: SnackBarType.info,
                                                    );
                                                  }
                                                },
                                                activeThumbColor: Colors.green,
                                                materialTapTargetSize:
                                                    MaterialTapTargetSize
                                                        .shrinkWrap,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                          ],

                                          // View button
                                          IconButton(
                                            icon: const Icon(
                                              Icons.remove_red_eye_outlined,
                                              color: Color(0xFF0D7FF2),
                                              size: 22,
                                            ),
                                            onPressed: () => Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    ProgramActionDetailView(
                                                      action: action,
                                                    ),
                                              ),
                                            ),
                                            tooltip: 'View Details',
                                          ),

                                          if (!isDeleted) ...[
                                            // Edit button
                                            IconButton(
                                              icon: const Icon(
                                                Icons.edit,
                                                color: Colors.blue,
                                                size: 20,
                                              ),
                                              onPressed: () {
                                                EditProgramActionDialog.show(
                                                  context,
                                                  ref,
                                                  action,
                                                );
                                              },
                                              tooltip: 'Edit',
                                            ),

                                            // Delete button
                                            IconButton(
                                              icon: const Icon(
                                                Icons.delete,
                                                color: Colors.red,
                                                size: 20,
                                              ),
                                              onPressed: () {
                                                DeleteProgramActionDialog.show(
                                                  context,
                                                  ref,
                                                  action.actionId,
                                                  action.actionName,
                                                );
                                              },
                                              tooltip: 'Delete',
                                            ),
                                          ],
                                        ],
                                      ),
                                  ],
                                ),
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

                                // Pagination buttons
                                Flexible(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Previous button
                                      IconButton(
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(
                                          minWidth: 36,
                                          minHeight: 36,
                                        ),
                                        onPressed:
                                            state.currentPage > 1 &&
                                                !state.isLoading
                                            ? () => _goToPage(
                                                state.currentPage - 1,
                                              )
                                            : null,
                                        icon: Icon(
                                          Icons.chevron_left,
                                          color: state.currentPage > 1
                                              ? primaryColor
                                              : Colors.grey.shade400,
                                        ),
                                        iconSize: 24,
                                      ),

                                      // Page indicator
                                      Container(
                                        constraints: const BoxConstraints(
                                          minWidth: 60,
                                        ),
                                        alignment: Alignment.center,
                                        child: state.isLoading
                                            ? SizedBox(
                                                width: 14,
                                                height: 14,
                                                child:
                                                    CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      color: primaryColor,
                                                    ),
                                              )
                                            : Text(
                                                '${state.currentPage} / ${state.totalPages}',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                  color: primaryColor,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                      ),

                                      // Next button
                                      IconButton(
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(
                                          minWidth: 36,
                                          minHeight: 36,
                                        ),
                                        onPressed:
                                            state.hasMoreData &&
                                                !state.isLoading
                                            ? () => _goToPage(
                                                state.currentPage + 1,
                                              )
                                            : null,
                                        icon: Icon(
                                          Icons.chevron_right,
                                          color: state.hasMoreData
                                              ? primaryColor
                                              : Colors.grey.shade400,
                                        ),
                                        iconSize: 24,
                                      ),

                                      // Page selector dropdown
                                      PopupMenuButton<int>(
                                        padding: EdgeInsets.zero,
                                        icon: Icon(
                                          Icons.more_vert,
                                          color: primaryColor,
                                          size: 20,
                                        ),
                                        iconSize: 20,
                                        offset: const Offset(0, -10),
                                        enabled: !state.isLoading,
                                        onSelected: (page) => _goToPage(page),
                                        itemBuilder: (context) {
                                          final totalPages =
                                              (state.totalCount / _pageSize)
                                                  .ceil();
                                          return List.generate(
                                            totalPages,
                                            (index) => PopupMenuItem<int>(
                                              value: index + 1,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text('Page ${index + 1}'),
                                                  if (state.currentPage ==
                                                      index + 1)
                                                    Icon(
                                                      Icons.check,
                                                      color: primaryColor,
                                                      size: 16,
                                                    ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
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

      // ➕ FAB
      floatingActionButton: state.isMultiSelect
          ? null
          : FloatingActionButton(
              backgroundColor: primaryColor,
              onPressed: () {
                AddProgramActionDialog.show(context, ref);
              },
              child: const Icon(Icons.add, color: Colors.white),
            ),
    );
  }
}
