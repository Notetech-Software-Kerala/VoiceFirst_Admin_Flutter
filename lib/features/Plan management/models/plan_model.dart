// --------------------
// Plan Action Summary
// --------------------
class PlanActionSummary {
  final int actionLinkId;
  final String actionName;
  final bool? active;

  const PlanActionSummary({
    required this.actionLinkId,
    required this.actionName,
    this.active,
  });

  factory PlanActionSummary.fromJson(Map<String, dynamic> json) {
    return PlanActionSummary(
      actionLinkId: json['actionLinkId'] as int,
      actionName: json['actionName'] as String? ?? '',
      active: json['active'] as bool?,
    );
  }
}


// -------------
// Plan Model
// -------------
class PlanModel {
  final int? planId;
  final String planName;
  final bool? active;
  final bool? deleted;

  // Audit fields
  final String? createdUser;
  final DateTime? createdDate;
  final String? modifiedUser;
  final DateTime? modifiedDate;
  final String? deletedUser;
  final DateTime? deletedDate;

  // Permission mapping
  final List<int> programActionLinkIds;
  final List<PlanActionSummary> actions;

  const PlanModel({
    this.planId,
    required this.planName,
    this.active,
    this.deleted,
    this.createdUser,
    this.createdDate,
    this.modifiedUser,
    this.modifiedDate,
    this.deletedUser,
    this.deletedDate,
    required this.programActionLinkIds,
    this.actions = const [],
  });

  // ---------- READ ----------
  factory PlanModel.fromJson(Map<String, dynamic> json) {
    final actionList = (json['actions'] as List<dynamic>? ?? [])
        .map((e) => PlanActionSummary.fromJson(e as Map<String, dynamic>))
        .toList();

    return PlanModel(
      planId: json['planId'] as int?,
      planName: json['planName'] as String? ?? '',
      active: json['active'] as bool?,
      deleted: json['deleted'] as bool?,
      createdUser: _emptyToNull(json['createdUser']),
      createdDate: _parseDate(json['createdDate']),
      modifiedUser: _emptyToNull(json['modifiedUser']),
      modifiedDate: _parseDate(json['modifiedDate']),
      deletedUser: _emptyToNull(json['deletedUser']),
      deletedDate: _parseDate(json['deletedDate']),
      programActionLinkIds: actionList.map((a) => a.actionLinkId).toList(),
      actions: actionList,
    );
  }

  // ---------- CREATE ----------
  Map<String, dynamic> toCreateJson() {
    return {'planName': planName, 'programActionLinkIds': programActionLinkIds};
  }

  // ---------- UPDATE ----------
  Map<String, dynamic> toUpdateJson({
    bool updateName = false,
    bool updateActions = false,
    bool? updateActive,
  }) {
    final Map<String, dynamic> body = {};

    if (updateName) {
      body['planName'] = planName;
    }

    if (updateActions) {
      body['programActionLinkIds'] = programActionLinkIds;
    }

    if (updateActive != null) {
      body['active'] = updateActive;
    }

    return body;
  }

  // ---------- COPY ----------
  PlanModel copyWith({
    int? planId,
    String? planName,
    bool? active,
    bool? deleted,
    String? createdUser,
    DateTime? createdDate,
    String? modifiedUser,
    DateTime? modifiedDate,
    String? deletedUser,
    DateTime? deletedDate,
    List<int>? programActionLinkIds,
    List<PlanActionSummary>? actions,
  }) {
    return PlanModel(
      planId: planId ?? this.planId,
      planName: planName ?? this.planName,
      active: active ?? this.active,
      deleted: deleted ?? this.deleted,
      createdUser: createdUser ?? this.createdUser,
      createdDate: createdDate ?? this.createdDate,
      modifiedUser: modifiedUser ?? this.modifiedUser,
      modifiedDate: modifiedDate ?? this.modifiedDate,
      deletedUser: deletedUser ?? this.deletedUser,
      deletedDate: deletedDate ?? this.deletedDate,
      programActionLinkIds: programActionLinkIds ?? this.programActionLinkIds,
      actions: actions ?? this.actions,
    );
  }
}

// --------------------
// Shared helpers
// --------------------
String? _emptyToNull(dynamic value) {
  if (value == null) return null;
  final v = value.toString().trim();
  return v.isEmpty ? null : value.toString();
}

DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString());
}
