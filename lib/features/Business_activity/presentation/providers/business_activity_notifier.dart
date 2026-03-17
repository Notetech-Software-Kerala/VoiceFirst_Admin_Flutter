import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/core/models/base_filter_model.dart';
import 'package:voice_first_admin/features/Business_activity/models/business_activity_filter.dart';
import 'package:voice_first_admin/features/Business_activity/models/update_activity_request.dart';
import '../../business_activity_service/business_activity_service.dart';
import 'business_activity_state.dart';

class BusinessActivityNotifier extends Notifier<BusinessActivityState> {
  late final BusinessActivityService _service;

  @override
  BusinessActivityState build() {
    _service = BusinessActivityService();
    return BusinessActivityState.initial();
  }

  BusinessActivityFilter _mapToApiFilter(
    BaseFilterModel filter,
    int pageNumber,
    int pageSize,
  ) {
    return BusinessActivityFilter(
      searchBy: filter.searchBy,
      searchText: filter.searchText,
      sortBy: filter.sortBy,
      sortOrder: filter.sortOrder,
      active: filter.active,
      deleted: filter.deleted,
      pageNumber: pageNumber,
      limit: pageSize,
      createdFromDate: filter.createdFromDate,
      createdToDate: filter.createdToDate,
      updatedFromDate: filter.updatedFromDate,
      updatedToDate: filter.updatedToDate,
      deletedFromDate: filter.deletedFromDate,
      deletedToDate: filter.deletedToDate,
    );
  }
  // ───────────────── LOAD ─────────────────

  Future<void> load({BaseFilterModel? filter, int? page}) async {
    if (state.isLoading) return;

    final currentFilter = filter ?? state.filter;
    final currentPage = page ?? state.currentPage;

    state = state.copyWith(
      isLoading: true,
      filter: currentFilter,
      currentPage: currentPage,
    );

    try {
      final apiFilter = _mapToApiFilter(currentFilter, currentPage, 10);

      final response = await _service.getAllActivities(apiFilter);

      state = state.copyWith(
        items: response.items,
        totalCount: response.totalCount,
        currentPage: response.currentPage,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  // ───────────────── CRUD ─────────────────

  Future<String?> add(String name, {List<int>? customFieldIds}) async {
    try {
      await _service.createActivity(name, customFieldIds: customFieldIds);
      // Reload to respect sort order and pagination
      await load();
      return null;
    } catch (e) {
      return 'Failed to add activity';
    }
  }
Future<String?> update({
  required int id,
  String? activityName,
  bool? active,
  List<int>? addCustomFieldIds,
  List<Map<String, dynamic>>? updateCustomField,
}) async {
  try {
    final request = UpdateActivityRequest(
      activityName: activityName,
      active: active,
      addCustomFieldIds: addCustomFieldIds,
      updateCustomField: updateCustomField,
    );

    if (request.toJson().isEmpty) {
      debugPrint('[Notifier] Nothing changed → skipping API');
      return null;
    }

    final updated = await _service.updateActivity(id, request);

    state = state.copyWith(
      items: state.items
          .map((a) => a.activityId == id ? updated : a)
          .toList(),
    );

    return null;
  } catch (e) {
    debugPrint('[Notifier] update error: $e');
    return 'Failed to update activity';
  }
}
  // Future<String?> update({
  //   required int id,
  //   String? activityName,
  //   bool? active,
  //   List<int>? addCustomFieldIds,
  //   List<Map<String, dynamic>>? updateCustomField,
  // }) async {
    // try {
    //   final oldActivity = state.items.firstWhere((a) => a.activityId == id);

    //   final request = UpdateActivityRequest.fromChanges(
    //     newName: activityName ?? oldActivity.activityName,
    //     oldName: oldActivity.activityName,
    //     newActive: active,
    //     oldActive: oldActivity.active,
    //     newFieldIds: addCustomFieldIds != null
    //         ? {
    //             ...oldActivity.activityCustomFields!.map(
    //               (e) => e.customFieldId,
    //             ),
    //             ...addCustomFieldIds,
    //           }
    //         : oldActivity.activityCustomFields!
    //               .where((f) => f.active)
    //               .map((f) => f.customFieldId)
    //               .toSet(),
    //     oldFields: oldActivity.activityCustomFields ?? [],
    //   );

    //   final updated = await _service.updateActivity(id, request);

    //   state = state.copyWith(
    //     items: state.items
    //         .map((a) => a.activityId == id ? updated : a)
    //         .toList(),
    //   );
    //   return null;
    // } catch (e) {
      // return 'Failed to update activity';
    // }
  // }

  Future<String?> delete(int id) async {
    try {
      final deleted = await _service.deleteActivity(id);

      state = state.copyWith(
        items: state.items
            .map((a) => a.activityId == id ? deleted : a)
            .toList(),
      );

      return null;
    } catch (e) {
      return 'Failed to delete activity';
    }
  }

  Future<String?> recover(int id) async {
    try {
      final updated = await _service.recoverActivity(id);

      state = state.copyWith(
        items: state.items
            .map((a) => a.activityId == id ? updated : a)
            .toList(),
      );

      return null;
    } catch (e) {
      return 'Failed to recover activity';
    }
  }

  Future<String?> deleteSelected() async {
    if (state.selectedIds.isEmpty) return 'No items selected';

    try {
      await _service.bulkDelete(state.selectedIds.toList());
      await load();
      return null;
    } catch (e) {
      return 'Failed to delete selected activities';
    }
  }

  // ───────────────── SELECTION MODE ─────────────────

  void enterSelectionMode({bool selectAll = false}) {
    final selected = <int>{};

    if (selectAll) {
      selected.addAll(state.items.map((e) => e.activityId));
    }

    state = state.copyWith(isMultiSelect: true, selectedIds: selected);
  }

  void exitSelectionMode() {
    state = state.copyWith(isMultiSelect: false, selectedIds: {});
  }

  void toggleSelection(int id) {
    final selected = {...state.selectedIds};

    selected.contains(id) ? selected.remove(id) : selected.add(id);

    state = state.copyWith(
      selectedIds: selected,
      isMultiSelect: selected.isNotEmpty,
    );
  }

  bool get allVisibleSelected =>
      state.items.isNotEmpty && state.selectedIds.length == state.items.length;
}
