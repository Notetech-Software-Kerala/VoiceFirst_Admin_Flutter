import 'package:voice_first_admin/core/models/base_filter_model.dart';
import 'package:voice_first_admin/features/country_managements/division1/data/models/division1_model.dart';

class DivisionOneState {
  final List<DivisionOneModel> items;
  final BaseFilterModel filter;

  final int totalCount;
  final int totalPages;
  final int currentPage;
  final bool hasMoreData;

  final bool isLoading;
  final String? error;
  final bool isMultiSelect;
  final Set<int> selectedIds;

  DivisionOneState({
    required this.items,
    required this.filter,
    required this.totalCount,
    required this.totalPages,
    required this.currentPage,
    required this.hasMoreData,
    required this.isLoading,
    this.error,
    required this.isMultiSelect,
    required this.selectedIds,
  });

  factory DivisionOneState.initial() => DivisionOneState(
    items: const [],
    filter: const BaseFilterModel(),
    isMultiSelect: false,
    selectedIds: <int>{},
    isLoading: false,
    error: null,
    hasMoreData: true,
    currentPage: 1,
    totalCount: 0,
    totalPages: 0,
  );

  DivisionOneState copyWith({
    List<DivisionOneModel>? items,
    BaseFilterModel? filter,
    bool? isMultiSelect,
    Set<int>? selectedIds,
    bool? isLoading,
    String? error,
    bool? hasMoreData,
    int? currentPage,
    int? totalCount,
    int? totalPages,
  }) {
    return DivisionOneState(
      items: items ?? this.items,
      filter: filter ?? this.filter,
      isMultiSelect: isMultiSelect ?? this.isMultiSelect,
      selectedIds: selectedIds ?? this.selectedIds,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      hasMoreData: hasMoreData ?? this.hasMoreData,
      currentPage: currentPage ?? this.currentPage,
      totalCount: totalCount ?? this.totalCount,
      totalPages: totalPages ?? this.totalPages,
    );
  }
}
