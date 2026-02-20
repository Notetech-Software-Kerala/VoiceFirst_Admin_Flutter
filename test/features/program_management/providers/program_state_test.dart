import 'package:flutter_test/flutter_test.dart';
import 'package:voice_first_admin/features/Program_management/models/program_management_model.dart';
import 'package:voice_first_admin/features/Program_management/presentation/providers/program_state.dart';

void main() {
  group('ProgramState', () {
    final mockPrograms = [
      const ProgramModel(
        sysProgramId: 1,
        programName: 'Dashboard',
        labelName: 'Dashboard',
        programRoute: '/dashboard',
        applicationId: 1,
        actions: [
          ProgramActionSummary(actionId: 1, actionName: 'View', active: true),
        ],
      ),
      const ProgramModel(
        sysProgramId: 2,
        programName: 'Settings',
        labelName: 'Settings',
        programRoute: '/settings',
        applicationId: 1,
        actions: [
          ProgramActionSummary(actionId: 2, actionName: 'Edit', active: true),
        ],
      ),
    ];

    test('initial state should have default values', () {
      final state = ProgramState.initial();
      expect(state.all, isEmpty);
      expect(state.filtered, isEmpty);
      expect(state.search, '');
      expect(state.selectedIds, isEmpty);
      expect(state.isMultiSelect, false);
      expect(state.selectedApplicationId, isNull);
      expect(state.selectedCompanyId, isNull);
      expect(state.isLoading, false);
      expect(state.hasMoreData, true);
      expect(state.currentPage, 1);
      expect(state.totalCount, 0);
    });

    test('copyWith should create new state with updated fields', () {
      final initialState = ProgramState.initial();
      final newState = initialState.copyWith(
        all: mockPrograms,
        filtered: mockPrograms,
        search: 'dashboard',
        isMultiSelect: true,
        selectedApplicationId: 1,
        isLoading: true,
        hasMoreData: false,
        currentPage: 2,
        totalCount: 10,
      );

      expect(newState.all, mockPrograms);
      expect(newState.filtered, mockPrograms);
      expect(newState.search, 'dashboard');
      expect(newState.isMultiSelect, true);
      expect(newState.selectedApplicationId, 1);
      expect(newState.selectedIds, isEmpty);
      expect(newState.isLoading, true);
      expect(newState.hasMoreData, false);
      expect(newState.currentPage, 2);
      expect(newState.totalCount, 10);
    });

    test('copyWith should keep original values when not specified', () {
      final state = ProgramState(
        all: mockPrograms,
        filtered: mockPrograms,
        search: 'test',
        selectedIds: {1, 2},
        isMultiSelect: true,
        selectedApplicationId: 1,
        selectedCompanyId: 5,
        isLoading: false,
        hasMoreData: true,
        currentPage: 1,
        totalCount: 0,
      );

      final newState = state.copyWith(search: 'updated');

      expect(newState.all, mockPrograms);
      expect(newState.filtered, mockPrograms);
      expect(newState.search, 'updated');
      expect(newState.selectedIds, {1, 2});
      expect(newState.isMultiSelect, true);
      expect(newState.selectedApplicationId, 1);
      expect(newState.selectedCompanyId, 5);
      expect(newState.isLoading, false);
      expect(newState.hasMoreData, true);
      expect(newState.currentPage, 1);
      expect(newState.totalCount, 0);
    });

    test('should handle selectedIds updates', () {
      final state = ProgramState.initial();
      final newState = state.copyWith(selectedIds: {1, 2, 3});

      expect(newState.selectedIds, {1, 2, 3});
      expect(newState.selectedIds.length, 3);
    });

    test('should handle application and company selection', () {
      final state = ProgramState.initial();
      final newState = state.copyWith(
        selectedApplicationId: 1,
        selectedCompanyId: 5,
      );

      expect(newState.selectedApplicationId, 1);
      expect(newState.selectedCompanyId, 5);
    });

    test('should handle multi-select mode toggle', () {
      final state = ProgramState.initial();

      final multiSelectOn = state.copyWith(isMultiSelect: true);
      expect(multiSelectOn.isMultiSelect, true);

      final multiSelectOff = multiSelectOn.copyWith(isMultiSelect: false);
      expect(multiSelectOff.isMultiSelect, false);
    });

    test('should handle filtered list separately from all list', () {
      final state = ProgramState(
        all: mockPrograms,
        filtered: mockPrograms,
        search: '',
        selectedIds: const {},
        isMultiSelect: false,
        selectedApplicationId: null,
        selectedCompanyId: null,
        isLoading: false,
        hasMoreData: true,
        currentPage: 1,
        totalCount: 0,
      );

      final filteredList = [mockPrograms[0]];
      final newState = state.copyWith(
        filtered: filteredList,
        search: 'dashboard',
      );

      expect(newState.all, mockPrograms);
      expect(newState.all.length, 2);
      expect(newState.filtered, filteredList);
      expect(newState.filtered.length, 1);
      expect(newState.search, 'dashboard');
    });
  });
}
