import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/features/issue_status/data/models/issue_status_filter.dart';
import 'package:voice_first_admin/features/issue_status/data/repositories/issue_status_repository.dart';
import 'issue_status_state.dart';
import 'issue_status_provider.dart';

class IssueStatusNotifier extends Notifier<IssueStatusState> {
  late final IssueStatusRepository _repository;

  @override
  IssueStatusState build() {
    _repository = ref.read(issueStatusRepositoryProvider);
    return IssueStatusState.initial();
  }

  static const int _defaultPageSize = 10;

  Future<void> loadAll({IssueStatusFilter? filter}) async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true);

    try {
      final effectiveFilter =
          filter ??
          IssueStatusFilter(pageNumber: 1, pageSize: _defaultPageSize);

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
        'IssueStatus PAGE=${response.pageNumber}, TOTAL_PAGES=${response.totalPages}, ITEMS=${response.items.length}',
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
      debugPrint('Failed to load issue statuses: $e');
    }
  }

  void search(String value) {
    state = state.copyWith(search: value);
    loadAll(
      filter: IssueStatusFilter(
        pageNumber: 1,
        pageSize: _defaultPageSize,
        search: value.isEmpty ? null : value,
      ),
    );
  }

  void goToPage(int page) {
    loadAll(
      filter: IssueStatusFilter(
        pageNumber: page,
        pageSize: _defaultPageSize,
        search: state.search.isEmpty ? null : state.search,
      ),
    );
  }

  Future<String> add(String name) async {
    final (_, message) = await _repository.createStatus(name);
    await loadAll();
    return message;
  }

  Future<String?> update({
    required int id,
    String? issueStatus,
    bool? active,
  }) async {
    try {
      final updated = await _repository.updateStatus(
        id: id,
        issueStatus: issueStatus,
        active: active,
      );

      state = state.copyWith(
        items: state.items
            .map((e) => e.issueStatusId == id ? updated : e)
            .toList(),
        filtered: state.filtered
            .map((e) => e.issueStatusId == id ? updated : e)
            .toList(),
      );
      return null;
    } catch (e) {
      debugPrint('Failed to update issue status: $e');
      return e.toString().replaceFirst('Exception: ', '');
    }
  }

  Future<String?> delete(int id) async {
    try {
      final deleted = await _repository.deleteStatus(id);

      state = state.copyWith(
        items: state.items
            .map((e) => e.issueStatusId == id ? deleted : e)
            .toList(),
        filtered: state.filtered
            .map((e) => e.issueStatusId == id ? deleted : e)
            .toList(),
      );

      return null;
    } catch (e) {
      debugPrint('Failed to delete issue status: $e');
      return e.toString().replaceFirst('Exception: ', '');
    }
  }

  Future<String?> recover(int id) async {
    try {
      final recovered = await _repository.recoverStatus(id);

      state = state.copyWith(
        items: state.items
            .map((e) => e.issueStatusId == id ? recovered : e)
            .toList(),
        filtered: state.filtered
            .map((e) => e.issueStatusId == id ? recovered : e)
            .toList(),
      );

      return null;
    } catch (e) {
      debugPrint('Failed to recover issue status: $e');
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

  void enterSelectionMode({bool selectAll = false}) {
    final selected = <int>{};

    if (selectAll) {
      selected.addAll(state.filtered.map((e) => e.issueStatusId));
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
