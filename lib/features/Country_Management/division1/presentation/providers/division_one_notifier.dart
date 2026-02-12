import 'package:flutter_riverpod/legacy.dart';
import 'package:voice_first_admin/features/Country_Management/division1/division1_service/division1_service.dart';
import 'package:voice_first_admin/features/Country_Management/division1/models/division1_filter.dart';
import 'division_one_state.dart';

class DivisionOneNotifier extends StateNotifier<DivisionOneState> {
  final DivisionOneService _service;
  final int countryId;

  DivisionOneNotifier({
    required this.countryId,
    required DivisionOneService service,
  }) : _service = service,
       super(DivisionOneState.initial()) {
    loadAll(filter: const DivisionOneFilter(pageNumber: 1, pageSize: 10));
  }

  Future<void> loadAll({DivisionOneFilter? filter}) async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true);

    try {
      final response = await _service.getAll(
        countryId,
        filter ?? const DivisionOneFilter(pageNumber: 1, pageSize: 10),
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

  // 🔍 Search
  Future<void> search(String query) async {
    state = state.copyWith(search: query);
    await loadAll(
      filter: DivisionOneFilter(
        pageNumber: 1,
        pageSize: 10,
        searchText: query.isEmpty ? null : query,
      ),
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
}
