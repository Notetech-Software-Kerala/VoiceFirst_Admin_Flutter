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

    test('initial state should be created with provided countries', () {
      final state = CountryState.initial(mockCountries);

      expect(state.countries, mockCountries);
      expect(state.filtered, mockCountries);
      expect(state.selectedIds, isEmpty);
      expect(state.isMultiSelect, false);
    });

    test('copyWith should create new state with updated fields', () {
      final state = CountryState.initial(mockCountries);
      final filteredList = [mockCountries[0]];

      final newState = state.copyWith(
        filtered: filteredList,
        isMultiSelect: true,
      );

      expect(newState.countries, mockCountries);
      expect(newState.filtered, filteredList);
      expect(newState.isMultiSelect, true);
      expect(newState.selectedIds, isEmpty);
    });

    test('copyWith should keep original values when not specified', () {
      final state = CountryState(
        countries: mockCountries,
        filtered: mockCountries,
        selectedIds: {'1', '2'},
        isMultiSelect: true,
      );

      final newState = state.copyWith(isMultiSelect: false);

      expect(newState.countries, mockCountries);
      expect(newState.filtered, mockCountries);
      expect(newState.selectedIds, {'1', '2'});
      expect(newState.isMultiSelect, false);
    });

    test('should handle selectedIds updates', () {
      final state = CountryState.initial(mockCountries);
      final newState = state.copyWith(selectedIds: {'1', '2'});

      expect(newState.selectedIds, {'1', '2'});
      expect(newState.selectedIds.length, 2);
    });

    test('should handle empty selectedIds', () {
      final state = CountryState(
        countries: mockCountries,
        filtered: mockCountries,
        selectedIds: {'1', '2'},
        isMultiSelect: true,
      );

      final newState = state.copyWith(selectedIds: <String>{});

      expect(newState.selectedIds, isEmpty);
    });

    test('should handle multi-select mode', () {
      final state = CountryState.initial(mockCountries);

      final multiSelectOn = state.copyWith(isMultiSelect: true);
      expect(multiSelectOn.isMultiSelect, true);

      final multiSelectOff = multiSelectOn.copyWith(isMultiSelect: false);
      expect(multiSelectOff.isMultiSelect, false);
    });
  });
}
