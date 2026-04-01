import 'package:flutter_test/flutter_test.dart';
import 'package:voice_first_admin/features/country_management/country/data/models/country_filter.dart';

void main() {
  group('CountryFilter', () {
    test('copyWith should override provided values', () {
      const filter = CountryFilter(
        pageNumber: 1,
        pageSize: 10,
        searchText: 'a',
      );

      final updated = filter.copyWith(
        pageNumber: 2,
        pageSize: 20,
        searchText: 'b',
      );

      expect(updated.pageNumber, 2);
      expect(updated.pageSize, 20);
      expect(updated.searchText, 'b');
    });

    test('copyWith should keep original values when not specified', () {
      const filter = CountryFilter(
        pageNumber: 1,
        pageSize: 10,
        searchText: 'a',
      );

      final updated = filter.copyWith();

      expect(updated.pageNumber, 1);
      expect(updated.pageSize, 10);
      expect(updated.searchText, 'a');
    });

    test('toQueryParams without searchText', () {
      const filter = CountryFilter(pageNumber: 2, pageSize: 25);

      final params = filter.toQueryParams();

      expect(params['PageNumber'], '2');
      expect(params['PageSize'], '25');
      expect(params.containsKey('SearchText'), isFalse);
    });

    test('toQueryParams with searchText', () {
      const filter = CountryFilter(
        pageNumber: 3,
        pageSize: 50,
        searchText: 'test',
      );

      final params = filter.toQueryParams();

      expect(params['PageNumber'], '3');
      expect(params['PageSize'], '50');
      expect(params['SearchText'], 'test');
    });

    test('toQueryParams should ignore empty searchText', () {
      const filter = CountryFilter(pageNumber: 1, pageSize: 10, searchText: '');

      final params = filter.toQueryParams();

      expect(params['PageNumber'], '1');
      expect(params['PageSize'], '10');
      expect(params.containsKey('SearchText'), isFalse);
    });
  });
}
