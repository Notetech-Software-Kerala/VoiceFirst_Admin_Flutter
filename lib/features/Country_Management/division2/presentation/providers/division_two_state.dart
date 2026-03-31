import 'package:voice_first_admin/core/models/base_filter_model.dart';
import 'package:voice_first_admin/features/Country_Management/division2/data/models/division_two_model.dart';

class DivisionTwoState {
  final List<DivisionTwoModel> items;
  final BaseFilterModel filter;

  final int totalCount;
  final int totalPages;
  final int currentPage;
  final bool hasMoreData;

  final bool isLoading;
  final String? error;
  final bool isMultiSelect;
  final Set<int> selectedIds;

  DivisionTwoState({
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

  factory DivisionTwoState.initial() => DivisionTwoState(
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

  DivisionTwoState copyWith({
    List<DivisionTwoModel>? items,
    BaseFilterModel? filter,
    bool? isMultiSelect,
    Set<int>? selectedIds,
    bool? isLoading,
    String? error,
    int? currentPage,
    int? totalPages,
    int? totalCount,
    bool? hasMoreData,
  }) {
    return DivisionTwoState(
      items: items ?? this.items,
      filter: filter ?? this.filter,
      isMultiSelect: isMultiSelect ?? this.isMultiSelect,
      selectedIds: selectedIds ?? this.selectedIds,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalCount: totalCount ?? this.totalCount,
      hasMoreData: hasMoreData ?? this.hasMoreData,
    );
  }
}
