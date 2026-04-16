import 'place_model.dart';

class CreatePlaceRequest {
  final String placeName;
  final List<int> zipCodeLinkIds;

  const CreatePlaceRequest({
    required this.placeName,
    required this.zipCodeLinkIds,
  });

  Map<String, dynamic> toJson() {
    return {'placeName': placeName, 'zipCodeLinkIds': zipCodeLinkIds};
  }
}

class UpdatePlaceRequest {
  final String? placeName;
  final bool? active;
  final List<ZipCodeLinkUpdate> updateZipCodeLinkIds;
  final List<int> insertZipCodeLinkIds;

  const UpdatePlaceRequest({
    this.placeName,
    this.active,
    this.updateZipCodeLinkIds = const [],
    this.insertZipCodeLinkIds = const [],
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (placeName != null) data['placeName'] = placeName;
    if (active != null) data['active'] = active;
    if (updateZipCodeLinkIds.isNotEmpty) {
      data['updateZipCodeLinkIds'] = updateZipCodeLinkIds
          .map((e) => e.toJson())
          .toList();
    }
    if (insertZipCodeLinkIds.isNotEmpty) {
      data['insertZipCodeLinkIds'] = insertZipCodeLinkIds;
    }
    return data;
  }
}
