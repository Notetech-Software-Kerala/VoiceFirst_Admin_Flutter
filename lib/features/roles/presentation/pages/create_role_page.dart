import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/role_model.dart';
import '../../data/repositories/roles_repository.dart';

class CreateRolePage extends ConsumerStatefulWidget {
  final RoleModel? role;

  const CreateRolePage({super.key, this.role});

  @override
  ConsumerState<CreateRolePage> createState() => _CreateRolePageState();
}

class _CreateRolePageState extends ConsumerState<CreateRolePage> {
  // State for expanded cards
  final Map<String, bool> _expandedModules = {};

  // Form State
  late TextEditingController _nameController;
  late TextEditingController
  _descController; // Mock description for now as it's not in model

  // Data State
  List<ProgramModel> availablePrograms = [];
  List<ProgramPermissionModel> permissions = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.role?.name ?? "");
    _descController = TextEditingController(
      text: "Full access to user tickets and basic configuration tools.",
    );
    _loadData();
  }

  Future<void> _loadData() async {
    // Mimic the load logic we had in the dialog
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

        // Initialize expanded state
        _expandedModules[program.label] = false;

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
          canCreate: program.create,
          canUpdate: program.update,
          canView: program.view,
          canDelete: program.delete,
          canDownload: program.download,
          canEmail: program.email,
        );
      }).toList();

      // Expand the first one by default
      if (permissions.isNotEmpty) {
        _expandedModules[permissions.first.label!] = true;
      }
    } catch (e) {
      debugPrint("Error loading programs: $e");
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  void _toggleModule(String module) {
    setState(() {
      _expandedModules[module] = !(_expandedModules[module] ?? false);
    });
  }

  void _submit() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Role Name is required")));
      return;
    }

    final newRole = RoleModel(
      id: widget.role?.id,
      name: name,
      // Description is not in model yet, ignoring for now
      allLocationAccess:
          false, // Defaulting as UI doesn't have it in this design
      allIssueAccess: false,
      permissions: permissions,
      status: widget.role?.status ?? true,
    );

    Navigator.pop(context, newRole);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Calculate progress (mock logic: name filled + at least one permission)
    double progress = 0.0;
    if (_nameController.text.isNotEmpty) progress += 0.2;
    int permissionsSet = permissions
        .where((p) => p.create || p.update || p.view || p.delete)
        .length;
    if (permissionsSet > 0)
      progress +=
          0.8 *
          (permissionsSet / (permissions.isEmpty ? 1 : permissions.length));
    progress = progress.clamp(0.0, 1.0);

    return Scaffold(
      // 1. Top App Bar (Sticky)
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(140), // Taller for progress bar
        child: Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor.withValues(alpha: 0.9),
            border: Border(bottom: BorderSide(color: theme.dividerColor)),
          ),
          child: SafeArea(
            bottom: false,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Header Row
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          InkWell(
                            onTap: () => Navigator.pop(context),
                            borderRadius: BorderRadius.circular(20),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(
                                Icons.arrow_back,
                                size: 24,
                                color: theme.iconTheme.color,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            widget.role == null ? "Create Role" : "Edit Role",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primaryColor,
                          foregroundColor: Colors.white,
                          elevation: 4,
                          shape: const StadiumBorder(),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                        ),
                        child: const Text(
                          "Save",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                // Progress Bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Role setup completion",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: theme.hintColor,
                            ),
                          ),
                          Text(
                            "${(progress * 100).toInt()}%",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: theme.primaryColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 6,
                          backgroundColor: isDark
                              ? Colors.grey[800]
                              : Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            theme.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      // 2. Main Content
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                ListView(
                  padding: const EdgeInsets.only(
                    bottom: 120,
                  ), // Space for sticky footer
                  children: [
                    const SizedBox(height: 16),

                    // Role Info Section
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: theme.dividerColor),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _LabelText("Role Name"),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _nameController,
                            onChanged: (v) => setState(
                              () {},
                            ), // trigger rebuild for progress bar
                            style: const TextStyle(fontWeight: FontWeight.w500),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: theme
                                  .cardColor, // Using theme inputs usually defined globally, but here respecting design
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: theme.dividerColor,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: theme.dividerColor,
                                ),
                              ),
                              hintText: "Enter role name",
                            ),
                          ),
                          const SizedBox(height: 16),
                          _LabelText("Role Description"),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _descController,
                            maxLines: 3,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: theme.cardColor,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: theme.dividerColor,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: theme.dividerColor,
                                ),
                              ),
                              hintText: "Describe the role...",
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Search Bar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: "Search permission modules...",
                          prefixIcon: Icon(
                            Icons.search,
                            color: theme.hintColor,
                          ),
                          filled: true,
                          fillColor: theme.cardColor,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 14,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: theme.dividerColor),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: theme.dividerColor),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        "MODULE PERMISSIONS",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                          color: theme.hintColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Module List
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 16,
                      ),
                      child: Column(
                        children: permissions.map((perm) {
                          // Calculate active count
                          int activeCount = 0;
                          if (perm.create) activeCount++;
                          if (perm.update) activeCount++;
                          if (perm.view) activeCount++;
                          if (perm.delete) activeCount++;
                          if (perm.download) activeCount++;
                          if (perm.email) activeCount++;

                          int totalPossible = 0;
                          if (perm.canCreate) totalPossible++;
                          if (perm.canUpdate) totalPossible++;
                          if (perm.canView) totalPossible++;
                          if (perm.canDelete) totalPossible++;
                          if (perm.canDownload) totalPossible++;
                          if (perm.canEmail) totalPossible++;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildModuleCard(
                              perm: perm,
                              count: "$activeCount of $totalPossible",
                              isExpanded: _expandedModules[perm.label] ?? false,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),

                // 3. Sticky Footer
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          theme.scaffoldBackgroundColor,
                          theme.scaffoldBackgroundColor.withValues(alpha: 0.95),
                          theme.scaffoldBackgroundColor.withValues(alpha: 0.0),
                        ],
                        stops: const [0.6, 0.8, 1.0],
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: isDark
                                  ? Colors.white.withValues(alpha: 0.05)
                                  : Colors.grey[200],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              "Cancel",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: theme.hintColor,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _submit,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: theme.primaryColor,
                              foregroundColor: Colors.white,
                              elevation: 6,
                              shadowColor: theme.primaryColor.withValues(
                                alpha: 0.4,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              "Create Role",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
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

  // Helper Widgets
  Widget _LabelText(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).hintColor,
      ),
    );
  }

  // Icon mapper
  IconData _getIconForModule(String label) {
    if (label.toLowerCase().contains("user")) return Icons.group_outlined;
    if (label.toLowerCase().contains("report")) return Icons.analytics_outlined;
    if (label.toLowerCase().contains("config"))
      return Icons.settings_suggest_outlined;
    if (label.toLowerCase().contains("voice")) return Icons.mic_none_outlined;
    return Icons.folder_outlined;
  }

  Widget _buildModuleCard({
    required ProgramPermissionModel perm,
    required String count,
    required bool isExpanded,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final title = perm.label ?? "Module";

    final borderColor = isExpanded ? theme.primaryColor : theme.dividerColor;
    final shadow = isExpanded
        ? BoxShadow(
            color: theme.primaryColor.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        : const BoxShadow(color: Colors.transparent);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: isExpanded ? 2 : 1),
        boxShadow: [shadow],
      ),
      child: Column(
        children: [
          // Header
          InkWell(
            onTap: () => _toggleModule(title),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isExpanded
                          ? theme.primaryColor.withValues(alpha: 0.1)
                          : (isDark ? Colors.grey[800] : Colors.grey[100]),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getIconForModule(title),
                      color: isExpanded ? theme.primaryColor : theme.hintColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          "$count permissions selected",
                          style: TextStyle(
                            fontSize: 12,
                            color: isExpanded
                                ? theme.primaryColor
                                : theme.hintColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
          ),

          // Expanded Content (Grid)
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  if (perm.canCreate)
                    SizedBox(
                      width:
                          (MediaQuery.of(context).size.width - 64) /
                          2, // Approx half width
                      height: 40,
                      child: _PermissionToggle(
                        "Create",
                        perm.create,
                        (v) => setState(() => perm.create = v),
                      ),
                    ),
                  if (perm.canView)
                    SizedBox(
                      width: (MediaQuery.of(context).size.width - 64) / 2,
                      height: 40,
                      child: _PermissionToggle(
                        "View",
                        perm.view,
                        (v) => setState(() => perm.view = v),
                      ),
                    ),
                  if (perm.canUpdate)
                    SizedBox(
                      width: (MediaQuery.of(context).size.width - 64) / 2,
                      height: 40,
                      child: _PermissionToggle(
                        "Update",
                        perm.update,
                        (v) => setState(() => perm.update = v),
                      ),
                    ),
                  if (perm.canDelete)
                    SizedBox(
                      width: (MediaQuery.of(context).size.width - 64) / 2,
                      height: 40,
                      child: _PermissionToggle(
                        "Delete",
                        perm.delete,
                        (v) => setState(() => perm.delete = v),
                      ),
                    ),
                  if (perm.canDownload)
                    SizedBox(
                      width: (MediaQuery.of(context).size.width - 64) / 2,
                      height: 40,
                      child: _PermissionToggle(
                        "Download",
                        perm.download,
                        (v) => setState(() => perm.download = v),
                      ),
                    ),
                  if (perm.canEmail)
                    SizedBox(
                      width: (MediaQuery.of(context).size.width - 64) / 2,
                      height: 40,
                      child: _PermissionToggle(
                        "Email",
                        perm.email,
                        (v) => setState(() => perm.email = v),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _PermissionToggle(
    String label,
    bool isSelected,
    ValueChanged<bool> onTap,
  ) {
    final theme = Theme.of(context);
    final borderColor = isSelected ? theme.primaryColor : theme.dividerColor;
    final bgColor = isSelected
        ? theme.primaryColor.withValues(alpha: 0.05)
        : Colors.transparent;

    return InkWell(
      onTap: () => onTap(!isSelected),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor, width: isSelected ? 2 : 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? theme.textTheme.bodyMedium?.color
                    : theme.hintColor,
              ),
            ),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: isSelected ? theme.primaryColor : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: isSelected ? theme.primaryColor : theme.disabledColor,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
