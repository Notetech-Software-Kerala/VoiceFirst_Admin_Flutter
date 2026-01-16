// import 'package:voice_first_admin/features/Country%20Management/division1/models/division1_model.dart';

// class DivisionOneState {
//   final List<DivisionOne> divisions;
//   final List<DivisionOne> filtered;
//   final Set<String> selectedIds;
//   final bool isMultiSelect;
//   final String search;

//   DivisionOneState({
//     required this.divisions,
//     required this.filtered,
//     required this.selectedIds,
//     required this.isMultiSelect,
//     required this.search,
//   });

//   factory DivisionOneState.initial() {
//     return DivisionOneState(
//       divisions: [],
//       filtered: [],
//       selectedIds: {},
//       isMultiSelect: false,
//       search: '',
//     );
//   }

//   DivisionOneState copyWith({
//     List<DivisionOne>? divisions,
//     List<DivisionOne>? filtered,
//     Set<String>? selectedIds,
//     bool? isMultiSelect,
//     String? search,
//   }) {
//     return DivisionOneState(
//       divisions: divisions ?? this.divisions,
//       filtered: filtered ?? this.filtered,
//       selectedIds: selectedIds ?? this.selectedIds,
//       isMultiSelect: isMultiSelect ?? this.isMultiSelect,
//       search: search ?? this.search,
//     );
//   }
// }

import 'package:voice_first_admin/features/Country%20Management/division1/models/division1_model.dart';

class DivisionOneState {
  final List<DivisionOneModel> all;
  final List<DivisionOneModel> filtered;
  final bool isMultiSelect;
  final Set<String> selectedIds;
  final String search;

  DivisionOneState({
    required this.all,
    required this.filtered,
    required this.isMultiSelect,
    required this.selectedIds,
    required this.search,
  });

  factory DivisionOneState.initial() => DivisionOneState(
    all: [],
    filtered: [],
    isMultiSelect: false,
    selectedIds: {},
    search: '',
  );

  DivisionOneState copyWith({
    List<DivisionOneModel>? all,
    List<DivisionOneModel>? filtered,
    bool? isMultiSelect,
    Set<String>? selectedIds,
    String? search,
  }) {
    return DivisionOneState(
      all: all ?? this.all,
      filtered: filtered ?? this.filtered,
      isMultiSelect: isMultiSelect ?? this.isMultiSelect,
      selectedIds: selectedIds ?? this.selectedIds,
      search: search ?? this.search,
    );
  }
}
