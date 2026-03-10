import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/features/issue_media_type/data/models/issue_media_type_filter.dart';
import 'package:voice_first_admin/features/issue_media_type/data/service/media_type_service.dart';
import 'issue_media_type_state.dart';

class IssueMediaTypeNotifier extends Notifier<IssueMediaTypeState> {
  late final MediaTypeService _service;

  @override
  IssueMediaTypeState build() {
    _service = MediaTypeService();
    return IssueMediaTypeState.initial();
  }

  static const int _defaultPageSize = 10;

  Future<void> loadAll({IssueMediaTypeFilter? filter}) async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true);

    try {
      final effectiveFilter =
          filter ??
          IssueMediaTypeFilter(pageNumber: 1, pageSize: _defaultPageSize);

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
        'IssueMediaType PAGE=${response.pageNumber}, TOTAL_PAGES=${response.totalPages}, ITEMS=${response.items.length}',
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
      debugPrint('Failed to load issue media types: $e');
    }
  }

  void search(String value) {
    state = state.copyWith(search: value);
    loadAll(
      filter: IssueMediaTypeFilter(
        pageNumber: 1,
        pageSize: _defaultPageSize,
        search: value.isEmpty ? null : value,
      ),
    );
  }

  void goToPage(int page) {
    loadAll(
      filter: IssueMediaTypeFilter(
        pageNumber: page,
        pageSize: _defaultPageSize,
        search: state.search.isEmpty ? null : state.search,
      ),
    );
  }

  Future<String> add(String name) async {
    final (_, message) = await _service.createMediaType(name);
    await loadAll();
    return message;
  }

  Future<String?> update({
    required int id,
    String? issueMediaType,
    bool? active,
  }) async {
    try {
      final updated = await _service.updateMediaType(
        id: id,
        issueMediaType: issueMediaType,
        active: active,
      );

      state = state.copyWith(
        items: state.items
            .map((e) => e.issueMediaTypeId == id ? updated : e)
            .toList(),
        filtered: state.filtered
            .map((e) => e.issueMediaTypeId == id ? updated : e)
            .toList(),
      );
      return null;
    } catch (e) {
      debugPrint('Failed to update issue media type: $e');
      return e.toString().replaceFirst('Exception: ', '');
    }
  }

  Future<String?> delete(int id) async {
    try {
      final deleted = await _service.deleteMediaType(id);

      state = state.copyWith(
        items: state.items
            .map((e) => e.issueMediaTypeId == id ? deleted : e)
            .toList(),
        filtered: state.filtered
            .map((e) => e.issueMediaTypeId == id ? deleted : e)
            .toList(),
      );

      return null;
    } catch (e) {
      debugPrint('Failed to delete issue media type: $e');
      return e.toString().replaceFirst('Exception: ', '');
    }
  }

  Future<String?> recover(int id) async {
    try {
      final recovered = await _service.recoverMediaType(id);

      state = state.copyWith(
        items: state.items
            .map((e) => e.issueMediaTypeId == id ? recovered : e)
            .toList(),
        filtered: state.filtered
            .map((e) => e.issueMediaTypeId == id ? recovered : e)
            .toList(),
      );

      return null;
    } catch (e) {
      debugPrint('Failed to recover issue media type: $e');
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
      selected.addAll(state.filtered.map((e) => e.issueMediaTypeId));
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
