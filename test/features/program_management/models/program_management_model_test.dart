import 'package:flutter_test/flutter_test.dart';
import 'package:voice_first_admin/features/Program_management/models/program_management_model.dart';

void main() {
  group('ProgramManagementModel', () {
    test('should create instance with required fields', () {
      final program = ProgramModel(
        programName: 'Test Program',
        labelName: 'Test Label',
        programRoute: '/test',
        applicationId: 1,
        programActionIds: [1, 2, 3],
      );

      expect(program.programName, 'Test Program');
      expect(program.labelName, 'Test Label');
      expect(program.programRoute, '/test');
      expect(program.applicationId, 1);
      expect(program.programActionIds, [1, 2, 3]);
      expect(program.sysProgramId, null);
      expect(program.companyId, null);
    });

    test('should create instance with optional fields', () {
      final program = ProgramModel(
        sysProgramId: 10,
        programName: 'Test Program',
        labelName: 'Test Label',
        programRoute: '/test',
        applicationId: 1,
        companyId: 5,
        programActionIds: [1, 2],
      );

      expect(program.sysProgramId, 10);
      expect(program.companyId, 5);
      expect(program.programActionIds, [1, 2]);
    });

    test('should parse from JSON correctly', () {
      final json = {
        'sysProgramId': 10,
        'programName': 'Dashboard',
        'labelName': 'Main Dashboard',
        'programRoute': '/dashboard',
        'applicationId': 1,
        'companyId': 5,
        'programActionIds': [1, 2, 3],
      };

      final program = ProgramModel.fromJson(json);

      expect(program.sysProgramId, 10);
      expect(program.programName, 'Dashboard');
      expect(program.labelName, 'Main Dashboard');
      expect(program.programRoute, '/dashboard');
      expect(program.applicationId, 1);
      expect(program.companyId, 5);
      expect(program.programActionIds, [1, 2, 3]);
    });

    test('should handle missing optional fields in JSON', () {
      final json = {
        'programName': 'Test',
        'labelName': 'Label',
        'programRoute': '/test',
        'applicationId': 1,
      };

      final program = ProgramModel.fromJson(json);

      expect(program.sysProgramId, null);
      expect(program.companyId, null);
      expect(program.programActionIds, isEmpty);
    });

    test('should handle empty programActionIds', () {
      final json = {
        'programName': 'Test',
        'labelName': 'Label',
        'programRoute': '/test',
        'applicationId': 1,
        'programActionIds': [],
      };

      final program = ProgramModel.fromJson(json);

      expect(program.programActionIds, isEmpty);
    });

    // test('should convert to JSON correctly', () {
    //   final program = ProgramManagementModel(
    //     sysProgramId: 10,
    //     programName: 'Test',
    //     labelName: 'Label',
    //     programRoute: '/test',
    //     applicationId: 1,
    //     companyId: 5,
    //     programActionIds: [1, 2],
    //   );

    //   final json = program.toJson();

    //   expect(json['sysProgramId'], 10);
    //   expect(json['programName'], 'Test');
    //   expect(json['labelName'], 'Label');
    //   expect(json['programRoute'], '/test');
    //   expect(json['applicationId'], 1);
    //   expect(json['companyId'], 5);
    //   expect(json['programActionIds'], [1, 2]);
    // });

    test('should convert to create JSON correctly', () {
      final program = ProgramModel(
        programName: 'Test',
        labelName: 'Label',
        programRoute: '/test',
        applicationId: 1,
        programActionIds: [1, 2],
      );

      final json = program.toCreateJson();

      expect(json['programName'], 'Test');
      expect(json['label'], 'Label');
      expect(json['route'], '/test');
      expect(json['platformId'], 1);
      expect(json['companyId'], null);
      expect(json['actionIds'], [1, 2]);
    });

    test('should convert to update JSON correctly', () {
      final action1 = ProgramActionSummary(
        actionId: 1,
        actionName: 'Action 1',
        active: true,
      );
      final action2 = ProgramActionSummary(
        actionId: 2,
        actionName: 'Action 2',
        active: false,
      );

      final program = ProgramModel(
        programName: 'Test',
        labelName: 'Label',
        programRoute: '/test',
        applicationId: 1,
        active: true,
        programActionIds: [1, 2],
        actions: [action1, action2],
      );

      final json = program.toUpdateJson();

      expect(json['programName'], 'Test');
      expect(json['label'], 'Label');
      expect(json['route'], '/test');
      expect(json['platformId'], 1);
      expect(json['companyId'], null);
      expect(json['active'], true);
      expect(json['action'], isA<List>());
      expect(json['action'].length, 2);
    });

    test('should parse from JSON with actions correctly', () {
      final json = {
        'programId': 10,
        'programName': 'Dashboard',
        'label': 'Main Dashboard',
        'route': '/dashboard',
        'platformId': 1,
        'companyId': 5,
        'action': [
          {'actionId': 1, 'actionName': 'View', 'active': true},
          {'actionId': 2, 'actionName': 'Edit', 'active': false},
        ],
      };

      final program = ProgramModel.fromJson(json);

      expect(program.programActionIds, [1, 2]);
      expect(program.actions.length, 2);
      expect(program.actions[0].actionId, 1);
      expect(program.actions[0].actionName, 'View');
      expect(program.actions[1].active, false);
    });

    test('copyWith should create new instance with updated fields', () {
      final program = ProgramModel(
        programName: 'Original',
        labelName: 'Label',
        programRoute: '/original',
        applicationId: 1,
        programActionIds: [1],
      );

      final updated = program.copyWith(
        programName: 'Updated',
        programRoute: '/updated',
        programActionIds: [1, 2, 3],
      );

      expect(updated.programName, 'Updated');
      expect(updated.programRoute, '/updated');
      expect(updated.labelName, 'Label');
      expect(updated.applicationId, 1);
      expect(updated.programActionIds, [1, 2, 3]);
    });

    test('copyWith should keep original values when not specified', () {
      final program = ProgramModel(
        sysProgramId: 10,
        programName: 'Original',
        labelName: 'Label',
        programRoute: '/original',
        applicationId: 1,
        companyId: 5,
        programActionIds: [1, 2],
      );

      final updated = program.copyWith(programName: 'Updated');

      expect(updated.programName, 'Updated');
      expect(updated.sysProgramId, 10);
      expect(updated.labelName, 'Label');
      expect(updated.programRoute, '/original');
      expect(updated.applicationId, 1);
      expect(updated.companyId, 5);
      expect(updated.programActionIds, [1, 2]);
    });
  });
}
