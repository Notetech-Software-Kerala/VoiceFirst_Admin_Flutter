import 'package:voice_first_admin/features/Country_Management/division1/data/models/division1_model.dart';

class DivisionOneState {
  final List<DivisionOneModel> all;
  final List<DivisionOneModel> filtered;
  final bool isMultiSelect;
  final Set<int> selectedIds;
  final String search;
  final bool isLoading;
  final String? error;
  final bool hasMoreData;
  final int currentPage;
  final int totalCount;
  final int totalPages;

  DivisionOneState({
    required this.all,
    required this.filtered,
    required this.isMultiSelect,
    required this.selectedIds,
    required this.search,
    required this.isLoading,
    this.error,
    required this.hasMoreData,
    required this.currentPage,
    required this.totalCount,
    required this.totalPages,
  });

  factory DivisionOneState.initial() => DivisionOneState(
    all: [],
    filtered: [],
    isMultiSelect: false,
    selectedIds: <int>{},
    search: '',
    isLoading: false,
    error: null,
    hasMoreData: true,
    currentPage: 1,
    totalCount: 0,
    totalPages: 1,
  );

  DivisionOneState copyWith({
    List<DivisionOneModel>? all,
    List<DivisionOneModel>? filtered,
    bool? isMultiSelect,
    Set<int>? selectedIds,
    String? search,
    bool? isLoading,
    String? error,
    bool? hasMoreData,
    int? currentPage,
    int? totalCount,
    int? totalPages,
  }) {
    return DivisionOneState(
      all: all ?? this.all,
      filtered: filtered ?? this.filtered,
      isMultiSelect: isMultiSelect ?? this.isMultiSelect,
      selectedIds: selectedIds ?? this.selectedIds,
      search: search ?? this.search,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      hasMoreData: hasMoreData ?? this.hasMoreData,
      currentPage: currentPage ?? this.currentPage,
      totalCount: totalCount ?? this.totalCount,
      totalPages: totalPages ?? this.totalPages,
    );
  }
}
