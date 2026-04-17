import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/core/widgets/custom_snackbar.dart';
import 'package:voice_first_admin/features/custom_field/data/models/custom_field_model.dart';
import 'package:voice_first_admin/features/custom_field/presentation/providers/custom_field_provider.dart';

// ─── Theme Colors ────────────────────────────────────────────────────────────
extension ContextColors on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  Color get bg => Theme.of(this).scaffoldBackgroundColor;
  Color get card => Theme.of(this).cardColor;
  Color get border => Theme.of(this).dividerColor;
  Color get text =>
      Theme.of(this).textTheme.bodyMedium?.color ??
      (isDark ? Colors.white : Colors.black87);
  Color get muted => isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
  Color get primary => Theme.of(this).primaryColor;
  Color get primaryDark =>
      isDark ? const Color(0xFF2563EB) : Theme.of(this).primaryColorDark;
  Color get error => Theme.of(this).colorScheme.error;
}

// ─── Main Screen ──────────────────────────────────────────────────────────────
class AddCustomFieldPage extends ConsumerStatefulWidget {
  const AddCustomFieldPage({super.key});

  @override
  ConsumerState<AddCustomFieldPage> createState() => _AddCustomFieldPageState();
}

class _AddCustomFieldPageState extends ConsumerState<AddCustomFieldPage> {
  final _fieldNameController = TextEditingController();
  final _fieldKeyController = TextEditingController();
  int? _selectedDataType;
  bool _isKeyManuallyEdited = false;

  // Validation rules list
  final List<_ValidationRule> _validationRules = [_ValidationRule()];

  // Dropdown options list
  final List<_DropdownOption> _dropdownOptions = [_DropdownOption()];

  @override
  void initState() {
    super.initState();
    _fieldNameController.addListener(_onFieldNameChanged);
    _fieldKeyController.addListener(() {
      _isKeyManuallyEdited = true;
    });
  }

  void _onFieldNameChanged() {
    if (!_isKeyManuallyEdited) {
      final raw = _fieldNameController.text;
      final key = raw
          .toLowerCase()
          .replaceAll(RegExp(r'\s+'), '_')
          .replaceAll(RegExp(r'[^a-z0-9_]'), '');
      _fieldKeyController.removeListener(() {});
      _fieldKeyController.value = _fieldKeyController.value.copyWith(text: key);
      _fieldKeyController.addListener(() {
        _isKeyManuallyEdited = true;
      });
    }
  }

