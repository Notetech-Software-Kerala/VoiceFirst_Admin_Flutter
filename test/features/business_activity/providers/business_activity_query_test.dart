import 'package:flutter_test/flutter_test.dart';
import 'package:voice_first_admin/features/Business_activity/models/activity_searchby.dart';
import 'package:voice_first_admin/features/Business_activity/models/business_activity_filter.dart';
import 'package:voice_first_admin/features/Business_activity/presentation/providers/business_activity_query.dart';

void main() {
  group('BusinessActivityQuery', () {
    test('initial factory uses default values', () {
      final query = BusinessActivityQuery.initial();

      expect(query.pageNumber, 1);
      expect(query.limit, 10);
      expect(query.searchBy, isNull);
      expect(query.searchText, isNull);
      expect(query.active, isNull);
      expect(query.deleted, isNull);
    });

    test('toApiFilter maps fields correctly', () {
      const query = BusinessActivityQuery(
        searchBy: ActivitySearchBy.activityName,
        searchText: 'abc',
        sortBy: 'CreatedDate',
        sortOrder: 'Desc',
        active: true,
        deleted: false,
        pageNumber: 3,
        limit: 50,
      );

      final BusinessActivityFilter filter = query.toApiFilter();

      final params = filter.toQueryParams();

      expect(params['SearchBy'], ActivitySearchBy.activityName.apiValue);
      expect(params['SearchText'], 'abc');
      expect(params['SortBy'], 'CreatedDate');
      expect(params['SortOrder'], 'Desc');
      expect(params['Active'], 'true');
      expect(params['Deleted'], 'false');
      expect(params['PageNumber'], '3');
      expect(params['PageSize'], '50');
    });

    test('copyWith updates provided fields and keeps others', () {
      const original = BusinessActivityQuery(
        searchBy: ActivitySearchBy.activityName,
        searchText: 'name',
        active: true,
        deleted: false,
        pageNumber: 1,
        limit: 10,
      );

      final copy = original.copyWith(searchText: 'updated', pageNumber: 2);

      expect(copy.searchBy, ActivitySearchBy.activityName);
      expect(copy.searchText, 'updated');
      expect(copy.active, isTrue);
      expect(copy.deleted, isFalse);
      expect(copy.pageNumber, 2);
      expect(copy.limit, 10);
    });
  });
}
