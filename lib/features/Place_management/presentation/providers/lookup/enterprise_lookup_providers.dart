import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/features/Place_management/data/place_service/place_lookup_service.dart';
import 'package:voice_first_admin/features/Place_management/data/models/lookup_models.dart';
import 'package:voice_first_admin/features/Place_management/presentation/providers/lookup/lookup_provider.dart';

/// ============================================================
/// PAGINATED STATE
/// ============================================================

class PaginatedState<T> {
  final List<T> items;
  final int page;
  final bool hasMore;
  final bool isLoading;
  final String searchText;

  const PaginatedState({
    this.items = const [],
    this.page = 1,
    this.hasMore = true,
    this.isLoading = false,
    this.searchText = '',
  });

  PaginatedState<T> copyWith({
    List<T>? items,
    int? page,
    bool? hasMore,
    bool? isLoading,
    String? searchText,
  }) {
    return PaginatedState<T>(
      items: items ?? this.items,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      isLoading: isLoading ?? this.isLoading,
      searchText: searchText ?? this.searchText,
    );
  }
}

/// ============================================================
/// COUNTRY LOOKUP
/// ============================================================

final countryLookupProvider =
    AsyncNotifierProvider<CountryLookupNotifier, PaginatedState<CountryLookup>>(
      CountryLookupNotifier.new,
    );

class CountryLookupNotifier
    extends AsyncNotifier<PaginatedState<CountryLookup>> {
  late final PlaceLookupService _service;

  @override
  Future<PaginatedState<CountryLookup>> build() async {
    _service = ref.read(placeLookupServiceProvider);
    return _loadPage(const PaginatedState<CountryLookup>());
  }

  Future<void> loadNextPage() async {
    final current = state.value;
    if (current == null || current.isLoading || !current.hasMore) return;

    state = AsyncData(current.copyWith(isLoading: true));

    final response = await _service.getCountries(
      pageNumber: current.page,
      searchText: current.searchText.isEmpty ? null : current.searchText,
    );

    state = AsyncData(
      current.copyWith(
        items: [...current.items, ...response.items],
        page: current.page + 1,
        hasMore: current.page < response.totalPages,
        isLoading: false,
      ),
    );
  }

  Future<void> search(String searchText) async {
    state = const AsyncLoading();

    final response = await _service.getCountries(
      pageNumber: 1,
      searchText: searchText.isEmpty ? null : searchText,
    );

    state = AsyncData(
      PaginatedState(
        items: response.items,
        page: 2,
        hasMore: 1 < response.totalPages,
        searchText: searchText,
      ),
    );
  }

  Future<PaginatedState<CountryLookup>> _loadPage(
    PaginatedState<CountryLookup> base,
  ) async {
    final response = await _service.getCountries(
      pageNumber: base.page,
      searchText: base.searchText.isEmpty ? null : base.searchText,
    );

    return base.copyWith(
      items: response.items,
      page: 2,
      hasMore: 1 < response.totalPages,
    );
  }
}

/// ============================================================
/// DIVISION ONE LOOKUP (Family)
/// ============================================================

final divisionOneLookupProvider =
    AsyncNotifierProvider.family<
      DivisionOneLookupNotifier,
      PaginatedState<DivisionOneLookup>,
      int
    >((countryId) => DivisionOneLookupNotifier(countryId));

class DivisionOneLookupNotifier
    extends AsyncNotifier<PaginatedState<DivisionOneLookup>> {
  DivisionOneLookupNotifier(this.countryId);

  final int countryId;
  late final PlaceLookupService _service;

  @override
  Future<PaginatedState<DivisionOneLookup>> build() async {
    _service = ref.read(placeLookupServiceProvider);
    return _loadPage(const PaginatedState<DivisionOneLookup>());
  }

  Future<void> loadNextPage() async {
    final current = state.value;
    if (current == null || current.isLoading || !current.hasMore) return;

    state = AsyncData(current.copyWith(isLoading: true));

    final response = await _service.getDivisionOne(
      countryId: countryId,
      pageNumber: current.page,
      searchText: current.searchText.isEmpty ? null : current.searchText,
    );

    state = AsyncData(
      current.copyWith(
        items: [...current.items, ...response.items],
        page: current.page + 1,
        hasMore: current.page < response.totalPages,
        isLoading: false,
      ),
    );
  }

  Future<void> search(String searchText) async {
    state = const AsyncLoading();

    final response = await _service.getDivisionOne(
      countryId: countryId,
      pageNumber: 1,
      searchText: searchText.isEmpty ? null : searchText,
    );

    state = AsyncData(
      PaginatedState(
        items: response.items,
        page: 2,
        hasMore: 1 < response.totalPages,
        searchText: searchText,
      ),
    );
  }

  Future<PaginatedState<DivisionOneLookup>> _loadPage(
    PaginatedState<DivisionOneLookup> base,
  ) async {
    final response = await _service.getDivisionOne(
      countryId: countryId,
      pageNumber: base.page,
      searchText: base.searchText.isEmpty ? null : base.searchText,
    );

    return base.copyWith(
      items: response.items,
      page: 2,
      hasMore: 1 < response.totalPages,
    );
  }
}

