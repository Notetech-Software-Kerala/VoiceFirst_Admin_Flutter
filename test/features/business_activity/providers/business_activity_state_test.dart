import 'package:flutter_test/flutter_test.dart';
import 'package:voice_first_admin/features/business_activity/data/models/business_activity_model.dart';
import 'package:voice_first_admin/core/models/base_filter_model.dart';
import 'package:voice_first_admin/features/business_activity/presentation/providers/business_activity_state.dart';

void main() {
  group('BusinessActivityState', () {
    final testDate = DateTime(2024, 1, 1);
    final mockItems = [
      BusinessActivity(
        activityId: 1,
        activityName: 'Activity 1',
        active: true,
        isDeleted: false,
        createdUser: 'admin',
        createdDate: testDate,
      ),
      BusinessActivity(
        activityId: 2,
        activityName: 'Activity 2',
        active: false,
        isDeleted: false,
        createdUser: 'admin',
        createdDate: testDate,
      ),
    ];

    test('initial has empty items and default filter', () {
      final state = BusinessActivityState.initial();

      expect(state.items, isEmpty);
      expect(state.filter, isA<BaseFilterModel>());
      expect(state.filter.sortOrder, 'Asc');
      expect(state.selectedIds, isEmpty);
      expect(state.isMultiSelect, isFalse);
      expect(state.isLoading, isFalse);
      expect(state.hasMoreData, isTrue);
      expect(state.currentPage, 1);
      expect(state.totalCount, 0);
    });

    test('copyWith updates provided fields', () {
      final initialState = BusinessActivityState.initial();
      final newFilter = const BaseFilterModel(
        searchText: 'abc',
        sortOrder: 'Desc',
      );

      final newState = initialState.copyWith(
        items: mockItems,
        filter: newFilter,
        isMultiSelect: true,
        selectedIds: {1},
        isLoading: true,
        totalCount: 2,
        currentPage: 1,
        hasMoreData: false,
      );

      expect(newState.items, mockItems);
      expect(newState.filter.searchText, 'abc');
      expect(newState.filter.sortOrder, 'Desc');
      expect(newState.isMultiSelect, isTrue);
      expect(newState.selectedIds, {1});
      expect(newState.isLoading, isTrue);
      expect(newState.totalCount, 2);
      expect(newState.currentPage, 1);
      expect(newState.hasMoreData, isFalse);
    });

    test('copyWith keeps original values when not specified', () {
      final state = BusinessActivityState(
        items: mockItems,
        filter: const BaseFilterModel(searchText: 'orig'),
        totalCount: 10,
        currentPage: 2,
        hasMoreData: false,
        isLoading: false,
        isMultiSelect: true,
        selectedIds: {1, 2},
      );

      final newState = state.copyWith(totalCount: 20);

      expect(newState.items, mockItems);
      expect(newState.filter.searchText, 'orig');
      expect(newState.selectedIds, {1, 2});
      expect(newState.isMultiSelect, isTrue);
      expect(newState.isLoading, isFalse);
      expect(newState.hasMoreData, isFalse);
      expect(newState.currentPage, 2);
      expect(newState.totalCount, 20);
    });

    test('supports updating selectedIds', () {
      final state = BusinessActivityState.initial();
      final newState = state.copyWith(selectedIds: {1, 2, 3});

      expect(newState.selectedIds, {1, 2, 3});
      expect(newState.selectedIds.length, 3);
    });

    test('supports toggling multi-select flag', () {
      final state = BusinessActivityState.initial();

      final multiSelectState = state.copyWith(isMultiSelect: true);
      expect(multiSelectState.isMultiSelect, isTrue);

      final normalState = multiSelectState.copyWith(isMultiSelect: false);
      expect(normalState.isMultiSelect, isFalse);
    });

    test('supports pagination state updates', () {
      final state = BusinessActivityState.initial();

      final loadingState = state.copyWith(isLoading: true);
      expect(loadingState.isLoading, isTrue);

      final loadedState = loadingState.copyWith(
        isLoading: false,
        currentPage: 2,
        totalCount: 50,
        hasMoreData: true,
      );
      expect(loadedState.isLoading, isFalse);
      expect(loadedState.currentPage, 2);
      expect(loadedState.totalCount, 50);
      expect(loadedState.hasMoreData, isTrue);
    });

    test('supports marking pagination completion', () {
      final state = BusinessActivityState.initial();

      final finalPageState = state.copyWith(
        currentPage: 5,
        totalCount: 100,
        hasMoreData: false,
      );

      expect(finalPageState.currentPage, 5);
      expect(finalPageState.totalCount, 100);
      expect(finalPageState.hasMoreData, isFalse);
    });
  });
}
