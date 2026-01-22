import 'package:flutter_test/flutter_test.dart';
import 'package:voice_first_admin/features/Business_activity/models/business_activity_model.dart';

void main() {
  group('BusinessActivity Model', () {
    final testDate = DateTime(2024, 1, 1);

    test('should create instance with required fields', () {
      final activity = BusinessActivity(
        activityId: 1,
        activityName: 'Test Activity',
        active: true,
        isDeleted: false,
        createdUser: 'admin',
        createdDate: testDate,
      );

      expect(activity.activityId, 1);
      expect(activity.activityName, 'Test Activity');
      expect(activity.active, true);
      expect(activity.isDeleted, false);
      expect(activity.createdUser, 'admin');
      expect(activity.createdDate, testDate);
    });

    test('should parse from JSON correctly', () {
      final json = {
        'id': 1,
        'name': 'Test Activity',
        'active': true,
        'delete': false,
        'createdUser': 'admin',
        'createdDate': '2024-01-01T00:00:00.000',
        'modifiedUser': 'user1',
        'modifiedDate': '2024-01-02T00:00:00.000',
      };

      final activity = BusinessActivity.fromJson(json);

      expect(activity.activityId, 1);
      expect(activity.activityName, 'Test Activity');
      expect(activity.active, true);
      expect(activity.isDeleted, false);
      expect(activity.createdUser, 'admin');
      expect(activity.modifiedUser, 'user1');
    });

    test('should handle null optional fields in JSON', () {
      final json = {
        'id': 1,
        'name': 'Test Activity',
        'active': true,
        'delete': false,
        'createdUser': 'admin',
        'createdDate': '2024-01-01T00:00:00.000',
        'modifiedUser': null,
        'modifiedDate': null,
        'deletedUser': null,
        'deletedDate': null,
      };

      final activity = BusinessActivity.fromJson(json);

      expect(activity.modifiedUser, null);
      expect(activity.modifiedDate, null);
      expect(activity.deletedUser, null);
      expect(activity.deletedDate, null);
    });

    test('copyWith should create new instance with updated fields', () {
      final activity = BusinessActivity(
        activityId: 1,
        activityName: 'Original',
        active: true,
        isDeleted: false,
        createdUser: 'admin',
        createdDate: testDate,
      );

      final updated = activity.copyWith(activityName: 'Updated', active: false);

      expect(updated.activityId, 1);
      expect(updated.activityName, 'Updated');
      expect(updated.active, false);
      expect(updated.createdUser, 'admin');
      expect(updated.createdDate, testDate);
    });

    test('copyWith should keep original values when not specified', () {
      final activity = BusinessActivity(
        activityId: 1,
        activityName: 'Original',
        active: true,
        isDeleted: false,
        createdUser: 'admin',
        createdDate: testDate,
      );

      final updated = activity.copyWith(activityName: 'Updated');

      expect(updated.activityId, activity.activityId);
      expect(updated.active, activity.active);
      expect(updated.isDeleted, activity.isDeleted);
    });
  });
}
