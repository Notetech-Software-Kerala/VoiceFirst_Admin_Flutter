import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/role_model.dart';
import '../../data/repositories/roles_repository.dart';

class AddRoleDialog extends ConsumerStatefulWidget {
  final RoleModel? role;

  const AddRoleDialog({super.key, this.role});

  @override
  ConsumerState<AddRoleDialog> createState() => _AddRoleDialogState();
}

class _AddRoleDialogState extends ConsumerState<AddRoleDialog> {
  final _controller = TextEditingController();
  bool allLocationAccess = false;
  bool allIssueAccess = false;

  List<ProgramModel> availablePrograms = [];
  List<ProgramPermissionModel> permissions = [];
  bool loading = true;
  bool submitting = false;

  @override
  void initState() {
    super.initState();
    _loadPrograms();
  }

  Future<void> _loadPrograms() async {
    // Ideally this comes from a ProgramsProvider, but for now we fetch via repository direct call or similar
    // We will use the repository provider
    try {
      final repo = ref.read(rolesRepositoryProvider);
      availablePrograms = await repo.getPrograms();

      permissions = availablePrograms.map((program) {
        final existing = widget.role?.permissions.firstWhere(
          (p) => p.programId == program.id,
          orElse: () => ProgramPermissionModel(
            programId: program.id,
            label: program.label,
          ),
        );

        return ProgramPermissionModel(
          id: existing?.id,
          programId: program.id,
          label: program.label,
          create: existing?.create ?? false,
          update: existing?.update ?? false,
          view: existing?.view ?? false,
          delete: existing?.delete ?? false,
          download: existing?.download ?? false,
          email: existing?.email ?? false,
          // Capabilities from ProgramModel
          canCreate: program.create,
          canUpdate: program.update,
          canView: program.view,
          canDelete: program.delete,
          canDownload: program.download,
          canEmail: program.email,
        );
      }).toList();

      if (widget.role != null) {
        _controller.text = widget.role!.name;
        allLocationAccess = widget.role!.allLocationAccess;
        allIssueAccess = widget.role!.allIssueAccess;
      }
    } catch (e) {
      debugPrint("Error loading programs: $e");
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  void _submit() {
    final name = _controller.text.trim();
    if (name.isEmpty) return;

    final newRole = RoleModel(
      id: widget.role?.id,
      name: name,
      allLocationAccess: allLocationAccess,
      allIssueAccess: allIssueAccess,
      permissions: permissions,
      status: widget.role?.status ?? true,
    );

    Navigator.pop(context, newRole);
  }

  Widget _checkbox(
    String label,
    bool value,
    bool enabled,
    ValueChanged<bool?> onChanged,
  ) {
    // Compact checkbox for the matrix
    return InkWell(
      onTap: enabled ? () => onChanged(!value) : null,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: value,
                onChanged: enabled ? onChanged : null,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: enabled ? null : Theme.of(context).disabledColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text(widget.role == null ? 'Add Role' : 'Edit Role'),
      content: loading
          ? const SizedBox(
              height: 100,
              child: Center(child: CircularProgressIndicator()),
            )
          : SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        labelText: 'Role Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('All Location Access'),
                      value: allLocationAccess,
                      onChanged: (val) =>
                          setState(() => allLocationAccess = val),
                      contentPadding: EdgeInsets.zero,
                    ),
                    SwitchListTile(
                      title: const Text('All Issue Access'),
                      value: allIssueAccess,
                      onChanged: (val) => setState(() => allIssueAccess = val),
                      contentPadding: EdgeInsets.zero,
                    ),
                    const Divider(height: 32),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Program Permissions",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 16),

                    ...permissions.map(
                      (perm) => Card(
                        elevation: 0,
                        color: theme.colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.3),
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                perm.label ?? perm.programId,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  _checkbox(
                                    'Create',
                                    perm.create,
                                    perm.canCreate,
                                    (v) => setState(() => perm.create = v!),
                                  ),
                                  _checkbox(
                                    'Update',
                                    perm.update,
                                    perm.canUpdate,
                                    (v) => setState(() => perm.update = v!),
                                  ),
                                  _checkbox(
                                    'View',
                                    perm.view,
                                    perm.canView,
                                    (v) => setState(() => perm.view = v!),
                                  ),
                                  _checkbox(
                                    'Delete',
                                    perm.delete,
                                    perm.canDelete,
                                    (v) => setState(() => perm.delete = v!),
                                  ),
                                  _checkbox(
                                    'Email',
                                    perm.email,
                                    perm.canEmail,
                                    (v) => setState(() => perm.email = v!),
                                  ),
                                  _checkbox(
                                    'DL',
                                    perm.download,
                                    perm.canDownload,
                                    (v) => setState(() => perm.download = v!),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(onPressed: _submit, child: const Text('Save')),
      ],
    );
  }
}
