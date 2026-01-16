import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/features/Program_Action/models/program_action_model.dart';
import 'package:voice_first_admin/features/Program_Action/presentation/providers/program_action_mockdata.dart';
import 'package:voice_first_admin/features/Program_management/models/program_management_model.dart';
import 'package:voice_first_admin/features/Program_management/presentation/providers/program_provider.dart';
import 'package:voice_first_admin/features/Program_management/presentation/providers/company_mockdata.dart';

class AddProgramPage extends ConsumerStatefulWidget {
  const AddProgramPage({super.key});

  @override
  ConsumerState<AddProgramPage> createState() => _AddProgramPageState();
}

class _AddProgramPageState extends ConsumerState<AddProgramPage> {
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _labelCtrl = TextEditingController();
  final TextEditingController _routeCtrl = TextEditingController();

  int _applicationId = 1;
  int? _companyId;
  final Set<int> _selectedActionIds = <int>{};

  @override
  void dispose() {
    _nameCtrl.dispose();
    _labelCtrl.dispose();
    _routeCtrl.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameCtrl.text.trim();
    final label = _labelCtrl.text.trim();
    var route = _routeCtrl.text.trim();

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
      applicationId: _applicationId,
      companyId: _companyId,
      programActionIds: _selectedActionIds.toList(),
    );

    ref.read(programProvider.notifier).add(program);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const primaryColor = Color(0xFF0D7FF2);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text('Add Program'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Program Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _labelCtrl,
              decoration: const InputDecoration(
                labelText: 'Label Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _routeCtrl,
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
                  value: _applicationId,
                  items: const [
                    DropdownMenuItem(value: 1, child: Text('App 1')),
                    DropdownMenuItem(value: 2, child: Text('App 2')),
                    DropdownMenuItem(value: 3, child: Text('App 3')),
                  ],
                  onChanged: (val) {
                    if (val == null) return;
                    setState(() => _applicationId = val);
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text('Company'),
                const SizedBox(width: 12),
                DropdownButton<int>(
                  value: _companyId,
                  hint: const Text('Select Company (optional)'),
                  items: mockCompanies
                      .map(
                        (c) => DropdownMenuItem<int>(
                          value: c.id,
                          child: Text(c.name),
                        ),
                      )
                      .toList(),
                  onChanged: (val) {
                    setState(() {
                      _companyId = val;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Program Actions',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 220,
              child: ListView.builder(
                itemCount: mockProgramActions.length,
                itemBuilder: (context, index) {
                  final ProgramActionModel a = mockProgramActions[index];
                  final selected = _selectedActionIds.contains(
                    a.ProgramActionId,
                  );
                  return CheckboxListTile(
                    dense: true,
                    value: selected,
                    onChanged: (v) {
                      setState(() {
                        if (selected) {
                          _selectedActionIds.remove(a.ProgramActionId);
                        } else {
                          _selectedActionIds.add(a.ProgramActionId);
                        }
                      });
                    },
                    title: Text(a.programActionName),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(onPressed: _save, child: const Text('Save')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
