import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:voice_first_admin/features/Program_management/models/program_model.dart';
import 'package:voice_first_admin/features/Program_management/presentation/providers/program_mockdata.dart';
import 'package:voice_first_admin/features/Program_management/presentation/providers/program_state.dart';

class ProgramNotifier extends StateNotifier<ProgramState> {
  ProgramNotifier() : super(ProgramState.initial()) {
    _load();
  }

  void _load() {
    state = state.copyWith(all: mockPrograms, filtered: mockPrograms);
  }

  void search(String query) {
    final newState = state.copyWith(search: query);
    state = newState.copyWith(filtered: _applyFilter(newState.all));
  }

  void setApplicationFilter(int? applicationId) {
    state = state.copyWith(selectedApplicationId: applicationId);
    state = state.copyWith(filtered: _applyFilter(state.all));
  }

  void setCompanyFilter(int? companyId) {
    state = state.copyWith(selectedCompanyId: companyId);
    state = state.copyWith(filtered: _applyFilter(state.all));
  }

  void add(SysProgram program) {
    final list = [...state.all, program];
    state = state.copyWith(all: list, filtered: _applyFilter(list));
  }

  void update(SysProgram updated) {
    final list = state.all
        .map((p) => p.sysProgramId == updated.sysProgramId ? updated : p)
        .toList();
    state = state.copyWith(all: list, filtered: _applyFilter(list));
  }

  void delete(int id) {
    final list = state.all.where((p) => p.sysProgramId != id).toList();
    state = state.copyWith(all: list, filtered: _applyFilter(list));
  }

  void deleteSelected() {
    final list = state.all
        .where((p) => !state.selectedIds.contains(p.sysProgramId))
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
      selected.addAll(
        state.filtered
            .where((p) => p.sysProgramId != null)
            .map((e) => e.sysProgramId!),
      );
    }
    state = state.copyWith(isMultiSelect: true, selectedIds: selected);
  }

  void exitSelectionMode() {
    state = state.copyWith(isMultiSelect: false, selectedIds: {});
  }

  bool get allVisibleSelected =>
      state.filtered.isNotEmpty &&
      state.selectedIds.length ==
          state.filtered.where((p) => p.sysProgramId != null).length;

  List<SysProgram> _applyFilter(List<SysProgram> source) {
    var list = source;

    // Filter by application
    if (state.selectedApplicationId != null) {
      list = list
          .where((p) => p.applicationId == state.selectedApplicationId)
          .toList();
    }

    // Filter by company (only programs created for that company)
    if (state.selectedCompanyId != null) {
      list = list.where((p) => p.companyId == state.selectedCompanyId).toList();
    }

    // Text search on name / label / route
    if (state.search.isNotEmpty) {
      final q = state.search.toLowerCase();
      list = list
          .where(
            (p) =>
                p.programName.toLowerCase().contains(q) ||
                p.labelName.toLowerCase().contains(q) ||
                p.programRoute.toLowerCase().contains(q),
          )
          .toList();
    }

    return list;
  }
}
