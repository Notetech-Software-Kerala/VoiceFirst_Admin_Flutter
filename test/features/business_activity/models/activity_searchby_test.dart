import 'package:flutter_test/flutter_test.dart';
import 'package:voice_first_admin/features/Business_activity/models/activity_searchby.dart';

void main() {
  group('ActivitySearchBy enum', () {
    test('apiValue maps correctly for all values', () {
      expect(ActivitySearchBy.activityName.apiValue, 'ActivityName');
      expect(ActivitySearchBy.createdUser.apiValue, 'CreatedUser');
      expect(ActivitySearchBy.updatedUser.apiValue, 'UpdatedUser');
      expect(ActivitySearchBy.deletedUser.apiValue, 'DeletedUser');
    });

    test('label maps correctly for all values', () {
      expect(ActivitySearchBy.activityName.label, 'Activity Name');
      expect(ActivitySearchBy.createdUser.label, 'Created User');
      expect(ActivitySearchBy.updatedUser.label, 'Updated User');
      expect(ActivitySearchBy.deletedUser.label, 'Deleted User');
    });
  });
}
