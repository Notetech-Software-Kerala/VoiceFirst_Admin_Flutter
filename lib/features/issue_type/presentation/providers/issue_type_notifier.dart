import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/features/issue_type/data/models/issue_type_filter.dart';
import 'package:voice_first_admin/features/issue_type/data/repositories/issue_type_repository.dart';
import 'issue_type_state.dart';
import 'issue_type_provider.dart';

class IssueTypeNotifier extends Notifier<IssueTypeState> {
  late final IssueTypeRepository _repository;

  @override
  IssueTypeState build() {
    _repository = ref.read(issueTypeRepositoryProvider);
    return IssueTypeState.initial();
  }

  static const int _defaultPageSize = 10;

  Future<void> loadAll({IssueTypeFilter? filter}) async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true);

    try {
      final effectiveFilter =
          filter ?? IssueTypeFilter(pageNumber: 1, pageSize: _defaultPageSize);

      final response = await _repository.getAll(effectiveFilter);

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
        'IssueType PAGE=${response.pageNumber}, TOTAL_PAGES=${response.totalPages}, ITEMS=${response.items.length}',
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
      debugPrint('Failed to load issue types: $e');
    }
  }

  void search(String value) {
    state = state.copyWith(search: value);
    loadAll(
      filter: IssueTypeFilter(
        pageNumber: 1,
        pageSize: _defaultPageSize,
        search: value.isEmpty ? null : value,
      ),
    );
  }

  void goToPage(int page) {
    loadAll(
      filter: IssueTypeFilter(
        pageNumber: page,
        pageSize: _defaultPageSize,
        search: state.search.isEmpty ? null : state.search,
      ),
    );
  }

  Future<String> add(String name, {String? description}) async {
    final (_, message) = await _repository.createType(
      name: name,
      description: description,
    );
    await loadAll();
    return message;
  }

  Future<String?> update({
    required int id,
    String? issueType,
    String? description,
    bool? active,
  }) async {
    try {
      final updated = await _repository.updateType(
        id: id,
        issueType: issueType,
        description: description,
        active: active,
      );

      state = state.copyWith(
        items: state.items.map((e) => e.issueTypeId == id ? updated : e).toList(),
        filtered: state.filtered.map((e) => e.issueTypeId == id ? updated : e).toList(),
      );
      return null;
    } catch (e) {
      debugPrint('Failed to update issue type: $e');
      return e.toString().replaceFirst('Exception: ', '');
    }
  }

  Future<String?> delete(int id) async {
    try {
      final deleted = await _repository.deleteType(id);

      state = state.copyWith(
        items: state.items.map((e) => e.issueTypeId == id ? deleted : e).toList(),
        filtered: state.filtered.map((e) => e.issueTypeId == id ? deleted : e).toList(),
      );
      return null;
    } catch (e) {
      debugPrint('Failed to delete issue type: $e');
      return e.toString().replaceFirst('Exception: ', '');
    }
  }

  Future<String?> recover(int id) async {
    try {
      final recovered = await _repository.recoverType(id);

      state = state.copyWith(
        items: state.items.map((e) => e.issueTypeId == id ? recovered : e).toList(),
        filtered: state.filtered.map((e) => e.issueTypeId == id ? recovered : e).toList(),
      );
      return null;
    } catch (e) {
      debugPrint('Failed to recover issue type: $e');
      return e.toString().replaceFirst('Exception: ', '');
    }
  }

  void toggleSelection(int id) {
    final selected = {...state.selectedIds};
    selected.contains(id) ? selected.remove(id) : selected.add(id);
    state = state.copyWith(
      selectedIds: selected,
      isMultiSelect: selected.isNotEmpty,
    );
  }

  void exitSelectionMode() {
    state = state.copyWith(isMultiSelect: false, selectedIds: {});
  }
}
