// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:voice_first_admin/features/Business_activity/presentation/widgets/custom_snackbar.dart';
// import 'package:voice_first_admin/features/Program_Action/models/program_action_model.dart';
// import 'package:voice_first_admin/features/Program_Action/presentation/providers/program_action_mockdata.dart';
// import 'package:voice_first_admin/features/Program_management/models/program_management_model.dart';
// import 'package:voice_first_admin/features/Program_management/presentation/providers/program_provider.dart';
// import 'package:voice_first_admin/features/Program_management/presentation/providers/company_mockdata.dart';

// class ProgramDetailPage extends ConsumerStatefulWidget {
//   const ProgramDetailPage({super.key, required this.program});

//   final ProgramManagementModel program;

//   @override
//   ConsumerState<ProgramDetailPage> createState() => _ProgramDetailPageState();
// }

// class _ProgramDetailPageState extends ConsumerState<ProgramDetailPage> {
//   late TextEditingController _nameCtrl;
//   late TextEditingController _labelCtrl;
//   late TextEditingController _routeCtrl;
//   late int _applicationId;
//   late Set<int> _selectedActionIds;
//   int? _companyId;
//   bool _isEditing = false;

//   @override
//   void initState() {
//     super.initState();
//     _nameCtrl = TextEditingController(text: widget.program.programName);
//     _labelCtrl = TextEditingController(text: widget.program.labelName);
//     _routeCtrl = TextEditingController(text: widget.program.programRoute);
//     _applicationId = widget.program.applicationId;
//     _selectedActionIds = widget.program.programActionIds.toSet();
//     _companyId = widget.program.companyId;
//   }

//   @override
//   void dispose() {
//     _nameCtrl.dispose();
//     _labelCtrl.dispose();
//     _routeCtrl.dispose();
//     super.dispose();
//   }

//   void _save() {
//     final name = _nameCtrl.text.trim();
//     final label = _labelCtrl.text.trim();
//     var route = _routeCtrl.text.trim();

//     if (name.isEmpty || label.isEmpty || route.isEmpty) {
//       CustomSnackbar.show(
//         context,
//         message: 'Name, label and route are required',
//         type: SnackBarType.error,
//       );
//       return;
//     }
//     if (!route.startsWith('/')) {
//       route = '/$route';
//     }
//     if (_selectedActionIds.isEmpty) {
//       CustomSnackbar.show(
//         context,
//         message: 'Select at least one action',
//         type: SnackBarType.error,
//       );
//       return;
//     }

//     final updated = widget.program.copyWith(
//       programName: name,
//       labelName: label,
//       programRoute: route,
//       applicationId: _applicationId,
//       companyId: _companyId,
//       programActionIds: _selectedActionIds.toList(),
//     );

//     ref.read(programProvider.notifier).update(updated);

//     CustomSnackbar.show(
//       context,
//       message: 'Program updated successfully',
//       type: SnackBarType.success,
//     );

//     Navigator.pop(context);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     const primaryColor = Color(0xFF0D7FF2);

//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: primaryColor,
//         title: const Text('Program Details'),
//         actions: [
//           TextButton(
//             onPressed: () {
//               setState(() {
//                 _isEditing = !_isEditing;
//               });
//             },
//             child: Text(
//               _isEditing ? 'View' : 'Edit',
//               style: const TextStyle(color: Colors.white),
//             ),
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             TextField(
//               controller: _nameCtrl,
//               readOnly: !_isEditing,
//               decoration: const InputDecoration(
//                 labelText: 'Program Name',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 12),
//             TextField(
//               controller: _labelCtrl,
//               readOnly: !_isEditing,
//               decoration: const InputDecoration(
//                 labelText: 'Label Name',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 12),
//             TextField(
//               controller: _routeCtrl,
//               readOnly: !_isEditing,
//               decoration: const InputDecoration(
//                 labelText: 'Program Route (e.g. /programs)',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 16),
//             Row(
//               children: [
//                 const Text('Application'),
//                 const SizedBox(width: 12),
//                 DropdownButton<int>(
//                   value: _applicationId,
//                   items: const [
//                     DropdownMenuItem(value: 1, child: Text('App 1')),
//                     DropdownMenuItem(value: 2, child: Text('App 2')),
//                     DropdownMenuItem(value: 3, child: Text('App 3')),
//                   ],
//                   onChanged: !_isEditing
//                       ? null
//                       : (val) {
//                           if (val == null) return;
//                           setState(() => _applicationId = val);
//                         },
//                 ),
//               ],
//             ),
//             const SizedBox(height: 12),
//             Row(
//               children: [
//                 const Text('Company'),
//                 const SizedBox(width: 12),
//                 DropdownButton<int>(
//                   value: _companyId,
//                   hint: const Text('Select Company (optional)'),
//                   items: mockCompanies
//                       .map(
//                         (c) => DropdownMenuItem<int>(
//                           value: c.id,
//                           child: Text(c.name),
//                         ),
//                       )
//                       .toList(),
//                   onChanged: !_isEditing
//                       ? null
//                       : (val) {
//                           setState(() {
//                             _companyId = val;
//                           });
//                         },
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             Text(
//               'Program Actions',
//               style: theme.textTheme.titleMedium?.copyWith(
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//             const SizedBox(height: 8),
//             SizedBox(
//               height: 220,
//               child: ListView.builder(
//                 itemCount: mockProgramActions.length,
//                 itemBuilder: (context, index) {
//                   final ProgramActionModel a = mockProgramActions[index];
//                   final selected = _selectedActionIds.contains(
//                     a.ProgramActionId,
//                   );
//                   return CheckboxListTile(
//                     dense: true,
//                     value: selected,
//                     onChanged: !_isEditing
//                         ? null
//                         : (v) {
//                             setState(() {
//                               if (selected) {
//                                 _selectedActionIds.remove(a.ProgramActionId);
//                               } else {
//                                 _selectedActionIds.add(a.ProgramActionId);
//                               }
//                             });
//                           },
//                     title: Text(a.programActionName),
//                   );
//                 },
//               ),
//             ),
//             const SizedBox(height: 24),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.end,
//               children: [
//                 TextButton(
//                   onPressed: () => Navigator.pop(context),
//                   child: const Text('Cancel'),
//                 ),
//                 const SizedBox(width: 12),
//                 ElevatedButton(
//                   onPressed: _isEditing ? _save : null,
//                   child: const Text('Save'),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
