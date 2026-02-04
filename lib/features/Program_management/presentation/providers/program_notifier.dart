import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/features/Program_management/models/create_program_request.dart';
import 'package:voice_first_admin/features/Program_management/models/program_management_model.dart';
import 'package:voice_first_admin/features/Program_management/models/update_program_request.dart';
import 'package:voice_first_admin/features/Program_management/presentation/providers/program_state.dart';
import 'package:voice_first_admin/features/Program_management/models/program_filter.dart';
import 'package:voice_first_admin/features/Program_management/program_management_service/program_management_service.dart';

class ProgramNotifier extends Notifier<ProgramState> {
  final ProgramManagementService _service = ProgramManagementService();

  @override
  ProgramState build() {
    debugPrint('[ProgramNotifier] build() -> initial state');
    return ProgramState.initial();
  }

  // Load all programs with optional filtering
  Future<void> loadAll({ProgramFilter? filter}) async {
    if (state.isLoading) return;

    debugPrint(
      '[ProgramNotifier] loadAll() called with filter: '
      '${filter ?? const ProgramFilter(pageNumber: 1, pageSize: 10)}',
    );

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

      debugPrint(
        '[ProgramNotifier] loadAll() -> '
        'items: ${response.items.length}, '
        'page: ${response.pageNumber}/${response.totalPages}, '
        'totalCount: ${response.totalCount}',
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
      debugPrint('Failed to load programs: $e');
    }
  }

  Future<void> search(String query) async {
    debugPrint('[ProgramNotifier] search() -> "$query"');
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
    debugPrint('[ProgramNotifier] setApplicationFilter() -> $applicationId');
    state = state.copyWith(selectedApplicationId: applicationId);
    state = state.copyWith(filtered: _applyFilter(state.all));
  }

  void setCompanyFilter(int? companyId) {
    debugPrint('[ProgramNotifier] setCompanyFilter() -> $companyId');
    state = state.copyWith(selectedCompanyId: companyId);
    state = state.copyWith(filtered: _applyFilter(state.all));
  }

  //add
  Future<void> add(ProgramModel program) async {
    debugPrint('[ProgramNotifier] add() -> validating program');
    _validate(program);

    final request = CreateProgramRequest(
      programName: program.programName,
      label: program.labelName,
      route: program.programRoute,
      platformId: program.applicationId,
      companyId: program.companyId ?? 0,
      actionIds: program.activeActionIds,
    );

    debugPrint('[ProgramNotifier] add() -> sending create request');
    final created = await _service.create(request);

    final list = [created, ...state.all];

    state = state.copyWith(all: list, filtered: _applyFilter(list));
    debugPrint(
      '[ProgramNotifier] add() -> created id: '
      '${created.sysProgramId}, total: ${list.length}',
    );
  }

  
  Future<void> updateProgram({required ProgramModel updated}) async {
    if (updated.sysProgramId == null) {
      throw Exception('Program id is required');
    }

    debugPrint(
      '[ProgramNotifier] updateProgram() -> id: ${updated.sysProgramId}',
    );

    final originalProgram = state.all.firstWhere(
      (p) => p.sysProgramId == updated.sysProgramId,
    );

    // Use the full original action id list from the stored program,
    // so the backend sees the true previous state.
    // final originalIds = List<int>.from(originalProgram.programActionIds);
    final originalActions = originalProgram.actions;

    /// ✅ Selected IDs coming from UI
    // final selectedIds = updated.programActionIds;
    final selectedIds = updated.activeActionIds;

    debugPrint(
      '[ProgramNotifier] updateProgram() original active actions: $originalActions',
    );
    debugPrint(
      '[ProgramNotifier] updateProgram() selected actions: $selectedIds',
    );

    final request = UpdateProgramRequest(
      programName: updated.programName != originalProgram.programName
          ? updated.programName
          : null,

      label: updated.labelName != originalProgram.labelName
          ? updated.labelName
          : null,

      route: updated.programRoute != originalProgram.programRoute
          ? updated.programRoute
          : null,

      platformId: updated.applicationId != originalProgram.applicationId
          ? updated.applicationId
          : null,

      companyId: updated.companyId != originalProgram.companyId
          ? updated.companyId
          : null,

      originalActions: originalActions,
      selectedActionIds: selectedIds.toSet(),
    );

    /// 🔥 VERY IMPORTANT
    /// Don't call API if nothing changed
    final requestJson = request.toJson();
    if (requestJson.isEmpty) {
      debugPrint(
        '[ProgramNotifier] updateProgram() -> No changes detected. Skipping API call.',
      );
      return;
    }
    debugPrint(
      '[ProgramNotifier] updateProgram() -> PATCH payload: $requestJson',
    );

    final saved = await _service.update(updated.sysProgramId!, request);
    debugPrint(
      '[ProgramNotifier] updateProgram() -> saved id: ${saved.sysProgramId}',
    );

    final list = state.all
        .map((p) => p.sysProgramId == saved.sysProgramId ? saved : p)
        .toList();

    state = state.copyWith(all: list, filtered: _applyFilter(list));
  }

