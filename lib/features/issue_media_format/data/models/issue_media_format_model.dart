class IssueMediaFormatModel {
  final int issueMediaFormatId;
  final String issueMediaFormat;
  final bool active;
  final bool deleted;

  // Audit fields
  final String? createdUser;
  final DateTime? createdDate;
  final String? modifiedUser;
  final DateTime? modifiedDate;
  final String? deletedUser;
  final DateTime? deletedDate;

  IssueMediaFormatModel({
    required this.issueMediaFormatId,
    required this.issueMediaFormat,
    required this.active,
    this.deleted = false,
    this.createdUser,
    this.createdDate,
    this.modifiedUser,
    this.modifiedDate,
    this.deletedUser,
    this.deletedDate,
  });

  factory IssueMediaFormatModel.fromJson(Map<String, dynamic> json) {
    return IssueMediaFormatModel(
      issueMediaFormatId: json['issueMediaFormatId'] as int,
      issueMediaFormat: json['issueMediaFormat'] as String? ?? '',
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

  /// Convenience for creating the POST body
  /// from an instance (only the name is required
  /// for create, according to the API contract).
  Map<String, dynamic> toCreateJson() {
    return {'issueMediaFormat': issueMediaFormat};
  }

  IssueMediaFormatModel copyWith({
    String? issueMediaFormat,
    bool? active,
    bool? deleted,
    String? deletedUser,
    DateTime? deletedDate,
    bool clearDeletedMeta = false,
  }) {
    return IssueMediaFormatModel(
      issueMediaFormatId: issueMediaFormatId,
      issueMediaFormat: issueMediaFormat ?? this.issueMediaFormat,
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
      other is IssueMediaFormatModel &&
          issueMediaFormatId == other.issueMediaFormatId;

  @override
  int get hashCode => issueMediaFormatId.hashCode;
}

List<IssueMediaFormatModel> issueMediaFormatListFromJson(List<dynamic> items) {
  return items
      .map((e) => IssueMediaFormatModel.fromJson(e as Map<String, dynamic>))
      .toList();
}
