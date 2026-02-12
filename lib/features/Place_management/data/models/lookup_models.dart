class CountryLookup {
  final int id;
  final String name;

  CountryLookup({required this.id, required this.name});

  factory CountryLookup.fromJson(Map<String, dynamic> json) {
    return CountryLookup(
      id: (json['countryId'] as num).toInt(),
      name: json['countryName'] ?? '',
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
  final int id;
  final String name;

  PostOfficeLookup({required this.id, required this.name});

  factory PostOfficeLookup.fromJson(Map<String, dynamic> json) {
    return PostOfficeLookup(
      id: (json['postOfficeId'] as num).toInt(),
      name: json['postOfficeName'] ?? '',
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
