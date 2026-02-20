class CountryLookup {
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
}

class DivisionOneLookup {
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
}

class DivisionTwoLookup {
  final int id;
  final String name;

  DivisionTwoLookup({required this.id, required this.name});

  factory DivisionTwoLookup.fromJson(Map<String, dynamic> json) {
    return DivisionTwoLookup(
      id: (json['divTwoId'] as num).toInt(),
      name: json['divTwoName'] ?? '',
    );
  }
}

class DivisionThreeLookup {
  final int id;
  final String name;

  DivisionThreeLookup({required this.id, required this.name});

  factory DivisionThreeLookup.fromJson(Map<String, dynamic> json) {
    return DivisionThreeLookup(
      id: (json['divThreeId'] as num).toInt(),
      name: json['divThreeName'] ?? '',
    );
  }
}


class PostOfficeLookup {
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
}

class ZipCodeLookup {
  final int zipCodeLinkId;
  final String zipCode;

  ZipCodeLookup({required this.zipCodeLinkId, required this.zipCode});

  factory ZipCodeLookup.fromJson(Map<String, dynamic> json) {
    return ZipCodeLookup(
      zipCodeLinkId: (json['zipCodeLinkId'] as num).toInt(),
      zipCode: json['zipCode'] ?? '',
    );
  }
}
