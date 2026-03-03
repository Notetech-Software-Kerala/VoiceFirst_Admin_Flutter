import 'package:equatable/equatable.dart';

class CountryLookup extends Equatable {
  final int id;
  final String name;
  final String? divisionOneLabel;
  final String? divisionTwoLabel;
  final String? divisionThreeLabel;

  CountryLookup({
    required this.id,
    required this.name,
    this.divisionOneLabel,
    this.divisionTwoLabel,
    this.divisionThreeLabel,
  });

  factory CountryLookup.fromJson(Map<String, dynamic> json) {
    return CountryLookup(
      id: (json['countryId'] as num).toInt(),
      name: json['countryName'] ?? '',
      divisionOneLabel: json['divisionOne'] as String?,
      divisionTwoLabel: json['divisionTwo'] as String?,
      divisionThreeLabel: json['divisionThree'] as String?,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    divisionOneLabel,
    divisionTwoLabel,
    divisionThreeLabel,
  ];
}

class DivisionOneLookup extends Equatable {
  final int id;
  final String name;

  DivisionOneLookup({required this.id, required this.name});

  factory DivisionOneLookup.fromJson(Map<String, dynamic> json) {
    return DivisionOneLookup(
      id: (json['divOneId'] as num).toInt(),
      // ✅ FIXED
      name: json['divOneName'] ?? '',
    );
  }

  @override
  List<Object?> get props => [id, name];
}

class DivisionTwoLookup extends Equatable {
  final int id;
  final String name;

  DivisionTwoLookup({required this.id, required this.name});

  factory DivisionTwoLookup.fromJson(Map<String, dynamic> json) {
    return DivisionTwoLookup(
      id: (json['divTwoId'] as num).toInt(),
      name: json['divTwoName'] ?? '',
    );
  }

  @override
  List<Object?> get props => [id, name];
}

class DivisionThreeLookup extends Equatable {
  final int id;
  final String name;

  DivisionThreeLookup({required this.id, required this.name});

  factory DivisionThreeLookup.fromJson(Map<String, dynamic> json) {
    return DivisionThreeLookup(
      id: (json['divThreeId'] as num).toInt(),
      name: json['divThreeName'] ?? '',
    );
  }

  @override
  List<Object?> get props => [id, name];
}

class PostOfficeLookup extends Equatable {
  final int postOfficeId;
  final String postOfficeName;
  final List<ZipCodeLookup> zipCodes;

  PostOfficeLookup({
    required this.postOfficeId,
    required this.postOfficeName,
    required this.zipCodes,
  });

  factory PostOfficeLookup.fromJson(Map<String, dynamic> json) {
    return PostOfficeLookup(
      postOfficeId: (json['postOfficeId'] as num).toInt(),
      postOfficeName: json['postOfficeName'] ?? '',
      zipCodes: (json['zipCodes'] as List? ?? [])
          .map((e) => ZipCodeLookup.fromJson(e))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [postOfficeId, postOfficeName, zipCodes];
}

class ZipCodeLookup extends Equatable {
  final int zipCodeLinkId;
  final String zipCode;
  final bool active;

  ZipCodeLookup({
    required this.zipCodeLinkId,
    required this.zipCode,
    required this.active,
  });

  factory ZipCodeLookup.fromJson(Map<String, dynamic> json) {
    return ZipCodeLookup(
      zipCodeLinkId: (json['zipCodeLinkId'] as num).toInt(),
      zipCode: json['zipCode'] ?? '',
      active: json['active'] ?? false,
    );
  }

  @override
  List<Object?> get props => [zipCodeLinkId, zipCode, active];
}
