class CustomFieldLookup {
  final int customFieldId;
  final String fieldName;
  final String fieldDataType;

  CustomFieldLookup({
    required this.customFieldId,
    required this.fieldName,
    required this.fieldDataType,
  });

  factory CustomFieldLookup.fromJson(Map<String, dynamic> json) {
    return CustomFieldLookup(
      customFieldId: json['customFieldId'],
      fieldName: json['fieldName'],
      fieldDataType: json['fieldDataType'],
    );
  }
}
