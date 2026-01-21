import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/features/Business_activity/business_activity_service/business_activity_service.dart';
import 'package:voice_first_admin/features/Business_activity/models/business_activity_model.dart';
import 'business_activity_state.dart';

class BusinessActivityNotifier extends Notifier<BusinessActivityState> {
  late final BusinessActivityService _service;

  @override
  BusinessActivityState build() {
    // Initialize service
    _service = BusinessActivityService();

    return BusinessActivityState.initial();
  }

  // 🔍 Search
  void search(String query) {
    final filtered = query.isEmpty
        ? state.activities
        : state.activities
              .where((a) => a.name.toLowerCase().contains(query.toLowerCase()))
              .toList();

    state = state.copyWith(search: query, filtered: filtered);
  }

  Future<void> loadAll({
    int pageNumber = 1,
    int pageSize = 20,
    String? searchTerm,
    bool? isActive,
  }) async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true);

    try {
      final response = await _service.getAllActivities(
        pageNumber: pageNumber,
        pageSize: pageSize,
        searchTerm: searchTerm,
        isActive: isActive,
      );

      state = state.copyWith(
        activities: response.items,
        filtered: _applyFilter(response.items),
        isLoading: false,
        hasMoreData: response.hasNextPage,
        currentPage: response.currentPage,
        totalCount: response.totalCount,
      );

      debugPrint(
        'Loaded ${response.items.length} of ${response.totalCount} activities (Page ${response.currentPage})',
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
      debugPrint('💥 Failed to load activities: $e');
    }
  }

  // ➕ Add
  Future<String?> add(String name) async {
    debugPrint('Starting add operation for: "$name"');

    try {
      debugPrint('Calling service.createActivity...');
      final activity = await _service.createActivity(name);

      final list = [...state.activities, activity];
      state = state.copyWith(activities: list, filtered: _applyFilter(list));

      debugPrint(' Activity added. Total activities: ${list.length}');

      return null; // ✅ success
    } catch (e) {
      debugPrint('💥 Exception caught: $e');
      return 'Failed to add activity';
    }
  }

  // ✏️ Update
  Future<String?> update(int id, String name) async {
    try {
      final updated = await _service.updateActivity(id, name);

      final list = state.activities
          .map((a) => a.id == updated.id ? updated : a)
          .toList();

      state = state.copyWith(activities: list, filtered: _applyFilter(list));

      debugPrint('✅ Activity updated: $name');
      return null; // success
    } catch (e) {
      debugPrint('💥 Failed to update activity: $e');
      return 'Failed to update activity';
    }
  }

  // 🔄 Status
  Future<String?> toggleStatus(int id, bool active) async {
    try {
      await _service.toggleStatus(id, active);

      final list = state.activities
          .map((a) => a.id == id ? a.copyWith(active: active) : a)
          .toList();

      state = state.copyWith(activities: list, filtered: _applyFilter(list));

      debugPrint('✅ Status toggled for activity ID: $id');
      return null; // success
    } catch (e) {
      debugPrint('💥 Failed to toggle status: $e');
      return 'Failed to toggle status';
    }
  }

  // ❌ Delete
  Future<String?> delete(int id) async {
    try {
      await _service.deleteActivity(id);

      final list = state.activities.where((a) => a.id != id).toList();
      state = state.copyWith(activities: list, filtered: _applyFilter(list));

      debugPrint('✅ Activity deleted: $id');
      return null; // success
    } catch (e) {
      debugPrint('💥 Failed to delete activity: $e');
      return 'Failed to delete activity';
    }
  }

  Future<String?> deleteSelected() async {
    if (state.selectedIds.isEmpty) return 'No items selected';

    try {
      await _service.bulkDelete(state.selectedIds.toList());

      final list = state.activities
          .where((a) => !state.selectedIds.contains(a.id))
          .toList();

      state = state.copyWith(
        activities: list,
        filtered: _applyFilter(list),
        selectedIds: {},
        isMultiSelect: false,
      );

      debugPrint('✅ Bulk delete completed: ${state.selectedIds.length} items');
      return null; // success
    } catch (e) {
      debugPrint('💥 Failed to delete selected activities: $e');
      return 'Failed to delete activities';
    }
  }

  // ☑️ Selection
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

  // 🔧 Helper
  List<BusinessActivity> _applyFilter(List<BusinessActivity> list) {
    if (state.search.isEmpty) return list;
    return list
        .where((a) => a.name.toLowerCase().contains(state.search.toLowerCase()))
        .toList();
  }

  void enterSelectionMode({bool selectAll = false}) {
    final selected = <int>{};

    if (selectAll) {
      selected.addAll(state.filtered.map((e) => e.id));
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
