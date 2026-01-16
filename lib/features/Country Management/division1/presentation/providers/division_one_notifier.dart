// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_riverpod/legacy.dart';
// import 'package:voice_first_admin/features/Country%20Management/division1/models/division1_model.dart';
// import 'division_one_state.dart';

// class DivisionOneNotifier extends StateNotifier<DivisionOneState> {
//   DivisionOneNotifier(String countryId)
//       : super(DivisionOneState.initial()) {
//     _loadDummyData(countryId);
//   }

//   void _loadDummyData(String countryId) {
//     final data = [
//       DivisionOne(id: '1', name: 'California', countryId: countryId, status: true),
//       DivisionOne(id: '2', name: 'Texas', countryId: countryId, status: true),
//       DivisionOne(id: '3', name: 'Florida', countryId: countryId, status: false),
//     ];

//     state = state.copyWith(divisions: data, filtered: data);
//   }

//   // 🔍 Search
//   void search(String query) {
//     final filtered = query.isEmpty
//         ? state.divisions
//         : state.divisions
//             .where((d) => d.name.toLowerCase().contains(query.toLowerCase()))
//             .toList();

//     state = state.copyWith(search: query, filtered: filtered);
//   }

//   // ➕ Add
//   void add(DivisionOne division) {
//     final list = [...state.divisions, division];
//     state = state.copyWith(divisions: list, filtered: _applyFilter(list));
//   }

//   // ✏️ Update
//   void update(DivisionOne updated) {
//     final list = state.divisions
//         .map((d) => d.id == updated.id ? updated : d)
//         .toList();

//     state = state.copyWith(divisions: list, filtered: _applyFilter(list));
//   }

//   // 🔄 Status
//   void toggleStatus(String id, bool status) {
//     final list = state.divisions
//         .map((d) => d.id == id ? d.copyWith(status: status) : d)
//         .toList();

//     state = state.copyWith(divisions: list, filtered: _applyFilter(list));
//   }

//   // ❌ Delete
//   void delete(String id) {
//     final list = state.divisions.where((d) => d.id != id).toList();
//     state = state.copyWith(divisions: list, filtered: _applyFilter(list));
//   }

//   void deleteSelected() {
//     final list = state.divisions
//         .where((d) => !state.selectedIds.contains(d.id))
//         .toList();

//     state = state.copyWith(
//       divisions: list,
//       filtered: _applyFilter(list),
//       selectedIds: {},
//       isMultiSelect: false,
//     );
//   }

//   // ☑ Selection
//   void toggleSelection(String id) {
//     final selected = {...state.selectedIds};
//     selected.contains(id) ? selected.remove(id) : selected.add(id);

//     state = state.copyWith(
//       selectedIds: selected,
//       isMultiSelect: selected.isNotEmpty,
//     );
//   }

//   void enterSelectionMode({bool selectAll = false}) {
//     final selected = <String>{};
//     if (selectAll) {
//       selected.addAll(state.filtered.map((e) => e.id));
//     }
//     state = state.copyWith(isMultiSelect: true, selectedIds: selected);
//   }

//   void exitSelectionMode() {
//     state = state.copyWith(isMultiSelect: false, selectedIds: {});
//   }

//   bool get allVisibleSelected =>
//       state.filtered.isNotEmpty &&
//       state.selectedIds.length == state.filtered.length;

//   List<DivisionOne> _applyFilter(List<DivisionOne> list) {
//     if (state.search.isEmpty) return list;
//     return list
//         .where((d) =>
//             d.name.toLowerCase().contains(state.search.toLowerCase()))
//         .toList();
//   }
// }

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:voice_first_admin/features/Country%20Management/division1/models/division1_model.dart';
import 'package:voice_first_admin/features/Country%20Management/division1/presentation/providers/division_one_mockdata.dart';
import 'division_one_state.dart';

class DivisionOneNotifier extends StateNotifier<DivisionOneState> {
  final String countryId;

  DivisionOneNotifier(this.countryId) : super(DivisionOneState.initial()) {
    _load();
  }

  void _load() {
    final data = mockDivisionOne
        .where((d) => d.countryId == countryId)
        .toList();
    state = state.copyWith(all: data, filtered: data);
  }

  void search(String query) {
    final filtered = query.isEmpty
        ? state.all
        : state.all
              .where((d) => d.name.toLowerCase().contains(query.toLowerCase()))
              .toList();
    state = state.copyWith(search: query, filtered: filtered);
  }

  void add(DivisionOneModel d) {
    final list = [...state.all, d];
    state = state.copyWith(all: list, filtered: _applyFilter(list));
  }

  void update(DivisionOneModel updated) {
    final list = state.all
        .map((d) => d.id == updated.id ? updated : d)
        .toList();
    state = state.copyWith(all: list, filtered: _applyFilter(list));
  }

  void toggleStatus(String id, bool status) {
    final list = state.all
        .map((d) => d.id == id ? d.copyWith(status: status) : d)
        .toList();
    state = state.copyWith(all: list, filtered: _applyFilter(list));
  }

  void delete(String id) {
    final list = state.all.where((d) => d.id != id).toList();
    state = state.copyWith(all: list, filtered: _applyFilter(list));
  }

  void deleteSelected() {
    final list = state.all
        .where((d) => !state.selectedIds.contains(d.id))
        .toList();
    state = state.copyWith(
      all: list,
      filtered: _applyFilter(list),
      selectedIds: {},
      isMultiSelect: false,
    );
  }

  void toggleSelection(String id) {
    final selected = {...state.selectedIds};
    selected.contains(id) ? selected.remove(id) : selected.add(id);
    state = state.copyWith(
      selectedIds: selected,
      isMultiSelect: selected.isNotEmpty,
    );
  }

  // ➕ Enter selection mode
  void enterSelectionMode({bool selectAll = false}) {
    final selected = <String>{};

    if (selectAll) {
      selected.addAll(state.filtered.map((e) => e.id));
    }

    state = state.copyWith(isMultiSelect: true, selectedIds: selected);
  }

  // ❌ Exit selection mode
  void exitSelectionMode() {
    state = state.copyWith(isMultiSelect: false, selectedIds: {});
  }

  bool get allVisibleSelected =>
      state.filtered.isNotEmpty &&
      state.selectedIds.length == state.filtered.length;

  List<DivisionOneModel> _applyFilter(List<DivisionOneModel> list) {
    if (state.search.isEmpty) return list;
    return list
        .where((d) => d.name.toLowerCase().contains(state.search.toLowerCase()))
        .toList();
  }
}
