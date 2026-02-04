import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/features/Business_activity/models/activity_filter_option.dart';
import 'package:voice_first_admin/features/Business_activity/models/activity_searchby.dart';
import '../../business_activity_service/business_activity_service.dart';
import '../../models/business_activity_model.dart';
import 'business_activity_query.dart';
import 'business_activity_state.dart';

class BusinessActivityNotifier extends Notifier<BusinessActivityState> {
  late final BusinessActivityService _service;

  @override
  BusinessActivityState build() {
    _service = BusinessActivityService();
    return BusinessActivityState.initial();
  }

  // ───────────────── LOAD ─────────────────

  Future<void> load({BusinessActivityQuery? query}) async {
    if (state.isLoading) return;

    final nextQuery = query ?? state.query;

    state = state.copyWith(isLoading: true, query: nextQuery);

    try {
      final response = await _service.getAllActivities(nextQuery.toApiFilter());

      state = state.copyWith(
        items: response.items,
        totalCount: response.totalCount,
        currentPage: response.currentPage,
        hasMoreData: response.hasNextPage,
        isLoading: false,
      );
    } catch (e) {
      debugPrint('❌ Load failed: $e');
      state = state.copyWith(isLoading: false);
    }
  }

  // ───────────────── SEARCH / FILTER / SORT ─────────────────

  void search({required ActivitySearchBy searchBy, required String text}) {
    load(
      query: state.query.copyWith(
        searchBy: text.isEmpty ? null : searchBy,
        searchText: text.isEmpty ? null : text,
        pageNumber: 1,
      ),
    );
  }

  void sort({String? sortBy, String? sortOrder}) {
    load(
      query: state.query.copyWith(
        sortBy: sortBy,
        sortOrder: sortOrder,
        pageNumber: 1,
      ),
    );
  }

  void setFilter(ActivityFilterOption option) {
    BusinessActivityQuery query;

    switch (option) {
      case ActivityFilterOption.all:
        query = BusinessActivityQuery.initial();
        break;

      case ActivityFilterOption.active:
        query = const BusinessActivityQuery(active: true, deleted: false);
        break;

      case ActivityFilterOption.inactive:
        query = const BusinessActivityQuery(active: false, deleted: false);
        break;

      case ActivityFilterOption.available:
        query = const BusinessActivityQuery(deleted: false);
        break;

      case ActivityFilterOption.deleted:
        query = const BusinessActivityQuery(deleted: true);
        break;
    }

    load(query: query);
  }

  void filterByDates({
    DateTime? createdFromDate,
    DateTime? createdToDate,
    DateTime? updatedFromDate,
    DateTime? updatedToDate,
    DateTime? deletedFromDate,
    DateTime? deletedToDate,
  }) {
    load(
      query: state.query.copyWith(
        createdFromDate: createdFromDate,
        createdToDate: createdToDate,
        updatedFromDate: updatedFromDate,
        updatedToDate: updatedToDate,
        deletedFromDate: deletedFromDate,
        deletedToDate: deletedToDate,
        pageNumber: 1,
      ),
    );
  }

  // ───────────────── CLEAR ALL FILTERS ─────────────────
  void clearAllFilters() {
    load(query: BusinessActivityQuery.initial());
  }

  void goToPage(int page) {
    load(query: state.query.copyWith(pageNumber: page));
  }

  // ───────────────── CRUD ─────────────────

  Future<String?> add(String name) async {
    try {
      await _service.createActivity(name);
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
  }) async {
    try {
      final updated = await _service.updateActivity(
        id: id,
        activityName: activityName,
        active: active,
      );

      state = state.copyWith(
        items: state.items
            .map((a) => a.activityId == id ? updated : a)
            .toList(),
      );
      return null;
    } catch (e) {
      return 'Failed to update activity';
    }
  }

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
