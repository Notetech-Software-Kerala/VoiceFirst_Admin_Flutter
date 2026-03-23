class ValidationRuleModel {
  final int? validationId;
  final String ruleName;
  final String ruleValue;
  final String message;

  const ValidationRuleModel({
    this.validationId,
    required this.ruleName,
    required this.ruleValue,
    required this.message,
  });

  factory ValidationRuleModel.fromJson(Map<String, dynamic> json) {
    return ValidationRuleModel(
      validationId:
          json['customFieldValidationId'] as int? ??
          json['validationId'] as int?,
      ruleName: json['ruleName']?.toString() ?? '',
      ruleValue: json['ruleValue']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'ruleName': ruleName,
    'ruleValue': ruleValue,
    'message': message,
  };
}

class FieldOptionModel {
  final int? optionId;
  final String label;
  final String value;

  const FieldOptionModel({
    this.optionId,
    required this.label,
    required this.value,
  });

  factory FieldOptionModel.fromJson(Map<String, dynamic> json) {
    return FieldOptionModel(
      optionId:
          json['customFieldOptionsId'] as int? ?? json['optionId'] as int?,
      label: json['label']?.toString() ?? '',
      value: json['value']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'label': label, 'value': value};
}

class CustomFieldModel {
  final int? fieldId;
  final String fieldName;
  final String fieldKey;
  final String fieldDataType;
  final bool active;
  final bool deleted;
  final List<ValidationRuleModel> validations;
  final List<FieldOptionModel> options;

  final String? createdUser;
  final DateTime? createdDate;
  final String? modifiedUser;
  final DateTime? modifiedDate;

  const CustomFieldModel({
    this.fieldId,
    required this.fieldName,
    required this.fieldKey,
    required this.fieldDataType,
    this.active = true,
    this.deleted = false,
    this.validations = const [],
    this.options = const [],
    this.createdUser,
    this.createdDate,
    this.modifiedUser,
    this.modifiedDate,
  });

  factory CustomFieldModel.fromJson(Map<String, dynamic> json) {
    List<ValidationRuleModel> validations = [];
    if (json['validations'] is List) {
      validations = (json['validations'] as List)
          .map((e) => ValidationRuleModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    List<FieldOptionModel> options = [];
    if (json['options'] is List) {
      options = (json['options'] as List)
          .map((e) => FieldOptionModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return CustomFieldModel(
      fieldId: json['customFieldId'] as int? ?? json['fieldId'] as int?,
      fieldName: json['fieldName']?.toString() ?? '',
      fieldKey: json['fieldKey']?.toString() ?? '',
      fieldDataType: json['fieldDataType']?.toString() ?? '',
      active: json['active'] as bool? ?? true,
      deleted: json['deleted'] as bool? ?? false,
      validations: validations,
      options: options,
      createdUser: json['createdUser']?.toString(),
      createdDate: _parseDate(json['createdDate']),
      modifiedUser: json['modifiedUser']?.toString(),
      modifiedDate: _parseDate(json['modifiedDate']),
    );
  }

  Map<String, dynamic> toCreateJson() => {
    'fieldName': fieldName,
    'fieldKey': fieldKey,
    'fieldDataType': fieldDataType,
    'addValidations': validations.map((v) => v.toJson()).toList(),
    'addOptions': options.map((o) => o.toJson()).toList(),
  };

  Map<String, dynamic> toUpdateJson() => {
    'fieldName': fieldName,
    'fieldDataType': fieldDataType,
    'updateValidations': validations
        .where((v) => v.validationId != null)
        .map((v) => {...v.toJson(), 'customFieldValidationId': v.validationId})
        .toList(),
    'addValidations': validations
        .where((v) => v.validationId == null)
        .map((v) => v.toJson())
        .toList(),
    'updateOptions': options
        .where((o) => o.optionId != null)
        .map((o) => {...o.toJson(), 'customFieldOptionsId': o.optionId})
        .toList(),
    'addOptions': options
        .where((o) => o.optionId == null)
        .map((o) => o.toJson())
        .toList(),
  };

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomFieldModel && fieldId == other.fieldId;

  @override
  int get hashCode => fieldId.hashCode;
}
