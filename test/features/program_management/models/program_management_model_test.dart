import 'package:flutter_test/flutter_test.dart';
import 'package:voice_first_admin/features/Program_management/models/program_management_model.dart';

void main() {
  group('ProgramActionSummary', () {
    test('fromJson maps fields and handles defaults', () {
      final json = {
        'actionId': 1,
        'actionName': 'View',
        'active': true,
        'createdUser': 'creator',
        'createdDate': '2024-01-01T00:00:00Z',
        'modifiedUser': '',
        'modifiedDate': null,
      };

      final action = ProgramActionSummary.fromJson(json);

      expect(action.actionId, 1);
      expect(action.actionName, 'View');
      expect(action.active, true);
      expect(action.createdUser, 'creator');
      expect(action.createdDate, isA<DateTime>());
      // empty string becomes null
      expect(action.modifiedUser, isNull);
      expect(action.modifiedDate, isNull);
    });
  });

  group('ProgramModel', () {
    test('constructor sets required and optional fields', () {
      final model = ProgramModel(
        sysProgramId: 10,
        programName: 'Dashboard',
        labelName: 'Main Dashboard',
        programRoute: '/dashboard',
        applicationId: 1,
        companyId: 5,
        active: true,
        deleted: false,
        platformName: 'Web',
        companyName: 'Acme',
        createdUser: 'creator',
        createdDate: DateTime(2024, 1, 1),
        modifiedUser: 'editor',
        modifiedDate: DateTime(2024, 1, 2),
        deletedUser: null,
        deletedDate: null,
        actions: const [
          ProgramActionSummary(actionId: 1, actionName: 'View', active: true),
        ],
      );

      expect(model.sysProgramId, 10);
      expect(model.programName, 'Dashboard');
      expect(model.labelName, 'Main Dashboard');
      expect(model.programRoute, '/dashboard');
      expect(model.applicationId, 1);
      expect(model.companyId, 5);
      expect(model.active, true);
      expect(model.deleted, false);
      expect(model.platformName, 'Web');
      expect(model.companyName, 'Acme');
      expect(model.createdUser, 'creator');
      expect(model.createdDate, DateTime(2024, 1, 1));
      expect(model.modifiedUser, 'editor');
      expect(model.modifiedDate, DateTime(2024, 1, 2));
      expect(model.deletedUser, isNull);
      expect(model.deletedDate, isNull);
      expect(model.actions.length, 1);
    });

    test('fromJson maps API fields and actions correctly', () {
      final json = {
        'programId': 10,
        'programName': 'Dashboard',
        'label': 'Main Dashboard',
        'route': '/dashboard',
        'platformId': 1,
        'companyId': 5,
        'active': true,
        'deleted': false,
        'platformName': 'Web',
        'companyName': 'Acme',
        'createdUser': ' creator ',
        'createdDate': '2024-01-01T00:00:00Z',
        'modifiedUser': '',
        'modifiedDate': null,
        'deletedUser': ' ',
        'deletedDate': null,
        'action': [
          {'actionId': 1, 'actionName': 'View', 'active': true},
          {'actionId': 2, 'actionName': 'Edit', 'active': false},
        ],
      };

      final program = ProgramModel.fromJson(json);

      expect(program.sysProgramId, 10);
      expect(program.programName, 'Dashboard');
      expect(program.labelName, 'Main Dashboard');
      expect(program.programRoute, '/dashboard');
      expect(program.applicationId, 1);
      expect(program.companyId, 5);
      expect(program.active, true);
      expect(program.deleted, false);
      expect(program.platformName, 'Web');
      expect(program.companyName, 'Acme');
      expect(program.createdUser, 'creator');
      expect(program.createdDate, isA<DateTime>());
      // empty/whitespace should become null
      expect(program.modifiedUser, isNull);
      expect(program.deletedUser, isNull);
      expect(program.actions.length, 2);
      expect(program.actions[0].actionId, 1);
      expect(program.actions[0].actionName, 'View');
      expect(program.actions[1].active, false);
      expect(program.activeActionIds, [1]);
    });

    test('fromJson handles missing optional fields and no actions', () {
      final json = {
        'programName': 'Test',
        'label': 'Label',
        'route': '/test',
        'platformId': 1,
      };

      final program = ProgramModel.fromJson(json);

      expect(program.sysProgramId, isNull);
      expect(program.companyId, isNull);
      expect(program.active, isNull);
      expect(program.deleted, isNull);
      expect(program.platformName, isNull);
      expect(program.companyName, isNull);
      expect(program.actions, isEmpty);
      expect(program.activeActionIds, isEmpty);
    });

    test('copyWith creates updated instance and keeps others', () {
      final original = ProgramModel(
        sysProgramId: 1,
        programName: 'Original',
        labelName: 'Label',
        programRoute: '/original',
        applicationId: 1,
        companyId: 5,
        active: true,
        deleted: false,
        platformName: 'Web',
        companyName: 'Acme',
        actions: const [
          ProgramActionSummary(actionId: 1, actionName: 'View', active: true),
        ],
      );

      final updated = original.copyWith(
        programName: 'Updated',
        programRoute: '/updated',
        actions: const [
          ProgramActionSummary(actionId: 2, actionName: 'Edit', active: false),
        ],
      );

      expect(updated.programName, 'Updated');
      expect(updated.programRoute, '/updated');
      expect(updated.sysProgramId, 1);
      expect(updated.labelName, 'Label');
      expect(updated.applicationId, 1);
      expect(updated.companyId, 5);
      expect(updated.actions.length, 1);
      expect(updated.actions[0].actionId, 2);

      // original unchanged
      expect(original.programName, 'Original');
      expect(original.programRoute, '/original');
      expect(original.actions[0].actionId, 1);
    });

    test('activeActionIds returns only active ones in order', () {
      final model = ProgramModel(
        programName: 'Test',
        labelName: 'Label',
        programRoute: '/test',
        applicationId: 1,
        actions: const [
          ProgramActionSummary(actionId: 2, actionName: 'Edit', active: false),
          ProgramActionSummary(actionId: 1, actionName: 'View', active: true),
          ProgramActionSummary(actionId: 3, actionName: 'Delete', active: true),
        ],
      );

      expect(model.activeActionIds, [1, 3]);
    });
  });
}
