import 'package:flutter_test/flutter_test.dart';
import 'package:voice_first_admin/features/Program_management/data/models/create_program_request.dart';

void main() {
  group('CreateProgramRequest', () {
    test('toJson should map all fields correctly', () {
      final request = CreateProgramRequest(
        programName: 'Program',
        label: 'Label',
        route: '/program',
        platformId: 1,
        companyId: 42,
        actionIds: const [1, 2, 3],
      );

      final json = request.toJson();

      expect(json['programName'], 'Program');
      expect(json['label'], 'Label');
      expect(json['route'], '/program');
      expect(json['platformId'], 1);
      expect(json['companyId'], 42);
      expect(json['actionIds'], [1, 2, 3]);
    });
  });
}
