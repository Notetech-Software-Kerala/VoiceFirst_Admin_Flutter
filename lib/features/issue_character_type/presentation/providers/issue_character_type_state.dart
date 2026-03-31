import 'package:voice_first_admin/core/models/base_filter_model.dart';
import 'package:voice_first_admin/features/issue_character_type/data/models/issue_character_type_filter.dart';
import 'package:voice_first_admin/features/issue_character_type/data/models/issue_charactertype_model.dart';

class IssueCharacterTypeState {
  final List<IssueCharacterTypeModel> items;
  final IssueCharacterTypeFilter filter;

  final int totalCount;
  final int totalPages;
  final int currentPage;
  final bool hasMoreData;

  final bool isLoading;
  final String? error;

  final bool isMultiSelect;
  final Set<int> selectedIds;

  IssueCharacterTypeState({
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

  factory IssueCharacterTypeState.initial() => IssueCharacterTypeState(
    items: const [],
    filter: const IssueCharacterTypeFilter(),
    isMultiSelect: false,
    selectedIds: <int>{},
    isLoading: false,
    error: null,
    hasMoreData: true,
    currentPage: 1,
    totalCount: 0,
    totalPages: 0,
  );

  IssueCharacterTypeState copyWith({
    List<IssueCharacterTypeModel>? items,
    IssueCharacterTypeFilter? filter,
    bool? isMultiSelect,
    Set<int>? selectedIds,
    bool? isLoading,
    String? error,
    int? currentPage,
    int? totalCount,
    int? totalPages,
    bool? hasMoreData,
  }) {
    return IssueCharacterTypeState(
      items: items ?? this.items,
      filter: filter ?? this.filter,
      isMultiSelect: isMultiSelect ?? this.isMultiSelect,
      selectedIds: selectedIds ?? this.selectedIds,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      currentPage: currentPage ?? this.currentPage,
      totalCount: totalCount ?? this.totalCount,
      totalPages: totalPages ?? this.totalPages,
      hasMoreData: hasMoreData ?? this.hasMoreData,
    );
  }
}
