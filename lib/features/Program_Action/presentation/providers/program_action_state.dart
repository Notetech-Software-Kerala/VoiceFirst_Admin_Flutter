import 'package:voice_first_admin/features/Program_Action/models/program_action_model.dart';

class ProgramActionState {
  final List<ProgramActionModel> all;
  final List<ProgramActionModel> filtered;
  final String search;
  final Set<int> selectedIds;
  final bool isMultiSelect;

  const ProgramActionState({
    required this.all,
    required this.filtered,
    required this.search,
    required this.selectedIds,
    required this.isMultiSelect,
  });

  factory ProgramActionState.initial() => const ProgramActionState(
    all: [],
    filtered: [],
    search: '',
    selectedIds: {},
    isMultiSelect: false,
  );

  ProgramActionState copyWith({
    List<ProgramActionModel>? all,
    List<ProgramActionModel>? filtered,
    String? search,
    Set<int>? selectedIds,
    bool? isMultiSelect,
  }) {
    return ProgramActionState(
      all: all ?? this.all,
      filtered: filtered ?? this.filtered,
      search: search ?? this.search,
      selectedIds: selectedIds ?? this.selectedIds,
      isMultiSelect: isMultiSelect ?? this.isMultiSelect,
    );
  }
}
