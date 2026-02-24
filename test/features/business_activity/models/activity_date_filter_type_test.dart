import 'package:flutter_test/flutter_test.dart';
import 'package:voice_first_admin/features/Business_activity/models/activity_date_filter_type.dart';

void main() {
  group('ActivityDateType enum', () {
    test('label maps correctly for all values', () {
      expect(ActivityDateType.created.label, 'Created Date');
      expect(ActivityDateType.updated.label, 'Updated Date');
      expect(ActivityDateType.deleted.label, 'Deleted Date');
    });
  });
}
