import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:voice_first_admin/features/profile/data/models/update_profile_request.dart';
import '../providers/profile_provider.dart';

// Dial code options — id maps to backend dialCodeId
const _dialCodes = [
  {'id': 1, 'label': '+91 (India)'},
  {'id': 2, 'label': '+1 (USA)'},
  {'id': 44, 'label': '+44 (UK)'},
];

const _genderOptions = ['Male', 'Female', 'Other'];

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _firstNameCtrl;
  late final TextEditingController _lastNameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _mobileCtrl;
  late final TextEditingController _birthYearCtrl;

  String _selectedGender = 'Male';
  int _selectedDialCodeId = 1;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(profileProvider);

    // Split the full name back into first/last for the form
    final parts = profile.userName.trim().split(' ');
    final firstName = parts.isNotEmpty ? parts.first : '';
    final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';

    _firstNameCtrl = TextEditingController(text: firstName);
    _lastNameCtrl = TextEditingController(text: lastName);
    _emailCtrl = TextEditingController(text: profile.email);
    _mobileCtrl = TextEditingController(text: profile.mobileNo);
    _birthYearCtrl = TextEditingController(text: profile.birthYear);

    // Match current gender to options
    final currentGender = profile.gender.toLowerCase();
    _selectedGender = _genderOptions.firstWhere(
      (g) => g.toLowerCase() == currentGender,
      orElse: () => 'Male',
    );

    // Match current dial code
    final matchedDial = _dialCodes.firstWhere(
      (d) => (d['label'] as String).startsWith(profile.dialCode),
      orElse: () => _dialCodes.first,
    );
    _selectedDialCodeId = matchedDial['id'] as int;
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _mobileCtrl.dispose();
    _birthYearCtrl.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();

    final request = UpdateProfileRequest(
      firstName: _firstNameCtrl.text.trim(),
      lastName: _lastNameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      gender: _selectedGender.toLowerCase(),
      mobileNo: _mobileCtrl.text.trim(),
      birthYear: _birthYearCtrl.text.trim(),
      dialCodeId: _selectedDialCodeId,
    );

    final success = await ref
        .read(profileProvider.notifier)
        .saveProfile(request);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
    } else {
      final error = ref.read(profileProvider).error ?? 'Update failed';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileProvider);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isSaving = profileState.isLoading;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.primary),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          'Edit Profile',
          style: GoogleFonts.manrope(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: colors.primary,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: isSaving
                ? const Center(
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : TextButton(
                    onPressed: _onSave,
                    style: TextButton.styleFrom(
                      foregroundColor: colors.primary,
                      textStyle: GoogleFonts.manrope(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    child: const Text('Save'),
                  ),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 672),
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 60),
              children: [
                // ── Avatar + Name Hero ─────────────────────────────────────
                Column(
                  children: [
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: colors.surfaceContainerHighest,
                              width: 4,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                            image: DecorationImage(
                              image: NetworkImage(profileState.profileImageUrl),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: colors.primary,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: Icon(
                              Icons.photo_camera,
                              size: 18,
                              color: colors.onPrimaryContainer,
                            ),
                            onPressed: () {},
                            constraints: const BoxConstraints(
                              minWidth: 40,
                              minHeight: 40,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      profileState.userName,
                      style: GoogleFonts.manrope(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: colors.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        profileState.userRole.toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: colors.onSurfaceVariant,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 36),

                // ── Personal Identity ──────────────────────────────────────
                _FormCard(
                  title: 'Personal Identity',
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _FormField(
                            label: 'First Name',
                            icon: Icons.person_outline,
                            controller: _firstNameCtrl,
                            validator: (v) =>
                                (v ?? '').isEmpty ? 'Required' : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _FormField(
                            label: 'Last Name',
                            icon: Icons.badge_outlined,
                            controller: _lastNameCtrl,
                            validator: (v) =>
                                (v ?? '').isEmpty ? 'Required' : null,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ── Communication ──────────────────────────────────────────
                _FormCard(
                  title: 'Communication',
                  children: [
                    _FormField(
                      label: 'Email Address',
                      icon: Icons.mail_outline,
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if ((v ?? '').isEmpty) return 'Required';
                        if (!v!.contains('@')) return 'Invalid email';
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    // Dial code label + short code in a compact row
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 4, bottom: 8),
                          child: Text(
                            'Dial Code',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        DropdownButtonFormField<int>(
                          value: _selectedDialCodeId,
                          isExpanded: true,
                          icon: Icon(
                            Icons.expand_more,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                          dropdownColor: Theme.of(context).cardColor,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 15,
                            fontFamily: 'Inter',
                          ),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest
                                .withValues(alpha: 0.5),
                            prefixIcon: Icon(
                              Icons.public,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                              size: 20,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 18,
                              horizontal: 16,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(
                                color: Theme.of(
                                  context,
                                ).colorScheme.primary.withValues(alpha: 0.5),
                                width: 2,
                              ),
                            ),
                          ),
                          items: _dialCodes
                              .map(
                                (d) => DropdownMenuItem<int>(
                                  value: d['id'] as int,
                                  child: Text(d['label'] as String),
                                ),
                              )
                              .toList(),
                          onChanged: (v) {
                            if (v != null)
                              setState(() => _selectedDialCodeId = v);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _FormField(
                      label: 'Mobile Number',
                      icon: Icons.call_outlined,
                      controller: _mobileCtrl,
                      keyboardType: TextInputType.phone,
                      validator: (v) => (v ?? '').isEmpty ? 'Required' : null,
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ── Demographics ───────────────────────────────────────────
                _FormCard(
                  title: 'Demographics',
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _DropdownField<String>(
                            label: 'Gender',
                            icon: Icons.wc,
                            value: _selectedGender,
                            items: _genderOptions
                                .map(
                                  (g) => DropdownMenuItem<String>(
                                    value: g,
                                    child: Text(g),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) {
                              if (v != null) {
                                setState(() => _selectedGender = v);
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _FormField(
                            label: 'Birth Year',
                            icon: Icons.calendar_today_outlined,
                            controller: _birthYearCtrl,
                            keyboardType: TextInputType.number,
                            validator: (v) =>
                                (v ?? '').isEmpty ? 'Required' : null,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ── Role (read only) ───────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: colors.primary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colors.primaryContainer,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          Icons.admin_panel_settings,
                          color: colors.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ACCOUNT ROLE',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: colors.primary.withValues(alpha: 0.8),
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              profileState.userRole,
                              style: GoogleFonts.manrope(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: colors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.lock_outline,
                        color: colors.primary.withValues(alpha: 0.4),
                        size: 20,
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
}

// ─────────────────────────────────────────────────────────────────────────────
// Form Card container
// ─────────────────────────────────────────────────────────────────────────────
class _FormCard extends StatelessWidget {
  const _FormCard({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: colors.primary,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Reusable text form field
// ─────────────────────────────────────────────────────────────────────────────
class _FormField extends StatelessWidget {
  const _FormField({
    required this.label,
    required this.icon,
    required this.controller,
    this.keyboardType,
    this.validator,
  });
  final String label;
  final IconData icon;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: colors.onSurfaceVariant,
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: TextStyle(color: colors.onSurface),
          validator: validator,
          decoration: InputDecoration(
            filled: true,
            fillColor: colors.surfaceContainerHighest.withValues(alpha: 0.5),
            prefixIcon: Icon(icon, color: colors.onSurfaceVariant, size: 20),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 18,
              horizontal: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: colors.primary.withValues(alpha: 0.5),
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: colors.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: colors.error, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Reusable dropdown field
// ─────────────────────────────────────────────────────────────────────────────
class _DropdownField<T> extends StatelessWidget {
  const _DropdownField({
    required this.label,
    required this.icon,
    required this.value,
    required this.items,
    required this.onChanged,
  });
  final String label;
  final IconData icon;
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: colors.onSurfaceVariant,
            ),
          ),
        ),
        DropdownButtonFormField<T>(
          value: value,
          icon: Icon(Icons.expand_more, color: colors.onSurfaceVariant),
          dropdownColor: Theme.of(context).cardColor,
          style: TextStyle(
            color: colors.onSurface,
            fontSize: 15,
            fontFamily: 'Inter',
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: colors.surfaceContainerHighest.withValues(alpha: 0.5),
            prefixIcon: Icon(icon, color: colors.onSurfaceVariant, size: 20),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 18,
              horizontal: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: colors.primary.withValues(alpha: 0.5),
                width: 2,
              ),
            ),
          ),
          items: items,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
