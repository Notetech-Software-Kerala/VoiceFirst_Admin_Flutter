import 'package:flutter_test/flutter_test.dart';
import 'package:voice_first_admin/features/Program_management/models/program_management_model.dart';
import 'package:voice_first_admin/features/Program_management/presentation/providers/program_state.dart';

void main() {
  group('ProgramState', () {
    final mockPrograms = [
      const ProgramManagementModel(
        sysProgramId: 1,
        programName: 'Dashboard',
        labelName: 'Dashboard',
        programRoute: '/dashboard',
        applicationId: 1,
        programActionIds: [1, 2],
      ),
      const ProgramManagementModel(
        sysProgramId: 2,
        programName: 'Settings',
        labelName: 'Settings',
        programRoute: '/settings',
        applicationId: 1,
        programActionIds: [3],
      ),
    ];

    test('initial state should have empty lists and null selections', () {
      final state = ProgramState.initial();

      expect(state.all, isEmpty);
      expect(state.filtered, isEmpty);
      expect(state.search, '');
      expect(state.selectedIds, isEmpty);
      expect(state.isMultiSelect, false);
      expect(state.selectedApplicationId, null);
      expect(state.selectedCompanyId, null);
    });

    test('copyWith should create new state with updated fields', () {
      final initialState = ProgramState.initial();
      final newState = initialState.copyWith(
        all: mockPrograms,
        filtered: mockPrograms,
        search: 'dashboard',
        isMultiSelect: true,
        selectedApplicationId: 1,
      );

      expect(newState.all, mockPrograms);
      expect(newState.filtered, mockPrograms);
      expect(newState.search, 'dashboard');
      expect(newState.isMultiSelect, true);
      expect(newState.selectedApplicationId, 1);
      expect(newState.selectedIds, isEmpty);
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
      );

      final newState = state.copyWith(search: 'updated');

      expect(newState.all, mockPrograms);
      expect(newState.filtered, mockPrograms);
      expect(newState.search, 'updated');
      expect(newState.selectedIds, {1, 2});
      expect(newState.isMultiSelect, true);
      expect(newState.selectedApplicationId, 1);
      expect(newState.selectedCompanyId, 5);
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
        selectedIds: {},
        isMultiSelect: false,
        selectedApplicationId: null,
        selectedCompanyId: null,
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
