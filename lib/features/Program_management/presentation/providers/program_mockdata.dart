// import 'package:voice_first_admin/features/Program_management/models/program_model.dart';

// /// Demo programs for the three applications.
// ///
// /// applicationId:
// /// 1 -> Web Admin
// /// 2 -> Mobile App
// /// 3 -> POS / Kiosk
// final List<SysProgram> mockPrograms = [
//   SysProgram(
//     sysProgramId: 1,
//     programName: 'Program Management',
//     labelName: 'Program Management',
//     programRoute: '/programs',
//     applicationId: 1,
//     companyId: null,
//   ),
//   SysProgram(
//     sysProgramId: 2,
//     programName: 'Program Actions',
//     labelName: 'Program Actions',
//     programRoute: '/program-actions',
//     applicationId: 1,
//     companyId: null,
//   ),
//   SysProgram(
//     sysProgramId: 3,
//     programName: 'Country Management',
//     labelName: 'Country Setup',
//     programRoute: '/country',
//     applicationId: 1,
//     companyId: 101, // specific company only
//   ),
//   SysProgram(
//     sysProgramId: 4,
//     programName: 'Business Activity',
//     labelName: 'Business Activity',
//     programRoute: '/business-activity',
//     applicationId: 2,
//     companyId: null,
//   ),
//   SysProgram(
//     sysProgramId: 5,
//     programName: 'Role Management',
//     labelName: 'Roles',
//     programRoute: '/roles',
//     applicationId: 2,
//     companyId: 101,
//   ),
//   SysProgram(
//     sysProgramId: 6,
//     programName: 'User Management',
//     labelName: 'Users',
//     programRoute: '/users',
//     applicationId: 2,
//     companyId: null,
//   ),
//   SysProgram(
//     sysProgramId: 7,
//     programName: 'Branch Dashboard',
//     labelName: 'Branch Dashboard',
//     programRoute: '/branch-dashboard',
//     applicationId: 3,
//     companyId: 102,
//   ),
//   SysProgram(
//     sysProgramId: 8,
//     programName: 'Kiosk Monitor',
//     labelName: 'Kiosk Monitor',
//     programRoute: '/kiosk-monitor',
//     applicationId: 3,
//     companyId: null,
//   ),
// ];

import 'package:voice_first_admin/features/Program_management/models/program_management_model.dart';

final List<ProgramManagementModel> mockPrograms = [
  ProgramManagementModel(
    sysProgramId: 1,
    programName: 'Program Management',
    labelName: 'Program Management',
    programRoute: '/programs',
    applicationId: 1,
    companyId: null,
    programActionIds: [1, 2, 3],
  ),
  ProgramManagementModel(
    sysProgramId: 2,
    programName: 'Country Management',
    labelName: 'Country Setup',
    programRoute: '/country',
    applicationId: 1,
    companyId: 101,
    programActionIds: [2, 4],
  ),
];
//   SysProgram(
//     sysProgramId: 2,   