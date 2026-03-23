import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/features/custom_field/data/models/custom_field_filter.dart';
import 'package:voice_first_admin/features/custom_field/data/models/custom_field_model.dart';
import 'package:voice_first_admin/features/custom_field/data/service/custom_field_service.dart';
import 'custom_field_state.dart';

class CustomFieldNotifier extends Notifier<CustomFieldState> {
  late final CustomFieldService _service;

  @override
  CustomFieldState build() {
    _service = CustomFieldService();
    return CustomFieldState.initial();
  }

  static const int _defaultPageSize = 10;

  // ─── Load / Paginate ───────────────────────────────────────────────────────
  Future<void> loadAll({CustomFieldFilter? filter}) async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final effectiveFilter = filter ??
          CustomFieldFilter(pageNumber: 1, pageSize: _defaultPageSize);
      final response = await _service.getAll(effectiveFilter);
      state = state.copyWith(
        items: response.items,
        filtered: response.items,
        isLoading: false,
        currentPage: response.pageNumber,
        totalCount: response.totalCount,
        totalPages: response.totalPages,
        hasMoreData: response.pageNumber < response.totalPages,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      debugPrint('CustomField loadAll error: $e');
    }
  }

  void search(String value) {
    state = state.copyWith(search: value);
    loadAll(
      filter: CustomFieldFilter(
        pageNumber: 1,
        pageSize: _defaultPageSize,
        search: value.isEmpty ? null : value,
      ),
    );
  }

  void goToPage(int page) {
    loadAll(
      filter: CustomFieldFilter(
        pageNumber: page,
        pageSize: _defaultPageSize,
        search: state.search.isEmpty ? null : state.search,
      ),
    );
  }

  // ─── Create ────────────────────────────────────────────────────────────────
  Future<String?> add(CustomFieldModel field) async {
    state = state.copyWith(isSaving: true, clearError: true);
    try {
      await _service.create(field);
      await loadAll();
      state = state.copyWith(isSaving: false);
      return null;
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      state = state.copyWith(isSaving: false, error: msg);
      return msg;
    }
  }

  // ─── Update ────────────────────────────────────────────────────────────────
  Future<String?> edit(int id, CustomFieldModel field) async {
    state = state.copyWith(isSaving: true, clearError: true);
    try {
      final updated = await _service.update(id: id, field: field);
      state = state.copyWith(
        isSaving: false,
        items: state.items.map((e) => e.fieldId == id ? updated : e).toList(),
        filtered:
            state.filtered.map((e) => e.fieldId == id ? updated : e).toList(),
      );
      return null;
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      state = state.copyWith(isSaving: false, error: msg);
      return msg;
    }
  }

  // ─── Delete ────────────────────────────────────────────────────────────────
  Future<String?> remove(int id) async {
    try {
      await _service.delete(id);
      state = state.copyWith(
        items: state.items.where((e) => e.fieldId != id).toList(),
        filtered: state.filtered.where((e) => e.fieldId != id).toList(),
        totalCount: state.totalCount - 1,
      );
      return null;
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      return msg;
    }
  }
}
