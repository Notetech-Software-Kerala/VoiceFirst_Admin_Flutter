class ProgramActionDetail {
  final int actionLinkId;
  final String actionName;
  final bool active;
  final bool? deleted;
  final String? createdUser;
  final DateTime? createdDate;
  final String? modifiedUser;
  final DateTime? modifiedDate;
  final String? deletedUser;
  final DateTime? deletedDate;

  ProgramActionDetail({
    required this.actionLinkId,
    required this.actionName,
    required this.active,
    this.deleted,
    this.createdUser,
    this.createdDate,
    this.modifiedUser,
    this.modifiedDate,
    this.deletedUser,
    this.deletedDate,
  });

  factory ProgramActionDetail.fromJson(Map<String, dynamic> json) {
    DateTime? _parse(dynamic v) =>
        v == null ? null : DateTime.tryParse(v.toString());
    String? _emptyToNull(dynamic v) {
      if (v == null) return null;
      final s = v.toString().trim();
      return s.isEmpty ? null : v.toString();
    }

    return ProgramActionDetail(
      actionLinkId: json['actionLinkId'] as int,
      actionName: json['actionName'] as String? ?? '',
      active: json['active'] as bool? ?? false,
      deleted: json['deleted'] as bool?,
      createdUser: _emptyToNull(json['createdUser']),
      createdDate: _parse(json['createdDate']),
      modifiedUser: _emptyToNull(json['modifiedUser']),
      modifiedDate: _parse(json['modifiedDate']),
      deletedUser: _emptyToNull(json['deletedUser']),
      deletedDate: _parse(json['deletedDate']),
    );
  }
}

class ProgramPlanDetail {
  final int programId;
  final String programName;
  final List<ProgramActionDetail> actions;

  ProgramPlanDetail({
    required this.programId,
    required this.programName,
    required this.actions,
  });

  factory ProgramPlanDetail.fromJson(Map<String, dynamic> json) {
    final actionsJson = (json['actions'] as List<dynamic>? ?? []);
    return ProgramPlanDetail(
      programId: json['programId'] as int,
      programName: json['programName'] as String? ?? '',
      actions: actionsJson
          .map((e) => ProgramActionDetail.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class PlanDetailModel {
  final int planId;
  final String planName;
  final bool active;
  final bool? deleted;
  final String? createdUser;
  final DateTime? createdDate;
  final String? modifiedUser;
  final DateTime? modifiedDate;
  final String? deletedUser;
  final DateTime? deletedDate;
  final List<ProgramPlanDetail> programPlanDetails;

  PlanDetailModel({
    required this.planId,
    required this.planName,
    required this.active,
    this.deleted,
    this.createdUser,
    this.createdDate,
    this.modifiedUser,
    this.modifiedDate,
    this.deletedUser,
    this.deletedDate,
    required this.programPlanDetails,
  });

  factory PlanDetailModel.fromJson(Map<String, dynamic> json) {
    DateTime? _parse(dynamic v) =>
        v == null ? null : DateTime.tryParse(v.toString());
    String? _emptyToNull(dynamic v) {
      if (v == null) return null;
      final s = v.toString().trim();
      return s.isEmpty ? null : v.toString();
    }

    final ppdJson = (json['programPlanDetails'] as List<dynamic>? ?? []);
    return PlanDetailModel(
      planId: json['planId'] as int,
      planName: json['planName'] as String? ?? '',
      active: json['active'] as bool? ?? false,
      deleted: json['deleted'] as bool?,
      createdUser: _emptyToNull(json['createdUser']),
      createdDate: _parse(json['createdDate']),
      modifiedUser: _emptyToNull(json['modifiedUser']),
      modifiedDate: _parse(json['modifiedDate']),
      deletedUser: _emptyToNull(json['deletedUser']),
      deletedDate: _parse(json['deletedDate']),
      programPlanDetails: ppdJson
          .map((e) => ProgramPlanDetail.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
