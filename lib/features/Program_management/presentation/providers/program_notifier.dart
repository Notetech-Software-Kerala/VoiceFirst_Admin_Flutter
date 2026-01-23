import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/features/Program_management/models/program_management_model.dart';
import 'package:voice_first_admin/features/Program_management/presentation/providers/program_state.dart';
import 'package:voice_first_admin/features/Program_management/program_management_service/program_management_service.dart';

class ProgramNotifier extends Notifier<ProgramState> {
  final ProgramManagementService _service = ProgramManagementService();

  @override
  ProgramState build() {
    // return initial state and then load from API
    Future.microtask(_load);
    return ProgramState.initial();
  }

  Future<void> _load() async {
    final items = await _service.getAll();
    state = state.copyWith(all: items, filtered: _applyFilter(items));
  }

  // void _load() {
  //   // Build ProgramManagementModel list from SysProgram mock data.
  //   // For now, initial action ids are empty and will be filled when adding.
  //   final List<ProgramManagementModel> combined = mockPrograms
  //       .map((prog) => ProgramManagementModel.fromProgram(prog, const []))
  //       .toList();

  //   state = state.copyWith(all: combined, filtered: combined);
  // }

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

  // void add(ProgramManagementModel program) {
  //   final list = [...state.all, program];
  //   state = state.copyWith(all: list, filtered: _applyFilter(list));
  // }

  Future<void> add(ProgramManagementModel program) async {
    _validate(program);
    final created = await _service.create(program);
    final list = [...state.all, created];
    state = state.copyWith(all: list, filtered: _applyFilter(list));
  }

  // Future<void> update(ProgramManagementModel updated) async {
  //   if (updated.sysProgramId == null) {
  //     throw Exception('Program id is required for update');
  //   }
  //   _validate(updated);
  //   final saved = await _service.update(updated.sysProgramId!, updated);
  //   final list = state.all
  //       .map((p) => p.sysProgramId == saved.sysProgramId ? saved : p)
  //       .toList();
  //   state = state.copyWith(all: list, filtered: _applyFilter(list));
  // }

  Future<void> update(
    ProgramManagementModel updated, {
    bool updateBasic = false,
    bool updateActions = false,
    bool? updateActive,
  }) async {
    if (updated.sysProgramId == null) {
      throw Exception('Program id is required for update');
    }

    _validate(updated);

    final saved = await _service.update(
      updated.sysProgramId!,
      updated,
      updateBasic: updateBasic,
      updateActions: updateActions,
      updateActive: updateActive,
    );

    final list = state.all
        .map((p) => p.sysProgramId == saved.sysProgramId ? saved : p)
        .toList();

    state = state.copyWith(all: list, filtered: _applyFilter(list));
  }

  // Future<String?> toggleStatus(int id, bool active) async {
  //   try {
  //     final program = state.all.firstWhere((p) => p.sysProgramId == id);

  //     final updated = program.copyWith(active: active);
  //     await _service.update(id, updated);

  //     state = state.copyWith(
  //       all: state.all.map((p) => p.sysProgramId == id ? updated : p).toList(),
  //       filtered: _applyFilter(state.all),
  //     );

  //     return null;
  //   } catch (e) {
  //     debugPrint('Failed to toggle program status: $e');
  //     return 'Failed to update program status';
  //   }
  // }

  Future<String?> toggleStatus(int id, bool active) async {
    try {
      await _service.update(
        id,
        ProgramManagementModel(
          programName: '',
          labelName: '',
          programRoute: '',
          applicationId: 0,
          programActionIds: const [],
        ),
        updateActive: active,
      );

      state = state.copyWith(
        all: state.all.map((p) {
          if (p.sysProgramId == id) {
            return p.copyWith(active: active);
          }
          return p;
        }).toList(),
        filtered: _applyFilter(state.all),
      );

      return null;
    } catch (e) {
      debugPrint('Failed to toggle program status: $e');
      return 'Failed to update program status';
    }
  }

  Future<void> delete(int id) async {
    await _service.delete(id);
    state = state.copyWith(
      all: state.all.map((p) {
        if (p.sysProgramId == id) {
          return p.copyWith(deleted: true);
        }
        return p;
      }).toList(),
      filtered: _applyFilter(state.all),
    );

    // final list = state.all.where((p) => p.sysProgramId != id).toList();
    // state = state.copyWith(all: list, filtered: _applyFilter(list));
  }

  Future<String?> recover(int id) async {
    try {
      await _service.recover(id);

      state = state.copyWith(
        all: state.all.map((p) {
          if (p.sysProgramId == id) {
            return p.copyWith(
              deleted: false,
              deletedUser: null,
              deletedDate: null,
            );
          }
          return p;
        }).toList(),
        filtered: _applyFilter(state.all),
      );

      return null;
    } catch (e) {
      debugPrint('💥 Failed to recover program: $e');
      return 'Failed to recover program';
    }
  }

  // Future<void> deleteSelected() async {
  //   final ids = state.selectedIds.whereType<int>().toList();
  //   if (ids.isEmpty) return;
  //   await _service.bulkDelete(ids);
  //   final list = state.all
  //       .where((p) => !state.selectedIds.contains(p.sysProgramId))
  //       .toList();
  //   state = state.copyWith(
  //     all: list,
  //     filtered: _applyFilter(list),
  //     selectedIds: {},
  //     isMultiSelect: false,
  //   );
  // }
  Future<void> deleteSelected() async {
    final ids = state.selectedIds.whereType<int>().toList();
    if (ids.isEmpty) return;

    await _service.bulkDelete(ids);

    state = state.copyWith(
      all: state.all.map((p) {
        if (ids.contains(p.sysProgramId)) {
          return p.copyWith(deleted: true);
        }
        return p;
      }).toList(),
      filtered: _applyFilter(state.all),
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

  void _validate(ProgramManagementModel program) {
    if (program.programName.trim().isEmpty) {
      throw Exception('Program name is required');
    }
    if (program.labelName.trim().isEmpty) {
      throw Exception('Label name is required');
    }
    if (program.programRoute.trim().isEmpty) {
      throw Exception('Program route is required');
    }
    if (program.applicationId == 0) {
      throw Exception('Application is required');
    }
    // if (program.programActionIds.isEmpty) {
    //   throw Exception('At least one action must be assigned');
    // }
    if (program.actions.isEmpty && program.programActionIds.isEmpty) {
      throw Exception('At least one action must be assigned');
    }
  }

  bool get allVisibleSelected =>
      state.filtered.isNotEmpty &&
      state.selectedIds.length ==
          state.filtered.where((p) => p.sysProgramId != null).length;

  List<ProgramManagementModel> _applyFilter(
    List<ProgramManagementModel> source,
  ) {
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
