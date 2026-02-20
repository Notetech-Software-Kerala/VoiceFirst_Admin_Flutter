import 'package:flutter_test/flutter_test.dart';
import 'package:voice_first_admin/features/Program_management/models/program_management_model.dart';
import 'package:voice_first_admin/features/Program_management/models/update_program_request.dart';

void main() {
  group('UpdateProgramRequest.toJson', () {
    test('includes only provided scalar fields when no action changes', () {
      final originalActions = [
        const ProgramActionSummary(
          actionId: 1,
          actionName: 'View',
          active: true,
        ),
        const ProgramActionSummary(
          actionId: 2,
          actionName: 'Edit',
          active: false,
        ),
      ];

      final request = UpdateProgramRequest(
        programName: 'Updated Program',
        label: 'Updated Label',
        route: '/updated',
        platformId: 2,
        companyId: 10,
        active: true,
        originalActions: originalActions,
        selectedActionIds: const {1}, // same active state as original
      );

      final json = request.toJson();

      expect(json['programName'], 'Updated Program');
      expect(json['label'], 'Updated Label');
      expect(json['route'], '/updated');
      expect(json['platformId'], 2);
      expect(json['companyId'], 10);
      expect(json['active'], true);
      expect(json.containsKey('updateActions'), isFalse);
      expect(json.containsKey('insertActions'), isFalse);
    });

    test('creates updateActions when existing action active flags change', () {
      final originalActions = [
        const ProgramActionSummary(
          actionId: 1,
          actionName: 'View',
          active: false,
        ),
        const ProgramActionSummary(
          actionId: 2,
          actionName: 'Edit',
          active: true,
        ),
      ];

      // Now select only action 1 -> it should become active, action 2 inactive
      final request = UpdateProgramRequest(
        originalActions: originalActions,
        selectedActionIds: const {1},
      );

      final json = request.toJson();

      final updates = json['updateActions'] as List<dynamic>;
      expect(updates.length, 2);

      final update1 = updates.firstWhere((e) => e['actionId'] == 1) as Map;
      final update2 = updates.firstWhere((e) => e['actionId'] == 2) as Map;

      expect(update1['active'], true);
      expect(update2['active'], false);
      expect(json.containsKey('insertActions'), isFalse);
    });

    test('creates insertActions for brand new selected actions', () {
      final originalActions = [
        const ProgramActionSummary(
          actionId: 1,
          actionName: 'View',
          active: true,
        ),
      ];

      // Newly selected 2 and 3 should appear as inserts
      final request = UpdateProgramRequest(
        originalActions: originalActions,
        selectedActionIds: const {1, 2, 3},
      );

      final json = request.toJson();

      expect(json.containsKey('updateActions'), isFalse);
      final inserts = json['insertActions'] as List<dynamic>;
      expect(inserts.toSet(), {2, 3});
    });
  });
}
