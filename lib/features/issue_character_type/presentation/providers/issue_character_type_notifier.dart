import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/features/issue_character_type/data/models/issue_character_type_filter.dart';
import 'package:voice_first_admin/features/issue_character_type/data/repositories/character_type_repository.dart';
import 'package:voice_first_admin/features/issue_character_type/presentation/providers/issue_character_type_state.dart';

class IssueCharacterTypeNotifier extends Notifier<IssueCharacterTypeState> {
  late final CharacterTypeRepository _repository;

  IssueCharacterTypeNotifier() {
    // no-op
  }

  @override
  IssueCharacterTypeState build() {
    _repository = ref.read(characterTypeRepositoryProvider);
    return IssueCharacterTypeState.initial();
  }

  static const int _defaultPageSize = 10;

  Future<void> loadAll({
    IssueCharacterTypeFilter? filter,
    int? page,
    int? pageSize,
  }) async {
    if (state.isLoading) return;

    final currentPage = page ?? state.currentPage;
    // final currentPageSize = pageSize ?? _defaultPageSize;
    final currentPageSize = pageSize ?? ((state.filter).pageSize);

    final IssueCharacterTypeFilter appliedFilter =
        filter ??
        IssueCharacterTypeFilter(
          pageNumber: currentPage,
          pageSize: currentPageSize,
          searchText: state.filter.searchText,
          searchBy: state.filter.searchBy,
          sortBy: state.filter.sortBy,
          sortOrder: state.filter.sortOrder,
          active: state.filter.active,
          deleted: state.filter.deleted,
          createdFromDate: state.filter.createdFromDate,
          createdToDate: state.filter.createdToDate,
          updatedFromDate: state.filter.updatedFromDate,
          updatedToDate: state.filter.updatedToDate,
          deletedFromDate: state.filter.deletedFromDate,
          deletedToDate: state.filter.deletedToDate,
        );

    state = state.copyWith(isLoading: true, filter: appliedFilter, error: null);

    try {
      final response = await _repository.getAll(appliedFilter);

      state = state.copyWith(
        items: response.items,
        isLoading: false,
        hasMoreData: response.pageNumber < response.totalPages,
        currentPage: response.pageNumber,
        totalCount: response.totalCount,
        totalPages: response.totalPages,
        error: null,
      );

      debugPrint(
        'IssueCharacterType PAGE=${response.pageNumber}, TOTAL_PAGES=${response.totalPages}, ITEMS=${response.items.length}',
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      debugPrint('Failed to load issue character types: $e');
    }
  }

  Future<void> search(String value) async {
    final newFilter = IssueCharacterTypeFilter(
      pageNumber: 1,
      pageSize: _defaultPageSize,
      searchText: value.isEmpty ? null : value,
      searchBy: state.filter.searchBy,
      sortBy: state.filter.sortBy,
      sortOrder: state.filter.sortOrder,
      active: state.filter.active,
      deleted: state.filter.deleted,
      createdFromDate: state.filter.createdFromDate,
      createdToDate: state.filter.createdToDate,
      updatedFromDate: state.filter.updatedFromDate,
      updatedToDate: state.filter.updatedToDate,
      deletedFromDate: state.filter.deletedFromDate,
      deletedToDate: state.filter.deletedToDate,
    );

    await loadAll(filter: newFilter);
  }

  // ───────────────── CRUD ─────────────────

  /// Returns the API success message on success.
  /// Throws an Exception with the API error message on failure.
  Future<String> add(String name) async {
    final (_, message) = await _repository.createCharacterType(name);
    // Reload to respect pagination and any sorting the API applies
    await loadAll();
    return message;
  }

  Future<String?> update({
    required int id,
    String? issueCharacterType,
    bool? active,
  }) async {
    try {
      final updated = await _repository.updateCharacterType(
        id: id,
        issueCharacterType: issueCharacterType,
        active: active,
      );

      state = state.copyWith(
        items: state.items
            .map((e) => e.issueCharacterTypeId == id ? updated : e)
            .toList(),
      );
      return null;
    } catch (e) {
      debugPrint('Failed to update issue character type: $e');
      return e.toString().replaceFirst('Exception: ', '');
    }
  }

  Future<String?> delete(int id) async {
    try {
      final deleted = await _repository.deleteCharacterType(id);

      state = state.copyWith(
        items: state.items
            .map((e) => e.issueCharacterTypeId == id ? deleted : e)
            .toList(),
      );

      return null;
    } catch (e) {
      debugPrint('Failed to delete issue character type: $e');
      return e.toString().replaceFirst('Exception: ', '');
    }
  }

  Future<String?> recover(int id) async {
    try {
      final recovered = await _repository.recoverCharacterType(id);

      state = state.copyWith(
        items: state.items
            .map((e) => e.issueCharacterTypeId == id ? recovered : e)
            .toList(),
      );

      return null;
    } catch (e) {
      debugPrint('Failed to recover issue character type: $e');
      return e.toString().replaceFirst('Exception: ', '');
    }
  }

  // Selection
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
      selected.addAll(state.items.map((e) => e.issueCharacterTypeId));
    }

    state = state.copyWith(isMultiSelect: true, selectedIds: selected);
  }

  void exitSelectionMode() {
    state = state.copyWith(isMultiSelect: false, selectedIds: {});
  }

  bool get allVisibleSelected =>
      state.items.isNotEmpty && state.selectedIds.length == state.items.length;
}
