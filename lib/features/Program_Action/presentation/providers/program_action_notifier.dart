import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:voice_first_admin/features/Program_Action/models/program_action_model.dart';
import 'package:voice_first_admin/features/Program_Action/presentation/providers/program_action_mockdata.dart';
import 'program_action_state.dart';

class ProgramActionNotifier extends StateNotifier<ProgramActionState> {
  ProgramActionNotifier() : super(ProgramActionState.initial()) {
    _load();
  }

  void _load() {
    state = state.copyWith(
      all: mockProgramActions,
      filtered: mockProgramActions,
    );
  }

  void search(String query) {
    final filtered = query.isEmpty
        ? state.all
        : state.all
              .where(
                (p) => p.programActionName.toLowerCase().contains(
                  query.toLowerCase(),
                ),
              )
              .toList();
    state = state.copyWith(search: query, filtered: filtered);
  }

  void add(ProgramActionModel p) {
    final list = [...state.all, p];
    state = state.copyWith(all: list, filtered: _applyFilter(list));
  }

  void update(ProgramActionModel updated) {
    final list = state.all
        .map((p) => p.ProgramActionId == updated.ProgramActionId ? updated : p)
        .toList();
    state = state.copyWith(all: list, filtered: _applyFilter(list));
  }

  void toggleStatus(int id, bool status) {
    final list = state.all
        .map((p) => p.ProgramActionId == id ? p.copyWith(isActive: status) : p)
        .toList();
    state = state.copyWith(all: list, filtered: _applyFilter(list));
  }

  void delete(int id) {
    final list = state.all.where((p) => p.ProgramActionId != id).toList();
    state = state.copyWith(all: list, filtered: _applyFilter(list));
  }

  void deleteSelected() {
    final list = state.all
        .where((p) => !state.selectedIds.contains(p.ProgramActionId))
        .toList();
    state = state.copyWith(
      all: list,
      filtered: _applyFilter(list),
      selectedIds: {},
      isMultiSelect: false,
    );
  }

  void toggleSelection(int id) {
    final selected = {...state.selectedIds};
    selected.contains(id) ? selected.remove(id) : selected.add(id);
    state = state.copyWith(
      selectedIds: selected,
      isMultiSelect: selected.isNotEmpty,
    );
  }

  void enterSelectionMode({bool selectAll = false}) {
    final selected = <int>{};
    if (selectAll) {
      selected.addAll(state.filtered.map((e) => e.ProgramActionId));
    }
    state = state.copyWith(isMultiSelect: true, selectedIds: selected);
  }

  void exitSelectionMode() {
    state = state.copyWith(isMultiSelect: false, selectedIds: {});
  }

  bool get allVisibleSelected =>
      state.filtered.isNotEmpty &&
      state.selectedIds.length == state.filtered.length;

  List<ProgramActionModel> _applyFilter(List<ProgramActionModel> list) {
    if (state.search.isEmpty) return list;
    return list
        .where(
          (p) => p.programActionName.toLowerCase().contains(
            state.search.toLowerCase(),
          ),
        )
        .toList();
  }
}
