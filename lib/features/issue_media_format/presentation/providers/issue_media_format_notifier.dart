import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/features/issue_media_format/data/models/issue_media_format_filter.dart';
import 'package:voice_first_admin/features/issue_media_format/data/service/media_format_service.dart';
import 'issue_media_format_state.dart';

class IssueMediaFormatNotifier extends Notifier<IssueMediaFormatState> {
  late final MediaFormatService _service;

  @override
  IssueMediaFormatState build() {
    _service = MediaFormatService();
    return IssueMediaFormatState.initial();
  }

  static const int _defaultPageSize = 10;

  Future<void> loadAll({IssueMediaFormatFilter? filter}) async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true);

    try {
      final effectiveFilter =
          filter ??
          IssueMediaFormatFilter(pageNumber: 1, pageSize: _defaultPageSize);

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
        'IssueMediaFormat PAGE=${response.pageNumber}, TOTAL_PAGES=${response.totalPages}, ITEMS=${response.items.length}',
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
      debugPrint('Failed to load issue media formats: $e');
    }
  }

  void search(String value) {
    state = state.copyWith(search: value);
    loadAll(
      filter: IssueMediaFormatFilter(
        pageNumber: 1,
        pageSize: _defaultPageSize,
        search: value.isEmpty ? null : value,
      ),
    );
  }

  void goToPage(int page) {
    loadAll(
      filter: IssueMediaFormatFilter(
        pageNumber: page,
        pageSize: _defaultPageSize,
        search: state.search.isEmpty ? null : state.search,
      ),
    );
  }

  /// Returns the API success message on success.
  /// Throws an Exception with the API error message on failure.
  Future<String> add(String name) async {
    final (_, message) = await _service.createMediaFormat(name);
    await loadAll();
    return message;
  }

  Future<String?> update({
    required int id,
    String? issueMediaFormat,
    bool? active,
  }) async {
    try {
      final updated = await _service.updateMediaFormat(
        id: id,
        issueMediaFormat: issueMediaFormat,
        active: active,
      );

      state = state.copyWith(
        items: state.items
            .map((e) => e.issueMediaFormatId == id ? updated : e)
            .toList(),
        filtered: state.filtered
            .map((e) => e.issueMediaFormatId == id ? updated : e)
            .toList(),
      );
      return null;
    } catch (e) {
      debugPrint('Failed to update issue media format: $e');
      return e.toString().replaceFirst('Exception: ', '');
    }
  }

  Future<String?> delete(int id) async {
    try {
      final deleted = await _service.deleteMediaFormat(id);

      state = state.copyWith(
        items: state.items
            .map((e) => e.issueMediaFormatId == id ? deleted : e)
            .toList(),
        filtered: state.filtered
            .map((e) => e.issueMediaFormatId == id ? deleted : e)
            .toList(),
      );

      return null;
    } catch (e) {
      debugPrint('Failed to delete issue media format: $e');
      return e.toString().replaceFirst('Exception: ', '');
    }
  }

  Future<String?> recover(int id) async {
    try {
      final recovered = await _service.recoverMediaFormat(id);

      state = state.copyWith(
        items: state.items
            .map((e) => e.issueMediaFormatId == id ? recovered : e)
            .toList(),
        filtered: state.filtered
            .map((e) => e.issueMediaFormatId == id ? recovered : e)
            .toList(),
      );

      return null;
    } catch (e) {
      debugPrint('Failed to recover issue media format: $e');
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
      selected.addAll(state.filtered.map((e) => e.issueMediaFormatId));
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
