import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/features/Business_activity/business_activity_service/business_activity_service.dart';
import 'package:voice_first_admin/features/Business_activity/models/business_activity_filter.dart';
import 'business_activity_state.dart';

class BusinessActivityNotifier extends Notifier<BusinessActivityState> {
  late final BusinessActivityService _service;

  @override
  BusinessActivityState build() {
    // Initialize service
    _service = BusinessActivityService();

    return BusinessActivityState.initial();
  }

  Future<void> loadAll({BusinessActivityFilter? filter}) async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true);

    try {
      final response = await _service.getAllActivities(
        filter ?? BusinessActivityFilter(pageNumber: 1, limit: 10),
      );

      state = state.copyWith(
        activities: response.items,
        filtered: response.items, // backend already filtered
        isLoading: false,
        hasMoreData: response.hasNextPage,
        currentPage: response.currentPage,
        totalCount: response.totalCount,
      );
      debugPrint(
        'PAGE=${response.currentPage}, TOTAL_PAGES=${response.totalPages}, HAS_NEXT=${response.hasNextPage}',
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  // ♻️ Recover
  Future<String?> recover(int activityId) async {
    try {
      // Call the API to recover the activity
      await _service.recoverActivity(activityId);

      // ✅ Update state locally (NO reload)
      state = state.copyWith(
        activities: state.activities.map((activity) {
          if (activity.activityId == activityId) {
            return activity.copyWith(isDeleted: false, clearDeletedMeta: true);
          }
          return activity;
        }).toList(),
        filtered: state.filtered.map((activity) {
          if (activity.activityId == activityId) {
            return activity.copyWith(isDeleted: false, clearDeletedMeta: true);
          }
          return activity;
        }).toList(),
      );

      return null; // Success
    } catch (e) {
      debugPrint('💥 Failed to recover activity: $e');
      return 'Failed to recover activity';
    }
  }

  // ➕ Add
  Future<String?> add(String name) async {
    debugPrint('Starting add operation for: "$name"');

    try {
      debugPrint('Calling service.createActivity...');
      final activity = await _service.createActivity(name);

      final list = [...state.activities, activity];
      state = state.copyWith(activities: list);

      debugPrint(' Activity added. Total activities: ${list.length}');

      return null; // ✅ success
    } catch (e) {
      debugPrint('💥 Exception caught: $e');
      return 'Failed to add activity';
    }
  }
  // Update
  Future<String?> update({
    required int id,
    String? activityName,
    bool? active,
  }) async {
    try {
      final updated = await _service.updateActivity(
        id: id,
        activityName: activityName,
        active: active,
      );

      // final list = state.activities
      //     .map((a) => a.activityId == updated.activityId ? updated : a)
      //     .toList();

      // state = state.copyWith(activities: list);
      state = state.copyWith(
        activities: state.activities
            .map((a) => a.activityId == updated.activityId ? updated : a)
            .toList(),
      );
      return null;
    } catch (e) {
      debugPrint(' Failed to update activity: $e');
      return 'Failed to update activity';
    }
  }

  // 🔄 Status
  Future<String?> toggleStatus(int activityId, bool active) async {
    try {
      await _service.toggleStatus(activityId, active);

      final list = state.activities
          .map(
            (a) => a.activityId == activityId ? a.copyWith(active: active) : a,
          )
          .toList();

      state = state.copyWith(activities: list);

      debugPrint('✅ Status toggled for activity ID: $activityId');
      return null; // success
    } catch (e) {
      debugPrint('💥 Failed to toggle status: $e');
      return 'Failed to toggle status';
    }
  }

  // ❌ Delete
  Future<String?> delete(int activityId) async {
    try {
      await _service.deleteActivity(activityId);

      // Reload the current page to get fresh data with deleted status
      await loadAll(
        filter: BusinessActivityFilter(
          pageNumber: state.currentPage,
          limit: 10,
          searchText: state.search.isEmpty ? null : state.search,
        ),
      );

      debugPrint('✅ Activity deleted: $activityId');
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

      // Clear selection first
      state = state.copyWith(selectedIds: {}, isMultiSelect: false);

      // Reload the current page to get fresh data with deleted status
      await loadAll(
        filter: BusinessActivityFilter(
          pageNumber: state.currentPage,
          limit: 10,
          searchText: state.search.isEmpty ? null : state.search,
        ),
      );

      debugPrint('✅ Bulk delete completed');
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
  // List<BusinessActivity> _applyFilter(List<BusinessActivity> list) {
  //   if (state.search.isEmpty) return list;
  //   return list
  //       .where((a) => a.name.toLowerCase().contains(state.search.toLowerCase()))
  //       .toList();
  // }

  void enterSelectionMode({bool selectAll = false}) {
    final selected = <int>{};

    if (selectAll) {
      selected.addAll(state.filtered.map((e) => e.activityId));
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
