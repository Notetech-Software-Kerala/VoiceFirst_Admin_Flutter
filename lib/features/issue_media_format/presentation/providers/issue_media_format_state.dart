import 'package:voice_first_admin/features/issue_media_format/data/models/issue_media_format_filter.dart';
import 'package:voice_first_admin/features/issue_media_format/data/models/issue_media_format_model.dart';

class IssueMediaFormatState {
  final List<IssueMediaFormatModel> items;
  final IssueMediaFormatFilter filter;

  final int totalCount;
  final int totalPages;
  final int currentPage;
  final bool hasMoreData;

  final bool isLoading;
  final String? error;

  final bool isMultiSelect;
  final Set<int> selectedIds;

  IssueMediaFormatState({
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

  factory IssueMediaFormatState.initial() => IssueMediaFormatState(
    items: const [],
    filter: const IssueMediaFormatFilter(),
    isMultiSelect: false,
    selectedIds: <int>{},
    isLoading: false,
    error: null,
    hasMoreData: true,
    currentPage: 1,
    totalCount: 0,
    totalPages: 1,
  );

  IssueMediaFormatState copyWith({
    List<IssueMediaFormatModel>? items,
    IssueMediaFormatFilter? filter,
    Set<int>? selectedIds,
    bool? isMultiSelect,
    bool? isLoading,
    String? error,
    bool? hasMoreData,
    int? currentPage,
    int? totalCount,
    int? totalPages,
  }) {
    return IssueMediaFormatState(
      items: items ?? this.items,
      filter: filter ?? this.filter,
      selectedIds: selectedIds ?? this.selectedIds,
      isMultiSelect: isMultiSelect ?? this.isMultiSelect,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      hasMoreData: hasMoreData ?? this.hasMoreData,
      currentPage: currentPage ?? this.currentPage,
      totalCount: totalCount ?? this.totalCount,
      totalPages: totalPages ?? this.totalPages,
    );
  }
}
