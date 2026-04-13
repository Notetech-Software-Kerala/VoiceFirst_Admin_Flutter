import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/core/widgets/custom_snackbar.dart';
import 'package:voice_first_admin/features/custom_field/data/models/custom_field_model.dart';
import 'package:voice_first_admin/features/custom_field/presentation/pages/edit_custom_field_page.dart';
import 'package:voice_first_admin/features/custom_field/presentation/providers/custom_field_provider.dart';

// ─── Accent / option icon mappings ───────────────────────────────────────────
const _optionIcons = [
  Icons.keyboard_double_arrow_up,
  Icons.drag_handle,
  Icons.keyboard_double_arrow_down,
  Icons.circle_outlined,
  Icons.star_outline,
];

const _optionColors = [
  Color(0xFFFEF2F2), // red-50
  Color(0xFFFFFBEB), // amber-50
  Color(0xFFF0FDF4), // green-50
  Color(0xFFEFF6FF), // blue-50
  Color(0xFFF5F3FF), // purple-50
];
const _optionIconColors = [
  Color(0xFFDC2626), // red-600
  Color(0xFFD97706), // amber-600
  Color(0xFF16A34A), // green-600
  Color(0xFF2563EB), // blue-600
  Color(0xFF7C3AED), // purple-600
];

const _dataTypeLabels = {
  'text': 'Short Text',
  'textarea': 'Long Text',
  'number': 'Number',
  'dropdown': 'Dropdown',
  'date': 'Date Picker',
};

const _dataTypeIcons = {
  'text': Icons.short_text,
  'textarea': Icons.notes,
  'number': Icons.tag,
  'dropdown': Icons.arrow_drop_down_circle_outlined,
  'date': Icons.calendar_today_outlined,
};

// ─── Main Page ────────────────────────────────────────────────────────────────
class CustomFieldDetailPage extends ConsumerWidget {
  final CustomFieldModel field;
  const CustomFieldDetailPage({super.key, required this.field});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isWide = MediaQuery.of(context).size.width >= 640;

    final asyncField = ref.watch(customFieldDetailProvider(field.fieldId!));
    final displayField = asyncField.value ?? field;

