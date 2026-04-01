import 'package:voice_first_admin/core/models/base_filter_model.dart';
import 'package:voice_first_admin/features/country_management/country/data/models/country_model.dart';

class CountryState {
  final List<CountryModel> items;
  final BaseFilterModel filter;

  final int totalCount;
  final int totalPages;
  final int currentPage;
  final bool hasMoreData;

  final bool isLoading;
  final String? error;

  const CountryState({
    required this.items,
    required this.filter,
    required this.totalCount,
    required this.totalPages,
    required this.currentPage,
    required this.hasMoreData,
    required this.isLoading,
    this.error,
  });

  factory CountryState.initial() => CountryState(
    items: const [],
    filter: const BaseFilterModel(),
    isLoading: false,
    hasMoreData: true,
    currentPage: 1,
    totalCount: 0,
    totalPages: 0,
    error: null,
  );

  CountryState copyWith({
    List<CountryModel>? items,
    BaseFilterModel? filter,
    int? totalCount,
    int? totalPages,
    int? currentPage,
    bool? hasMoreData,
    bool? isLoading,
    String? error,
  }) {
    return CountryState(
      items: items ?? this.items,
      filter: filter ?? this.filter,
      totalCount: totalCount ?? this.totalCount,
      totalPages: totalPages ?? this.totalPages,
      currentPage: currentPage ?? this.currentPage,
      hasMoreData: hasMoreData ?? this.hasMoreData,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// CountryNotifier and provider logic moved to country_provider.dart
