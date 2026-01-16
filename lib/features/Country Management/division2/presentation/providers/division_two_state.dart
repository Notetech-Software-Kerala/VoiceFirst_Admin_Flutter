import 'package:voice_first_admin/features/Country%20Management/division2/models/DivisionTwoModel';

class DivisionTwoState {
  final List<DivisionTwoModel> all;
  final List<DivisionTwoModel> filtered;
  final bool isMultiSelect;
  final Set<String> selectedIds;
  final String search;

  DivisionTwoState({
    required this.all,
    required this.filtered,
    required this.isMultiSelect,
    required this.selectedIds,
    required this.search,
  });

  factory DivisionTwoState.initial() => DivisionTwoState(
    all: [],
    filtered: [],
    isMultiSelect: false,
    selectedIds: {},
    search: '',
  );

  DivisionTwoState copyWith({
    List<DivisionTwoModel>? all,
    List<DivisionTwoModel>? filtered,
    bool? isMultiSelect,
    Set<String>? selectedIds,
    String? search,
  }) {
    return DivisionTwoState(
      all: all ?? this.all,
      filtered: filtered ?? this.filtered,
      isMultiSelect: isMultiSelect ?? this.isMultiSelect,
      selectedIds: selectedIds ?? this.selectedIds,
      search: search ?? this.search,
    );
  }
}
