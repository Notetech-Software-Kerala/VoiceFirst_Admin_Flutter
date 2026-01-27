import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/features/Country Management/country/country_service/country_service.dart';
import 'package:voice_first_admin/features/Country Management/country/models/country_filter.dart';
import 'country_state.dart';

final countryProvider = NotifierProvider<CountryNotifier, CountryState>(
  CountryNotifier.new,
);

class CountryNotifier extends Notifier<CountryState> {
  final _service = CountryService();

  @override
  CountryState build() {
    loadAll(filter: const CountryFilter(pageNumber: 1, pageSize: 10));
    return CountryState.initial();
  }

  Future<void> loadAll({CountryFilter? filter}) async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true);

    try {
      final response = await _service.getAll(
        filter ?? const CountryFilter(pageNumber: 1, pageSize: 10),
      );

      state = state.copyWith(
        countries: response.items,
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
        error: 'Failed to load countries',
      );
    }
  }

  Future<void> search(String query) async {
    state = state.copyWith(search: query);
    await loadAll(
      filter: CountryFilter(
        pageNumber: 1,
        pageSize: 10,
        searchText: query.isEmpty ? null : query,
      ),
    );
  }
}
