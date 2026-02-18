import 'package:voice_first_admin/features/Country_Management/country/models/country_model.dart';

class CountryState {
  final List<CountryModel> countries;
  final List<CountryModel> filtered;
  final String search;
  final bool isLoading;
  final bool hasMoreData;
  final int currentPage;
  final int totalCount;
  final int totalPages;
  final String? error;

  const CountryState({
    required this.countries,
    required this.filtered,
    required this.search,
    required this.isLoading,
    required this.hasMoreData,
    required this.currentPage,
    required this.totalCount,
    required this.totalPages,
    this.error,
  });

  factory CountryState.initial() => const CountryState(
    countries: [],
    filtered: [],
    search: '',
    isLoading: false,
    hasMoreData: true,
    currentPage: 1,
    totalCount: 0,
    totalPages: 1,
    error: null,
  );

  CountryState copyWith({
    List<CountryModel>? countries,
    List<CountryModel>? filtered,
    String? search,
    bool? isLoading,
    bool? hasMoreData,
    int? currentPage,
    int? totalCount,
    int? totalPages,
    String? error,
  }) {
    return CountryState(
      countries: countries ?? this.countries,
      filtered: filtered ?? this.filtered,
      search: search ?? this.search,
      isLoading: isLoading ?? this.isLoading,
      hasMoreData: hasMoreData ?? this.hasMoreData,
      currentPage: currentPage ?? this.currentPage,
      totalCount: totalCount ?? this.totalCount,
      totalPages: totalPages ?? this.totalPages,
      error: error ?? this.error,
    );
  }
}

// CountryNotifier and provider logic moved to country_provider.dart
