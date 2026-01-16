class SysProgram {
  final int? sysProgramId;
  final String programName;
  final String labelName;
  final String programRoute;
  final int applicationId;
  final int? companyId;

  const SysProgram({
    this.sysProgramId,
    required this.programName,
    required this.labelName,
    required this.programRoute,
    required this.applicationId,
    this.companyId,
  });

  factory SysProgram.fromJson(Map<String, dynamic> json) {
    return SysProgram(
      sysProgramId: json['sysProgramId'] as int?,
      programName: json['programName'] as String? ?? '',
      labelName: json['labelName'] as String? ?? '',
      programRoute: json['programRoute'] as String? ?? '',
      applicationId: json['applicationId'] as int? ?? 0,
      companyId: json['companyId'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sysProgramId': sysProgramId,
      'programName': programName,
      'labelName': labelName,
      'programRoute': programRoute,
      'applicationId': applicationId,
      'companyId': companyId,
    };
  }

  SysProgram copyWith({
    int? sysProgramId,
    String? programName,
    String? labelName,
    String? programRoute,
    int? applicationId,
    int? companyId,
  }) {
    return SysProgram(
      sysProgramId: sysProgramId ?? this.sysProgramId,
      programName: programName ?? this.programName,
      labelName: labelName ?? this.labelName,
      programRoute: programRoute ?? this.programRoute,
      applicationId: applicationId ?? this.applicationId,
      companyId: companyId ?? this.companyId,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SysProgram &&
          runtimeType == other.runtimeType &&
          sysProgramId == other.sysProgramId;

  @override
  int get hashCode => sysProgramId.hashCode;
}
