import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/user_model.dart';
import '../providers/user_lookup_provider.dart';
import '../providers/user_provider.dart';

class EditUserScreen extends ConsumerStatefulWidget {
  final UserModel? user; // Null = Create Mode, Not Null = Edit Mode

  const EditUserScreen({super.key, this.user});

  @override
  ConsumerState<EditUserScreen> createState() => _EditUserScreenState();
}

class _EditUserScreenState extends ConsumerState<EditUserScreen> {
  // Form Controllers
  late TextEditingController _fNameCtrl;
  late TextEditingController _lNameCtrl;
  late TextEditingController _birthYearCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _emailCtrl;

  // State Variables
  String _selectedGender = 'male';
  int? _selectedDialCodeId;
  int? _selectedRoleId;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    final user = widget.user;
    _fNameCtrl = TextEditingController(text: user?.firstName ?? "");
    _lNameCtrl = TextEditingController(text: user?.lastName ?? "");
    _birthYearCtrl = TextEditingController(text: user?.birthYear ?? "");
    _phoneCtrl = TextEditingController(text: user?.mobileNo ?? "");
    _emailCtrl = TextEditingController(text: user?.email ?? "");

    if (user != null) {
      _isActive = user.active;
      // Pre-select from model if user has actual ID fields.
      // Currently, UserModel doesn't expose dialCodeId or roleId explicitly inside the client model,
      // but if the API returns it as 'roleIds' or similar, we set it here.
      // Assuming for now it resets or we need to map roleName -> roleId.
      // As per request body, we need to pass dialCodeId and roleIds when saving.

      // Attempt to map from existing text if IDs are missing in model, or default null
      // e.g., if user model later has `user.dialCodeId`, use that.
    }
  }

  @override
  void dispose() {
    _fNameCtrl.dispose();
    _lNameCtrl.dispose();
    _birthYearCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  bool _isSaving = false;

  void _onSave() async {
    final email = _emailCtrl.text.trim();

    // Basic Validation
    if (_fNameCtrl.text.trim().isEmpty || _lNameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("First Name and Last Name are required")),
      );
      return;
    }
    if (_selectedDialCodeId == null || _phoneCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Phone Number and Dial Code are required"),
        ),
      );
      return;
    }
    if (_selectedRoleId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Access Role is required")));
      return;
    }

    setState(() => _isSaving = true);

    try {
      await ref
          .read(userProvider.notifier)
          .saveUser(
            id: widget.user?.id,
            firstName: _fNameCtrl.text.trim(),
            lastName: _lNameCtrl.text.trim(),
            gender: _selectedGender,
            birthYear: _birthYearCtrl.text.trim(),
            email: email,
            mobileNo: _phoneCtrl.text.trim(),
            dialCodeId: _selectedDialCodeId!,
            roleIds: [_selectedRoleId!],
            active: _isActive,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.user == null
                  ? "User created successfully"
                  : "User updated successfully",
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to save: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.primaryColor;
    final isEditMode = widget.user != null;

    return Scaffold(
      // 1. Sticky AppBar
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor.withValues(alpha: 0.8),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        title: Text(
          isEditMode ? "Edit User" : "Create User",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
            child: ElevatedButton(
              onPressed: _isSaving ? null : _onSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 4,
                shadowColor: primary.withValues(alpha: 0.4),
                padding: const EdgeInsets.symmetric(horizontal: 20),
              ),
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      "Save",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: theme.dividerColor, height: 1),
        ),
      ),

      // 2. Main Scrollable Form
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 40),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 440,
            ), // Matches max-w-md
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // --- Section 1: Personal Information ---
                _buildCardContainer(
                  icon: Icons.person,
                  title: "Personal Information",
                  child: Column(
                    children: [
                      _buildTextField(
                        label: "First Name",
                        controller: _fNameCtrl,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        label: "Last Name",
                        controller: _lNameCtrl,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDropdown<String>(
                              label: "Gender",
                              value: _selectedGender,
                              items: const [
                                DropdownMenuItem(
                                  value: 'female',
                                  child: Text("Female"),
                                ),
                                DropdownMenuItem(
                                  value: 'male',
                                  child: Text("Male"),
                                ),
                                DropdownMenuItem(
                                  value: 'other',
                                  child: Text("Other"),
                                ),
                                DropdownMenuItem(
                                  value: 'prefer_not_to_say',
                                  child: Text("N/A"),
                                ),
                              ],
                              onChanged: (val) =>
                                  setState(() => _selectedGender = val!),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              label: "Birth Year",
                              controller: _birthYearCtrl,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // --- Section 2: Contact Details ---
                _buildCardContainer(
                  icon: Icons.alternate_email,
                  title: "Contact Details",
                  child: Column(
                    children: [
                      // Email Field (Editable in Create, ReadOnly in Edit usually, but let's follow design)
                      _buildTextField(
                        label: "Email Address",
                        controller: _emailCtrl,
                        readOnly: isEditMode, // Lock email on edit
                        helperText: isEditMode
                            ? "Primary email cannot be changed"
                            : null,
                      ),
                      const SizedBox(height: 16),
                      // Phone Number Row
                      const Padding(
                        padding: EdgeInsets.only(left: 4, bottom: 6),
                        child: Text(
                          "Phone Number",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Consumer(
                            builder: (context, ref, child) {
                              final codesAsync = ref.watch(
                                dialCodeLookupProvider,
                              );

                              return SizedBox(
                                width: 130, // Slightly wider for IDs
                                child: codesAsync.when(
                                  data: (codes) {
                                    // Make sure selected ID exists in list, otherwise null
                                    final safeValue =
                                        _selectedDialCodeId != null &&
                                            codes.any(
                                              (c) =>
                                                  c.id == _selectedDialCodeId,
                                            )
                                        ? _selectedDialCodeId
                                        : (codes.isNotEmpty
                                              ? codes.first.id
                                              : null);

                                    // Auto-select first if we don't have one
                                    if (_selectedDialCodeId == null &&
                                        safeValue != null) {
                                      WidgetsBinding.instance
                                          .addPostFrameCallback((_) {
                                            if (mounted) {
                                              setState(
                                                () => _selectedDialCodeId =
                                                    safeValue,
                                              );
                                            }
                                          });
                                    }

                                    return _buildDropdown<int>(
                                      value: safeValue,
                                      hint: "Code",
                                      items: codes
                                          .map(
                                            (c) => DropdownMenuItem(
                                              value: c.id,
                                              child: Text(c.name),
                                            ),
                                          )
                                          .toList(),
                                      onChanged: (val) {
                                        if (val != null) {
                                          setState(
                                            () => _selectedDialCodeId = val,
                                          );
                                        }
                                      },
                                    );
                                  },
                                  loading: () => const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  ),
                                  error: (err, _) => const Icon(
                                    Icons.error,
                                    color: Colors.red,
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildTextField(
                              controller: _phoneCtrl,
                              keyboardType: TextInputType.phone,
                              hint: "0000000000",
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // --- Section 3: Account Configuration ---
                _buildCardContainer(
                  icon: Icons.refresh,
                  title: "Account Configuration",
                  child: Column(
                    children: [
                      // Status Toggle
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFF1E293B,
                          ).withValues(alpha: 0.5), // slate-800/20
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFF1E293B)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Account Status",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _isActive
                                      ? "Currently Active"
                                      : "Currently Inactive",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: _isActive
                                        ? Colors.green
                                        : Colors.grey, // Emerald replacement
                                  ),
                                ),
                              ],
                            ),
                            Switch(
                              value: _isActive,
                              onChanged: (val) =>
                                  setState(() => _isActive = val),
                              activeTrackColor: primary,
                              inactiveThumbColor: Colors.grey,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Role Dropdown
                      Consumer(
                        builder: (context, ref, child) {
                          final rolesAsync = ref.watch(rolesLookupProvider);

                          return rolesAsync.when(
                            data: (roles) {
                              final safeValue =
                                  _selectedRoleId != null &&
                                      roles.any((r) => r.id == _selectedRoleId)
                                  ? _selectedRoleId
                                  : (roles.isNotEmpty ? roles.first.id : null);

                              // Auto-select first
                              if (_selectedRoleId == null &&
                                  safeValue != null) {
                                WidgetsBinding.instance.addPostFrameCallback((
                                  _,
                                ) {
                                  if (mounted) {
                                    setState(() => _selectedRoleId = safeValue);
                                  }
                                });
                              }

                              return _buildDropdown<int>(
                                label: "Access Role",
                                value: safeValue,
                                helperText:
                                    "Roles determine system permissions.",
                                items: roles
                                    .map(
                                      (r) => DropdownMenuItem(
                                        value: r.id,
                                        child: Text(r.name),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() => _selectedRoleId = val);
                                  }
                                },
                              );
                            },
                            loading: () => const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: CircularProgressIndicator(),
                              ),
                            ),
                            error: (err, _) => Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'Error loading roles: $err',
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // --- Danger Zone (Only for Edit Mode) ---
                if (isEditMode)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade900.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.red.shade900.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Deactivate User",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.red[400],
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                "Temporarily suspend this user's access",
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                        OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red[400],
                            side: BorderSide(
                              color: Colors.red.shade900.withValues(alpha: 0.5),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text("Disable"),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // HELPER WIDGETS
  // ---------------------------------------------------------------------------

  Widget _buildCardContainer({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
        boxShadow: theme.brightness == Brightness.light
            ? [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: theme.primaryColor, size: 20),
              const SizedBox(width: 8),
              Text(
                title.toUpperCase(),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                  color: Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildTextField({
    String? label,
    TextEditingController? controller,
    String? initialValue,
    String? hint,
    String? helperText,
    bool readOnly = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    final theme = Theme.of(context);
    final borderColor = theme.brightness == Brightness.dark
        ? const Color(0xFF334155)
        : theme.dividerColor; // slate-700 or divider

    // Simplified fill color logic
    final fillColor = readOnly
        ? (theme.brightness == Brightness.dark
              ? const Color(0xFF1E293B).withValues(alpha: 0.3)
              : Colors.grey[300])
        : (theme.brightness == Brightness.dark
              ? theme.cardColor.withValues(alpha: 0.5)
              : Colors.grey[200]);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 6),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF94A3B8),
              ),
            ),
          ),
        TextFormField(
          controller: controller,
          initialValue: initialValue,
          readOnly: readOnly,
          keyboardType: keyboardType,
          style: TextStyle(
            color: readOnly ? Colors.grey : theme.textTheme.bodyMedium?.color,
            fontSize: 15,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF64748B)),
            filled: true,
            fillColor: fillColor,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: readOnly ? borderColor : theme.primaryColor,
              ),
            ),
          ),
        ),
        if (helperText != null)
          Padding(
            padding: const EdgeInsets.only(left: 4, top: 4),
            child: Text(
              helperText,
              style: TextStyle(
                fontSize: 10,
                fontStyle: FontStyle.italic,
                color: Colors.grey[500],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDropdown<T>({
    String? label,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required Function(T?) onChanged,
    String? helperText,
    String? hint,
  }) {
    final theme = Theme.of(context);
    final borderColor = theme.brightness == Brightness.dark
        ? const Color(0xFF334155)
        : theme.dividerColor; // slate-700 or divider

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 6),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF94A3B8),
              ),
            ),
          ),
        DropdownButtonFormField<T>(
          key: ValueKey(value),
          initialValue: value,
          items: items,
          onChanged: onChanged,
          hint: hint != null ? Text(hint) : null,
          icon: Icon(
            Icons.expand_more,
            color: theme.brightness == Brightness.dark
                ? const Color(0xFF64748B)
                : theme.iconTheme.color,
          ),
          isExpanded: true,
          decoration: InputDecoration(
            filled: true,
            fillColor: theme.brightness == Brightness.dark
                ? theme.cardColor.withValues(alpha: 0.5)
                : Colors.grey[200],
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: theme.primaryColor),
            ),
          ),
        ),
        if (helperText != null)
          Padding(
            padding: const EdgeInsets.only(left: 4, top: 8),
            child: Text(
              helperText,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
                height: 1.4,
              ),
            ),
          ),
      ],
    );
  }
}
