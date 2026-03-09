import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/features/issue_character_type/data/models/issue_character_type_filter.dart';
import 'package:voice_first_admin/features/issue_character_type/data/service/character_type_service.dart';
import 'issue_character_type_state.dart';

class IssueCharacterTypeNotifier extends Notifier<IssueCharacterTypeState> {
  late final CharacterTypeService _service;

  @override
  IssueCharacterTypeState build() {
    _service = CharacterTypeService();
    return IssueCharacterTypeState.initial();
  }

  static const int _defaultPageSize = 10;

  Future<void> loadAll({IssueCharacterTypeFilter? filter}) async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true);

    try {
      final effectiveFilter =
          filter ??
          IssueCharacterTypeFilter(pageNumber: 1, pageSize: _defaultPageSize);

      final response = await _service.getAll(effectiveFilter);

      state = state.copyWith(
        items: response.items,
        filtered: response.items,
        isLoading: false,
        hasMoreData: response.pageNumber < response.totalPages,
        currentPage: response.pageNumber,
        totalCount: response.totalCount,
        totalPages: response.totalPages,
      );

      debugPrint(
        'IssueCharacterType PAGE=${response.pageNumber}, TOTAL_PAGES=${response.totalPages}, ITEMS=${response.items.length}',
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
      debugPrint('Failed to load issue character types: $e');
    }
  }

  void search(String value) {
    state = state.copyWith(search: value);
    loadAll(
      filter: IssueCharacterTypeFilter(
        pageNumber: 1,
        pageSize: _defaultPageSize,
        search: value.isEmpty ? null : value,
      ),
    );
  }

  void goToPage(int page) {
    loadAll(
      filter: IssueCharacterTypeFilter(
        pageNumber: page,
        pageSize: _defaultPageSize,
        search: state.search.isEmpty ? null : state.search,
      ),
    );
  }

  // ───────────────── CRUD ─────────────────

  Future<String?> add(String name) async {
    try {
      await _service.createCharacterType(name);
      // Reload to respect pagination and any sorting the API applies
      await loadAll();
      return null;
    } catch (e) {
      debugPrint('Failed to add issue character type: $e');
      return 'Failed to add issue character type';
    }
  }

  Future<String?> update({
    required int id,
    String? issueCharacterType,
    bool? active,
  }) async {
    try {
      final updated = await _service.updateCharacterType(
        id: id,
        issueCharacterType: issueCharacterType,
        active: active,
      );

      state = state.copyWith(
        items: state.items
            .map((e) => e.issueCharacterTypeId == id ? updated : e)
            .toList(),
        filtered: state.filtered
            .map((e) => e.issueCharacterTypeId == id ? updated : e)
            .toList(),
      );
      return null;
    } catch (e) {
      debugPrint('Failed to update issue character type: $e');
      return 'Failed to update issue character type';
    }
  }

  Future<String?> delete(int id) async {
    try {
      final deleted = await _service.deleteCharacterType(id);

      state = state.copyWith(
        items: state.items
            .map((e) => e.issueCharacterTypeId == id ? deleted : e)
            .toList(),
        filtered: state.filtered
            .map((e) => e.issueCharacterTypeId == id ? deleted : e)
            .toList(),
      );

      return null;
    } catch (e) {
      debugPrint('Failed to delete issue character type: $e');
      return 'Failed to delete issue character type';
    }
  }

  Future<String?> recover(int id) async {
    try {
      final recovered = await _service.recoverCharacterType(id);

      state = state.copyWith(
        items: state.items
            .map((e) => e.issueCharacterTypeId == id ? recovered : e)
            .toList(),
        filtered: state.filtered
            .map((e) => e.issueCharacterTypeId == id ? recovered : e)
            .toList(),
      );

      return null;
    } catch (e) {
      debugPrint('Failed to recover issue character type: $e');
      return 'Failed to recover issue character type';
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
      selected.addAll(state.filtered.map((e) => e.issueCharacterTypeId));
    }

    state = state.copyWith(isMultiSelect: true, selectedIds: selected);
  }

  void exitSelectionMode() {
    state = state.copyWith(isMultiSelect: false, selectedIds: {});
  }

  bool get allVisibleSelected =>
      state.filtered.isNotEmpty &&
      state.selectedIds.length == state.filtered.length;
}
