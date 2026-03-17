class ActivityCustomField {
  final int activityCustomFieldLinkId;
  final int activityId;
  final int customFieldId;
  final String fieldName;
  final String fieldDataType;
  final bool active;

  ActivityCustomField({
    required this.activityCustomFieldLinkId,
    required this.activityId,
    required this.customFieldId,
    required this.fieldName,
    required this.fieldDataType,
    required this.active,
  });

  factory ActivityCustomField.fromJson(Map<String, dynamic> json) {
    return ActivityCustomField(
      activityCustomFieldLinkId: json['activityCustomFieldLinkId'],
      activityId: json['activityId'],
      customFieldId: json['customFieldId'],
      fieldName: json['fieldName'],
      fieldDataType: json['fieldDataType'],
      active: json['active'],
    );
  }
}
