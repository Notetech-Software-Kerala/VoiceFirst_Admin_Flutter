import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/features/country_management/division1/data/repositories/division_one_repository.dart';
import 'package:voice_first_admin/features/country_management/division1/data/models/division1_filter.dart';
import 'package:voice_first_admin/features/country_management/division1/presentation/providers/division_one_state.dart';

class DivisionOneNotifier extends Notifier<DivisionOneState> {
  final int countryId;
  DivisionOneNotifier(this.countryId);

  late final DivisionOneRepository _repository;

  @override
  DivisionOneState build() {
    _repository = ref.read(divisionOneRepositoryProvider);

    // IMPORTANT: do not auto-call APIs from build(); UI should trigger loadAll

    return DivisionOneState.initial();
  }

  Future<void> loadAll({
    DivisionOneFilter? filter,
    int? page,
    int? pageSize,
  }) async {
    if (state.isLoading) return;

    final currentPage = page ?? state.currentPage;
    final currentPageSize = pageSize ?? 10;

    final DivisionOneFilter appliedFilter =
        filter ??
        DivisionOneFilter(
          countryId: countryId,
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

    // Save filter into state before API call
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

  // 🔍 Backend search only
  Future<void> search(String query) async {
    final newFilter = DivisionOneFilter(
      countryId: countryId,
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