  //status toggle

  Future<String?> toggleStatus(int id, bool active) async {
    try {
      debugPrint(
        '[ProgramNotifier] toggleStatus() -> id: $id, active: $active',
      );
      final existing = state.all.firstWhere((p) => p.sysProgramId == id);
      // final activeIds = existing.actions
      //     .where((a) => a.active)
      //     .map((e) => e.actionId)
      //     .toList();

      // final request = UpdateProgramRequest(
      //   active: active,
      //   originalActionIds: activeIds,
      //   selectedActionIds: activeIds,
      // );
      final request = UpdateProgramRequest(
        active: active,
        originalActions: existing.actions,
        selectedActionIds: existing.actions
            .where((a) => a.active)
            .map((e) => e.actionId)
            .toSet(),
      );

      debugPrint(
        '[ProgramNotifier] toggleStatus() -> PATCH payload: ${request.toJson()}',
      );
      await _service.update(id, request);

      state = state.copyWith(
        all: state.all.map((p) {
          if (p.sysProgramId == id) {
            return p.copyWith(active: active);
          }
          return p;
        }).toList(),
        filtered: _applyFilter(state.all),
      );

      debugPrint(
        '[ProgramNotifier] toggleStatus() -> success, id: $id now active=$active',
      );
      return null;
    } catch (e) {
      debugPrint('[ProgramNotifier] toggleStatus() FAILED: $e');
      return 'Failed to update program status';
    }
  }

  Future<void> delete(int id) async {
    debugPrint('[ProgramNotifier] delete() -> id: $id');
    final deleted = await _service.delete(id);
    debugPrint(
      '[ProgramNotifier] delete() -> backend returned deleted id: ${deleted.sysProgramId}, deleted=${deleted.deleted}',
    );

    state = state.copyWith(
      all: state.all.map((p) {
        if (p.sysProgramId == id) {
          return deleted;
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
      debugPrint('[ProgramNotifier] recover() -> id: $id');

      final recovered = await _service.recover(id);
      debugPrint(
        '[ProgramNotifier] recover() -> backend returned id: ${recovered.sysProgramId}, deleted=${recovered.deleted}',
      );

      final updatedList = state.all.map((p) {
        return p.sysProgramId == id ? recovered : p;
      }).toList();

      state = state.copyWith(
        all: updatedList,
        filtered: _applyFilter(updatedList),
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

    debugPrint('[ProgramNotifier] deleteSelected() -> ids: $ids');

    await _service.bulkDelete(ids);
    debugPrint('[ProgramNotifier] deleteSelected() -> bulk delete completed');
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
    debugPrint(
      '[ProgramNotifier] toggleSelection() -> id: $id, '
      'selected: $selected',
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
    debugPrint(
      '[ProgramNotifier] enterSelectionMode() '
      'selectAll: $selectAll, selected: $selected',
    );
  }

  void exitSelectionMode() {
    state = state.copyWith(isMultiSelect: false, selectedIds: {});
    debugPrint('[ProgramNotifier] exitSelectionMode()');
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
    // if (program.applicationId == 0) {
    //   throw Exception('Application is required');
    // }

    // if (program.programActionIds.isEmpty) {
    //   throw Exception('At least one action must be assigned');
    // }
    if (program.activeActionIds.isEmpty) {
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
