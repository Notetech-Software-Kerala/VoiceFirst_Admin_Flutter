class ProgramActionModel {
  final int ProgramActionId;
  final String programActionName;
  final bool isActive;

  ProgramActionModel({
    required this.ProgramActionId,
    required this.programActionName,
    required this.isActive,
  });

  factory ProgramActionModel.fromJson(Map<String, dynamic> json) {
    return ProgramActionModel(
      ProgramActionId: json['ProgramActionId'],
      programActionName: json['programActionName'],
      isActive: json['isActive'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'ProgramActionId': ProgramActionId,
      'programActionName': programActionName,
      'isActive': isActive,
    };
  }

  ProgramActionModel copyWith({
    int? sysProgramActionId,
    String? programActionName,
    bool? isActive,
  }) {
    return ProgramActionModel(
      ProgramActionId: sysProgramActionId ?? this.ProgramActionId,
      programActionName: programActionName ?? this.programActionName,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProgramActionModel &&
          runtimeType == other.runtimeType &&
          ProgramActionId == other.ProgramActionId;

  @override
  int get hashCode => ProgramActionId.hashCode;
}
