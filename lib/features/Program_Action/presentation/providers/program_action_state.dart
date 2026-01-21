
import 'package:voice_first_admin/features/Program_Action/models/program_action_model.dart';

class ProgramActionState {
  final List<ProgramActionModel> actions;
  final List<ProgramActionModel> filtered;
  final Set<int> selectedIds;
  final bool isMultiSelect;
  final String search;
  final bool isLoading;
  final bool hasMoreData;
  final int currentPage;
  final int totalCount;
  final int totalPages;


  ProgramActionState({
    required this.actions,
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

  factory ProgramActionState.initial() {
    return ProgramActionState(
      actions: [],
      filtered: [],
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

  ProgramActionState copyWith({
    List<ProgramActionModel>? actions,
    List<ProgramActionModel>? filtered,
    Set<int>? selectedIds,
    bool? isMultiSelect,
    String? search,
    bool? isLoading,
    bool? hasMoreData,
    int? currentPage,
    int? totalCount,
    int? totalPages,
  }) {
    return ProgramActionState(
      actions: actions ?? this.actions,
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
