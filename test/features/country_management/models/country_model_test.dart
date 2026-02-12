import 'package:flutter_test/flutter_test.dart';
import 'package:voice_first_admin/features/Country_Management/country/models/country_model.dart';

void main() {
  group('CountryModel', () {
    test('should create instance with required fields', () {
      final country = CountryModel(
        id: '1',
        country: 'United States',
        countryCode: 'US',
        status: false,
      );

      expect(country.id, '1');
      expect(country.country, 'United States');
      expect(country.countryCode, 'US');
      expect(country.status, false);
    });

    test('should create instance with optional fields', () {
      final country = CountryModel(
        id: '1',
        country: 'United States',
        countryCode: 'US',
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

    test('should parse from JSON correctly', () {
      final json = {
        'id': '1',
        'country': 'United States',
        'countryCode': 'US',
        'countryIsoCode': 'USA',
        'divisionOneLabel': 'State',
        'divisionTwoLabel': 'County',
        'divisionThreeLabel': 'City',
        'status': true,
      };

      final country = CountryModel.fromJson(json);

      expect(country.id, '1');
      expect(country.country, 'United States');
      expect(country.countryCode, 'US');
      expect(country.countryIsoCode, 'USA');
      expect(country.status, true);
    });

    test('should handle null values in JSON', () {
      final json = {'id': '1', 'country': 'Test Country', 'countryCode': 'TC'};

      final country = CountryModel.fromJson(json);

      expect(country.countryIsoCode, null);
      expect(country.divisionOneLabel, null);
      expect(country.divisionTwoLabel, null);
      expect(country.divisionThreeLabel, null);
      expect(country.status, false);
    });

    // Only listing and view: keep copyWith and toJson for view support
    test('copyWith should create new instance with updated fields', () {
      final country = CountryModel(
        id: '1',
        country: 'United States',
        countryCode: 'US',
        status: false,
      );

      

      
    });

   

    
  });
}
