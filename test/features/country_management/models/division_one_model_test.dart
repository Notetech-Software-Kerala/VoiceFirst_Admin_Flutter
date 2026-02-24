import 'package:flutter_test/flutter_test.dart';
import 'package:voice_first_admin/features/Country_Management/division1/models/division1_model.dart';

void main() {
  group('DivisionOneModel', () {
    test('should create instance with required fields', () {
      final model = DivisionOneModel(
        id: 1,
        countryId: 10,
        name: 'State 1',
        status: true,
      );

      expect(model.id, 1);
      expect(model.countryId, 10);
      expect(model.name, 'State 1');
      expect(model.status, true);
    });

    test('fromJson should map API fields correctly', () {
      final json = {
        'divOneId': 5,
        'countryId': 20,
        'divOneName': 'Region A',
        'active': true,
      };

      final model = DivisionOneModel.fromJson(json);

      expect(model.id, 5);
      expect(model.countryId, 20);
      expect(model.name, 'Region A');
      expect(model.status, true);
    });

    test('fromJson should use defaults for missing optional fields', () {
      final json = {'divOneId': 6, 'countryId': 30};

      final model = DivisionOneModel.fromJson(json);

      expect(model.id, 6);
      expect(model.countryId, 30);
      expect(model.name, '');
      expect(model.status, false);
    });

    test('copyWith should override provided fields only', () {
      final original = DivisionOneModel(
        id: 1,
        countryId: 10,
        name: 'Original',
        status: false,
      );

      final updated = original.copyWith(id: 2, name: 'Updated', status: true);

      expect(updated.id, 2);
      expect(updated.countryId, 10);
      expect(updated.name, 'Updated');
      expect(updated.status, true);
    });
  });
}
