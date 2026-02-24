import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/role_model.dart';
import '../providers/roles_provider.dart';
import 'create_role_page.dart';
import 'package:voice_first_admin/core/widgets/delete_bottom_sheet.dart';

class RoleDetailsPage extends ConsumerStatefulWidget {
  final RoleModel role;

  const RoleDetailsPage({super.key, required this.role});

  @override
  ConsumerState<RoleDetailsPage> createState() => _RoleDetailsPageState();
}

class _RoleDetailsPageState extends ConsumerState<RoleDetailsPage> {
  late RoleModel _role;

  @override
  void initState() {
    super.initState();
    _role = widget.role;
  }

  void _deleteRole() {
    showDeleteBottomSheet(
      context: context,
      itemName: _role.roleName,
      title: "DELETE ROLE?",
      onDelete: () {
        ref.read(rolesProvider.notifier).deleteRole(_role.id);
        Navigator.pop(context); // Close details page after delete
      },
    );
  }

  void _editRole() async {
    final updatedRole = await Navigator.push<RoleModel>(
      context,
      MaterialPageRoute(builder: (context) => CreateRolePage(role: _role)),
    );

    if (updatedRole != null) {
      ref.read(rolesProvider.notifier).updateRole(updatedRole);
      setState(() {
        _role = updatedRole;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      // 1. Sticky Header
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor.withValues(alpha: 0.9),
        elevation: 0,
        scrolledUnderElevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: theme.dividerColor, height: 1),
        ),
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          borderRadius: BorderRadius.circular(50),
          child: Container(
            margin: const EdgeInsets.all(8),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.grey[100],
            ),
            child: const Icon(Icons.arrow_back_ios_new, size: 20),
          ),
        ),
        title: const Text(
          "Role Details",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: theme.primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: theme.primaryColor.withValues(alpha: 0.2),
              ),
            ),
            child: Icon(Icons.shield, color: theme.primaryColor, size: 20),
          ),
        ],
      ),

      // 2. Main Content
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
            children: [
              // Info Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.dividerColor),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _LabelText("Role Name"),
                    const SizedBox(height: 4),
                    Text(
                      _role.roleName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (_role.rolePurpose != null &&
                        _role.rolePurpose!.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _LabelText("Purpose"),
                      const SizedBox(height: 4),
                      Text(
                        _role.rolePurpose!,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: theme.textTheme.bodyMedium?.color,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 24),
              _SectionHeader("Configuration"),
              const SizedBox(height: 8),

              // Expandable Cards
              _ExpandableCard(
                title: "General Status",
                subtitle: _role.active ? "Active Role" : "Inactive Role",
                icon: Icons.info_outline,
                isExpanded: true,
                children: [
                  _DetailGridItem(
                    label: "Status",
                    value: _role.active ? "Active" : "Inactive",
                  ),
                  _DetailGridItem(
                    label: "Mandatory",
                    value: _role.isMandatory ? "Yes" : "No",
                  ),
                  _DetailGridItem(
                    label: "Platform ID",
                    value: _role.platformId?.toString() ?? "N/A",
                  ),
                  _DetailGridItem(
                    label: "Deleted",
                    value: _role.deleted ? "Yes" : "No",
                  ),
                ],
              ),

              const SizedBox(height: 12),
              _ExpandableCard(
                title: "Permissions",
                subtitle: "${_role.permissions.length} Programs Configured",
                icon: Icons.security,
                isExpanded: false,
                children: _role.permissions
                    .map(
                      (p) => _DetailGridItem(
                        label: "Program ID: ${p.programId}",
                        value: [
                          if (p.create) "C",
                          if (p.view) "R",
                          if (p.update) "U",
                          if (p.delete) "D",
                        ].join(" | "),
                      ),
                    )
                    .toList(),
              ),

              const SizedBox(height: 12),
              _ExpandableCard(
                title: "Audit Trail",
                subtitle: "Created by: ${_role.createdUser ?? 'Unknown'}",
                icon: Icons.history,
                isExpanded: false,
                children: [
                  _DetailGridItem(
                    label: "Created By",
                    value: _role.createdUser ?? "Unknown",
                  ),
                  _DetailGridItem(
                    label: "Created Date",
                    value:
                        _role.createdDate?.toString().split(' ')[0] ??
                        "Unknown",
                  ),
                  _DetailGridItem(
                    label: "Modified By",
                    value: _role.modifiedUser ?? "N/A",
                  ),
                  _DetailGridItem(
                    label: "Modified Date",
                    value:
                        _role.modifiedDate?.toString().split(' ')[0] ?? "N/A",
                  ),
                ],
              ),
            ],
          ),

          // 3. Floating Footer
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 30),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    theme.scaffoldBackgroundColor,
                    theme.scaffoldBackgroundColor.withValues(alpha: 0.95),
                    theme.scaffoldBackgroundColor.withValues(alpha: 0.0),
                  ],
                ),
              ),
              child: Row(
                children: [
                  // Delete Button
                  Expanded(
                    child: TextButton.icon(
                      onPressed: _deleteRole,
                      icon: Icon(
                        Icons.delete_outline,
                        color: theme.colorScheme.error,
                      ),
                      label: Text(
                        "Delete",
                        style: TextStyle(
                          color: theme.colorScheme.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: theme.colorScheme.error.withValues(
                          alpha: 0.1,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Edit Button
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _editRole,
                      icon: const Icon(Icons.edit_outlined, size: 20),
                      label: const Text(
                        "Edit Role",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 4,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Helper Widgets
// -----------------------------------------------------------------------------

class _LabelText extends StatelessWidget {
  final String text;
  const _LabelText(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5,
        color: Theme.of(context).iconTheme.color,
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 2.0,
          color: Theme.of(context).iconTheme.color,
        ),
      ),
    );
  }
}

class _ExpandableCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isExpanded;
  final List<Widget>? children;

  const _ExpandableCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isExpanded,
    this.children,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.primaryColor;

    // Determine styles based on state
    final borderColor = isExpanded ? primary : theme.dividerColor;
    final borderWidth = isExpanded ? 2.0 : 1.0;
    final iconBg = isExpanded
        ? primary.withValues(alpha: 0.1)
        : (theme.brightness == Brightness.dark
              ? Colors.grey[800]
              : Colors.grey[100]);
    final iconColor = isExpanded ? primary : theme.iconTheme.color;
    final subtitleColor = isExpanded ? primary : theme.iconTheme.color;

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: borderWidth),
        boxShadow: isExpanded
            ? [
                BoxShadow(
                  color: primary.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: isExpanded,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: subtitleColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          trailing: Icon(
            isExpanded ? Icons.expand_less : Icons.expand_more,
            color: Colors.grey,
          ),
          children: children != null
              ? [
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 2.2,
                    children: children!,
                  ),
                ]
              : [],
        ),
      ),
    );
  }
}

class _DetailGridItem extends StatelessWidget {
  final String label;
  final String value;

  const _DetailGridItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF101922) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: theme.iconTheme.color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
