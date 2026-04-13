class LookupDataTypeModel {
  final int id;
  final String label;

  const LookupDataTypeModel({required this.id, required this.label});

  factory LookupDataTypeModel.fromJson(Map<String, dynamic> json) {
    return LookupDataTypeModel(
      id: json['fieldDataTypeId'] as int? ?? json['id'] as int? ?? 0,
      label: json['fieldDataType']?.toString() ?? json['label']?.toString() ?? '',
    );
  }
}

class LookupValidationRuleModel {
  final int id;
  final String ruleName;

  const LookupValidationRuleModel({required this.id, required this.ruleName});

  factory LookupValidationRuleModel.fromJson(Map<String, dynamic> json) {
    return LookupValidationRuleModel(
      id: json['ruleId'] as int? ?? json['id'] as int? ?? 0,
      ruleName: json['ruleName']?.toString() ?? '',
    );
  }
}

class ValidationRuleModel {
  final int? validationId;
  final int? ruleId;
  final String ruleName;
  final String ruleValue;
  final String message;

  const ValidationRuleModel({
    this.validationId,
    this.ruleId,
    required this.ruleName,
    required this.ruleValue,
    required this.message,
  });

  factory ValidationRuleModel.fromJson(Map<String, dynamic> json) {
    return ValidationRuleModel(
      validationId:
          json['customFieldValidationId'] as int? ?? json['validationId'] as int?,
      ruleId: json['ruleId'] as int?,
      ruleName: json['ruleName']?.toString() ?? '',
      ruleValue: json['ruleValue']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        if (ruleId != null) 'ruleId': ruleId,
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

class CustomFieldDataTypeModel {
  final int? customFieldLinkId;
  final int fieldDataTypeId;
  final String? fieldDataType;
  final List<ValidationRuleModel> validations;
  final List<FieldOptionModel> options;

  const CustomFieldDataTypeModel({
    this.customFieldLinkId,
    required this.fieldDataTypeId,
    this.fieldDataType,
    this.validations = const [],
    this.options = const [],
  });

  factory CustomFieldDataTypeModel.fromJson(Map<String, dynamic> json) {
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

    return CustomFieldDataTypeModel(
      customFieldLinkId: json['customFieldLinkId'] as int?,
      fieldDataTypeId: json['fieldDataTypeId'] as int? ?? 0,
      fieldDataType: json['fieldDataType']?.toString(),
      validations: validations,
      options: options,
    );
  }
}

class CustomFieldModel {
  final int? fieldId;
  final String fieldName;
  final String fieldKey;
  final bool active;
  final bool deleted;
  final List<CustomFieldDataTypeModel> fieldDataTypes;

  final String? createdUser;
  final DateTime? createdDate;
  final String? modifiedUser;
  final DateTime? modifiedDate;

  const CustomFieldModel({
    this.fieldId,
    required this.fieldName,
    required this.fieldKey,
    this.active = true,
    this.deleted = false,
    this.fieldDataTypes = const [],
    this.createdUser,
    this.createdDate,
    this.modifiedUser,
    this.modifiedDate,
  });

  // Helper getters to mimic old flat structure when adding/editing 
  // (Assuming mostly 1 datatype per field conceptually from UI)
  int? get primaryDataTypeId => fieldDataTypes.isNotEmpty ? fieldDataTypes.first.fieldDataTypeId : null;
  String get primaryDataTypeLabel => fieldDataTypes.isNotEmpty ? (fieldDataTypes.first.fieldDataType ?? '') : '';
  List<ValidationRuleModel> get primaryValidations => fieldDataTypes.isNotEmpty ? fieldDataTypes.first.validations : [];
  List<FieldOptionModel> get primaryOptions => fieldDataTypes.isNotEmpty ? fieldDataTypes.first.options : [];

  factory CustomFieldModel.fromJson(Map<String, dynamic> json) {
    List<CustomFieldDataTypeModel> fieldDataTypes = [];
    if (json['fieldDataTypes'] is List) {
      fieldDataTypes = (json['fieldDataTypes'] as List)
          .map((e) => CustomFieldDataTypeModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } else if (json['fieldDataType'] != null) {
      // In case GET fallback needed for older items
      fieldDataTypes = [
        CustomFieldDataTypeModel(
          fieldDataTypeId: int.tryParse(json['fieldDataType'].toString()) ?? 0,
          fieldDataType: json['fieldDataType']?.toString(),
        )
      ];
    }

    return CustomFieldModel(
      fieldId: json['customFieldId'] as int? ?? json['fieldId'] as int?,
      fieldName: json['fieldName']?.toString() ?? '',
      fieldKey: json['fieldKey']?.toString() ?? '',
      active: json['active'] as bool? ?? true,
      deleted: json['deleted'] as bool? ?? false,
      fieldDataTypes: fieldDataTypes,
      createdUser: json['createdUser']?.toString(),
      createdDate: _parseDate(json['createdDate']),
      modifiedUser: json['modifiedUser']?.toString(),
      modifiedDate: _parseDate(json['modifiedDate']),
    );
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'fieldName': fieldName,
      'fieldKey': fieldKey,
      'addCustomFieldDataType': fieldDataTypes.map((dt) => {
        'fieldDataTypeId': dt.fieldDataTypeId,
        'addValidations': dt.validations.map((v) => v.toJson()).toList(),
        'addOptions': dt.options.map((o) => o.toJson()).toList(),
      }).toList(),
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'fieldName': fieldName,
      'active': active,
      'updateCustomFieldDataTypes': fieldDataTypes
          .where((dt) => dt.customFieldLinkId != null)
          .map((dt) => {
                'customFieldLinkId': dt.customFieldLinkId,
                'fieldDataTypeId': dt.fieldDataTypeId,
                'updateValidations': dt.validations
                    .where((v) => v.validationId != null)
                    .map((v) => {...v.toJson(), 'customFieldValidationId': v.validationId})
                    .toList(),
                'addValidations': dt.validations
                    .where((v) => v.validationId == null)
                    .map((v) => v.toJson())
                    .toList(),
                'updateOptions': dt.options
                    .where((o) => o.optionId != null)
                    .map((o) => {...o.toJson(), 'customFieldOptionsId': o.optionId})
                    .toList(),
                'addOptions': dt.options
                    .where((o) => o.optionId == null)
                    .map((o) => o.toJson())
                    .toList(),
              })
          .toList(),
      'addCustomFieldDataTypes': fieldDataTypes
          .where((dt) => dt.customFieldLinkId == null)
          .map((dt) => {
                'fieldDataTypeId': dt.fieldDataTypeId,
                'addValidations': dt.validations.map((v) => v.toJson()).toList(),
                'addOptions': dt.options.map((o) => o.toJson()).toList(),
              })
          .toList(),
    };
  }

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
