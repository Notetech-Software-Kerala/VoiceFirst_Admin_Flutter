import 'package:voice_first_admin/features/Country%20Management/division3/models/division_three_model.dart';

class DivisionThreeState {
  final List<DivisionThreeModel> all;
  final List<DivisionThreeModel> filtered;
  final String search;
  final Set<String> selectedIds;
  final bool isMultiSelect;

  const DivisionThreeState({
    required this.all,
    required this.filtered,
    required this.search,
    required this.selectedIds,
    required this.isMultiSelect,
  });

  factory DivisionThreeState.initial() => const DivisionThreeState(
    all: [],
    filtered: [],
    search: '',
    selectedIds: {},
    isMultiSelect: false,
  );

  DivisionThreeState copyWith({
    List<DivisionThreeModel>? all,
    List<DivisionThreeModel>? filtered,
    String? search,
    Set<String>? selectedIds,
    bool? isMultiSelect,
  }) {
    return DivisionThreeState(
      all: all ?? this.all,
      filtered: filtered ?? this.filtered,
      search: search ?? this.search,
      selectedIds: selectedIds ?? this.selectedIds,
      isMultiSelect: isMultiSelect ?? this.isMultiSelect,
    );
  }
}
