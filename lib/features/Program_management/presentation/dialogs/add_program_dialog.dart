import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/features/Program_Action/models/program_action_model.dart';
import 'package:voice_first_admin/features/Program_Action/presentation/providers/program_action_mockdata.dart';
import 'package:voice_first_admin/features/Program_management/models/program_management_model.dart';
import 'package:voice_first_admin/features/Program_management/presentation/providers/program_provider.dart';

class AddProgramDialog {
  static Future<ProgramManagementModel?> show(
    BuildContext context,
    WidgetRef ref,
  ) {
    final nameCtrl = TextEditingController();
    final labelCtrl = TextEditingController();
    final routeCtrl = TextEditingController();

    int applicationId = 1;
    int? companyId;
    final selectedActionIds = <int>{};

    return showDialog<ProgramManagementModel>(
      context: context,
      useRootNavigator: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add Program'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Program Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: labelCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Label Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: routeCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Program Route (e.g. /programs)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Text('Application'),
                        const SizedBox(width: 12),
                        DropdownButton<int>(
                          value: applicationId,
                          items: const [
                            DropdownMenuItem(value: 1, child: Text('App 1')),
                            DropdownMenuItem(value: 2, child: Text('App 2')),
                            DropdownMenuItem(value: 3, child: Text('App 3')),
                          ],
                          onChanged: (val) {
                            if (val == null) return;
                            setState(() => applicationId = val);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Company Id (optional)',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        if (value.trim().isEmpty) {
                          companyId = null;
                        } else {
                          companyId = int.tryParse(value.trim());
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Program Actions',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 180,
                      width: 350,
                      child: ListView.builder(
                        itemCount: mockProgramActions.length,
                        itemBuilder: (context, index) {
                          final ProgramActionModel a =
                              mockProgramActions[index];
                          final selected = selectedActionIds.contains(
                            a.ProgramActionId,
                          );
                          return CheckboxListTile(
                            dense: true,
                            value: selected,
                            onChanged: (v) {
                              setState(() {
                                if (selected) {
                                  selectedActionIds.remove(a.ProgramActionId);
                                } else {
                                  selectedActionIds.add(a.ProgramActionId);
                                }
                              });
                            },
                            title: Text(a.programActionName),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final name = nameCtrl.text.trim();
                    final label = labelCtrl.text.trim();
                    var route = routeCtrl.text.trim();
                    if (name.isEmpty || label.isEmpty || route.isEmpty) {
                      return;
                    }
                    if (!route.startsWith('/')) {
                      route = '/$route';
                    }

                    final state = ref.read(programProvider);
                    final nextId =
                        (state.all
                            .where((p) => p.sysProgramId != null)
                            .map((p) => p.sysProgramId!)
                            .fold<int>(0, (max, id) => id > max ? id : max)) +
                        1;

                    final program = ProgramManagementModel(
                      sysProgramId: nextId,
                      programName: name,
                      labelName: label,
                      programRoute: route,
                      applicationId: applicationId,
                      companyId: companyId,
                      programActionIds: selectedActionIds.toList(),
                    );

                    Navigator.pop(dialogContext, program);
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