    final primary = theme.primaryColor;
    final bg = theme.scaffoldBackgroundColor;
    final card = theme.cardColor;
    final border = theme.dividerColor;
    final textPrimary =
        theme.textTheme.bodyLarge?.color ??
        (isDark ? Colors.white : const Color(0xFF0F172A));
    final textSecondary = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF475569);
    final textMuted = isDark
        ? const Color(0xFF64748B)
        : const Color(0xFF94A3B8);

    return Scaffold(
      backgroundColor: bg,
      body: Column(
        children: [
          // ── Top Bar ────────────────────────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              color: card,
              border: Border(bottom: BorderSide(color: border)),
            ),
            child: SafeArea(
              bottom: false,
              child: SizedBox(
                height: 60,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.arrow_back, color: primary),
                            onPressed: () => Navigator.maybePop(context),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Field Configuration',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: textPrimary,
                            ),
                          ),
                        ],
                      ),
                      TextButton.icon(
                        onPressed: () => _goToEdit(context, ref),
                        icon: Icon(
                          Icons.edit_outlined,
                          size: 16,
                          color: primary,
                        ),
                        label: Text(
                          'Edit',
                          style: TextStyle(
                            color: primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          if (asyncField.isLoading)
            LinearProgressIndicator(
              minHeight: 2,
              color: primary,
              backgroundColor: primary.withValues(alpha: 0.1),
            )
          else
            const SizedBox(height: 2),

          // ── Scrollable Content ─────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 48),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Page Header ──────────────────────────────────────────
                  _PageHeader(
                    field: displayField,
                    isWide: isWide,
                    primary: primary,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                    textMuted: textMuted,
                    card: card,
                    border: border,
                  ),
                  const SizedBox(height: 32),

                  // ── Bento Row: Basic Config + Validation ─────────────────
                  isWide
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 2,
                              child: _BasicConfigCard(
                                field: displayField,
                                card: card,
                                border: border,
                                textPrimary: textPrimary,
                                textSecondary: textSecondary,
                                textMuted: textMuted,
                                primary: primary,
                                isDark: isDark,
                              ),
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              flex: 1,
                              child: _ValidationCard(
                                field: displayField,
                                primary: primary,
                              ),
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            _BasicConfigCard(
                              field: displayField,
                              card: card,
                              border: border,
                              textPrimary: textPrimary,
                              textSecondary: textSecondary,
                              textMuted: textMuted,
                              primary: primary,
                              isDark: isDark,
                            ),
                            const SizedBox(height: 24),
                            _ValidationCard(
                              field: displayField,
                              primary: primary,
                            ),
                          ],
                        ),

                  // ── Dropdown Options ─────────────────────────────────────
                  if (displayField.primaryDataTypeLabel.toLowerCase() ==
                          'dropdown' &&
                      displayField.primaryOptions.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _DropdownOptionsCard(
                      field: displayField,
                      isWide: isWide,
                      card: card,
                      border: border,
                      textPrimary: textPrimary,
                      textMuted: textMuted,
                      primary: primary,
                    ),
                  ],

                  const SizedBox(height: 40),

                  // ── Footer Actions ───────────────────────────────────────
                  _FooterActions(
                    isWide: isWide,
                    field: displayField,
                    textSecondary: textSecondary,
                    textMuted: textMuted,
                    border: border,
                    textPrimary: textPrimary,
                    onEdit: () => _goToEdit(context, ref),
                    onDelete: () => _confirmDelete(context, ref),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _goToEdit(BuildContext context, WidgetRef ref) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditCustomFieldPage(field: field)),
    );
    if (context.mounted) {
      ref.read(customFieldProvider.notifier).loadAll();
      Navigator.maybePop(context);
    }
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Custom Field'),
        content: Text(
          'Are you sure you want to delete "${field.fieldName}"? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final err = await ref
          .read(customFieldProvider.notifier)
          .remove(field.fieldId!);
      if (context.mounted) {
        if (err == null) {
          CustomSnackbar.show(
            context,
            message: '${field.fieldName} deleted',
            type: SnackBarType.success,
          );
          Navigator.maybePop(context);
        } else {
          CustomSnackbar.show(context, message: err, type: SnackBarType.error);
        }
      }
    }
  }
}

// ─── Page Header ──────────────────────────────────────────────────────────────
class _PageHeader extends StatelessWidget {
  final CustomFieldModel field;
  final bool isWide;
  final Color primary;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color card;
  final Color border;

  const _PageHeader({
    required this.field,
    required this.isWide,
    required this.primary,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.card,
    required this.border,
  });

  @override
  Widget build(BuildContext context) {
    final breadcrumb = Row(
      children: [
        Text(
          'Custom Fields',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: textMuted,
            letterSpacing: 1.2,
          ),
        ),
        Icon(Icons.chevron_right, size: 14, color: textMuted),
        Text(
          'ID: ${field.fieldId ?? '—'}',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: primary,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );

    final title = Text(
      field.fieldName,
      style: TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.w900,
        color: textPrimary,
        letterSpacing: -0.5,
      ),
    );

    final meta = Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.history_edu_outlined, size: 18, color: primary),
          const SizedBox(width: 8),
          Text(
            field.createdUser != null
                ? 'Created by ${field.createdUser}'
                : 'Created',
            style: TextStyle(fontSize: 13, color: textSecondary),
          ),
          if (field.createdDate != null) ...[
            Text(
              ' on ${_fmt(field.createdDate!)}',
              style: TextStyle(fontSize: 13, color: textMuted),
            ),
          ],
        ],
      ),
    );

    return isWide
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [breadcrumb, const SizedBox(height: 8), title],
              ),
              meta,
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              breadcrumb,
              const SizedBox(height: 8),
              title,
              const SizedBox(height: 16),
              meta,
            ],
          );
  }

  String _fmt(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
}

// ─── Basic Config Card ────────────────────────────────────────────────────────
class _BasicConfigCard extends StatelessWidget {
  final CustomFieldModel field;
  final Color card;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color primary;
  final bool isDark;

