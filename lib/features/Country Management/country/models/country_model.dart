class CountryModel {
  final String id;
  final String country;
  final String countryCode;
  final String? countryIsoCode;
  final String? divisionOneLabel;
  final String? divisionTwoLabel;
  final String? divisionThreeLabel;
  final bool? status;

  CountryModel({
    required this.id,
    required this.country,
    required this.countryCode,
    this.countryIsoCode,
    this.divisionOneLabel,
    this.divisionTwoLabel,
    this.divisionThreeLabel,
    this.status = false,
  });

  CountryModel copyWith({
    String? id,
    String? country,
    String? countryCode,
    String? countryIsoCode,
    String? divisionOneLabel,
    String? divisionTwoLabel,
    String? divisionThreeLabel,
    bool? status,
  }) {
    return CountryModel(
      id: id ?? this.id,
      country: country ?? this.country,
      countryCode: countryCode ?? this.countryCode,
      countryIsoCode: countryIsoCode ?? this.countryIsoCode,
      divisionOneLabel: divisionOneLabel ?? this.divisionOneLabel,
      divisionTwoLabel: divisionTwoLabel ?? this.divisionTwoLabel,
      divisionThreeLabel: divisionThreeLabel ?? this.divisionThreeLabel,
      status: status ?? this.status,
    );
  }

  factory CountryModel.fromJson(Map<String, dynamic> json) {
    return CountryModel(
      id: json['id'] ?? '',
      country: json['country'] ?? '',
      countryCode: json['countryCode'] ?? '',
      countryIsoCode: json['countryIsoCode'],
      divisionOneLabel: json['divisionOneLabel'],
      divisionTwoLabel: json['divisionTwoLabel'],
      divisionThreeLabel: json['divisionThreeLabel'],
      status: json['status'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'country': country,
      'countryCode': countryCode,
      'countryIsoCode': countryIsoCode,
      'divisionOneLabel': divisionOneLabel,
      'divisionTwoLabel': divisionTwoLabel,
      'divisionThreeLabel': divisionThreeLabel,
      'status': status,
    };
  }
}
