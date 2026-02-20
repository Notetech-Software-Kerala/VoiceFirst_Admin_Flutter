import 'package:flutter_test/flutter_test.dart';
import 'package:voice_first_admin/features/Country_Management/division2/models/division_two_model.dart';
import 'package:voice_first_admin/features/Country_Management/division2/presentation/providers/division_two_state.dart';

void main() {
  group('DivisionTwoState', () {
    final mockItems = [
      DivisionTwoModel(id: 1, divisionOneId: 1, name: 'A', status: true),
      DivisionTwoModel(id: 2, divisionOneId: 1, name: 'B', status: false),
    ];

    test('initial should have expected defaults', () {
      final state = DivisionTwoState.initial();

      expect(state.all, isEmpty);
      expect(state.filtered, isEmpty);
      expect(state.isMultiSelect, isFalse);
      expect(state.selectedIds, isEmpty);
      expect(state.search, '');
      expect(state.isLoading, isFalse);
      expect(state.currentPage, 1);
      expect(state.totalPages, 1);
      expect(state.totalCount, 0);
      expect(state.hasMoreData, isTrue);
      expect(state.error, isNull);
    });

    test('copyWith should update provided fields', () {
      final base = DivisionTwoState(
        all: mockItems,
        filtered: mockItems,
        isMultiSelect: false,
        selectedIds: {1},
        search: 'a',
        isLoading: false,
        currentPage: 1,
        totalPages: 1,
        totalCount: 2,
        hasMoreData: true,
        error: null,
      );

      final updated = base.copyWith(
        filtered: [mockItems.first],
        isMultiSelect: true,
        selectedIds: {2},
        search: 'b',
        isLoading: true,
        currentPage: 2,
        totalPages: 3,
        totalCount: 10,
        hasMoreData: false,
        error: 'error',
      );

      expect(updated.all, mockItems);
      expect(updated.filtered, [mockItems.first]);
      expect(updated.isMultiSelect, isTrue);
      expect(updated.selectedIds, {2});
      expect(updated.search, 'b');
      expect(updated.isLoading, isTrue);
      expect(updated.currentPage, 2);
      expect(updated.totalPages, 3);
      expect(updated.totalCount, 10);
      expect(updated.hasMoreData, isFalse);
      expect(updated.error, 'error');
    });

    test('copyWith should keep original values when not specified', () {
      final base = DivisionTwoState(
        all: mockItems,
        filtered: mockItems,
        isMultiSelect: true,
        selectedIds: {1},
        search: 'search',
        isLoading: true,
        currentPage: 2,
        totalPages: 2,
        totalCount: 2,
        hasMoreData: false,
        error: null,
      );

      final updated = base.copyWith();

      expect(updated.all, mockItems);
      expect(updated.filtered, mockItems);
      expect(updated.isMultiSelect, true);
      expect(updated.selectedIds, {1});
      expect(updated.search, 'search');
      expect(updated.isLoading, true);
      expect(updated.currentPage, 2);
      expect(updated.totalPages, 2);
      expect(updated.totalCount, 2);
      expect(updated.hasMoreData, false);
      expect(updated.error, null);
    });
  });
}
