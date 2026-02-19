import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/features/Program_Action/models/program_action_filter.dart';
import 'package:voice_first_admin/features/Program_Action/program_action_service/program_action_service.dart';
import 'program_action_state.dart';

class ProgramActionNotifier extends Notifier<ProgramActionState> {
  final ProgramActionService _service = ProgramActionService();

  @override
  ProgramActionState build() {
    // _service = ProgramActionService();
    return ProgramActionState.initial();
  }

  Future<void> loadAll({ProgramActionFilter? filter}) async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true);

    try {
      final response = await _service.getAll(
        filter ?? ProgramActionFilter(pageNumber: 1, pageSize: 10),
      );

      state = state.copyWith(
        actions: response.items,
        filtered: response.items, // backend already filtered
        isLoading: false,
        // hasMoreData: response.items.length >= (filter?.pageSize ?? 10),
        hasMoreData: response.pageNumber < response.totalPages,
        currentPage: response.pageNumber,
        totalCount: response.totalCount,
        totalPages: response.totalPages,
      );
      debugPrint(
        'PAGE=${response.pageNumber}, TOTAL_PAGES=${response.totalPages}, ITEMS=${response.items.length}',
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
      debugPrint('💥 Failed to load program actions: $e');
    }
  }

  // Recover
  Future<String?> recover(int actionId) async {
    try {
      // Call API
      await _service.recover(actionId);

      // ✅ Update state locally (NO reload)
      state = state.copyWith(
        actions: state.actions.map((action) {
          if (action.actionId == actionId) {
            return action.copyWith(deleted: false, clearDeletedMeta: true);
          }
          return action;
        }).toList(),

        filtered: state.filtered.map((action) {
          if (action.actionId == actionId) {
            return action.copyWith(deleted: false, clearDeletedMeta: true);
          }
          return action;
        }).toList(),
      );

      return null; // success
    } catch (e) {
      debugPrint('💥 Failed to recover program action: $e');
      return 'Failed to recover program action';
    }
  }

  // Add
  Future<String?> add(String name) async {
    debugPrint('Starting add operation for: "$name"');

    try {
      debugPrint('Calling service.create...');
      await _service.create(name);

      // Reload the current page to get fresh data with proper pagination
      await loadAll(
        filter: ProgramActionFilter(
          pageNumber: state.currentPage,
          pageSize: 10,
          search: state.search.isEmpty ? null : state.search,
        ),
      );

      debugPrint('✅ Action added successfully');

      return null; // ✅ success
    } catch (e) {
      debugPrint('💥 Exception caught: $e');
      return 'Failed to add program action';
    }
  }

  // Update name
  Future<String?> update(int id, String name) async {
    try {
      await _service.updateAction(id, name: name);

      // Reload the current page to get fresh data
      await loadAll(
        filter: ProgramActionFilter(
          pageNumber: state.currentPage,
          pageSize: 10,
          search: state.search.isEmpty ? null : state.search,
        ),
      );

      debugPrint('✅ Program action updated: $name');
      return null; // success
    } catch (e) {
      debugPrint('💥 Failed to update program action: $e');
      return 'Failed to update program action';
    }
  }

  // Toggle status
  // Future<String?> toggleStatus(int id, bool active) async {
  //   try {
  //     await _service.updateAction(id, active: active);

  //     // Reload the current page to get fresh data
  //     await loadAll(
  //       filter: ProgramActionFilter(
  //         pageNumber: state.currentPage,
  //         pageSize: 10,
  //         search: state.search.isEmpty ? null : state.search,
  //       ),
  //     );

  //     debugPrint('✅ Status toggled for program action ID: $id');
  //     return null; // success
  //   } catch (e) {
  //     debugPrint('💥 Failed to toggle status: $e');
  //     return 'Failed to toggle status';
  //   }
  // }
  Future<String?> toggleStatus(int id, bool active) async {
    // ✅ Backup for rollback
    final previousActions = state.actions;
    final previousFiltered = state.filtered;

    // ✅ Instant UI update
    state = state.copyWith(
      actions: state.actions.map((a) {
        if (a.actionId == id) {
          return a.copyWith(active: active);
        }
        return a;
      }).toList(),
      filtered: state.filtered.map((a) {
        if (a.actionId == id) {
          return a.copyWith(active: active);
        }
        return a;
      }).toList(),
    );

    try {
      await _service.updateAction(id, active: active);

      debugPrint('✅ Status toggled');
      return null;
    } catch (e) {
      // ❗ rollback if API fails
      state = state.copyWith(
        actions: previousActions,
        filtered: previousFiltered,
      );

      debugPrint('💥 Toggle failed → rolled back');
      return 'Failed to toggle status';
    }
  }

  // Delete
  Future<String?> delete(int id) async {
    try {
      await _service.delete(id);

      // Reload the current page to get fresh data
      await loadAll(
        filter: ProgramActionFilter(
          pageNumber: state.currentPage,
          pageSize: 10,
          search: state.search.isEmpty ? null : state.search,
        ),
      );

      debugPrint('✅ Program action deleted: $id');
      return null; // success
    } catch (e) {
      debugPrint('💥 Failed to delete program action: $e');
      return 'Failed to delete program action';
    }
  }

  Future<String?> deleteSelected() async {
    if (state.selectedIds.isEmpty) return 'No items selected';

    try {
      await _service.bulkDelete(state.selectedIds.toList());

      // Clear selection first
      state = state.copyWith(selectedIds: {}, isMultiSelect: false);

      // Reload the current page to get fresh data
      await loadAll(
        filter: ProgramActionFilter(
          pageNumber: state.currentPage,
          pageSize: 10,
          search: state.search.isEmpty ? null : state.search,
        ),
      );

      debugPrint('✅ Bulk delete completed');
      return null; // success
    } catch (e) {
      debugPrint('💥 Failed to delete selected program actions: $e');
      return 'Failed to delete program actions';
    }
  }

  // Selection
  void toggleSelection(int id) {
    final selected = {...state.selectedIds};
    selected.contains(id) ? selected.remove(id) : selected.add(id);

    state = state.copyWith(
      selectedIds: selected,
      isMultiSelect: selected.isNotEmpty,
    );
  }

  void clearSelection() {
    state = state.copyWith(selectedIds: {}, isMultiSelect: false);
  }

  void enterSelectionMode({bool selectAll = false}) {
    final selected = <int>{};

    if (selectAll) {
      selected.addAll(state.filtered.map((e) => e.actionId));
    }

    state = state.copyWith(isMultiSelect: true, selectedIds: selected);
  }

  void exitSelectionMode() {
    state = state.copyWith(isMultiSelect: false, selectedIds: {});
  }

  bool get allVisibleSelected =>
      state.filtered.isNotEmpty &&
      state.selectedIds.length == state.filtered.length;
}
