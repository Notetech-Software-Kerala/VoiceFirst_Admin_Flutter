import 'package:flutter_test/flutter_test.dart';
import 'package:voice_first_admin/features/business_activity/data/models/business_activity_filter.dart';

void main() {
  group('BusinessActivityFilter', () {
    test('toQueryParams includes required pagination fields', () {
      const filter = BusinessActivityFilter(pageNumber: 2, limit: 25);

      final params = filter.toQueryParams();

      expect(params['PageNumber'], '2');
      expect(params['PageSize'], '25');
    });

    test('toQueryParams includes non-empty string fields', () {
      const filter = BusinessActivityFilter(
        pageNumber: 1,
        limit: 10,
        searchBy: 'ActivityName',
        searchText: 'test',
        sortBy: 'CreatedDate',
        sortOrder: 'Desc',
      );

      final params = filter.toQueryParams();

      expect(params['SearchBy'], 'ActivityName');
      expect(params['SearchText'], 'test');
      expect(params['SortBy'], 'CreatedDate');
      expect(params['SortOrder'], 'Desc');
    });

    test('toQueryParams skips null or empty strings', () {
      const filter = BusinessActivityFilter(
        pageNumber: 1,
        limit: 10,
        searchBy: null,
        searchText: '',
        sortBy: null,
        sortOrder: '',
      );

      final params = filter.toQueryParams();

      expect(params.containsKey('SearchBy'), isFalse);
      expect(params.containsKey('SearchText'), isFalse);
      expect(params.containsKey('SortBy'), isFalse);
      expect(params.containsKey('SortOrder'), isFalse);
    });

    test('toQueryParams encodes active/deleted flags when present', () {
      const filter = BusinessActivityFilter(
        pageNumber: 1,
        limit: 10,
        active: true,
        deleted: false,
      );

      final params = filter.toQueryParams();

      expect(params['Active'], 'true');
      expect(params['Deleted'], 'false');
    });

    test('toQueryParams encodes date filters as ISO8601 strings', () {
      final createdFrom = DateTime(2024, 1, 1);
      final createdTo = DateTime(2024, 1, 31);

      final filter = BusinessActivityFilter(
        pageNumber: 1,
        limit: 10,
        createdFromDate: createdFrom,
        createdToDate: createdTo,
      );

      final params = filter.toQueryParams();

      expect(params['CreatedFromDate'], createdFrom.toIso8601String());
      expect(params['CreatedToDate'], createdTo.toIso8601String());
    });
  });
}
