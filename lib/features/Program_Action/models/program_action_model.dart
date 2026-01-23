class ProgramActionModel {
  final int actionId;
  final String actionName;
  final bool active;
  final bool deleted;

  // Audit fields
  final String? createdUser;
  final DateTime? createdDate;
  final String? modifiedUser;
  final DateTime? modifiedDate;
  final String? deletedUser;
  final DateTime? deletedDate;

  ProgramActionModel({
    required this.actionId,
    required this.actionName,
    required this.active,
    this.deleted = false,
    this.createdUser,
    this.createdDate,
    this.modifiedUser,
    this.modifiedDate,
    this.deletedUser,
    this.deletedDate,
  });

  factory ProgramActionModel.fromJson(Map<String, dynamic> json) {
    return ProgramActionModel(
      actionId: json['actionId'],
      actionName: json['actionName'] ?? '',
      active: json['active'] ?? false,
      deleted: json['deleted'] ?? false,
      createdUser: _emptyToNull(json['createdUser']),
      createdDate: _parseDate(json['createdDate']),
      modifiedUser: _emptyToNull(json['modifiedUser']),
      modifiedDate: _parseDate(json['modifiedDate']),
      deletedUser: _emptyToNull(json['deletedUser']),
      deletedDate: _parseDate(json['deletedDate']),
    );
  }

  ProgramActionModel copyWith({
    String? actionName,
    bool? active,
    bool? deleted,
    String? deletedUser,
    DateTime? deletedDate,
    bool clearDeletedMeta = false,
  }) {
    return ProgramActionModel(
      actionId: actionId,
      actionName: actionName ?? this.actionName,
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
    return DateTime.tryParse(value);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProgramActionModel && actionId == other.actionId;

  @override
  int get hashCode => actionId.hashCode;
}
