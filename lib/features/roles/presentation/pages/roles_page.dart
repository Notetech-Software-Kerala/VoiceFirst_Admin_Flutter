import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/roles_provider.dart';
import 'create_role_page.dart';
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

    // Add/Edit Dialog (Now Full Screen Page)
    void _showAddEditDialog(RoleModel? role) async {
      final newRole = await Navigator.push<RoleModel>(
        context,
        MaterialPageRoute(builder: (context) => CreateRolePage(role: role)),
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

    // Responsive check for menu button
    final isDesktop = MediaQuery.of(context).size.width > 900;

    return Stack(
      children: [
        Column(
          children: [
            // 1. Custom Header
            Container(
              height:
                  90 +
                  MediaQuery.of(context).padding.top, // Adjust for status bar
              padding: EdgeInsets.fromLTRB(
                16,
                MediaQuery.of(context).padding.top + 16,
                16,
                12,
              ),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor.withValues(alpha: 0.95),
                border: Border(bottom: BorderSide(color: theme.dividerColor)),
              ),
              child: Row(
                children: [
                  // Menu Button (Mobile) or Shield Icon (Desktop)
                  if (!isDesktop)
                    InkWell(
                      onTap: () => Scaffold.of(context).openDrawer(),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          border: Border.all(color: theme.dividerColor),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.menu_rounded,
                          color: theme.iconTheme.color,
                        ),
                      ),
                    )
                  else
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.shield, color: theme.primaryColor),
                    ),

                  const SizedBox(width: 16),

                  // Title
                  Expanded(
                    child: Text(
                      "Role Management",
                      textAlign: isDesktop ? TextAlign.left : TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                  ),

                  // Refresh Button
                  InkWell(
                    onTap: _refresh,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: theme.dividerColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.refresh, color: theme.iconTheme.color),
                    ),
                  ),
                ],
              ),
            ),

            // 2. Main Body Content
            Expanded(
              child: Column(
                children: [
                  // Sticky Search Bar
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    color: theme.scaffoldBackgroundColor,
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          prefixIcon: Icon(
                            Icons.search,
                            color: theme.colorScheme.secondary,
                          ),
                          hintText: "Search roles...",
                          hintStyle: TextStyle(
                            color: theme.colorScheme.secondary,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // List
                  Expanded(
                    child: rolesState.isLoading && rolesState.roles.isEmpty
                        ? const Center(child: CircularProgressIndicator())
                        : rolesState.error != null
                        ? Center(child: Text("Error: ${rolesState.error}"))
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 120),
                            itemCount: rolesState.roles.length + 1,
                            itemBuilder: (context, index) {
                              if (index == 0)
                                return const _SectionHeader("System Roles");
                              final role = rolesState.roles[index - 1];
                              final isSystem = role.name.toLowerCase().contains(
                                "admin",
                              );

                              return _RoleCard(
                                title: role.name,
                                description: isSystem
                                    ? "Manage system-wide settings and users."
                                    : "Access to specific modules and features.",
                                icon: isSystem
                                    ? Icons.security
                                    : Icons.person_outline,
                                iconColor: isSystem
                                    ? theme.primaryColor
                                    : Colors.grey,
                                borderSideColor: isSystem
                                    ? theme.primaryColor
                                    : Colors.transparent,
                                isSystem: isSystem,
                                actions: [
                                  _EditButton(
                                    onTap: () => _showAddEditDialog(role),
                                  ),
                                  const SizedBox(width: 8),
                                  _DeleteButton(
                                    onTap: () => _deleteRole(role.id!),
                                  ),
                                ],
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),

        // 3. Floating Action Button
        Positioned(
          bottom: 24, // above bottom nav
          right: 16,
          child: FloatingActionButton(
            onPressed: () => _showAddEditDialog(null),
            backgroundColor: theme.primaryColor,
            elevation: 4,
            // Ensure it sits above other elements
            heroTag: "addRoleFab",
            child: const Icon(Icons.add, color: Colors.white, size: 30),
          ),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// Helper Widgets
// -----------------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 8, left: 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: Theme.of(context).colorScheme.secondary,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color iconColor;
  final Color borderSideColor;
  final bool isSystem;
  final List<Widget>? actions;

  const _RoleCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.iconColor,
    required this.borderSideColor,
    this.isSystem = false,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: borderSideColor != Colors.transparent
            ? Border(left: BorderSide(color: borderSideColor, width: 4))
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon Box
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isDark
                  ? iconColor.withValues(alpha: 0.15)
                  : iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 16),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (isSystem) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: theme.primaryColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          "SYSTEM",
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: theme.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: theme.colorScheme.secondary,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Actions
          if (actions != null)
            Padding(
              padding: const EdgeInsets.only(left: 8, top: 4),
              child: Row(children: actions!),
            ),
        ],
      ),
    );
  }
}

class _EditButton extends StatelessWidget {
  final VoidCallback onTap;
  const _EditButton({required this.onTap});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(99),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.edit,
          size: 18,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }
}

class _DeleteButton extends StatelessWidget {
  final VoidCallback onTap;

  const _DeleteButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(99),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.delete, size: 18, color: Colors.red),
      ),
    );
  }
}
