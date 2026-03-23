import 'package:voice_first_admin/features/Country_Management/division2/data/models/division_two_model.dart';

class DivisionTwoState {
  final List<DivisionTwoModel> all;
  final List<DivisionTwoModel> filtered;
  final bool isMultiSelect;
  final Set<int> selectedIds;
  final String search;
  final bool isLoading;
  final int currentPage;
  final int totalPages;
  final int totalCount;
  final bool hasMoreData;
  final String? error;

  DivisionTwoState({
    required this.all,
    required this.filtered,
    required this.isMultiSelect,
    required this.selectedIds,
    required this.search,
    required this.isLoading,
    required this.currentPage,
    required this.totalPages,
    required this.totalCount,
    required this.hasMoreData,
    this.error,
  });

  factory DivisionTwoState.initial() => DivisionTwoState(
    all: [],
    filtered: [],
    isMultiSelect: false,
    selectedIds:<int> {},
    search: '',
    isLoading: false,
    currentPage: 1,
    totalPages: 1,
    totalCount: 0,
    hasMoreData: true,
    error: null,
  );

  DivisionTwoState copyWith({
    List<DivisionTwoModel>? all,
    List<DivisionTwoModel>? filtered,
    bool? isMultiSelect,
    Set<int>? selectedIds,
    String? search,
    bool? isLoading,
    int? currentPage,
    int? totalPages,
    int? totalCount,
    bool? hasMoreData,
    String? error,
  }) {
    return DivisionTwoState(
      all: all ?? this.all,
      filtered: filtered ?? this.filtered,
      isMultiSelect: isMultiSelect ?? this.isMultiSelect,
      selectedIds: selectedIds ?? this.selectedIds,
      search: search ?? this.search,
      isLoading: isLoading ?? this.isLoading,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalCount: totalCount ?? this.totalCount,
      hasMoreData: hasMoreData ?? this.hasMoreData,
      error: error,
    );
  }
}
