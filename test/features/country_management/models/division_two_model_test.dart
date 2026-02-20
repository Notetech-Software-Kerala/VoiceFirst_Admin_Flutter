import 'package:flutter_test/flutter_test.dart';
import 'package:voice_first_admin/features/Country_Management/division2/models/division_two_model.dart';

void main() {
  group('DivisionTwoModel', () {
    test('should create instance with required fields', () {
      final model = DivisionTwoModel(
        id: 1,
        divisionOneId: 10,
        name: 'District 1',
        status: true,
      );

      expect(model.id, 1);
      expect(model.divisionOneId, 10);
      expect(model.name, 'District 1');
      expect(model.status, true);
    });

    test('fromJson should map API fields correctly', () {
      final json = {
        'divTwoId': 5,
        'divOneId': 20,
        'divTwoName': 'Block A',
        'active': true,
      };

      final model = DivisionTwoModel.fromJson(json);

      expect(model.id, 5);
      expect(model.divisionOneId, 20);
      expect(model.name, 'Block A');
      expect(model.status, true);
    });

    test('fromJson should use defaults for missing optional fields', () {
      final json = {'divTwoId': 6, 'divOneId': 30};

      final model = DivisionTwoModel.fromJson(json);

      expect(model.id, 6);
      expect(model.divisionOneId, 30);
      expect(model.name, '');
      expect(model.status, false);
    });

    test('copyWith should override provided fields only', () {
      final original = DivisionTwoModel(
        id: 1,
        divisionOneId: 10,
        name: 'Original',
        status: false,
      );

      final updated = original.copyWith(
        id: 2,
        divisionOneId: 11,
        name: 'Updated',
        status: true,
      );

      expect(updated.id, 2);
      expect(updated.divisionOneId, 11);
      expect(updated.name, 'Updated');
      expect(updated.status, true);
    });
  });
}
