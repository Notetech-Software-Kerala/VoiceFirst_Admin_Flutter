class IssueTypeModel {
  final int issueTypeId;
  final String issueType;
  final String? description;
  final bool active;
  final bool deleted;

  final String? createdUser;
  final DateTime? createdDate;
  final String? modifiedUser;
  final DateTime? modifiedDate;
  final String? deletedUser;
  final DateTime? deletedDate;

  IssueTypeModel({
    required this.issueTypeId,
    required this.issueType,
    this.description,
    required this.active,
    this.deleted = false,
    this.createdUser,
    this.createdDate,
    this.modifiedUser,
    this.modifiedDate,
    this.deletedUser,
    this.deletedDate,
  });

  factory IssueTypeModel.fromJson(Map<String, dynamic> json) {
    return IssueTypeModel(
      issueTypeId: json['issueTypeId'] as int,
      issueType: json['issueType'] as String? ?? '',
      description: _emptyToNull(json['description']),
      active: json['active'] as bool? ?? false,
      deleted: json['deleted'] as bool? ?? false,
      createdUser: _emptyToNull(json['createdUser']),
      createdDate: _parseDate(json['createdDate']),
      modifiedUser: _emptyToNull(json['modifiedUser']),
      modifiedDate: _parseDate(json['modifiedDate']),
      deletedUser: _emptyToNull(json['deletedUser']),
      deletedDate: _parseDate(json['deletedDate']),
    );
  }

  IssueTypeModel copyWith({
    String? issueType,
    String? description,
    bool? active,
    bool? deleted,
    String? deletedUser,
    DateTime? deletedDate,
    bool clearDeletedMeta = false,
  }) {
    return IssueTypeModel(
      issueTypeId: issueTypeId,
      issueType: issueType ?? this.issueType,
      description: description ?? this.description,
      active: active ?? this.active,
      deleted: deleted ?? this.deleted,
      createdUser: createdUser,
      createdDate: createdDate,
      modifiedUser: modifiedUser,
      modifiedDate: modifiedDate,
      deletedUser: clearDeletedMeta ? null : deletedUser ?? this.deletedUser,
      deletedDate: clearDeletedMeta ? null : deletedDate ?? this.deletedDate,
    );
  }

  static String? _emptyToNull(dynamic value) {
    if (value == null) return null;
    final v = value.toString().trim();
    return v.isEmpty ? null : v;
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IssueTypeModel && issueTypeId == other.issueTypeId;

  @override
  int get hashCode => issueTypeId.hashCode;
}

List<IssueTypeModel> issueTypeListFromJson(List<dynamic> items) {
  return items
      .map((e) => IssueTypeModel.fromJson(e as Map<String, dynamic>))
      .toList();
}
