class CustomFieldLookup {
  final int customFieldLinkId;
  final String fieldName;
  final String fieldDataType;

  CustomFieldLookup({
    required this.customFieldLinkId,
    required this.fieldName,
    required this.fieldDataType,
  });

  factory CustomFieldLookup.fromJson(Map<String, dynamic> json) {
    return CustomFieldLookup(
      customFieldLinkId: json['customFieldLinkId'],
      fieldName: json['fieldName'],
      fieldDataType: json['fieldDataType'],
    );
  }
}
