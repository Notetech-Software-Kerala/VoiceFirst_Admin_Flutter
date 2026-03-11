class IssueStatusModel {
  final int issueStatusId;
  final String issueStatus;
  final bool active;
  final bool deleted;

  final String? createdUser;
  final DateTime? createdDate;
  final String? modifiedUser;
  final DateTime? modifiedDate;
  final String? deletedUser;
  final DateTime? deletedDate;

  IssueStatusModel({
    required this.issueStatusId,
    required this.issueStatus,
    required this.active,
    this.deleted = false,
    this.createdUser,
    this.createdDate,
    this.modifiedUser,
    this.modifiedDate,
    this.deletedUser,
    this.deletedDate,
  });

  factory IssueStatusModel.fromJson(Map<String, dynamic> json) {
    return IssueStatusModel(
      issueStatusId: json['issueStatusId'] as int,
      issueStatus: json['issueStatus'] as String? ?? '',
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
    return {'issueStatus': issueStatus};
  }

  IssueStatusModel copyWith({
    String? issueStatus,
    bool? active,
    bool? deleted,
    String? deletedUser,
    DateTime? deletedDate,
    bool clearDeletedMeta = false,
  }) {
    return IssueStatusModel(
      issueStatusId: issueStatusId,
      issueStatus: issueStatus ?? this.issueStatus,
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
      other is IssueStatusModel && issueStatusId == other.issueStatusId;

  @override
  int get hashCode => issueStatusId.hashCode;
}

List<IssueStatusModel> issueStatusListFromJson(List<dynamic> items) {
  return items
      .map((e) => IssueStatusModel.fromJson(e as Map<String, dynamic>))
      .toList();
}