  @override
  void dispose() {
    _fieldNameController.dispose();
    _fieldKeyController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _fieldNameController.text.trim();
    final key = _fieldKeyController.text.trim();
    if (name.isEmpty || key.isEmpty || _selectedDataType == null) {
      CustomSnackbar.show(
        context,
        message: 'Please fill in all required fields',
        type: SnackBarType.error,
      );
      return;
    }
    final validations = _validationRules
        .where((r) => r.nameCtrl.text.trim().isNotEmpty)
        .map(
          (r) => ValidationRuleModel(
            ruleName: r.nameCtrl.text.trim(),
            ruleValue: r.valueCtrl.text.trim(),
            message: r.errorCtrl.text.trim(),
          ),
        )
        .toList();
    final options = _dropdownOptions
        .where((o) => o.labelCtrl.text.trim().isNotEmpty)
        .map(
          (o) => FieldOptionModel(
            label: o.labelCtrl.text.trim(),
            value: o.valueCtrl.text.trim(),
          ),
        )
        .toList();
    final field = CustomFieldModel(
      fieldName: name,
      fieldKey: key,
      fieldDataTypes: [
        CustomFieldDataTypeModel(
          fieldDataTypeId: _selectedDataType!,
          validations: validations,
          options: options,
        ),
      ],
    );
    final err = await ref.read(customFieldProvider.notifier).add(field);
    if (mounted) {
      if (err == null) {
        CustomSnackbar.show(
          context,
          message: '$name created successfully',
          type: SnackBarType.success,
        );
        Navigator.maybePop(context);
      } else {
        CustomSnackbar.show(context, message: err, type: SnackBarType.error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = ref.watch(customFieldProvider).isSaving;
    return Builder(
      builder: (outerContext) => Scaffold(
        backgroundColor: context.bg,
        body: Column(
          children: [
            // ── Header ──────────────────────────────────────────────────────────
            _AppHeader(onBackPressed: () => Navigator.maybePop(outerContext)),

            // ── Scrollable Body ─────────────────────────────────────────────────
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                children: [
                  // Basic Configuration
                  _SectionCard(
                    title: 'Basic Configuration',
                    child: Column(
                      children: [
                        // Field Name
                        _LabeledField(
                          label: 'Field Name',
                          required: true,
                          child: TextField(
                            controller: _fieldNameController,
                            style: TextStyle(color: context.text),
                            decoration: _inputDecoration(
                              hintText: 'Enter field name',
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Field Key
                        _LabeledField(
                          label: 'Field Key',
                          required: true,
                          labelSuffix: Icon(
                            Icons.lock_outline,
                            color: context.muted,
                          ),
                          child: Stack(
                            alignment: Alignment.centerRight,
                            children: [
                              TextField(
                                controller: _fieldKeyController,
                                style: TextStyle(
                                  color: context.text,
                                  fontStyle: FontStyle.italic,
                                ),
                                decoration:
                                    _inputDecoration(
                                      hintText: 'enter_unique_field_key',
                                    ).copyWith(
                                      contentPadding: const EdgeInsets.fromLTRB(
                                        16,
                                        14,
                                        90,
                                        14,
                                      ),
                                    ),
                              ),
                              Positioned(
                                right: 12,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: context.bg,
                                    border: Border.all(color: context.border),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'AUTO-GEN',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                      color: context.muted,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Data Type
                        _LabeledField(
                          label: 'Data Type',
                          required: true,
                          child: Consumer(
                            builder: (context, ref, child) {
                              final datatypesAsync = ref.watch(
                                lookupDataTypesProvider,
                              );
                              return datatypesAsync.when(
                                data: (datatypes) {
                                  return _StyledDropdown<int>(
                                    hint: 'Select Data Type',
                                    value: _selectedDataType,
                                    items: datatypes
                                        .map(
                                          (e) => DropdownMenuItem<int>(
                                            value: e.id,
                                            child: Text(e.label),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (v) {
                                      setState(() {
                                        _selectedDataType = v;
                                        // Clear current validations if type changes
                                        _validationRules.clear();
                                        _validationRules.add(_ValidationRule());
                                      });
                                    },
                                  );
                                },
                                loading: () => const Center(
                                  child: CircularProgressIndicator(),
                                ),
                                error: (e, st) => Text(
                                  'Error loading datatypes: $e',
                                  style: TextStyle(color: context.error),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Validation Rules
                  if (_selectedDataType != null)
                    Consumer(
                      builder: (context, ref, child) {
                        final rulesAsync = ref.watch(
                          lookupValidationRulesProvider(_selectedDataType!),
                        );
                        return rulesAsync.when(
                          data: (apiRules) {
                            return _ValidationRulesSection(
                              rules: _validationRules,
                              apiRules: apiRules,
                              onAddRule: () => setState(
                                () => _validationRules.add(_ValidationRule()),
                              ),
                              onRemoveRule: (i) =>
                                  setState(() => _validationRules.removeAt(i)),
                            );
                          },
                          loading: () => const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          error: (e, st) => Text(
                            'Error loading rules',
                            style: TextStyle(color: context.error),
                          ),
                        );
                      },
                    ),

                  if (_selectedDataType != null) ...[
                    // Option assumes ID 12 is dropdown etc, but showing for now based on if user adds options
                    const SizedBox(height: 24),
                    // Dropdown Options
                    _DropdownOptionsSection(
                      options: _dropdownOptions,
                      onAddOption: () => setState(
                        () => _dropdownOptions.add(_DropdownOption()),
                      ),
                      onRemoveOption: (i) =>
                          setState(() => _dropdownOptions.removeAt(i)),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),

        // ── Footer Buttons ──────────────────────────────────────────────────────
        bottomNavigationBar: _FooterActions(isSaving: isSaving, onSave: _save),
      ),
    );
  }

  InputDecoration _inputDecoration({required String hintText}) {
    return InputDecoration(
      hintText: hintText,
      filled: true,
      fillColor: context.bg,
      hintStyle: TextStyle(color: context.muted, fontSize: 14),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: context.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: context.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: context.primary, width: 2),
      ),
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────
class _AppHeader extends StatelessWidget {
  final VoidCallback onBackPressed;

  const _AppHeader({required this.onBackPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.bg.withValues(alpha: 0.95),
        border: Border(bottom: BorderSide(color: context.border)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back, color: context.primary, size: 28),
                onPressed: onBackPressed,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'VOICEFIRST',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                        color: context.primary,
                      ),
                    ),
                    SizedBox(height: 1),
                    Text(
                      'Add Custom Field',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: context.text,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: context.primaryDark,
                  shape: BoxShape.circle,
                  border: Border.all(color: context.border, width: 2),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'Y', // In a real app, this would be the user's initial
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Section Card ─────────────────────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
              color: context.muted,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

// ─── Labeled Field ────────────────────────────────────────────────────────────
class _LabeledField extends StatelessWidget {
  final String label;
  final bool required;
  final Widget? labelSuffix;
  final Widget child;

  const _LabeledField({
    required this.label,
    this.required = false,
    this.labelSuffix,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: context.text,
              ),
            ),
            if (required) ...[
              SizedBox(width: 4),
              Text('*', style: TextStyle(color: context.error, fontSize: 13)),
            ],
            if (labelSuffix != null) ...[
              const SizedBox(width: 6),
              labelSuffix!,
            ],
          ],
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}

// ─── Styled Dropdown ──────────────────────────────────────────────────────────
class _StyledDropdown<T> extends StatelessWidget {
  final String hint;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  const _StyledDropdown({
    required this.hint,
    this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.border),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          hint: Text(
            hint,
            style: TextStyle(color: context.muted, fontSize: 14),
          ),
          dropdownColor: context.card,
          style: TextStyle(color: context.text, fontSize: 14),
          icon: Icon(Icons.keyboard_arrow_down, color: context.muted),
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }
}

// ─── Validation Rules Section ─────────────────────────────────────────────────
class _ValidationRule {
  final nameCtrl = TextEditingController();
  final valueCtrl = TextEditingController();
  final errorCtrl = TextEditingController();
}

class _ValidationRulesSection extends StatelessWidget {
  final List<_ValidationRule> rules;
  final List<LookupValidationRuleModel> apiRules;
  final VoidCallback onAddRule;
  final ValueChanged<int> onRemoveRule;

  const _ValidationRulesSection({
    required this.rules,
    required this.apiRules,
    required this.onAddRule,
    required this.onRemoveRule,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'VALIDATION RULES',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.5,
                color: context.muted,
              ),
            ),
            GestureDetector(
              onTap: onAddRule,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: context.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(
                    color: context.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.add, size: 16, color: context.primary),
                    SizedBox(width: 4),
                    Text(
                      'ADD RULE',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: context.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Rule cards
        ...rules.asMap().entries.map((entry) {
          final i = entry.key;
          final rule = entry.value;
          final isFirst = i == 0;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _RuleCard(
              rule: rule,
              apiRules: apiRules,
              isDashed: !isFirst,
              canRemove: isFirst,
              onRemove: () => onRemoveRule(i),
            ),
          );
        }),
      ],
    );
  }
}

class _RuleCard extends StatefulWidget {
  final _ValidationRule rule;
  final List<LookupValidationRuleModel> apiRules;
  final bool isDashed;
  final bool canRemove;
  final VoidCallback onRemove;

  const _RuleCard({
    required this.rule,
    required this.apiRules,
    required this.isDashed,
    required this.canRemove,
    required this.onRemove,
  });

  @override
  State<_RuleCard> createState() => _RuleCardState();
}

class _RuleCardState extends State<_RuleCard> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: widget.isDashed
                ? context.card.withValues(alpha: 0.6)
                : context.card,
            borderRadius: BorderRadius.circular(20),
            border: widget.isDashed
                ? Border.all(
                    color: context.border.withValues(alpha: 0.5),
                    style: BorderStyle.solid,
                    width: 1,
                  )
                : Border.all(color: context.border),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'RULE NAME',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                            color: context.muted,
                          ),
                        ),
                        const SizedBox(height: 6),
                        _StyledDropdown<String>(
                          hint: 'Select Rule',
                          value: widget.rule.nameCtrl.text.isEmpty
                              ? null
                              : widget.rule.nameCtrl.text,
                          items: widget.apiRules
                              .map(
                                (r) => DropdownMenuItem<String>(
                                  value: r.ruleName,
                                  child: Text(r.ruleName),
                                ),
                              )
                              .toList(),
                          onChanged: (v) {
                            if (v != null) {
                              setState(() {
                                widget.rule.nameCtrl.text = v;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MiniField(
                      label: 'Value',
                      controller: widget.rule.valueCtrl,
                      hint: 'e.g. 10',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _MiniField(
                label: 'Custom Error Message',
                controller: widget.rule.errorCtrl,
                hint: 'Custom error msg',
              ),
            ],
          ),
        ),

        // Remove button
        if (widget.canRemove)
          Positioned(
            top: -8,
            right: -8,
            child: GestureDetector(
              onTap: widget.onRemove,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: context.error.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: context.error.withValues(alpha: 0.3),
                  ),
                ),
                child: Icon(Icons.close, color: context.error),
              ),
            ),
          ),
      ],
    );
  }
}

class _MiniField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;

  const _MiniField({
    required this.label,
    required this.controller,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
            color: context.muted,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          style: TextStyle(color: context.text, fontSize: 13),
          decoration: InputDecoration(
            hintText: hint,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: context.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: context.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: context.primary),
            ),
            filled: true,
            fillColor: context.bg,
            hintStyle: TextStyle(color: context.muted, fontSize: 14),
          ),
        ),
      ],
    );
  }
}

// ─── Dropdown Options Section ─────────────────────────────────────────────────
class _DropdownOption {
  final labelCtrl = TextEditingController();
  final valueCtrl = TextEditingController();
}

class _DropdownOptionsSection extends StatelessWidget {
  final List<_DropdownOption> options;
  final VoidCallback onAddOption;
  final ValueChanged<int> onRemoveOption;

  const _DropdownOptionsSection({
    required this.options,
    required this.onAddOption,
    required this.onRemoveOption,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'OPTIONS (DROPDOWN)',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                  color: context.muted,
                ),
              ),
              IconButton(
                icon: Icon(Icons.add, color: context.primary, size: 22),
                onPressed: onAddOption,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...options.asMap().entries.map((entry) {
            final i = entry.key;
            final opt = entry.value;
            final isLast = i == options.length - 1;

            return Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
              child: Opacity(
                opacity: isLast ? 0.5 : 1.0,
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: opt.labelCtrl,
                        enabled: !isLast,
                        style: TextStyle(color: context.text, fontSize: 13),
                        decoration: InputDecoration(
                          hintText: isLast ? 'Add Label...' : 'Label',
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: context.border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: context.border),
                          ),
                          filled: true,
                          fillColor: context.bg,
                          hintStyle: TextStyle(
                            color: context.muted,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: opt.valueCtrl,
                        enabled: !isLast,
                        style: TextStyle(color: context.text, fontSize: 13),
                        decoration: InputDecoration(
                          hintText: isLast ? 'Add Value...' : 'Value',
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: context.border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: context.border),
                          ),
                          filled: true,
                          fillColor: context.bg,
                          hintStyle: TextStyle(
                            color: context.muted,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    if (!isLast)
                      IconButton(
                        icon: Icon(
                          Icons.delete_outline,
                          color: context.muted,
                          size: 20,
                        ),
                        onPressed: () => onRemoveOption(i),
                        padding: const EdgeInsets.all(4),
                        constraints: const BoxConstraints(),
                      )
                    else
                      const SizedBox(width: 28),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ─── Footer Actions ───────────────────────────────────────────────────────────
class _FooterActions extends StatelessWidget {
  final bool isSaving;
  final VoidCallback onSave;
  const _FooterActions({required this.isSaving, required this.onSave});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.bg.withValues(alpha: 0.98),
        border: Border(top: BorderSide(color: context.border)),
      ),
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        MediaQuery.of(context).padding.bottom + 12,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextButton(
              onPressed: () => Navigator.maybePop(context),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: context.border),
                ),
              ),
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: context.text,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: isSaving ? null : onSave,
              icon: isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.check, size: 20),
              label: Text(
                isSaving ? 'Saving...' : 'Save Field',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.primaryDark,
                foregroundColor: Colors.white,
                disabledBackgroundColor: context.primaryDark.withValues(
                  alpha: 0.6,
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 8,
                shadowColor: context.primaryDark.withValues(alpha: 0.4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
