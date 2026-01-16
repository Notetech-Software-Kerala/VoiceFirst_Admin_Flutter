// import 'package:voice_first_admin/features/Program_management/models/program_model.dart';

// /// Combined model to represent data for both SysProgram
// /// and its related SysProgramActionsLink records in one object.
// class ProgramManagementModel {
//   final int? sysProgramId;
//   final String programName;
//   final String labelName;
//   final String programRoute;
//   final int applicationId;
//   final int? companyId;

//   /// All action ids linked to this program (one entry per SysProgramActionsLink).
//   final List<int> programActionIds;

//   const ProgramManagementModel({
//     this.sysProgramId,
//     required this.programName,
//     required this.labelName,
//     required this.programRoute,
//     required this.applicationId,
//     this.companyId,
//     required this.programActionIds,
//   });

//   /// Build from a SysProgram and a collection of action ids
//   /// (each id corresponds to a SysProgramActionsLink row).
//   factory ProgramManagementModel.fromProgram(
//     SysProgram program,
//     Iterable<int> actionIds,
//   ) {
//     return ProgramManagementModel(
//       sysProgramId: program.sysProgramId,
//       programName: program.programName,
//       labelName: program.labelName,
//       programRoute: program.programRoute,
//       applicationId: program.applicationId,
//       companyId: program.companyId,
//       programActionIds: List<int>.from(actionIds),
//     );
//   }

//   /// Convert back to SysProgram (table SysProgram only).
//   SysProgram toSysProgram() {
//     return SysProgram(
//       sysProgramId: sysProgramId,
//       programName: programName,
//       labelName: labelName,
//       programRoute: programRoute,
//       applicationId: applicationId,
//       companyId: companyId,
//     );
//   }

//   factory ProgramManagementModel.fromJson(Map<String, dynamic> json) {
//     return ProgramManagementModel(
//       sysProgramId: json['sysProgramId'] as int?,
//       programName: json['programName'] as String? ?? '',
//       labelName: json['labelName'] as String? ?? '',
//       programRoute: json['programRoute'] as String? ?? '',
//       applicationId: json['applicationId'] as int? ?? 0,
//       companyId: json['companyId'] as int?,
//       programActionIds: (json['programActionIds'] as List<dynamic>? ?? [])
//           .map((e) => e as int)
//           .toList(),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'sysProgramId': sysProgramId,
//       'programName': programName,
//       'labelName': labelName,
//       'programRoute': programRoute,
//       'applicationId': applicationId,
//       'companyId': companyId,
//       // This list represents all rows that would go into SysProgramActionsLink
//       // for this program.
//       'programActionIds': programActionIds,
//     };
//   }

//   ProgramManagementModel copyWith({
//     int? sysProgramId,
//     String? programName,
//     String? labelName,
//     String? programRoute,
//     int? applicationId,
//     int? companyId,
//     List<int>? programActionIds,
//   }) {
//     return ProgramManagementModel(
//       sysProgramId: sysProgramId ?? this.sysProgramId,
//       programName: programName ?? this.programName,
//       labelName: labelName ?? this.labelName,
//       programRoute: programRoute ?? this.programRoute,
//       applicationId: applicationId ?? this.applicationId,
//       companyId: companyId ?? this.companyId,
//       programActionIds: programActionIds ?? this.programActionIds,
//     );
//   }
// }
class ProgramManagementModel {
  final int? sysProgramId;
  final String programName;
  final String labelName;
  final String programRoute;
  final int applicationId;
  final int? companyId;
  final List<int> programActionIds;

  const ProgramManagementModel({
    this.sysProgramId,
    required this.programName,
    required this.labelName,
    required this.programRoute,
    required this.applicationId,
    this.companyId,
    required this.programActionIds,
  });

  factory ProgramManagementModel.fromJson(Map<String, dynamic> json) {
    return ProgramManagementModel(
      sysProgramId: json['sysProgramId'] as int?,
      programName: json['programName'] ?? '',
      labelName: json['labelName'] ?? '',
      programRoute: json['programRoute'] ?? '',
      applicationId: json['applicationId'] ?? 0,
      companyId: json['companyId'],
      programActionIds: (json['programActionIds'] as List<dynamic>? ?? [])
          .map((e) => e as int)
          .toList(),
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
      'programActionIds': programActionIds,
    };
  }

  ProgramManagementModel copyWith({
    int? sysProgramId,
    String? programName,
    String? labelName,
    String? programRoute,
    int? applicationId,
    int? companyId,
    List<int>? programActionIds,
  }) {
    return ProgramManagementModel(
      sysProgramId: sysProgramId ?? this.sysProgramId,
      programName: programName ?? this.programName,
      labelName: labelName ?? this.labelName,
      programRoute: programRoute ?? this.programRoute,
      applicationId: applicationId ?? this.applicationId,
      companyId: companyId ?? this.companyId,
      programActionIds: programActionIds ?? this.programActionIds,
    );
  }
}
