import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/features/Country_Management/country/data/country_service/country_service.dart';
import 'package:voice_first_admin/core/network/dio_client.dart';
import '../../data/models/country_filter.dart';
import 'country_state.dart';

/// Provider that constructs the CountryService using the centralized Dio client.
final countryServiceProvider = Provider<CountryService>((ref) {
  return CountryService(ref.read(dioClientProvider));
});

final countryProvider = NotifierProvider<CountryNotifier, CountryState>(
  CountryNotifier.new,
);

class CountryNotifier extends Notifier<CountryState> {
  late final CountryService _service;

  @override
  CountryState build() {
    _service = ref.read(countryServiceProvider);
    // Do NOT call loadAll here! Initial load should be triggered from the widget's initState.
    return CountryState.initial();
  }

  Future<void> loadAll({
    CountryFilter? filter,
    int? page,
    int? pageSize,
  }) async {
    if (state.isLoading) return;

    final currentPage = page ?? state.currentPage;
    final currentPageSize = pageSize ?? 10;

    // Build applied filter: prefer explicit CountryFilter, otherwise map from state.filter
    final CountryFilter appliedFilter =
        filter ??
        CountryFilter(
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

    // Update filter in state before API call
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
    final newFilter = CountryFilter(
      pageNumber: 1,
      pageSize: 10,
      searchText: query.isEmpty ? null : query,
    );

    await loadAll(filter: newFilter);
  }
}
