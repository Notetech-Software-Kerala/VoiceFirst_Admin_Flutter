import 'package:flutter_test/flutter_test.dart';
import 'package:voice_first_admin/features/Business_activity/models/business_activity_model.dart';

void main() {
  group('BusinessActivity Model', () {
    final testDate = DateTime(2024, 1, 1);

    test('creates instance with required fields', () {
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
      expect(activity.active, isTrue);
      expect(activity.isDeleted, isFalse);
      expect(activity.createdUser, 'admin');
      expect(activity.createdDate, testDate);
      expect(activity.modifiedUser, isNull);
      expect(activity.deletedUser, isNull);
    });

    test('parses from JSON with full data', () {
      final json = {
        'activityId': 1,
        'activityName': 'Test Activity',
        'active': true,
        'deleted': false,
        'createdUser': 'admin',
        'createdDate': '2024-01-01T00:00:00.000',
        'modifiedUser': 'user1',
        'modifiedDate': '2024-01-02T00:00:00.000',
        'deletedUser': 'deleter',
        'deletedDate': '2024-01-03T00:00:00.000',
      };

      final activity = BusinessActivity.fromJson(json);

      expect(activity.activityId, 1);
      expect(activity.activityName, 'Test Activity');
      expect(activity.active, isTrue);
      expect(activity.isDeleted, isFalse);
      expect(activity.createdUser, 'admin');
      expect(activity.modifiedUser, 'user1');
      expect(activity.modifiedDate, isNotNull);
      expect(activity.deletedUser, 'deleter');
      expect(activity.deletedDate, isNotNull);
    });

    test('treats empty modified/deleted users as null', () {
      final json = {
        'activityId': 1,
        'activityName': 'Test Activity',
        'active': true,
        'deleted': false,
        'createdUser': 'admin',
        'createdDate': '2024-01-01T00:00:00.000',
        'modifiedUser': '   ',
        'modifiedDate': null,
        'deletedUser': '',
        'deletedDate': null,
      };

      final activity = BusinessActivity.fromJson(json);

      expect(activity.modifiedUser, isNull);
      expect(activity.deletedUser, isNull);
    });

    test('handles null optional fields in JSON', () {
      final json = {
        'activityId': 1,
        'activityName': 'Test Activity',
        'active': true,
        'deleted': false,
        'createdUser': 'admin',
        'createdDate': '2024-01-01T00:00:00.000',
        'modifiedUser': null,
        'modifiedDate': null,
        'deletedUser': null,
        'deletedDate': null,
      };

      final activity = BusinessActivity.fromJson(json);

      expect(activity.modifiedUser, isNull);
      expect(activity.modifiedDate, isNull);
      expect(activity.deletedUser, isNull);
      expect(activity.deletedDate, isNull);
    });

    test('copyWith updates specified fields', () {
      final activity = BusinessActivity(
        activityId: 1,
        activityName: 'Original',
        active: true,
        isDeleted: false,
        createdUser: 'admin',
        createdDate: testDate,
      );

      final updated = activity.copyWith(
        activityName: 'Updated',
        active: false,
        isDeleted: true,
      );

      expect(updated.activityId, 1);
      expect(updated.activityName, 'Updated');
      expect(updated.active, isFalse);
      expect(updated.isDeleted, isTrue);
      expect(updated.createdUser, 'admin');
      expect(updated.createdDate, testDate);
    });

    test('copyWith keeps original values when not specified', () {
      final activity = BusinessActivity(
        activityId: 1,
        activityName: 'Original',
        active: true,
        isDeleted: false,
        createdUser: 'admin',
        createdDate: testDate,
        deletedUser: 'deleter',
        deletedDate: testDate,
      );

      final updated = activity.copyWith(activityName: 'Updated');

      expect(updated.activityId, activity.activityId);
      expect(updated.activityName, 'Updated');
      expect(updated.active, activity.active);
      expect(updated.isDeleted, activity.isDeleted);
      expect(updated.deletedUser, activity.deletedUser);
      expect(updated.deletedDate, activity.deletedDate);
    });

    test('copyWith with clearDeletedMeta clears deleted metadata', () {
      final activity = BusinessActivity(
        activityId: 1,
        activityName: 'Test Activity',
        active: true,
        isDeleted: true,
        createdUser: 'admin',
        createdDate: testDate,
        deletedUser: 'admin',
        deletedDate: testDate,
      );

      final updated = activity.copyWith(
        isDeleted: false,
        clearDeletedMeta: true,
      );

      expect(updated.isDeleted, isFalse);
      expect(updated.deletedUser, isNull);
      expect(updated.deletedDate, isNull);
      expect(updated.activityId, activity.activityId);
      expect(updated.activityName, activity.activityName);
    });
  });
}
