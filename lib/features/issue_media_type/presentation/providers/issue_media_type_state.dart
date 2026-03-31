import 'package:voice_first_admin/features/issue_media_type/data/models/issue_media_type_model.dart';
import 'package:voice_first_admin/features/issue_media_type/data/models/issue_media_type_filter.dart';

class IssueMediaTypeState {
  final List<IssueMediaTypeModel> items;
  final IssueMediaTypeFilter filter;
  final String? error;
  final Set<int> selectedIds;
  final bool isMultiSelect;
  final bool isLoading;
  final bool hasMoreData;
  final int currentPage;
  final int totalCount;
  final int totalPages;

  IssueMediaTypeState({
    required this.items,
    required this.filter,
    required this.selectedIds,
    required this.isMultiSelect,
    required this.error,
    required this.isLoading,
    required this.hasMoreData,
    required this.currentPage,
    required this.totalCount,
    required this.totalPages,
  });

  factory IssueMediaTypeState.initial() {
    return IssueMediaTypeState(
      items: const [],
      filter: const IssueMediaTypeFilter(),
      error: null,
      selectedIds: <int>{},
      isMultiSelect: false,
      isLoading: false,
      hasMoreData: true,
      currentPage: 1,
      totalCount: 0,
      totalPages: 1,
    );
  }

  IssueMediaTypeState copyWith({
    List<IssueMediaTypeModel>? items,
    IssueMediaTypeFilter? filter,
    String? error,
    bool clearError = false, // ✅ ADD THIS
    Set<int>? selectedIds,
    bool? isMultiSelect,
    bool? isLoading,
    bool? hasMoreData,
    int? currentPage,
    int? totalCount,
    int? totalPages,
  }) {
    return IssueMediaTypeState(
      items: items ?? this.items,
      filter: filter ?? this.filter,
      error: clearError ? null : (error ?? this.error),
      selectedIds: selectedIds ?? this.selectedIds,
      isMultiSelect: isMultiSelect ?? this.isMultiSelect,
      isLoading: isLoading ?? this.isLoading,
      hasMoreData: hasMoreData ?? this.hasMoreData,
      currentPage: currentPage ?? this.currentPage,
      totalCount: totalCount ?? this.totalCount,
      totalPages: totalPages ?? this.totalPages,
    );
  }
}
