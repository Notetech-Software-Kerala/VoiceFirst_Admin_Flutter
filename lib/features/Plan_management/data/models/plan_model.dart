class Plan {
  final int planId;
  final String planName;
  final bool active;
  final bool deleted;

  final String? createdUser;
  final DateTime? createdDate;
  final String? modifiedUser;
  final DateTime? modifiedDate;
  final String? deletedUser;
  final DateTime? deletedDate;

  /// NULL when coming from LIST API
  final List<ProgramPlanDetail>? programPlanDetails;

  const Plan({
    required this.planId,
    required this.planName,
    required this.active,
    required this.deleted,
    this.createdUser,
    this.createdDate,
    this.modifiedUser,
    this.modifiedDate,
    this.deletedUser,
    this.deletedDate,
    this.programPlanDetails,
  });

  factory Plan.fromJson(Map<String, dynamic> json) {
    DateTime? parse(dynamic v) =>
        v == null ? null : DateTime.tryParse(v.toString());

    String? clean(dynamic v) {
      if (v == null) return null;
      final s = v.toString().trim();
      return s.isEmpty ? null : s;
    }

    return Plan(
      planId: json['planId'],
      planName: json['planName'] ?? '',
      active: json['active'] ?? false,
      deleted: json['deleted'] ?? false,
      createdUser: clean(json['createdUser']),
      createdDate: parse(json['createdDate']),
      modifiedUser: clean(json['modifiedUser']),
      modifiedDate: parse(json['modifiedDate']),
      deletedUser: clean(json['deletedUser']),
      deletedDate: parse(json['deletedDate']),
      programPlanDetails: (json['programPlanDetails'] as List?)
          ?.map((e) => ProgramPlanDetail.fromJson(e))
          .toList(),
    );
  }

  Plan copyWith({
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
    List<ProgramPlanDetail>? programPlanDetails,
  }) {
    return Plan(
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
      programPlanDetails: programPlanDetails ?? this.programPlanDetails,
    );
  }

  /// CREATE BODY

  Map<String, dynamic> toCreateJson(List<int> actionIds) {
    return {"planName": planName, "programActionLinkIds": actionIds};
  }
}

//child models

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
    DateTime? parse(dynamic v) =>
        v == null ? null : DateTime.tryParse(v.toString());
    String? clean(dynamic v) {
      if (v == null) return null;
      final s = v.toString().trim();
      return s.isEmpty ? null : s;
    }

    return ProgramActionDetail(
      actionLinkId: json['actionLinkId'] as int,
      actionName: json['actionName'] as String? ?? '',
      active: json['active'] as bool? ?? false,
      deleted: json['deleted'] as bool?,
      createdUser: clean(json['createdUser']),
      createdDate: parse(json['createdDate']),
      modifiedUser: clean(json['modifiedUser']),
      modifiedDate: parse(json['modifiedDate']),
      deletedUser: clean(json['deletedUser']),
      deletedDate: parse(json['deletedDate']),
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
