import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/core/models/base_filter_model.dart';
import 'package:voice_first_admin/features/Business_activity/data/models/business_activity_filter.dart';
import 'package:voice_first_admin/features/Business_activity/data/models/update_activity_request.dart';
import '../../data/business_activity_service/business_activity_service.dart';
import 'business_activity_state.dart';

class BusinessActivityNotifier extends Notifier<BusinessActivityState> {
  late final BusinessActivityService _service;

  @override
  BusinessActivityState build() {
    _service = BusinessActivityService();
    return BusinessActivityState.initial();
  }

  // ───────────────── MAPPER ─────────────────
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

      debugPrint(
        '[Notifier] load: apiFilter=${apiFilter.toQueryParams()} page=$currentPage',
      );

      final response = await _service.getAllActivities(apiFilter);

      debugPrint(
        '[Notifier] load: received ${response.items.length} items, totalCount=${response.totalCount}',
      );

      state = state.copyWith(
        items: response.items,
        totalCount: response.totalCount,
        currentPage: response.currentPage,
        isLoading: false,
      );
    } catch (e) {
      debugPrint('[Notifier] load error: $e');
      state = state.copyWith(isLoading: false);
    }
  }

  // ───────────────── CRUD ─────────────────

  Future<String?> add(String name, {List<int>? customFieldIds}) async {
    try {
      debugPrint('[Notifier] add: name=$name customFieldIds=$customFieldIds');
      await _service.createActivity(name, customFieldIds: customFieldIds);
      debugPrint('[Notifier] add: createActivity succeeded for name=$name');
      // Reload to respect sort order and pagination
      await load();
      return null;
    } catch (e) {
      debugPrint('[Notifier] add error: $e');
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

      debugPrint('[Notifier] update: id=$id request=${request.toJson()}');

      final updated = await _service.updateActivity(id, request);

      debugPrint(
        '[Notifier] update: received updated activity id=${updated.activityId}',
      );

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
 

  Future<String?> delete(int id) async {
    try {
      debugPrint('[Notifier] delete: id=$id');
      final deleted = await _service.deleteActivity(id);

      debugPrint(
        '[Notifier] delete: received deleted activity id=${deleted.activityId}',
      );

      state = state.copyWith(
        items: state.items
            .map((a) => a.activityId == id ? deleted : a)
            .toList(),
      );

      return null;
    } catch (e) {
      debugPrint('[Notifier] delete error: $e');
      return 'Failed to delete activity';
    }
  }

  Future<String?> recover(int id) async {
    try {
      debugPrint('[Notifier] recover: id=$id');
      final updated = await _service.recoverActivity(id);

      debugPrint(
        '[Notifier] recover: received activity id=${updated.activityId}',
      );

      state = state.copyWith(
        items: state.items
            .map((a) => a.activityId == id ? updated : a)
            .toList(),
      );

      return null;
    } catch (e) {
      debugPrint('[Notifier] recover error: $e');
      return 'Failed to recover activity';
    }
  }

  Future<String?> deleteSelected() async {
    if (state.selectedIds.isEmpty) return 'No items selected';

    try {
      debugPrint('[Notifier] deleteSelected: ids=${state.selectedIds}');
      await _service.bulkDelete(state.selectedIds.toList());
      debugPrint('[Notifier] deleteSelected: bulkDelete succeeded');
      await load();
      return null;
    } catch (e) {
      debugPrint('[Notifier] deleteSelected error: $e');
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
