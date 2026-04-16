import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/features/country_managements/division2/data/repositories/division_two_repository.dart';
import 'package:voice_first_admin/features/country_managements/division2/data/models/division2_filter.dart';
import 'package:voice_first_admin/features/country_managements/division2/data/models/division_two_model.dart';
import 'package:voice_first_admin/features/country_managements/division2/presentation/providers/division_two_state.dart';

class DivisionTwoNotifier extends Notifier<DivisionTwoState> {
  final int divisionOneId;
  DivisionTwoNotifier(this.divisionOneId);

  late final DivisionTwoRepository _repository;

  @override
  DivisionTwoState build() {
    _repository = ref.read(divisionTwoRepositoryProvider);

    // IMPORTANT: do not auto-call APIs from build(); UI should trigger loadAll

    return DivisionTwoState.initial();
  }

  Future<void> loadAll({
    DivisionTwoFilter? filter,
    int? page,
    int? pageSize,
  }) async {
    if (state.isLoading) return;

    final currentPage = page ?? state.currentPage;
    final currentPageSize = pageSize ?? 10;

    final DivisionTwoFilter appliedFilter =
        filter ??
        DivisionTwoFilter(
          divisionOneId: divisionOneId,
          pageNumber: currentPage,
          pageSize: currentPageSize,
          searchText: state.filter.searchText,
          searchBy: state.filter.searchBy,
          sortBy: state.filter.sortBy,
          sortOrder: state.filter.sortOrder,
          active: state.filter.active,
          deleted: state.filter.deleted,
          createdFromDate: state.filter.createdFromDate,
          createdToDate: state.filter.createdToDate,
          updatedFromDate: state.filter.updatedFromDate,
          updatedToDate: state.filter.updatedToDate,
          deletedFromDate: state.filter.deletedFromDate,
          deletedToDate: state.filter.deletedToDate,
        );

    state = state.copyWith(isLoading: true, filter: appliedFilter, error: null);

    try {
      final response = await _repository.getAll(appliedFilter);

      state = state.copyWith(
        items: response.items,
        isLoading: false,
        hasMoreData: response.pageNumber < response.totalPages,
        currentPage: response.pageNumber,
        totalCount: response.totalCount,
        totalPages: response.totalPages,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // 🔍 Backend Search
  Future<void> search(String query) async {
    final newFilter = DivisionTwoFilter(
      divisionOneId: divisionOneId,
      pageNumber: 1,
      pageSize: 10,
      searchText: query.isEmpty ? null : query,
      searchBy: state.filter.searchBy,
      sortBy: state.filter.sortBy,
      sortOrder: state.filter.sortOrder,
      active: state.filter.active,
      deleted: state.filter.deleted,
      createdFromDate: state.filter.createdFromDate,
      createdToDate: state.filter.createdToDate,
      updatedFromDate: state.filter.updatedFromDate,
      updatedToDate: state.filter.updatedToDate,
      deletedFromDate: state.filter.deletedFromDate,
      deletedToDate: state.filter.deletedToDate,
    );

    await loadAll(filter: newFilter);
  }

  // ➕ Add
  void add(DivisionTwoModel d) {
    final list = [...state.items, d];
    state = state.copyWith(items: list);
  }

  // ✏️ Update
  void update(DivisionTwoModel updated) {
    final list = state.items
        .map((d) => d.id == updated.id ? updated : d)
        .toList();
    state = state.copyWith(items: list);
  }

  // 🔄 Status
  void toggleStatus(int id, bool status) {
    final list = state.items
        .map((d) => d.id == id ? d.copyWith(status: status) : d)
        .toList();
    state = state.copyWith(items: list);
  }

  // ❌ Delete
  void delete(int id) {
    final list = state.items.where((d) => d.id != id).toList();
    state = state.copyWith(items: list);
  }

  // ❌ Delete selected
  void deleteSelected() {
    final list = state.items
        .where((d) => !state.selectedIds.contains(d.id))
        .toList();

    state = state.copyWith(items: list, selectedIds: {}, isMultiSelect: false);
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
      selected.addAll(state.items.map((e) => e.id));
    }

    state = state.copyWith(isMultiSelect: true, selectedIds: selected);
  }

  void exitSelectionMode() {
    state = state.copyWith(isMultiSelect: false, selectedIds: {});
  }

  bool get allVisibleSelected =>
      state.items.isNotEmpty && state.selectedIds.length == state.items.length;
}
