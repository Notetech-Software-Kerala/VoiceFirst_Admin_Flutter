import 'package:flutter_test/flutter_test.dart';
import 'package:voice_first_admin/features/Country_Management/country/data/models/country_model.dart';

void main() {
  group('CountryModel', () {
    test('should create instance with required fields', () {
      final country = CountryModel(
        id: 1,
        country: 'United States',
        countryCode: '+1',
        status: false,
      );

      expect(country.id, 1);
      expect(country.country, 'United States');
      expect(country.countryCode, '+1');
      expect(country.status, false);
      expect(country.countryIsoCode, isNull);
      expect(country.divisionOneLabel, isNull);
      expect(country.divisionTwoLabel, isNull);
      expect(country.divisionThreeLabel, isNull);
    });

    test('should create instance with optional fields', () {
      final country = CountryModel(
        id: 1,
        country: 'United States',
        countryCode: '+1',
        countryIsoCode: 'USA',
        divisionOneLabel: 'State',
        divisionTwoLabel: 'County',
        divisionThreeLabel: 'City',
        status: true,
      );

      expect(country.countryIsoCode, 'USA');
      expect(country.divisionOneLabel, 'State');
      expect(country.divisionTwoLabel, 'County');
      expect(country.divisionThreeLabel, 'City');
      expect(country.status, true);
    });

    test('should parse from JSON with all fields', () {
      final json = {
        'countryId': 1,
        'countryName': 'United States',
        'dialCode': '+1',
        'isoAlphaTwo': 'US',
        'divisionOne': 'State',
        'divisionTwo': 'County',
        'divisionThree': 'City',
        'active': true,
      };

      final country = CountryModel.fromJson(json);

      expect(country.id, 1);
      expect(country.country, 'United States');
      expect(country.countryCode, '+1');
      expect(country.countryIsoCode, 'US');
      expect(country.divisionOneLabel, 'State');
      expect(country.divisionTwoLabel, 'County');
      expect(country.divisionThreeLabel, 'City');
      expect(country.status, true);
    });

    test('should handle missing optional values in JSON', () {
      final json = {
        'countryId': 2,
        'countryName': 'Test Country',
        'dialCode': '+999',
      };

      final country = CountryModel.fromJson(json);

      expect(country.id, 2);
      expect(country.country, 'Test Country');
      expect(country.countryCode, '+999');
      expect(country.countryIsoCode, isNull);
      expect(country.divisionOneLabel, isNull);
      expect(country.divisionTwoLabel, isNull);
      expect(country.divisionThreeLabel, isNull);
      expect(country.status, false);
    });
  });
}
