import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/features/Program_management/models/program_management_model.dart';
import 'package:voice_first_admin/features/Program_management/presentation/providers/program_provider.dart';
import 'package:voice_first_admin/features/Applications/Providers/application_provider.dart';
import 'package:voice_first_admin/features/Program_Action/presentation/providers/program_action_lookup_provider.dart';

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

  final Set<int> _selectedActionIds = <int>{};

  @override
  void dispose() {
    _nameCtrl.dispose();
    _labelCtrl.dispose();
    _routeCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    final label = _labelCtrl.text.trim();
    var route = _routeCtrl.text.trim();

    if (name.isEmpty || label.isEmpty || route.isEmpty) {
      return;
    }
    // Validate route: first and last characters must be letters only
    // Allowed characters in between: letters, numbers, '/', '_' and '-'
    final routePattern = RegExp(r'^[A-Za-z](?:[A-Za-z0-9/_-]*[A-Za-z])?$');
    if (!routePattern.hasMatch(route)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Invalid route. It must start and end with a letter and not have special characters at the beginning or end.',
            ),
          ),
        );
      }
      return;
    }

    // final program = ProgramModel(
    //   sysProgramId: null,
    //   programName: name,
    //   labelName: label,
    //   programRoute: route,
    //   applicationId: _applicationId,
    //   companyId: null,
    //   programActionIds: _selectedActionIds.toList(),
    // );
    final program = ProgramModel(
      sysProgramId: null,
      programName: name,
      labelName: label,
      programRoute: route,
      applicationId: _applicationId,
      companyId: null,

      /// 🔥 CREATE fake actions from selected IDs
      actions: _selectedActionIds.map((id) {
        return ProgramActionSummary(actionId: id, actionName: '', active: true);
      }).toList(),
    );

    await ref.read(programProvider.notifier).add(program);
    if (mounted) Navigator.pop(context);
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
            Row(children: const [Text('Application'), SizedBox(width: 12)]),
            const SizedBox(height: 8),
            ref
                .watch(applicationProvider)
                .when(
                  data: (apps) {
                    final items = apps
                        .map(
                          (a) => DropdownMenuItem<int>(
                            value: a.platformId,
                            child: Text(a.platformName),
                          ),
                        )
                        .toList();
                    final current =
                        apps.any((a) => a.platformId == _applicationId)
                        ? _applicationId
                        : (apps.isNotEmpty ? apps.first.platformId : null);
                    if (current != null && current != _applicationId) {
                      // initialize default selection from API
                      _applicationId = current;
                    }
                    return DropdownButtonFormField<int>(
                      value: current,
                      decoration: const InputDecoration(
                        labelText: 'Application',
                        border: OutlineInputBorder(),
                      ),
                      items: items,
                      onChanged: (val) {
                        if (val == null) return;
                        setState(() => _applicationId = val);
                      },
                    );
                  },
                  loading: () => const LinearProgressIndicator(minHeight: 2),
                  error: (_, __) => const Text('Failed to load applications'),
                ),

            const SizedBox(height: 16),
            Text(
              'Program Actions',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            ref
                .watch(programActionLookupProvider)
                .when(
                  data: (actions) {
                    if (actions.isEmpty) {
                      return const Text('No actions available');
                    }
                    return Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: actions
                          .map(
                            (a) => FilterChip(
                              label: Text(a.actionName),
                              selected: _selectedActionIds.contains(a.actionId),
                              onSelected: (sel) {
                                setState(() {
                                  if (sel) {
                                    _selectedActionIds.add(a.actionId);
                                  } else {
                                    _selectedActionIds.remove(a.actionId);
                                  }
                                });
                              },
                            ),
                          )
                          .toList(),
                    );
                  },
                  loading: () => const LinearProgressIndicator(minHeight: 2),
                  error: (_, __) =>
                      const Text('Failed to load program actions'),
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
