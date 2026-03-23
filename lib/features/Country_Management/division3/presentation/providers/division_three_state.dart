import 'package:voice_first_admin/features/Country_Management/division3/data/models/division_three_model.dart';

class DivisionThreeState {
  final List<DivisionThreeModel> items;
  final int currentPage;
  final int totalPages;
  final int totalCount;
  final int pageSize;
  final bool isLoading;
  final bool hasMoreData;
  final String search;
  final String? error;

  const DivisionThreeState({
    required this.items,
    required this.currentPage,
    required this.totalPages,
    required this.totalCount,
    required this.pageSize,
    required this.isLoading,
    required this.hasMoreData,
    required this.search,
    this.error,
  });

  factory DivisionThreeState.initial() => const DivisionThreeState(
    items: [],
    currentPage: 1,
    totalPages: 1,
    totalCount: 0,
    pageSize: 10,
    isLoading: false,
    hasMoreData: false,
    search: '',
    error: null,
  );

  DivisionThreeState copyWith({
    List<DivisionThreeModel>? items,
    int? currentPage,
    int? totalPages,
    int? totalCount,
    int? pageSize,
    bool? isLoading,
    bool? hasMoreData,
    String? search,
    String? error,
  }) {
    return DivisionThreeState(
      items: items ?? this.items,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalCount: totalCount ?? this.totalCount,
      pageSize: pageSize ?? this.pageSize,
      isLoading: isLoading ?? this.isLoading,
      hasMoreData: hasMoreData ?? this.hasMoreData,
      search: search ?? this.search,
      error: error,
    );
  }
}
