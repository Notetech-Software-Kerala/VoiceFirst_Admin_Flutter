class PostOfficeZipCode {
  final int id;
  final String code;
  final bool active;

  PostOfficeZipCode({
    required this.id,
    required this.code,
    required this.active,
  });

  factory PostOfficeZipCode.fromJson(Map<String, dynamic> json) {
    return PostOfficeZipCode(
      id: json['zipCodeId'] ?? 0,
      code: json['zipCode'] ?? '',
      active: json['active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {"zipCodeId": id, "zipCode": code, "active": active};
  }
}

class PostOffice {
  final int id;
  final String name;
  final String countryName;
  final int countryId;
  final String countryIso;
  final bool isActive;
  final List<PostOfficeZipCode> zipCodes;

  PostOffice({
    required this.id,
    required this.name,
    required this.countryName,
    required this.countryId,
    required this.countryIso,
    required this.isActive,
    required this.zipCodes,
  });

  factory PostOffice.fromJson(Map<String, dynamic> json) {
    return PostOffice(
      id: json['postOfficeId'] ?? 0,
      name: json['postOfficeName'] ?? 'Unknown Name',
      countryName: json['countryName'] ?? 'Unknown Country',
      countryId: json['countryId'] ?? 0,
      countryIso: json['isoAlphaTwo'] ?? '',
      isActive: json['active'] ?? true,
      zipCodes:
          (json['zipCodes'] as List<dynamic>?)
              ?.map((e) => PostOfficeZipCode.fromJson(e))
              .toList() ??
          [],
    );
  }

  // Helper for flag generation
  String get flag {
    if (countryIso.length != 2) return "🌐";
    int flagOffset = 0x1F1E6;
    int asciiOffset = 0x41;
    String firstChar = String.fromCharCode(
      countryIso.codeUnitAt(0) - asciiOffset + flagOffset,
    );
    String secondChar = String.fromCharCode(
      countryIso.codeUnitAt(1) - asciiOffset + flagOffset,
    );
    return firstChar + secondChar;
  }
}

class Country {
  final int id;
  final String name;
  final String isoCode; // e.g., "US", "IN"
  final String dialCode;

  Country({
    required this.id,
    required this.name,
    required this.isoCode,
    required this.dialCode,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      id: json['countryId'],
      name: json['countryName'],
      isoCode: json['isoAlphaTwo'],
      dialCode: json['dialCode'],
    );
  }

  // Helper to convert "US" -> 🇺🇸
  String get flag {
    if (isoCode.length != 2) return "🏳️";
    int flagOffset = 0x1F1E6;
    int asciiOffset = 0x41;
    String firstChar = String.fromCharCode(
      isoCode.codeUnitAt(0) - asciiOffset + flagOffset,
    );
    String secondChar = String.fromCharCode(
      isoCode.codeUnitAt(1) - asciiOffset + flagOffset,
    );
    return firstChar + secondChar;
  }
}

class ApiResponse {
  final int statusCode;
  final String message;

  ApiResponse({required this.statusCode, required this.message});

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      statusCode: json['StatusCode'] ?? 0,
      message: json['Message'] ?? 'Unknown status',
    );
  }
}
