import 'package:flutter_test/flutter_test.dart';
import 'package:voice_first_admin/features/Country%20Management/country/models/country_model.dart';
import 'package:voice_first_admin/features/Country%20Management/country/presentation/providers/country_state.dart';

void main() {
  group('CountryState', () {
    final mockCountries = [
      CountryModel(id: '1', country: 'USA', countryCode: 'US', status: true),
      CountryModel(id: '2', country: 'Canada', countryCode: 'CA', status: true),
      CountryModel(
        id: '3',
        country: 'Mexico',
        countryCode: 'MX',
        status: false,
      ),
    ];

    test('initial state should be created with default values', () {
      final state = CountryState.initial();
      expect(state.countries, isEmpty);
      expect(state.filtered, isEmpty);
      expect(state.search, '');
      expect(state.isLoading, false);
      expect(state.hasMoreData, true);
      expect(state.currentPage, 1);
      expect(state.totalCount, 0);
      expect(state.totalPages, 1);
      expect(state.error, null);
    });

    test('copyWith should create new state with updated fields', () {
      final state = CountryState(
        countries: mockCountries,
        filtered: mockCountries,
        search: '',
        isLoading: false,
        hasMoreData: true,
        currentPage: 1,
        totalCount: 3,
        totalPages: 1,
        error: null,
      );
      final filteredList = [mockCountries[0]];

      final newState = state.copyWith(
        filtered: filteredList,
        isLoading: true,
        currentPage: 2,
        error: 'Some error',
      );

      expect(newState.countries, mockCountries);
      expect(newState.filtered, filteredList);
      expect(newState.isLoading, true);
      expect(newState.currentPage, 2);
      expect(newState.error, 'Some error');
    });

    test('copyWith should keep original values when not specified', () {
      final state = CountryState(
        countries: mockCountries,
        filtered: mockCountries,
        search: 'abc',
        isLoading: false,
        hasMoreData: true,
        currentPage: 1,
        totalCount: 3,
        totalPages: 1,
        error: null,
      );

      final newState = state.copyWith();

      expect(newState.countries, mockCountries);
      expect(newState.filtered, mockCountries);
      expect(newState.search, 'abc');
      expect(newState.isLoading, false);
      expect(newState.hasMoreData, true);
      expect(newState.currentPage, 1);
      expect(newState.totalCount, 3);
      expect(newState.totalPages, 1);
      expect(newState.error, null);
    });
  });
}
