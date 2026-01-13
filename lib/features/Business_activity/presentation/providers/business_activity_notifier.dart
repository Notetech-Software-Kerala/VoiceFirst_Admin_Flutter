import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:voice_first_admin/features/Business_activity/models/business_activity_model.dart';
import 'business_activity_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BusinessActivityNotifier extends StateNotifier<BusinessActivityState> {
  BusinessActivityNotifier() : super(BusinessActivityState.initial()) {
    _loadStaticData();
  }

  void _loadStaticData() {
    final data = <BusinessActivity>[
      BusinessActivity(
        id: '1',
        activityName: 'Sales',
        // isForCompany: true,
        // isForBranch: true,
        status: true,
      ),
      BusinessActivity(
        id: '2',
        activityName: 'Marketing',
        // isForCompany: true,
        // isForBranch: false,
        status: true,
      ),
    ];

    state = state.copyWith(activities: data, filtered: data);
  }

  // 🔍 Search
  void search(String query) {
    final filtered = query.isEmpty
        ? state.activities
        : state.activities
              .where(
                (a) =>
                    a.activityName.toLowerCase().contains(query.toLowerCase()),
              )
              .toList();

    state = state.copyWith(search: query, filtered: filtered);
  }

  // ➕ Add
  void add(BusinessActivity activity) {
    final list = [...state.activities, activity];
    state = state.copyWith(activities: list, filtered: _applyFilter(list));
  }

  // ✏️ Update
  void update(BusinessActivity updated) {
    final list = state.activities
        .map((a) => a.id == updated.id ? updated : a)
        .toList();

    state = state.copyWith(activities: list, filtered: _applyFilter(list));
  }

  // 🔄 Status
  void toggleStatus(String id, bool status) {
    final list = state.activities
        .map((a) => a.id == id ? a.copyWith(status: status) : a)
        .toList();

    state = state.copyWith(activities: list, filtered: _applyFilter(list));
  }

  // ❌ Delete
  void delete(String id) {
    final list = state.activities.where((a) => a.id != id).toList();
    state = state.copyWith(activities: list, filtered: _applyFilter(list));
  }

  void deleteSelected() {
    final list = state.activities
        .where((a) => !state.selectedIds.contains(a.id))
        .toList();

    state = state.copyWith(
      activities: list,
      filtered: _applyFilter(list),
      selectedIds: {},
      isMultiSelect: false,
    );
  }

  // ☑️ Selection
  void toggleSelection(String id) {
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
        .where(
          (a) =>
              a.activityName.toLowerCase().contains(state.search.toLowerCase()),
        )
        .toList();
  }

  void enterSelectionMode({bool selectAll = false}) {
    final selected = <String>{};

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
