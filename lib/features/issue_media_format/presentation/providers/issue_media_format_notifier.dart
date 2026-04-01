import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/features/issue_media_format/data/models/issue_media_format_filter.dart';
import 'package:voice_first_admin/features/issue_media_format/data/repositories/media_format_repository.dart';
import 'package:voice_first_admin/features/issue_media_format/presentation/providers/issue_media_format_state.dart';

class IssueMediaFormatNotifier extends Notifier<IssueMediaFormatState> {
  late final MediaFormatRepository _repository;

  @override
  IssueMediaFormatState build() {
    _repository = ref.read(issueMediaFormatRepositoryProvider);
    return IssueMediaFormatState.initial();
  }

  static const int _defaultPageSize = 10;
  Future<void> loadAll({
    IssueMediaFormatFilter? filter,
    int? page,
    int? pageSize,
  }) async {
    if (state.isLoading) return;

    final currentPage = page ?? state.currentPage;
    final currentPageSize = pageSize ?? state.filter.pageSize;

    final IssueMediaFormatFilter appliedFilter =
        filter ??
        IssueMediaFormatFilter(
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

    if (currentPage < 1) return;

    state = state.copyWith(isLoading: true, filter: appliedFilter, error: null);

    try {
      final response = await _repository.getAll(appliedFilter);

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
          'IssueMediaFormat PAGE=${response.pageNumber}, TOTAL_PAGES=${response.totalPages}, ITEMS=${response.items.length}',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
      if (kDebugMode) {
        debugPrint('Failed to load issue media formats: $e');
      }
    }
  }

  Future<void> search(String value) async {
    final newFilter = IssueMediaFormatFilter(
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

    await loadAll(filter: newFilter, page: 1);
  }

  /// Returns the API success message on success.
  /// Throws an Exception with the API error message on failure.
  Future<String> add(String name) async {
    final (_, message) = await _repository.createMediaFormat(name);
    await loadAll();
    return message;
  }

  Future<String?> update({
    required int id,
    String? issueMediaFormat,
    bool? active,
  }) async {
    try {
      final updated = await _repository.updateMediaFormat(
        id: id,
        issueMediaFormat: issueMediaFormat,
        active: active,
      );

      state = state.copyWith(
        items: state.items
            .map((e) => e.issueMediaFormatId == id ? updated : e)
            .toList(),
      );
      await loadAll();
      return null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to update issue media format: $e');
      }
      return e.toString().replaceFirst('Exception: ', '');
    }
  }

  Future<String?> delete(int id) async {
    try {
      final deleted = await _repository.deleteMediaFormat(id);

      state = state.copyWith(
        items: state.items
            .map((e) => e.issueMediaFormatId == id ? deleted : e)
            .toList(),
      );

      await loadAll();

      return null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to delete issue media format: $e');
      }
      return e.toString().replaceFirst('Exception: ', '');
    }
  }

  Future<String?> recover(int id) async {
    try {
      final recovered = await _repository.recoverMediaFormat(id);

      state = state.copyWith(
        items: state.items
            .map((e) => e.issueMediaFormatId == id ? recovered : e)
            .toList(),
      );

      await loadAll();

      return null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to recover issue media format: $e');
      }
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
      selected.addAll(state.items.map((e) => e.issueMediaFormatId));
    }

    state = state.copyWith(isMultiSelect: true, selectedIds: selected);
  }

  void exitSelectionMode() {
    state = state.copyWith(isMultiSelect: false, selectedIds: {});
  }

  bool get allVisibleSelected =>
      state.items.isNotEmpty && state.selectedIds.length == state.items.length;
}
