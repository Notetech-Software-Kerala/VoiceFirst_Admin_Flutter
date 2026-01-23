import 'package:voice_first_admin/features/Program_management/models/program_management_model.dart';

class ProgramState {
  final List<ProgramManagementModel> all;
  final List<ProgramManagementModel> filtered;
  final String search;
  final Set<int> selectedIds;
  final bool isMultiSelect;
  final int? selectedApplicationId;
  final int? selectedCompanyId;
  final bool isLoading;
  final bool hasMoreData;
  final int currentPage;
  final int totalCount;

  const ProgramState({
    required this.all,
    required this.filtered,
    required this.search,
    required this.selectedIds,
    required this.isMultiSelect,
    required this.selectedApplicationId,
    required this.selectedCompanyId,
    required this.isLoading,
    required this.hasMoreData,
    required this.currentPage,
    required this.totalCount,
  });

  factory ProgramState.initial() => const ProgramState(
    all: [],
    filtered: [],
    search: '',
    selectedIds: {},
    isMultiSelect: false,
    selectedApplicationId: null,
    selectedCompanyId: null,
    isLoading: false,
    hasMoreData: true,
    currentPage: 1,
    totalCount: 0,
  );

  ProgramState copyWith({
    List<ProgramManagementModel>? all,
    List<ProgramManagementModel>? filtered,
    String? search,
    Set<int>? selectedIds,
    bool? isMultiSelect,
    int? selectedApplicationId,
    int? selectedCompanyId,
    bool? isLoading,
    bool? hasMoreData,
    int? currentPage,
    int? totalCount,
  }) {
    return ProgramState(
      all: all ?? this.all,
      filtered: filtered ?? this.filtered,
      search: search ?? this.search,
      selectedIds: selectedIds ?? this.selectedIds,
      isMultiSelect: isMultiSelect ?? this.isMultiSelect,
      selectedApplicationId:
          selectedApplicationId ?? this.selectedApplicationId,
      selectedCompanyId: selectedCompanyId ?? this.selectedCompanyId,
      isLoading: isLoading ?? this.isLoading,
      hasMoreData: hasMoreData ?? this.hasMoreData,
      currentPage: currentPage ?? this.currentPage,
      totalCount: totalCount ?? this.totalCount,
    );
  }
}
