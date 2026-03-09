import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/features/menu_configuration/presentation/providers/menu_master_provider.dart';

class AddMenuItemScreen extends ConsumerStatefulWidget {
  const AddMenuItemScreen({super.key});

  @override
  ConsumerState<AddMenuItemScreen> createState() => _AddMenuItemScreenState();
}

class _AddMenuItemScreenState extends ConsumerState<AddMenuItemScreen> {
  // Form State
  final _formKey = GlobalKey<FormState>();

  final _menuNameController = TextEditingController();
  final _iconController = TextEditingController();
  final _routeController = TextEditingController();

  int? _selectedPlatformId;

  bool _superAdminAccess = true;
  bool _companyAdminAccess = true;
  bool _standardUserAccess = false;

  bool _isSubmitting = false;

  @override
  void dispose() {
    _menuNameController.dispose();
    _iconController.dispose();
    _routeController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = true);
      try {
        final repo = ref.read(menuMasterRepositoryProvider);

        if (_selectedPlatformId == null) return;
        final int plateFormId = _selectedPlatformId!;

        final payload = {
          "menuName": _menuNameController.text.trim(),
          "icon": _iconController.text.trim(),
          "route": _routeController.text.trim(),
          "plateFormId": plateFormId,
          "programIds": [
            {
              "programId": 0,
              "primary": true,
            }, // Fixed default as per requirements
          ],
          "web": true,
          "app": true,
        };

        debugPrint("=== SUBMITTING NEW MENU ITEM ===");
        debugPrint(payload.toString());

        await repo.createMenu(payload);

        debugPrint("=== SUCCESSFULLY CREATED MENU ITEM ===");

        // Refresh the list after successful creation
        ref.invalidate(menuMasterProvider);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Menu item created successfully'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to create menu item: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.primaryColor;
    final platformsAsync = ref.watch(platformLookupProvider);

    return Scaffold(
      // 1. Sticky Header
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor.withValues(alpha: 0.9),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleSpacing: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: theme.iconTheme.color ?? Colors.white,
          ),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text(
          "Add Menu Item",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.help_outline), onPressed: () {}),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: theme.dividerColor, height: 1),
        ),
      ),

      // 2. Main Scrollable Content
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  // --- Hero / Preview Card ---
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: primary.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: primary,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: primary.withValues(alpha: 0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.dashboard_customize,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "New Navigation Element",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Configure how this item appears in the enterprise navigation sidebar.",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[400],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // --- General Information ---
                  _buildSectionHeader(
                    Icons.info_outline,
                    "General Information",
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: "Menu Name",
                    hint: "e.g. Analytics Dashboard",
                    controller: _menuNameController,
                    validator: (val) =>
                        val == null || val.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: "Icon Selection",
                    hint: "Search icons... e.g., settings, users",
                    prefixIcon: Icons.search,
                    controller: _iconController,
                    validator: (val) =>
                        val == null || val.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 32),

                  // --- Technical Details ---
                  _buildSectionHeader(
                    Icons.settings_ethernet,
                    "Technical Details",
                  ),
                  const SizedBox(height: 16),
                  platformsAsync.when(
                    data: (platforms) {
                      return _buildDropdown<int>(
                        label: "Platform Compatibility",
                        value: _selectedPlatformId,
                        items: platforms
                            .map(
                              (e) => DropdownMenuItem<int>(
                                value: e.platformId,
                                child: Text(e.platformName),
                              ),
                            )
                            .toList(),
                        onChanged: (val) =>
                            setState(() => _selectedPlatformId = val),
                        validator: (val) => val == null ? 'Required' : null,
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (err, stack) =>
                        Text('Error loading platforms: $err'),
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: "Route / URL",
                    hint: "/admin/analytics",
                    controller: _routeController,
                    // Optional field per user request
                    validator: (val) => null,
                  ),
                  const SizedBox(height: 32),

                  // --- Visibility & Permissions ---
                  _buildSectionHeader(
                    Icons.visibility_outlined,
                    "Visibility & Permissions",
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: theme.dividerColor),
                    ),
                    child: Column(
                      children: [
                        _buildRoleTile(
                          title: "Super Admin",
                          subtitle: "Full system access and configuration",
                          icon: Icons.admin_panel_settings,
                          iconColor: primary,
                          iconBg: primary.withValues(alpha: 0.1),
                          value: _superAdminAccess,
                          onChanged: (val) =>
                              setState(() => _superAdminAccess = val),
                          showBorder: true,
                        ),
                        _buildRoleTile(
                          title: "Company Admin",
                          subtitle: "Manage organization-level settings",
                          icon: Icons.corporate_fare,
                          iconColor: Colors.grey[400]!,
                          iconBg: const Color(0xFF1E293B), // slate-800
                          value: _companyAdminAccess,
                          onChanged: (val) =>
                              setState(() => _companyAdminAccess = val),
                          showBorder: true,
                        ),
                        _buildRoleTile(
                          title: "Standard User",
                          subtitle: "Base operational access",
                          icon: Icons.groups,
                          iconColor: Colors.grey[400]!,
                          iconBg: const Color(0xFF1E293B),
                          value: _standardUserAccess,
                          onChanged: (val) =>
                              setState(() => _standardUserAccess = val),
                          showBorder: false,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 3. Fixed Bottom Action Buttons
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor.withValues(alpha: 0.9),
                border: Border(top: BorderSide(color: theme.dividerColor)),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: OutlinedButton(
                      onPressed: () => Navigator.maybePop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: theme.textTheme.bodyLarge?.color,
                        side: BorderSide(color: theme.dividerColor),
                        minimumSize: const Size(0, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text("Cancel"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(0, 48),
                        elevation: 4,
                        shadowColor: primary.withValues(alpha: 0.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Text(
                              "Create Menu Item",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // HELPER WIDGETS
  // ---------------------------------------------------------------------------

  Widget _buildSectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).primaryColor, size: 20),
        const SizedBox(width: 8),
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
            color: Color(0xFF64748B), // slate-500
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    IconData? prefixIcon,
    TextEditingController? controller,
    String? Function(String?)? validator,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ),
        TextFormField(
          controller: controller,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[600]),
            filled: true,
            fillColor: theme.cardColor,
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, color: Colors.grey[500])
                : null,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: theme.dividerColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: theme.dividerColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: theme.primaryColor),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required Function(T?) onChanged,
    String? Function(T?)? validator,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ),
        DropdownButtonFormField<T>(
          initialValue: value,
          items: items,
          onChanged: onChanged,
          validator: validator,
          icon: const Icon(Icons.expand_more, color: Colors.grey),
          decoration: InputDecoration(
            filled: true,
            fillColor: theme.cardColor,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: theme.dividerColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: theme.dividerColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: theme.primaryColor),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRoleTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required bool value,
    required Function(bool) onChanged,
    required bool showBorder,
  }) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        border: showBorder
            ? Border(bottom: BorderSide(color: theme.dividerColor))
            : null,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: theme.primaryColor,
            inactiveTrackColor: const Color(0xFF334155), // slate-700
            inactiveThumbColor: Colors.white,
          ),
        ],
      ),
    );
  }
}
