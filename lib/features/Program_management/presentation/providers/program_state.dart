import 'package:voice_first_admin/features/Program_management/models/program_management_model.dart';

class ProgramState {
  final List<ProgramManagementModel> all;
  final List<ProgramManagementModel> filtered;
  final String search;
  final Set<int> selectedIds;
  final bool isMultiSelect;
  final int? selectedApplicationId;
  final int? selectedCompanyId;

  const ProgramState({
    required this.all,
    required this.filtered,
    required this.search,
    required this.selectedIds,
    required this.isMultiSelect,
    required this.selectedApplicationId,
    required this.selectedCompanyId,
  });

  factory ProgramState.initial() => const ProgramState(
    all: [],
    filtered: [],
    search: '',
    selectedIds: {},
    isMultiSelect: false,
    selectedApplicationId: null,
    selectedCompanyId: null,
  );

  ProgramState copyWith({
    List<ProgramManagementModel>? all,
    List<ProgramManagementModel>? filtered,
    String? search,
    Set<int>? selectedIds,
    bool? isMultiSelect,
    int? selectedApplicationId,
    int? selectedCompanyId,
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
    );
  }
}
