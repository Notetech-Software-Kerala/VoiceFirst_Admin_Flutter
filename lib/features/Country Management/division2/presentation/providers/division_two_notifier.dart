import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:voice_first_admin/features/Country%20Management/division2/models/DivisionTwoModel';
import 'package:voice_first_admin/features/Country%20Management/division2/presentation/providers/division_two_mockdata.dart';
import 'division_two_state.dart';

class DivisionTwoNotifier extends StateNotifier<DivisionTwoState> {
  final String divisionOneId;

  DivisionTwoNotifier(this.divisionOneId) : super(DivisionTwoState.initial()) {
    _load();
  }

  void _load() {
    final data = mockDivisionTwo
        .where((d) => d.divisionOneId == divisionOneId)
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

  void add(DivisionTwoModel d) {
    final list = [...state.all, d];
    state = state.copyWith(all: list, filtered: _applyFilter(list));
  }

  void update(DivisionTwoModel updated) {
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

  List<DivisionTwoModel> _applyFilter(List<DivisionTwoModel> list) {
    if (state.search.isEmpty) return list;
    return list
        .where((d) => d.name.toLowerCase().contains(state.search.toLowerCase()))
        .toList();
  }
}