  const _BasicConfigCard({
    required this.field,
    required this.card,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.primary,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final typeLabel =
        _dataTypeLabels[field.primaryDataTypeLabel.toLowerCase()] ??
        field.primaryDataTypeLabel;
    final typeIcon =
        _dataTypeIcons[field.primaryDataTypeLabel.toLowerCase()] ?? Icons.input;

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Watermark icon
          Positioned(
            top: -8,
            right: -8,
            child: Opacity(
              opacity: 0.06,
              child: Icon(
                Icons.settings_input_component_outlined,
                size: 80,
                color: textPrimary,
              ),
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.info_outline, size: 20, color: primary),
                  const SizedBox(width: 8),
                  Text(
                    'Basic Configuration',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              LayoutBuilder(
                builder: (context, constraints) {
                  final twoCol = constraints.maxWidth > 380;
                  final items = [
                    _InfoW(
                      label: 'Field Name',
                      child: Text(
                        field.fieldName,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: textPrimary,
                        ),
                      ),
                    ),
                    _InfoW(
                      label: 'Field Key',
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.08)
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          field.fieldKey,
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 13,
                            color: primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    _InfoW(
                      label: 'Data Type',
                      child: Row(
                        children: [
                          Icon(typeIcon, size: 20, color: textSecondary),
                          const SizedBox(width: 8),
                          Text(
                            typeLabel,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _InfoW(
                      label: 'Status',
                      child: Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: field.active
                              ? const Color(0xFFD1FAE5)
                              : const Color(0xFFFEE2E2),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Text(
                          field.active ? 'Active' : 'Inactive',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: field.active
                                ? const Color(0xFF065F46)
                                : const Color(0xFF991B1B),
                          ),
                        ),
                      ),
                    ),
                  ];

                  if (twoCol) {
                    return Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: items[0]),
                            const SizedBox(width: 28),
                            Expanded(child: items[1]),
                          ],
                        ),
                        const SizedBox(height: 28),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: items[2]),
                            const SizedBox(width: 28),
                            Expanded(child: items[3]),
                          ],
                        ),
                      ],
                    );
                  }

                  return Column(
                    children: items
                        .map(
                          (i) => Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: i,
                          ),
                        )
                        .toList(),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoW extends StatelessWidget {
  final String label;
  final Widget child;
  const _InfoW({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: Color(0xFF94A3B8),
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}

// ─── Validation Card ──────────────────────────────────────────────────────────
class _ValidationCard extends StatelessWidget {
  final CustomFieldModel field;
  final Color primary;

  const _ValidationCard({required this.field, required this.primary});

  @override
  Widget build(BuildContext context) {
    final rules = field.primaryValidations;
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [primary, primary.withValues(alpha: 0.8)],
    );

    if (rules.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: primary.withValues(alpha: 0.25),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Row(
              children: [
                Icon(
                  Icons.verified_user_outlined,
                  size: 20,
                  color: Colors.white,
                ),
                SizedBox(width: 8),
                Text(
                  'Validation Rules',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),
            Text(
              'No validation rules defined.',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: 0.25),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.verified_user_outlined, size: 20, color: Colors.white),
              SizedBox(width: 8),
              Text(
                'Validation Rules',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          ...rules.asMap().entries.map((entry) {
            final i = entry.key;
            final rule = entry.value;
            final isLast = i == rules.length - 1;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.check_circle,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            rule.ruleName.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.white70,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            rule.ruleValue,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (rule.message.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '"${rule.message}"',
                      style: const TextStyle(
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
                if (!isLast)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Divider(
                      color: Colors.white.withValues(alpha: 0.15),
                      thickness: 1,
                    ),
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

// ─── Dropdown Options Card ────────────────────────────────────────────────────
class _DropdownOptionsCard extends StatelessWidget {
  final CustomFieldModel field;
  final bool isWide;
  final Color card;
  final Color border;
  final Color textPrimary;
  final Color textMuted;
  final Color primary;

  const _DropdownOptionsCard({
    required this.field,
    required this.isWide,
    required this.card,
    required this.border,
    required this.textPrimary,
    required this.textMuted,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    final options = field.primaryOptions;

    return Container(
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(24, 18, 24, 18),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: border)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.list_outlined, size: 20, color: primary),
                    const SizedBox(width: 8),
                    Text(
                      'Dropdown Options',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: border.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Text(
                    '${options.length} Option${options.length == 1 ? '' : 's'}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: textMuted,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Options grid or list
          if (isWide && options.length > 1)
            IntrinsicHeight(
              child: Row(
                children: options.asMap().entries.map((entry) {
                  final i = entry.key;
                  final opt = entry.value;
                  return Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: i < options.length - 1
                            ? Border(right: BorderSide(color: border))
                            : null,
                      ),
                      child: _OptionTile(
                        label: opt.label,
                        value: opt.value,
                        bgColor: _optionColors[i % _optionColors.length],
                        iconColor:
                            _optionIconColors[i % _optionIconColors.length],
                        icon: _optionIcons[i % _optionIcons.length],
                        textPrimary: textPrimary,
                        textMuted: textMuted,
                      ),
                    ),
                  );
                }).toList(),
              ),
            )
          else
            Column(
              children: options.asMap().entries.map((entry) {
                final i = entry.key;
                final opt = entry.value;
                return Container(
                  decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: border)),
                  ),
                  child: _OptionTile(
                    label: opt.label,
                    value: opt.value,
                    bgColor: _optionColors[i % _optionColors.length],
                    iconColor: _optionIconColors[i % _optionIconColors.length],
                    icon: _optionIcons[i % _optionIcons.length],
                    textPrimary: textPrimary,
                    textMuted: textMuted,
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}

class _OptionTile extends StatefulWidget {
  final String label;
  final String value;
  final Color bgColor;
  final Color iconColor;
  final IconData icon;
  final Color textPrimary;
  final Color textMuted;

  const _OptionTile({
    required this.label,
    required this.value,
    required this.bgColor,
    required this.iconColor,
    required this.icon,
    required this.textPrimary,
    required this.textMuted,
  });

  @override
  State<_OptionTile> createState() => _OptionTileState();
}

class _OptionTileState extends State<_OptionTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        color: _hovered
            ? widget.bgColor.withValues(alpha: 0.5)
            : Colors.transparent,
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            AnimatedScale(
              scale: _hovered ? 1.1 : 1.0,
              duration: const Duration(milliseconds: 150),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: widget.bgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(widget.icon, color: widget.iconColor, size: 22),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'OPTION',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: widget.textMuted,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.label,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: widget.textPrimary,
                    ),
                  ),
                  if (widget.value.isNotEmpty && widget.value != widget.label)
                    Text(
                      'Value: ${widget.value}',
                      style: TextStyle(
                        fontSize: 11,
                        color: widget.textMuted,
                        fontFamily: 'monospace',
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
}

// ─── Footer Actions ───────────────────────────────────────────────────────────
class _FooterActions extends StatelessWidget {
  final bool isWide;
  final CustomFieldModel field;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color border;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _FooterActions({
    required this.isWide,
    required this.field,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.border,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final actionButtons = Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        ElevatedButton.icon(
          onPressed: onEdit,
          icon: const Icon(Icons.edit_outlined, size: 16),
          label: const Text('Edit Configuration'),
          style: ElevatedButton.styleFrom(
            backgroundColor: textPrimary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            textStyle: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        OutlinedButton.icon(
          onPressed: onDelete,
          icon: const Icon(Icons.delete_outline, size: 16),
          label: const Text('Delete Field'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.red,
            side: const BorderSide(color: Color(0xFFFECACA)),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            textStyle: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );

    final modifiedInfo = Column(
      crossAxisAlignment: isWide
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          'LAST MODIFIED',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: textMuted,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          field.modifiedDate != null
              ? '${_fmt(field.modifiedDate!)} by ${field.modifiedUser ?? 'System'}'
              : 'Not modified yet',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: textSecondary,
          ),
        ),
      ],
    );

    return Container(
      padding: const EdgeInsets.only(top: 28),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: border)),
      ),
      child: isWide
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [actionButtons, modifiedInfo],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                actionButtons,
                const SizedBox(height: 20),
                modifiedInfo,
              ],
            ),
    );
  }

  String _fmt(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
}