/// ============================================================
/// DIVISION TWO LOOKUP (Family)
/// ============================================================

final divisionTwoLookupProvider =
    AsyncNotifierProvider.family<
      DivisionTwoLookupNotifier,
      PaginatedState<DivisionTwoLookup>,
      int
    >((divOneId) => DivisionTwoLookupNotifier(divOneId));

class DivisionTwoLookupNotifier
    extends AsyncNotifier<PaginatedState<DivisionTwoLookup>> {
  DivisionTwoLookupNotifier(this.divOneId);

  final int divOneId;
  late final PlaceLookupService _service;

  @override
  Future<PaginatedState<DivisionTwoLookup>> build() async {
    _service = ref.read(placeLookupServiceProvider);
    return _loadPage(const PaginatedState<DivisionTwoLookup>());
  }

  Future<void> loadNextPage() async {
    final current = state.value;
    if (current == null || current.isLoading || !current.hasMore) return;

    state = AsyncData(current.copyWith(isLoading: true));

    final response = await _service.getDivisionTwo(
      divOneId: divOneId,
      pageNumber: current.page,
      searchText: current.searchText.isEmpty ? null : current.searchText,
    );

    state = AsyncData(
      current.copyWith(
        items: [...current.items, ...response.items],
        page: current.page + 1,
        hasMore: current.page < response.totalPages,
        isLoading: false,
      ),
    );
  }

  Future<void> search(String searchText) async {
    state = const AsyncLoading();

    final response = await _service.getDivisionTwo(
      divOneId: divOneId,
      pageNumber: 1,
      searchText: searchText.isEmpty ? null : searchText,
    );

    state = AsyncData(
      PaginatedState(
        items: response.items,
        page: 2,
        hasMore: 1 < response.totalPages,
        searchText: searchText,
      ),
    );
  }

  Future<PaginatedState<DivisionTwoLookup>> _loadPage(
    PaginatedState<DivisionTwoLookup> base,
  ) async {
    final response = await _service.getDivisionTwo(
      divOneId: divOneId,
      pageNumber: base.page,
      searchText: base.searchText.isEmpty ? null : base.searchText,
    );

    return base.copyWith(
      items: response.items,
      page: 2,
      hasMore: 1 < response.totalPages,
    );
  }
}

/// ============================================================
/// DIVISION THREE LOOKUP (Family)
/// ============================================================

final divisionThreeLookupProvider =
    AsyncNotifierProvider.family<
      DivisionThreeLookupNotifier,
      PaginatedState<DivisionThreeLookup>,
      int
    >((divTwoId) => DivisionThreeLookupNotifier(divTwoId));

class DivisionThreeLookupNotifier
    extends AsyncNotifier<PaginatedState<DivisionThreeLookup>> {
  DivisionThreeLookupNotifier(this.divTwoId);

  final int divTwoId;
  late final PlaceLookupService _service;

  @override
  Future<PaginatedState<DivisionThreeLookup>> build() async {
    _service = ref.read(placeLookupServiceProvider);
    return _loadPage(const PaginatedState<DivisionThreeLookup>());
  }

  Future<void> loadNextPage() async {
    final current = state.value;
    if (current == null || current.isLoading || !current.hasMore) return;

    state = AsyncData(current.copyWith(isLoading: true));

    final response = await _service.getDivisionThree(
      divTwoId: divTwoId,
      pageNumber: current.page,
      searchText: current.searchText.isEmpty ? null : current.searchText,
    );

    state = AsyncData(
      current.copyWith(
        items: [...current.items, ...response.items],
        page: current.page + 1,
        hasMore: current.page < response.totalPages,
        isLoading: false,
      ),
    );
  }

  Future<void> search(String searchText) async {
    state = const AsyncLoading();

    final response = await _service.getDivisionThree(
      divTwoId: divTwoId,
      pageNumber: 1,
      searchText: searchText.isEmpty ? null : searchText,
    );

    state = AsyncData(
      PaginatedState(
        items: response.items,
        page: 2,
        hasMore: 1 < response.totalPages,
        searchText: searchText,
      ),
    );
  }

  Future<PaginatedState<DivisionThreeLookup>> _loadPage(
    PaginatedState<DivisionThreeLookup> base,
  ) async {
    final response = await _service.getDivisionThree(
      divTwoId: divTwoId,
      pageNumber: base.page,
      searchText: base.searchText.isEmpty ? null : base.searchText,
    );

    return base.copyWith(
      items: response.items,
      page: 2,
      hasMore: 1 < response.totalPages,
    );
  }
}
