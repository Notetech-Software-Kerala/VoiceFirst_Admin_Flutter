import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/features/Country_Management/division3/data/division3_service/division3_service.dart';
import 'package:voice_first_admin/features/Country_Management/division3/data/models/division3_filter.dart';
import 'package:voice_first_admin/features/Country_Management/division3/presentation/providers/division_three_state.dart';

class DivisionThreeNotifier extends Notifier<DivisionThreeState> {
  final int divisionTwoId;
  DivisionThreeNotifier(this.divisionTwoId);

  late final DivisionThreeService _service;

  @override
  DivisionThreeState build() {
    _service = ref.read(divisionThreeServiceProvider);

    // IMPORTANT: do not auto-call APIs from build(); UI should trigger loadAll

    return DivisionThreeState.initial();
  }

  Future<void> loadAll({
    DivisionThreeFilter? filter,
    int? page,
    int? pageSize,
  }) async {
    if (state.isLoading) return;

    final currentPage = page ?? state.currentPage;
    final currentPageSize = pageSize ?? 10;

    final DivisionThreeFilter appliedFilter =
        filter ??
        DivisionThreeFilter(
          divisionTwoId: divisionTwoId,
          pageNumber: currentPage,
          pageSize: currentPageSize,
          searchText: state.filter.searchText,
          searchBy: state.filter.searchBy,
          sortBy: state.filter.sortBy,
          sortOrder: state.filter.sortOrder,
          active: state.filter.active,
          deleted: state.filter.deleted,
        );

    state = state.copyWith(isLoading: true, filter: appliedFilter, error: null);

    try {
      final response = await _service.getAll(appliedFilter);

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

  Future<void> search(String query) async {
    final newFilter = DivisionThreeFilter(
      divisionTwoId: divisionTwoId,
      pageNumber: 1,
      pageSize: 10,
      searchText: query.isEmpty ? null : query,
      searchBy: state.filter.searchBy,
      sortBy: state.filter.sortBy,
      sortOrder: state.filter.sortOrder,
      active: state.filter.active,
      deleted: state.filter.deleted,
    );

    await loadAll(filter: newFilter);
  }
}
