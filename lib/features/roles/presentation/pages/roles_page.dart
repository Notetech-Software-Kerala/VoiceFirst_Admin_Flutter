import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/core/widgets/advanced_search_header.dart';
import 'package:voice_first_admin/core/widgets/standard_pagination_controls.dart';
import 'package:voice_first_admin/core/widgets/standard_list_card.dart';
import 'package:voice_first_admin/core/widgets/standard_page_layout.dart';
import 'package:voice_first_admin/core/widgets/standard_icon_box.dart';
import '../widgets/roles_filter_bottom_sheet.dart';
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    // ref.read(rolesProvider.notifier).updateSearchText(query);
    // For better experience, we might want to debounce this or let the user hit enter/search button
    // The AdvancedSearchHeader usually triggers onChanged immediately.
    // Given the API nature, let's update state immediately or maybe rely on the search button?
    // User requirement mentioned 'searchBy' and 'searchText', so maybe typing is live.
    // I'll update it live.
    ref.read(rolesProvider.notifier).updateSearchText(query);
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => RolesFilterBottomSheet(
        currentFilter: ref.read(rolesProvider).filter,
        onApply: (filter) {
          ref.read(rolesProvider.notifier).setFilter(filter);
        },
      ),
    );
  }

  Future<void> _refresh() async {
    await ref.read(rolesProvider.notifier).loadRoles();
  }

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

  @override
  Widget build(BuildContext context) {
    final rolesState = ref.watch(rolesProvider);
    final roles = rolesState.roles;
    final theme = Theme.of(context);
    final isDesktop = MediaQuery.of(context).size.width > 900;

    return StandardPageLayout(
      title: "Role Management",
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
      bottom: AdvancedSearchHeader(
        searchController: _searchController,
        onSearchChanged: _onSearchChanged,
        onFilterTap: _showFilterSheet,
        onRefresh: _refresh,
        hintText: "Search roles...",
      ),
      slivers: [
        if (rolesState.isLoading && roles.isEmpty)
          const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          )
        else if (rolesState.error != null)
          SliverFillRemaining(
            child: Center(child: Text("Error: ${rolesState.error}")),
          )
        else if (roles.isEmpty)
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
                final role = roles[index];
                final isActive = role.active;

                return StandardListCard(
                  title: role.roleName,
                  subtitle: isActive ? "Active Role" : "Inactive Role",
                  leading: StandardIconBox(
                    icon: Icons.shield,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.blue,
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isActive
                          ? Colors.green.withOpacity(0.1)
                          : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      isActive ? "Active" : "Inactive",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isActive ? Colors.green : Colors.grey,
                      ),
                    ),
                  ),
                  actions: [
                    StandardActionButton(
                      icon: Icons.edit,
                      color: Colors.blue,
                      onTap: () => _showAddEditDialog(role),
                    ),
                    const SizedBox(width: 8),
                    StandardActionButton(
                      icon: Icons.delete,
                      color: Colors.red,
                      onTap: () => _deleteRole(role.id, role.roleName),
                    ),
                  ],
                );
              }, childCount: roles.length),
            ),
          ),
      ],
      bottomNavigationBar: StandardPaginationControls(
        currentPage: rolesState.filter.pageNumber,
        totalPages: rolesState.totalPages,
        onPageChanged: (page) =>
            ref.read(rolesProvider.notifier).updatePage(page),
      ),
    );
  }
}
