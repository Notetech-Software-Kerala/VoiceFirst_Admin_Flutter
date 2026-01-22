import 'package:flutter_test/flutter_test.dart';
import 'package:voice_first_admin/features/Business_activity/models/business_activity_model.dart';
import 'package:voice_first_admin/features/Business_activity/presentation/providers/business_activity_state.dart';

void main() {
  group('BusinessActivityState', () {
    final testDate = DateTime(2024, 1, 1);
    final mockActivities = [
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

    test('initial state should have empty lists and false flags', () {
      final state = BusinessActivityState.initial();

      expect(state.activities, isEmpty);
      expect(state.filtered, isEmpty);
      expect(state.selectedIds, isEmpty);
      expect(state.isMultiSelect, false);
      expect(state.search, '');
      expect(state.isLoading, false);
      expect(state.hasMoreData, true);
      expect(state.currentPage, 1);
      expect(state.totalCount, 0);
    });

    test('copyWith should create new state with updated fields', () {
      final initialState = BusinessActivityState.initial();
      final newState = initialState.copyWith(
        activities: mockActivities,
        filtered: mockActivities,
        isMultiSelect: true,
      );

      expect(newState.activities, mockActivities);
      expect(newState.filtered, mockActivities);
      expect(newState.isMultiSelect, true);
      expect(newState.selectedIds, isEmpty);
      expect(newState.search, '');
    });

    test('copyWith should keep original values when not specified', () {
      final state = BusinessActivityState(
        activities: mockActivities,
        filtered: mockActivities,
        selectedIds: {1, 2},
        isMultiSelect: true,
        search: 'test',
        isLoading: false,
        hasMoreData: true,
        currentPage: 1,
        totalCount: 10,
      );

      final newState = state.copyWith(search: 'updated');

      expect(newState.activities, mockActivities);
      expect(newState.filtered, mockActivities);
      expect(newState.selectedIds, {1, 2});
      expect(newState.isMultiSelect, true);
      expect(newState.search, 'updated');
      expect(newState.isLoading, false);
      expect(newState.hasMoreData, true);
      expect(newState.currentPage, 1);
      expect(newState.totalCount, 10);
    });

    test('should handle selectedIds updates', () {
      final state = BusinessActivityState.initial();
      final newState = state.copyWith(selectedIds: {1, 2, 3});

      expect(newState.selectedIds, {1, 2, 3});
      expect(newState.selectedIds.length, 3);
    });

    test('should handle multi-select mode toggle', () {
      final state = BusinessActivityState.initial();

      final multiSelectState = state.copyWith(isMultiSelect: true);
      expect(multiSelectState.isMultiSelect, true);

      final normalState = multiSelectState.copyWith(isMultiSelect: false);
      expect(normalState.isMultiSelect, false);
    });

    test('should handle pagination state updates', () {
      final state = BusinessActivityState.initial();

      final loadingState = state.copyWith(isLoading: true);
      expect(loadingState.isLoading, true);

      final loadedState = loadingState.copyWith(
        isLoading: false,
        currentPage: 2,
        totalCount: 50,
        hasMoreData: true,
      );
      expect(loadedState.isLoading, false);
      expect(loadedState.currentPage, 2);
      expect(loadedState.totalCount, 50);
      expect(loadedState.hasMoreData, true);
    });

    test('should handle pagination completion', () {
      final state = BusinessActivityState.initial();

      final finalPageState = state.copyWith(
        currentPage: 5,
        totalCount: 100,
        hasMoreData: false,
      );

      expect(finalPageState.currentPage, 5);
      expect(finalPageState.totalCount, 100);
      expect(finalPageState.hasMoreData, false);
    });
  });
}
