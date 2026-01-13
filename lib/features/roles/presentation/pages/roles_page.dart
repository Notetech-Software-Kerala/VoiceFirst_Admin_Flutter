import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/roles_provider.dart';
import '../widgets/add_role_dialog.dart';
import '../../models/role_model.dart';

class RolesPage extends ConsumerWidget {
  const RolesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rolesState = ref.watch(rolesProvider);
    final theme = Theme.of(context);

    // Refresh function
    Future<void> _refresh() async {
      await ref.read(rolesProvider.notifier).loadRoles();
    }

    // Add/Edit Dialog
    void _showAddEditDialog(RoleModel? role) async {
      final newRole = await showDialog<RoleModel>(
        context: context,
        builder: (_) => AddRoleDialog(role: role),
      );

      if (newRole != null) {
        if (role == null) {
          ref.read(rolesProvider.notifier).addRole(newRole);
        } else {
          ref.read(rolesProvider.notifier).updateRole(newRole);
        }
      }
    }

    void _deleteRole(String id) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Confirm Delete"),
          content: const Text("Are you sure you want to delete this role?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                ref.read(rolesProvider.notifier).deleteRole(id);
                Navigator.pop(ctx);
              },
              child: const Text("Delete"),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage System Roles"),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _refresh),
        ],
      ),
      body: rolesState.isLoading && rolesState.roles.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : rolesState.error != null
          ? Center(child: Text("Error: ${rolesState.error}"))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: rolesState.roles.length,
              itemBuilder: (context, index) {
                final role = rolesState.roles[index];
                return Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: theme.dividerColor),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    title: Text(
                      role.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Wrap(
                        spacing: 8,
                        children: [
                          _AccessChip(
                            label: "All Locs",
                            enabled: role.allLocationAccess,
                          ),
                          _AccessChip(
                            label: "All Issues",
                            enabled: role.allIssueAccess,
                          ),
                        ],
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          color: theme.primaryColor,
                          onPressed: () => _showAddEditDialog(role),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          color: Colors.red,
                          onPressed: () => _deleteRole(role.id!),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(null),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _AccessChip extends StatelessWidget {
  final String label;
  final bool enabled;

  const _AccessChip({required this.label, required this.enabled});

  @override
  Widget build(BuildContext context) {
    // Only show if enabled? Or show greyed out?
    // User's original code showed check/close icons. Let's make it look nicer with Chips.
    final theme = Theme.of(context);
    final color = enabled ? Colors.green : theme.disabledColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            enabled ? Icons.check_circle : Icons.cancel,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
