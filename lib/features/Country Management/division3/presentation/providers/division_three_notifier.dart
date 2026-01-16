import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:voice_first_admin/features/Country%20Management/division3/models/division_three_model.dart';
import 'package:voice_first_admin/features/Country%20Management/division3/presentation/providers/division_three_mockdata.dart';
import 'division_three_state.dart';

class DivisionThreeNotifier extends StateNotifier<DivisionThreeState> {
  final String divisionTwoId;

  DivisionThreeNotifier(this.divisionTwoId)
    : super(DivisionThreeState.initial()) {
    _load();
  }

  void _load() {
    final data = mockDivisionThree
        .where((d) => d.divisionTwoId == divisionTwoId)
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

  void add(DivisionThreeModel d) {
    final list = [...state.all, d];
    state = state.copyWith(all: list, filtered: _applyFilter(list));
  }

  void update(DivisionThreeModel updated) {
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

  List<DivisionThreeModel> _applyFilter(List<DivisionThreeModel> list) {
    if (state.search.isEmpty) return list;
    return list
        .where((d) => d.name.toLowerCase().contains(state.search.toLowerCase()))
        .toList();
  }
}
