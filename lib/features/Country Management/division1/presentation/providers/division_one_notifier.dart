import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/features/Country%20Management/division1/models/division1_model.dart';
import 'package:voice_first_admin/features/Country%20Management/division1/presentation/providers/division_one_mockdata.dart';
import 'division_one_state.dart';

// class DivisionOneNotifier extends FamilyNotifier<DivisionOneState, String> {
//   @override
//   DivisionOneState build(String countryId) {
//     final data = mockDivisionOne
//         .where((d) => d.countryId == countryId)
//         .toList();

//     return DivisionOneState.initial().copyWith(all: data, filtered: data);
//   }

class DivisionOneNotifier extends Notifier<DivisionOneState> {
  String _countryId = '';

  @override
  DivisionOneState build() {
    return DivisionOneState.initial();
  }

  void initialize(String countryId) {
    _countryId = countryId;
    final data = mockDivisionOne
        .where((d) => d.countryId == countryId)
        .toList();
    state = state.copyWith(all: data, filtered: data);
  }

  // 🔍 Search
  void search(String query) {
    final filtered = query.isEmpty
        ? state.all
        : state.all
              .where((d) => d.name.toLowerCase().contains(query.toLowerCase()))
              .toList();

    state = state.copyWith(search: query, filtered: filtered);
  }

  // ➕ Add
  void add(DivisionOneModel d) {
    final list = [...state.all, d];
    state = state.copyWith(all: list, filtered: _applyFilter(list));
  }

  // ✏️ Update
  void update(DivisionOneModel updated) {
    final list = state.all
        .map((d) => d.id == updated.id ? updated : d)
        .toList();

    state = state.copyWith(all: list, filtered: _applyFilter(list));
  }

  // 🔄 Status
  void toggleStatus(String id, bool status) {
    final list = state.all
        .map((d) => d.id == id ? d.copyWith(status: status) : d)
        .toList();

    state = state.copyWith(all: list, filtered: _applyFilter(list));
  }

  // ❌ Delete
  void delete(String id) {
    final list = state.all.where((d) => d.id != id).toList();
    state = state.copyWith(all: list, filtered: _applyFilter(list));
  }

  // ❌ Delete selected
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

  // ☑️ Selection
  void toggleSelection(String id) {
    final selected = {...state.selectedIds};
    selected.contains(id) ? selected.remove(id) : selected.add(id);

    state = state.copyWith(
      selectedIds: selected,
      isMultiSelect: selected.isNotEmpty,
    );
  }

  void enterSelectionMode({bool selectAll = false}) {
    final selected = <String>{};

    if (selectAll) {
      selected.addAll(state.filtered.map((e) => e.id));
    }

    state = state.copyWith(isMultiSelect: true, selectedIds: selected);
  }

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
