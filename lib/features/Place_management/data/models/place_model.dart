class PlaceModel {
  final int placeId;
  final String placeName;
  final bool active;
  final bool deleted;
  final String? createdUser;
  final DateTime? createdDate;
  final String? modifiedUser;
  final DateTime? modifiedDate;
  final String? deletedUser;
  final DateTime? deletedDate;
  final List<PlacePostOffice> postOffices;

  const PlaceModel({
    required this.placeId,
    required this.placeName,
    required this.active,
    required this.deleted,
    this.createdUser,
    this.createdDate,
    this.modifiedUser,
    this.modifiedDate,
    this.deletedUser,
    this.deletedDate,
    this.postOffices = const [],
  });

  factory PlaceModel.fromJson(Map<String, dynamic> json) {
    return PlaceModel(
      // placeId: json['placeId'] as int,
      placeId: (json['placeId'] as num).toInt(),
      placeName: json['placeName'] as String? ?? '',
      active: json['active'] as bool? ?? false,
      deleted: json['deleted'] as bool? ?? false,
      createdUser: _clean(json['createdUser']),
      createdDate: _parseDate(json['createdDate']),
      modifiedUser: _clean(json['modifiedUser']),
      modifiedDate: _parseDate(json['modifiedDate']),
      deletedUser: _clean(json['deletedUser']),
      deletedDate: _parseDate(json['deletedDate']),
      // postOffices: (json['postOffices'] as List<dynamic>? ?? [])
      //     .map((e) => PlacePostOffice.fromJson(e as Map<String, dynamic>))
      //     .toList(),
      postOffices:
          (json['postOffices'] as List?)
              ?.map((e) => PlacePostOffice.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  PlaceModel copyWith({
    int? placeId,
    String? placeName,
    bool? active,
    bool? deleted,
    String? createdUser,
    DateTime? createdDate,
    String? modifiedUser,
    DateTime? modifiedDate,
    String? deletedUser,
    DateTime? deletedDate,
    List<PlacePostOffice>? postOffices,
  }) {
    return PlaceModel(
      placeId: placeId ?? this.placeId,
      placeName: placeName ?? this.placeName,
      active: active ?? this.active,
      deleted: deleted ?? this.deleted,
      createdUser: createdUser ?? this.createdUser,
      createdDate: createdDate ?? this.createdDate,
      modifiedUser: modifiedUser ?? this.modifiedUser,
      modifiedDate: modifiedDate ?? this.modifiedDate,
      deletedUser: deletedUser ?? this.deletedUser,
      deletedDate: deletedDate ?? this.deletedDate,
      postOffices: postOffices ?? this.postOffices,
    );
  }
}

class PlacePostOffice {
  final int postOfficeId;
  final String postOfficeName;
  final String? countryName;
  final String? divisionOneLabel;
  final String? divisionTwoLabel;
  final String? divisionThreeLabel;
  final String? divisionOneName;
  final String? divisionTwoName;
  final String? divisionThreeName;
  final List<PlaceZipCodeLink> zipCodes;

  const PlacePostOffice({
    required this.postOfficeId,
    required this.postOfficeName,
    required this.countryName,
    this.divisionOneLabel,
    this.divisionTwoLabel,
    this.divisionThreeLabel,
    this.divisionOneName,
    this.divisionTwoName,
    this.divisionThreeName,
    required this.zipCodes,
  });

  factory PlacePostOffice.fromJson(Map<String, dynamic> json) {
    return PlacePostOffice(
      // postOfficeId: json['postOfficeId'] as int,
      postOfficeId: (json['postOfficeId'] as num).toInt(),
      postOfficeName: json['postOfficeName'] as String? ?? '',
      countryName: _clean(json['countryName']),
      divisionOneLabel: json['divisionOneLabel'] as String?,
      divisionTwoLabel: json['divisionTwoLabel'] as String?,
      divisionThreeLabel: json['divisionThreeLabel'] as String?,
      divisionOneName: json['divisionOneName'] as String?,
      divisionTwoName: json['divisionTwoName'] as String?,
      divisionThreeName: json['divisionThreeName'] as String?,
      zipCodes:
          (json['zipCodes'] as List?)
              ?.map((e) => PlaceZipCodeLink.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }
}

class PlaceZipCodeLink {
  final int placeZipCodeLinkId;
  final int zipCodeLinkId;
  final String zipCode;
  final bool active;
  final String? createdUser;
  final DateTime? createdDate;
  final String? modifiedUser;
  final DateTime? modifiedDate;

  const PlaceZipCodeLink({
    required this.placeZipCodeLinkId,
    required this.zipCodeLinkId,
    required this.zipCode,
    required this.active,
    this.createdUser,
    this.createdDate,
    this.modifiedUser,
    this.modifiedDate,
  });

  factory PlaceZipCodeLink.fromJson(Map<String, dynamic> json) {
    return PlaceZipCodeLink(
      // placeZipCodeLinkId: json['placeZipCodeLinkId'] as int,
      // zipCodeLinkId: json['zipCodeLinkId'] as int,
      placeZipCodeLinkId: (json['placeZipCodeLinkId'] as num).toInt(),
      zipCodeLinkId: (json['zipCodeLinkId'] as num).toInt(),
      zipCode: json['zipCode'] as String? ?? '',
      active: json['active'] as bool? ?? false,
      createdUser: _clean(json['createdUser']),
      createdDate: _parseDate(json['createdDate']),
      modifiedUser: _clean(json['modifiedUser']),
      modifiedDate: _parseDate(json['modifiedDate']),
    );
  }
}

class ZipCodeLinkUpdate {
  final int zipCodeLinkId;
  final bool active;

  const ZipCodeLinkUpdate({required this.zipCodeLinkId, required this.active});

  Map<String, dynamic> toJson() {
    return {'zipCodeLinkId': zipCodeLinkId, 'active': active};
  }
}

String? _clean(dynamic value) {
  if (value == null) return null;
  final trimmed = value.toString().trim();
  return trimmed.isEmpty ? null : trimmed;
}

DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString());
}
