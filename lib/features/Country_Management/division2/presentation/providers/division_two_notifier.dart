import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:voice_first_admin/features/Country_Management/division2/data/division2_service/division2_service.dart';
import 'package:voice_first_admin/features/Country_Management/division2/data/models/division2_filter.dart';
import 'package:voice_first_admin/features/Country_Management/division2/data/models/division_two_model.dart';
import 'division_two_state.dart';

class DivisionTwoNotifier extends StateNotifier<DivisionTwoState> {
  final DivisionTwoService _service;
  final int divisionOneId;

  DivisionTwoNotifier({
    required this.divisionOneId,
    required DivisionTwoService service,
  }) : _service = service,
       super(DivisionTwoState.initial()) {
    loadAll(
      filter: DivisionTwoFilter(
        divisionOneId: divisionOneId,
        pageNumber: 1,
        pageSize: 10,
      ),
    );
  }

  Future<void> loadAll({DivisionTwoFilter? filter}) async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true);

    try {
      final response = await _service.getAll(
        filter ??
            DivisionTwoFilter(
              divisionOneId: divisionOneId,
              pageNumber: 1,
              pageSize: 10,
            ),
      );

      state = state.copyWith(
        all: response.items,
        filtered: response.items,
        isLoading: false,
        hasMoreData: response.pageNumber < response.totalPages,
        currentPage: response.pageNumber,
        totalCount: response.totalCount,
        totalPages: response.totalPages,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load divisions',
      );
    }
  }

  // 🔍 Backend Search
  Future<void> search(String query) async {
    state = state.copyWith(search: query);
    await loadAll(
      filter: DivisionTwoFilter(
        divisionOneId: divisionOneId,
        pageNumber: 1,
        pageSize: 10,
        searchText: query.isEmpty ? null : query,
      ),
    );
  }

  // ➕ Add
  void add(DivisionTwoModel d) {
    final list = [...state.all, d];
    state = state.copyWith(all: list, filtered: _applyFilter(list));
  }

  // ✏️ Update
  void update(DivisionTwoModel updated) {
    final list = state.all
        .map((d) => d.id == updated.id ? updated : d)
        .toList();
    state = state.copyWith(all: list, filtered: _applyFilter(list));
  }

  // 🔄 Status
  void toggleStatus(int id, bool status) {
    final list = state.all
        .map((d) => d.id == id ? d.copyWith(status: status) : d)
        .toList();
    state = state.copyWith(all: list, filtered: _applyFilter(list));
  }

  // ❌ Delete
  void delete(int id) {
    final list = state.all.where((d) => d.id != id).toList();
    state = state.copyWith(all: list, filtered: _applyFilter(list));
  }

  // ❌ Delete selected
  void deleteSelected() {
    final list = state.all
        .where((d) => !state.selectedIds.contains(d.id))
        .toList();

    state = state.copyWith(
      all: list,
      filtered: _applyFilter(list),
      selectedIds: {},
      isMultiSelect: false,
    );
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

  List<DivisionTwoModel> _applyFilter(List<DivisionTwoModel> list) {
    if (state.search.isEmpty) return list;
    return list
        .where((d) => d.name.toLowerCase().contains(state.search.toLowerCase()))
        .toList();
  }
}
