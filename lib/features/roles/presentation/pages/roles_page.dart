import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/core/widgets/standard_list_card.dart';
import 'package:voice_first_admin/core/widgets/standard_page_layout.dart';
import '../providers/roles_provider.dart';
import 'create_role_page.dart';
import 'package:voice_first_admin/core/widgets/delete_bottom_sheet.dart';
import '../../models/role_model.dart';

class RolesPage extends ConsumerStatefulWidget {
  const RolesPage({super.key});

  @override
  ConsumerState<RolesPage> createState() => _RolesPageState();
}

class _RolesPageState extends ConsumerState<RolesPage> {
  // Add Search Controller
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
    // TODO: Connect to provider if backend search is needed
    // ref.read(rolesProvider.notifier).searchRoles(query);
  }

  @override
  Widget build(BuildContext context) {
    final rolesState = ref.watch(rolesProvider);
    final theme = Theme.of(context);

    // Filter roles locally for now since provider might not implement search
    final filteredRoles = rolesState.roles.where((role) {
      if (_searchQuery.isEmpty) return true;
      return role.name.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

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

    void _deleteRole(String id, String name) {
      showDeleteBottomSheet(
        context: context,
        itemName: name,
        title: "DELETE ROLE?",
        onDelete: () {
          ref.read(rolesProvider.notifier).deleteRole(id);
        },
      );
    }

    // Responsive check for menu button
    final isDesktop = MediaQuery.of(context).size.width > 900;

    return StandardPageLayout(
      title: "Role Management",
      // Connect Search Controller to Layout
      searchController: _searchController,
      onSearchChanged: _onSearchChanged,
      searchHint: "Search roles...",
      onRefresh: _refresh,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(null),
        backgroundColor: theme.primaryColor,
        elevation: 4,
        heroTag: "addRoleFab",
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
      actions: [
        if (isDesktop)
          Container(
            margin: const EdgeInsets.only(right: 16),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: theme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.shield, color: theme.primaryColor),
          ),
      ],
      slivers: [
        if (rolesState.isLoading && rolesState.roles.isEmpty)
          const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          )
        else if (rolesState.error != null)
          SliverFillRemaining(
            child: Center(child: Text("Error: ${rolesState.error}")),
          )
        // If filtered list is empty but loaded
        else if (filteredRoles.isEmpty)
          SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 64, color: theme.disabledColor),
                  const SizedBox(height: 16),
                  Text(
                    "No roles found",
                    style: TextStyle(color: theme.disabledColor),
                  ),
                ],
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 120),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                if (index == 0) return const _SectionHeader("System Roles");
                // Use filtered list
                final role = filteredRoles[index - 1];
                final isSystem = role.name.toLowerCase().contains("admin");

                return StandardListCard(
                  title: role.name,
                  subtitle: isSystem
                      ? "Manage system-wide settings and users."
                      : "Access to specific modules and features.",
                  leading: StandardIconBox(
                    icon: isSystem ? Icons.security : Icons.person_outline,
                    color: isSystem ? theme.primaryColor : Colors.grey,
                  ),
                  trailing: isSystem
                      ? Container(
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
                        )
                      : null,
                  actions: [
                    StandardActionButton(
                      icon: Icons.edit,
                      color: theme.primaryColor,
                      onTap: () => _showAddEditDialog(role),
                    ),
                    const SizedBox(width: 8),
                    StandardActionButton(
                      icon: Icons.delete,
                      color: Colors.red,
                      onTap: () => _deleteRole(role.id!, role.name),
                    ),
                  ],
                );
              }, childCount: filteredRoles.length + 1),
            ),
          ),
      ],
    );
  }
}

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
