import 'package:flutter_test/flutter_test.dart';
import 'package:voice_first_admin/features/Country_Management/division1/data/models/division1_filter.dart';

void main() {
  group('DivisionOneFilter', () {
    test('copyWith should override provided values', () {
      const filter = DivisionOneFilter(
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
      const filter = DivisionOneFilter(
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
      const filter = DivisionOneFilter(pageNumber: 2, pageSize: 25);

      final params = filter.toQueryParams(99);

      expect(params['PageNumber'], '2');
      expect(params['PageSize'], '25');
      expect(params['countryId'], '99');
      expect(params.containsKey('SearchText'), isFalse);
    });

    test('toQueryParams with searchText', () {
      const filter = DivisionOneFilter(
        pageNumber: 3,
        pageSize: 50,
        searchText: 'test',
      );

      final params = filter.toQueryParams(5);

      expect(params['PageNumber'], '3');
      expect(params['PageSize'], '50');
      expect(params['countryId'], '5');
      expect(params['SearchText'], 'test');
    });

    test('toQueryParams should ignore empty searchText', () {
      const filter = DivisionOneFilter(
        pageNumber: 1,
        pageSize: 10,
        searchText: '',
      );

      final params = filter.toQueryParams(7);

      expect(params['PageNumber'], '1');
      expect(params['PageSize'], '10');
      expect(params['countryId'], '7');
      expect(params.containsKey('SearchText'), isFalse);
    });
  });
}
