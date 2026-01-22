import 'package:flutter_test/flutter_test.dart';
import 'package:voice_first_admin/features/Country%20Management/country/models/country_model.dart';

void main() {
  group('CountryModel', () {
    test('should create instance with required fields', () {
      final country = CountryModel(
        id: '1',
        country: 'United States',
        countryCode: 'US',
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

    test('copyWith should create new instance with updated fields', () {
      final country = CountryModel(
        id: '1',
        country: 'United States',
        countryCode: 'US',
      );

      final updated = country.copyWith(
        country: 'Canada',
        countryCode: 'CA',
        status: true,
      );

      expect(updated.id, '1');
      expect(updated.country, 'Canada');
      expect(updated.countryCode, 'CA');
      expect(updated.status, true);
    });

    test('copyWith should keep original values when not specified', () {
      final country = CountryModel(
        id: '1',
        country: 'United States',
        countryCode: 'US',
        divisionOneLabel: 'State',
      );

      final updated = country.copyWith(country: 'USA');

      expect(updated.id, country.id);
      expect(updated.country, 'USA');
      expect(updated.countryCode, country.countryCode);
      expect(updated.divisionOneLabel, country.divisionOneLabel);
    });

    test('toJson should convert to map correctly', () {
      final country = CountryModel(
        id: '1',
        country: 'United States',
        countryCode: 'US',
        countryIsoCode: 'USA',
        status: true,
      );

      final json = country.toJson();

      expect(json['id'], '1');
      expect(json['country'], 'United States');
      expect(json['countryCode'], 'US');
      expect(json['countryIsoCode'], 'USA');
      expect(json['status'], true);
    });
  });
}
