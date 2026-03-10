class IssueMediaTypeModel {
  final int issueMediaTypeId;
  final String issueMediaType;
  final bool active;
  final bool deleted;

  // Audit fields
  final String? createdUser;
  final DateTime? createdDate;
  final String? modifiedUser;
  final DateTime? modifiedDate;
  final String? deletedUser;
  final DateTime? deletedDate;

  IssueMediaTypeModel({
    required this.issueMediaTypeId,
    required this.issueMediaType,
    required this.active,
    this.deleted = false,
    this.createdUser,
    this.createdDate,
    this.modifiedUser,
    this.modifiedDate,
    this.deletedUser,
    this.deletedDate,
  });

  factory IssueMediaTypeModel.fromJson(Map<String, dynamic> json) {
    return IssueMediaTypeModel(
      issueMediaTypeId: json['issueMediaTypeId'] as int,
      issueMediaType: json['issueMediaType'] as String? ?? '',
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

  Map<String, dynamic> toCreateJson() {
    return {'issueMediaType': issueMediaType};
  }

  IssueMediaTypeModel copyWith({
    String? issueMediaType,
    bool? active,
    bool? deleted,
    String? deletedUser,
    DateTime? deletedDate,
    bool clearDeletedMeta = false,
  }) {
    return IssueMediaTypeModel(
      issueMediaTypeId: issueMediaTypeId,
      issueMediaType: issueMediaType ?? this.issueMediaType,
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
      other is IssueMediaTypeModel &&
          issueMediaTypeId == other.issueMediaTypeId;

  @override
  int get hashCode => issueMediaTypeId.hashCode;
}

List<IssueMediaTypeModel> issueMediaTypeListFromJson(List<dynamic> items) {
  return items
      .map((e) => IssueMediaTypeModel.fromJson(e as Map<String, dynamic>))
      .toList();
}
