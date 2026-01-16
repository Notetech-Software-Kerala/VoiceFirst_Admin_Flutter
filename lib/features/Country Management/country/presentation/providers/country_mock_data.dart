import 'package:voice_first_admin/features/Country%20Management/country/models/country_model.dart';

final mockCountries = <CountryModel>[
  CountryModel(
    id: '1',
    country: 'India',
    countryCode: '+91',
    countryIsoCode: 'IN',
    divisionOneLabel: 'State',
    divisionTwoLabel: 'District',
    divisionThreeLabel: 'City',
    status: true,
  ),
  CountryModel(
    id: '2',
    country: 'United States',
    countryCode: '+1',
    countryIsoCode: 'US',
    divisionOneLabel: 'State',
    divisionTwoLabel: 'County',
    divisionThreeLabel: 'City',
    status: true,
  ),
  CountryModel(
    id: '3',
    country: 'Germany',
    countryCode: '+49',
    countryIsoCode: 'DE',
    status: false,
  ),
];
