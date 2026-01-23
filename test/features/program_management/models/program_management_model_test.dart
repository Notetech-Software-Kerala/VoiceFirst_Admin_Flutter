import 'package:flutter_test/flutter_test.dart';
import 'package:voice_first_admin/features/Program_management/models/program_management_model.dart';

void main() {
  group('ProgramManagementModel', () {
    test('should create instance with required fields', () {
      final program = ProgramManagementModel(
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
      final program = ProgramManagementModel(
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

      final program = ProgramManagementModel.fromJson(json);

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

      final program = ProgramManagementModel.fromJson(json);

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

      final program = ProgramManagementModel.fromJson(json);

      expect(program.programActionIds, isEmpty);
    });

    test('should convert to JSON correctly', () {
      final program = ProgramManagementModel(
        sysProgramId: 10,
        programName: 'Test',
        labelName: 'Label',
        programRoute: '/test',
        applicationId: 1,
        companyId: 5,
        programActionIds: [1, 2],
      );

      final json = program.toJson();

      expect(json['sysProgramId'], 10);
      expect(json['programName'], 'Test');
      expect(json['labelName'], 'Label');
      expect(json['programRoute'], '/test');
      expect(json['applicationId'], 1);
      expect(json['companyId'], 5);
      expect(json['programActionIds'], [1, 2]);
    });

    test('copyWith should create new instance with updated fields', () {
      final program = ProgramManagementModel(
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
      final program = ProgramManagementModel(
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
