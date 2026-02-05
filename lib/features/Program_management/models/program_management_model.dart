class ProgramActionSummary {
  final int actionId;
  final String actionName;
  final bool active;
  final String? createdUser;
  final DateTime? createdDate;
  final String? modifiedUser;
  final DateTime? modifiedDate;

  const ProgramActionSummary({
    required this.actionId,
    required this.actionName,
    required this.active,
    this.createdUser,
    this.createdDate,
    this.modifiedUser,
    this.modifiedDate,
  });

  factory ProgramActionSummary.fromJson(Map<String, dynamic> json) {
    return ProgramActionSummary(
      actionId: json['actionId'] as int,
      actionName: json['actionName'] as String? ?? '',
      active: json['active'] as bool? ?? true,
      createdUser: _emptyToNull(json['createdUser']),
      createdDate: _parseDate(json['createdDate']),
      modifiedUser: _emptyToNull(json['modifiedUser']),
      modifiedDate: _parseDate(json['modifiedDate']),
    );
  }
}

class ProgramModel {
  final int? sysProgramId;
  final String programName;
  final String labelName;
  final String programRoute;
  final int applicationId;
  final int? companyId;
  final bool? active;
  final bool? deleted;
  final String? platformName;
  final String? companyName;
  final String? createdUser;
  final DateTime? createdDate;
  final String? modifiedUser;
  final DateTime? modifiedDate;
  final String? deletedUser;
  final DateTime? deletedDate;

  /// ✅ ONLY SOURCE OF TRUTH
  final List<ProgramActionSummary> actions;

  const ProgramModel({
    this.sysProgramId,
    required this.programName,
    required this.labelName,
    required this.programRoute,
    required this.applicationId,
    this.companyId,
    this.active,
    this.deleted,
    this.platformName,
    this.companyName,
    this.createdUser,
    this.createdDate,
    this.modifiedUser,
    this.modifiedDate,
    this.deletedUser,
    this.deletedDate,
    this.actions = const [],
  });

  /// ✅ DERIVED LIST (Never store duplicates!)
  List<int> get activeActionIds =>
      actions.where((a) => a.active).map((a) => a.actionId).toList();

  factory ProgramModel.fromJson(Map<String, dynamic> json) {
    final actionList = (json['action'] as List<dynamic>? ?? [])
        .map((e) => ProgramActionSummary.fromJson(e as Map<String, dynamic>))
        .toList();

    return ProgramModel(
      sysProgramId: json['programId'] as int?,
      programName: json['programName'] as String? ?? '',
      labelName: json['label'] as String? ?? '',
      programRoute: json['route'] as String? ?? '',
      applicationId: json['platformId'] as int,
      companyId: json['companyId'] as int?,
      active: json['active'] as bool?,
      deleted: json['deleted'] as bool?,
      platformName: json['platformName'] as String?,
      companyName: json['companyName'] as String?,
      createdUser: _emptyToNull(json['createdUser']),
      createdDate: _parseDate(json['createdDate']),
      modifiedUser: _emptyToNull(json['modifiedUser']),
      modifiedDate: _parseDate(json['modifiedDate']),
      deletedUser: _emptyToNull(json['deletedUser']),
      deletedDate: _parseDate(json['deletedDate']),
      actions: actionList,
    );
  }

  ProgramModel copyWith({
    int? sysProgramId,
    String? programName,
    String? labelName,
    String? programRoute,
    int? applicationId,
    int? companyId,
    bool? active,
    bool? deleted,
    String? platformName,
    String? companyName,
    String? createdUser,
    DateTime? createdDate,
    String? modifiedUser,
    DateTime? modifiedDate,
    String? deletedUser,
    DateTime? deletedDate,
    List<ProgramActionSummary>? actions,
  }) {
    return ProgramModel(
      sysProgramId: sysProgramId ?? this.sysProgramId,
      programName: programName ?? this.programName,
      labelName: labelName ?? this.labelName,
      programRoute: programRoute ?? this.programRoute,
      applicationId: applicationId ?? this.applicationId,
      companyId: companyId ?? this.companyId,
      active: active ?? this.active,
      deleted: deleted ?? this.deleted,
      platformName: platformName ?? this.platformName,
      companyName: companyName ?? this.companyName,
      createdUser: createdUser ?? this.createdUser,
      createdDate: createdDate ?? this.createdDate,
      modifiedUser: modifiedUser ?? this.modifiedUser,
      modifiedDate: modifiedDate ?? this.modifiedDate,
      deletedUser: deletedUser ?? this.deletedUser,
      deletedDate: deletedDate ?? this.deletedDate,
      actions: actions ?? this.actions,
    );
  }
}

String? _emptyToNull(dynamic value) {
  if (value == null) return null;
  final v = value.toString().trim();
  return v.isEmpty ? null : v;
}

DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString());
}
