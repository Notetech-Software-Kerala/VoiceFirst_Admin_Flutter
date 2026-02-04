import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/core/widgets/delete_bottom_sheet.dart';
import 'package:voice_first_admin/core/widgets/standard_page_layout.dart';
import 'package:voice_first_admin/core/widgets/standard_list_card.dart';
import 'package:voice_first_admin/core/widgets/custom_snackbar.dart';
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final state = ref.watch(programActionProvider);
    final notifier = ref.read(programActionProvider.notifier);

    final searchController = TextEditingController(text: state.search);

    return StandardPageLayout(
      title: state.isMultiSelect
          ? '${state.selectedIds.length} selected'
          : 'Program Actions',
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
      searchController: searchController,
      searchHint: 'Search program actions...',
      onSearchChanged: (value) {
        notifier.loadAll(
          filter: ProgramActionFilter(
            search: value,
            pageNumber: 1,
            pageSize: _pageSize,
          ),
        );
      },
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
          : Container(
              height: 60,
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: state.currentPage > 1
                        ? () => _goToPage(state.currentPage - 1)
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Builder(
                    builder: (_) {
                      final totalPages =
                          (state.totalCount / _pageSize).ceil();
                      final safeTotalPages =
                          totalPages > 0 ? totalPages : 1;
                      return Text(
                        'Page ${state.currentPage} of $safeTotalPages',
                        style:
                            const TextStyle(fontWeight: FontWeight.bold),
                      );
                    },
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: (() {
                      final totalPages =
                          (state.totalCount / _pageSize).ceil();
                      final safeTotalPages =
                          totalPages > 0 ? totalPages : 1;
                      return state.currentPage < safeTotalPages
                          ? () => _goToPage(state.currentPage + 1)
                          : null;
                    })(),
                  ),
                ],
              ),
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

                // final statusChip = Container(
                //   padding:
                //       const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                //   decoration: BoxDecoration(
                //     color: isDeleted
                //         ? Colors.red.withAlpha(38)
                //         : action.active
                //             ? Colors.green.withAlpha(38)
                //             : Colors.orange.withAlpha(38),
                //     borderRadius: BorderRadius.circular(20),
                //   ),
                //   child: Text(
                //     isDeleted
                //         ? 'DELETED'
                //         : action.active
                //             ? 'ACTIVE'
                //             : 'INACTIVE',
                //     style: TextStyle(
                //       fontSize: 11,
                //       fontWeight: FontWeight.bold,
                //       color: isDeleted
                //           ? Colors.red
                //           : action.active
                //               ? Colors.green
                //               : Colors.orange,
                //     ),
                //   ),
                // );

                final actions = <Widget>[];
                if (!isDeleted) {
                  actions.add(
                    Transform.scale(
                      scale: 0.8,
                      child: Switch(
                        value: action.active,
                        onChanged: (val) async {
                          final error = await notifier.toggleStatus(
                            action.actionId,
                            val,
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
                }

                // actions.add(
                //   StandardActionButton(
                //     icon: Icons.remove_red_eye_outlined,
                //     color: const Color(0xFF0D7FF2),
                //     onTap: () => Navigator.push(
                //       context,
                //       MaterialPageRoute(
                //         builder: (_) => ProgramActionDetailView(action: action),
                //       ),
                //     ),
                //   ),
                // );

                if (!isDeleted) {
                  actions.add(
                    StandardActionButton(
                      icon: Icons.edit,
                      color: Colors.blue,
                      onTap: () =>
                          EditProgramActionDialog.show(context, ref, action),
                    ),
                  );
                  actions.add(
                    StandardActionButton(
                      icon: Icons.delete,
                      color: Colors.red,
                      onTap: () {
                        showDeleteBottomSheet(
                          context: context,
                          itemName: action.actionName,
                          onDelete: () async {
                            final error = await notifier.delete(
                              action.actionId,
                            );
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
                                  message:
                                      'Program action deleted successfully',
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
                    subtitle: isDeleted
                        ? 'Deleted'
                        : (action.active ? 'Active' : 'Inactive'),
                    leading: leading,
                    // trailing: statusChip,
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
