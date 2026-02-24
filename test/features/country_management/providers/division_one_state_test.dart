import 'package:flutter_test/flutter_test.dart';
import 'package:voice_first_admin/features/Country_Management/division1/models/division1_model.dart';
import 'package:voice_first_admin/features/Country_Management/division1/presentation/providers/division_one_state.dart';

void main() {
  group('DivisionOneState', () {
    final mockItems = [
      DivisionOneModel(id: 1, countryId: 1, name: 'A', status: true),
      DivisionOneModel(id: 2, countryId: 1, name: 'B', status: false),
    ];

    test('initial should have expected defaults', () {
      final state = DivisionOneState.initial();

      expect(state.all, isEmpty);
      expect(state.filtered, isEmpty);
      expect(state.isMultiSelect, isFalse);
      expect(state.selectedIds, isEmpty);
      expect(state.search, '');
      expect(state.isLoading, isFalse);
      expect(state.error, isNull);
      expect(state.hasMoreData, isTrue);
      expect(state.currentPage, 1);
      expect(state.totalCount, 0);
      expect(state.totalPages, 1);
    });

    test('copyWith should update provided fields', () {
      final base = DivisionOneState(
        all: mockItems,
        filtered: mockItems,
        isMultiSelect: false,
        selectedIds: {1},
        search: 'a',
        isLoading: false,
        error: null,
        hasMoreData: true,
        currentPage: 1,
        totalCount: 2,
        totalPages: 1,
      );

      final updated = base.copyWith(
        filtered: [mockItems.first],
        isMultiSelect: true,
        selectedIds: {2},
        search: 'b',
        isLoading: true,
        error: 'error',
        hasMoreData: false,
        currentPage: 2,
        totalCount: 10,
        totalPages: 3,
      );

      expect(updated.all, mockItems);
      expect(updated.filtered, [mockItems.first]);
      expect(updated.isMultiSelect, isTrue);
      expect(updated.selectedIds, {2});
      expect(updated.search, 'b');
      expect(updated.isLoading, isTrue);
      expect(updated.error, 'error');
      expect(updated.hasMoreData, isFalse);
      expect(updated.currentPage, 2);
      expect(updated.totalCount, 10);
      expect(updated.totalPages, 3);
    });

    test('copyWith should keep original values when not specified', () {
      final base = DivisionOneState(
        all: mockItems,
        filtered: mockItems,
        isMultiSelect: true,
        selectedIds: {1},
        search: 'search',
        isLoading: true,
        error: null,
        hasMoreData: false,
        currentPage: 2,
        totalCount: 2,
        totalPages: 2,
      );

      final updated = base.copyWith();

      expect(updated.all, mockItems);
      expect(updated.filtered, mockItems);
      expect(updated.isMultiSelect, true);
      expect(updated.selectedIds, {1});
      expect(updated.search, 'search');
      expect(updated.isLoading, true);
      expect(updated.error, null);
      expect(updated.hasMoreData, false);
      expect(updated.currentPage, 2);
      expect(updated.totalCount, 2);
      expect(updated.totalPages, 2);
    });
  });
}
