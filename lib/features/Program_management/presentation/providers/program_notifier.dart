import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/features/Program_management/models/program_management_model.dart';
import 'package:voice_first_admin/features/Program_management/presentation/providers/program_state.dart';
import 'package:voice_first_admin/features/Program_management/models/program_filter.dart';
import 'package:voice_first_admin/features/Program_management/program_management_service/program_management_service.dart';

class ProgramNotifier extends Notifier<ProgramState> {
  final ProgramManagementService _service = ProgramManagementService();

  @override
  ProgramState build() {
    return ProgramState.initial();
  }
// Load all programs with optional filtering
  Future<void> loadAll({ProgramFilter? filter}) async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true);

    try {
      final response = await _service.getAll(
        filter ?? const ProgramFilter(pageNumber: 1, pageSize: 10),
      );

      state = state.copyWith(
        all: response.items,
        filtered: _applyFilter(response.items),
        isLoading: false,
        hasMoreData: response.pageNumber < response.totalPages,
        currentPage: response.pageNumber,
        totalCount: response.totalCount,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
      debugPrint('Failed to load programs: $e');
    }
  }

  Future<void> search(String query) async {
    state = state.copyWith(search: query);
    await loadAll(
      filter: ProgramFilter(
        pageNumber: 1,
        pageSize: 10,
        searchText: query.isEmpty ? null : query,
      ),
    );
  }

  void setApplicationFilter(int? applicationId) {
    state = state.copyWith(selectedApplicationId: applicationId);
    state = state.copyWith(filtered: _applyFilter(state.all));
  }

  void setCompanyFilter(int? companyId) {
    state = state.copyWith(selectedCompanyId: companyId);
    state = state.copyWith(filtered: _applyFilter(state.all));
  }

  //add
  Future<void> add(ProgramModel program) async {
    _validate(program);
    final created = await _service.create(program);
    final list = [...state.all, created];
    state = state.copyWith(all: list, filtered: _applyFilter(list));
  }


//update
  Future<void> update(
    ProgramModel updated, {
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


  Future<String?> toggleStatus(int id, bool active) async {
    try {
      await _service.update(
        id,
        ProgramModel(
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
    // Reload current page so server-side pagination stays correct
    await loadAll(
      filter: ProgramFilter(
        pageNumber: state.currentPage,
        pageSize: 10,
        searchText: state.search.isEmpty ? null : state.search,
      ),
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


  Future<void> deleteSelected() async {
    final ids = state.selectedIds.whereType<int>().toList();
    if (ids.isEmpty) return;

    await _service.bulkDelete(ids);
    state = state.copyWith(selectedIds: {}, isMultiSelect: false);
    await loadAll(
      filter: ProgramFilter(
        pageNumber: state.currentPage,
        pageSize: 10,
        searchText: state.search.isEmpty ? null : state.search,
      ),
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

  void _validate(ProgramModel program) {
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

  List<ProgramModel> _applyFilter(List<ProgramModel> source) {
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
