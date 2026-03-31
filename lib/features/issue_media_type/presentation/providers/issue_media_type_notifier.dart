import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/features/issue_media_type/data/models/issue_media_type_filter.dart';
import 'package:voice_first_admin/features/issue_media_type/data/service/media_type_service.dart';
// dio client is accessed via service providers; notifier shouldn't read dio directly
import 'issue_media_type_state.dart';

class IssueMediaTypeNotifier extends Notifier<IssueMediaTypeState> {
  late final MediaTypeService _service;

  @override
  IssueMediaTypeState build() {
    _service = ref.read(issueMediaTypeServiceProvider);
    return IssueMediaTypeState.initial();
  }

  Future<void> loadAll({
    IssueMediaTypeFilter? filter,
    int? page,
    int? pageSize,
  }) async {
    if (state.isLoading) return;

    final currentPage = page ?? state.currentPage;
    final currentPageSize = pageSize ?? state.filter.pageSize;

    final IssueMediaTypeFilter appliedFilter =
        filter ??
        state.filter.copyWith(
          pageNumber: currentPage,
          pageSize: currentPageSize,
        );

    // state = state.copyWith(isLoading: true, filter: appliedFilter, error: null);
    state = state.copyWith(isLoading: true, filter: appliedFilter, error: null);

    if (currentPage < 1) {
      state = state.copyWith(isLoading: false);
      return;
    }

    try {
      final response = await _service.getAll(appliedFilter);

      final safePage = response.pageNumber > response.totalPages
          ? response.totalPages
          : response.pageNumber;

      state = state.copyWith(
        items: response.items,
        selectedIds: {},
        isMultiSelect: false,
        isLoading: false,
        hasMoreData: response.pageNumber < response.totalPages,
        currentPage: safePage,
        totalCount: response.totalCount,
        totalPages: response.totalPages,
        error: null,
      );

      if (kDebugMode) {
        debugPrint(
          'IssueMediaType PAGE=${response.pageNumber}, TOTAL_PAGES=${response.totalPages}, ITEMS=${response.items.length}',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
      if (kDebugMode) debugPrint('Failed to load issue media types: $e');
    }
  }

  Future<void> search(String value) async {
    final newFilter = state.filter.copyWith(
      pageNumber: 1,
      pageSize: state.filter.pageSize,
      searchText: value.trim().isEmpty ? null : value,
    );

    await loadAll(filter: newFilter, page: 1);
  }

  void goToPage(int page) {
    loadAll(filter: state.filter.copyWith(pageNumber: page));
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
      );
      return null;
    } catch (e) {
      if (kDebugMode) debugPrint('Failed to update issue media type: $e');
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
      );
      return null;
    } catch (e) {
      if (kDebugMode) debugPrint('Failed to delete issue media type: $e');
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
      );
      return null;
    } catch (e) {
      if (kDebugMode) debugPrint('Failed to recover issue media type: $e');
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
      selected.addAll(state.items.map((e) => e.issueMediaTypeId));
    }

    state = state.copyWith(isMultiSelect: true, selectedIds: selected);
  }

  void exitSelectionMode() {
    state = state.copyWith(isMultiSelect: false, selectedIds: {});
  }

  bool get allVisibleSelected =>
      state.items.isNotEmpty && state.selectedIds.length == state.items.length;
}
