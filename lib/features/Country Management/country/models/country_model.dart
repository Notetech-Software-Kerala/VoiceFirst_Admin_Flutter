class CountryModel {
  final String id;
  final String country;
  final String countryCode;
  final String? countryIsoCode;
  final String? divisionOneLabel;
  final String? divisionTwoLabel;
  final String? divisionThreeLabel;
  final bool status;

  CountryModel({
    required this.id,
    required this.country,
    required this.countryCode,
    this.countryIsoCode,
    this.divisionOneLabel,
    this.divisionTwoLabel,
    this.divisionThreeLabel,
    required this.status,
  });

  factory CountryModel.fromJson(Map<String, dynamic> json) {
    return CountryModel(
      id: json['countryId'].toString(),
      country: json['countryName'] ?? '',
      countryCode: json['dialCode'] ?? '',
      countryIsoCode: json['isoAlphaTwo'],
      divisionOneLabel: json['divisionOne'],
      divisionTwoLabel: json['divisionTwo'],
      divisionThreeLabel: json['divisionThree'],
      status: json['active'] ?? false,
    );
  }
}
