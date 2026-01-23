import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/features/Program_management/models/program_management_model.dart';
import 'package:voice_first_admin/features/Program_management/presentation/providers/program_provider.dart';

class EditProgramDialog {
  static void show(
    BuildContext context,
    WidgetRef ref,
    ProgramManagementModel program,
  ) {
    final nameCtrl = TextEditingController(text: program.programName);
    final labelCtrl = TextEditingController(text: program.labelName);
    final routeCtrl = TextEditingController(text: program.programRoute);

    int applicationId = program.applicationId;
    int? companyId = program.companyId;

    showDialog(
      context: context,
      useRootNavigator: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Edit Program'),
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
                        labelText: 'Program Route',
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
                      controller: TextEditingController(
                        text: companyId?.toString() ?? '',
                      ),
                      onChanged: (value) {
                        if (value.trim().isEmpty) {
                          companyId = null;
                        } else {
                          companyId = int.tryParse(value.trim());
                        }
                      },
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

                    final updated = program.copyWith(
                      programName: name,
                      labelName: label,
                      programRoute: route,
                      applicationId: applicationId,
                      companyId: null,
                    );

                    // ref.read(programProvider.notifier).update(updated);
                    ref
                        .read(programProvider.notifier)
                        .update(updated, updateBasic: true);

                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Update'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
