import 'package:voice_first_admin/features/issue_type/data/models/issue_type_model.dart';

class IssueTypeState {
  final List<IssueTypeModel> items;
  final List<IssueTypeModel> filtered;
  final Set<int> selectedIds;
  final bool isMultiSelect;
  final String search;
  final bool isLoading;
  final bool hasMoreData;
  final int currentPage;
  final int totalCount;
  final int totalPages;

  IssueTypeState({
    required this.items,
    required this.filtered,
    required this.selectedIds,
    required this.isMultiSelect,
    required this.search,
    required this.isLoading,
    required this.hasMoreData,
    required this.currentPage,
    required this.totalCount,
    required this.totalPages,
  });

  factory IssueTypeState.initial() {
    return IssueTypeState(
      items: const [],
      filtered: const [],
      selectedIds: <int>{},
      isMultiSelect: false,
      search: '',
      isLoading: false,
      hasMoreData: true,
      currentPage: 1,
      totalCount: 0,
      totalPages: 1,
    );
  }

  int get activeCount => items.where((e) => e.active && !e.deleted).length;
  int get inactiveCount => items.where((e) => !e.active && !e.deleted).length;

  IssueTypeState copyWith({
    List<IssueTypeModel>? items,
    List<IssueTypeModel>? filtered,
    Set<int>? selectedIds,
    bool? isMultiSelect,
    String? search,
    bool? isLoading,
    bool? hasMoreData,
    int? currentPage,
    int? totalCount,
    int? totalPages,
  }) {
    return IssueTypeState(
      items: items ?? this.items,
      filtered: filtered ?? this.filtered,
      selectedIds: selectedIds ?? this.selectedIds,
      isMultiSelect: isMultiSelect ?? this.isMultiSelect,
      search: search ?? this.search,
      isLoading: isLoading ?? this.isLoading,
      hasMoreData: hasMoreData ?? this.hasMoreData,
      currentPage: currentPage ?? this.currentPage,
      totalCount: totalCount ?? this.totalCount,
      totalPages: totalPages ?? this.totalPages,
    );
  }
}
