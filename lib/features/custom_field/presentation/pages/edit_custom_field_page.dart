import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/core/widgets/custom_snackbar.dart';
import 'package:voice_first_admin/features/custom_field/data/models/custom_field_model.dart';
import 'package:voice_first_admin/features/custom_field/presentation/providers/custom_field_provider.dart';

class EditCustomFieldPage extends ConsumerStatefulWidget {
  final CustomFieldModel field;
  const EditCustomFieldPage({super.key, required this.field});

  @override
  ConsumerState<EditCustomFieldPage> createState() =>
      _EditCustomFieldPageState();
}

class _EditCustomFieldPageState extends ConsumerState<EditCustomFieldPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _fieldNameController;
  late int? _selectedDataType;

  final List<_EditValidationRule> _validationRules = [];
  final List<_EditDropdownOption> _dropdownOptions = [];

  @override
  void initState() {
    super.initState();
    final f = widget.field;
    _fieldNameController = TextEditingController(text: f.fieldName);
    _selectedDataType = f.fieldDataTypes.isNotEmpty ? f.fieldDataTypes.first.fieldDataTypeId : null;

    for (final v in f.primaryValidations) {
      _validationRules.add(_EditValidationRule(
        validationId: v.validationId,
        nameCtrl: TextEditingController(text: v.ruleName),
        valueCtrl: TextEditingController(text: v.ruleValue),
        errorCtrl: TextEditingController(text: v.message),
      ));
    }

    for (final o in f.primaryOptions) {
      _dropdownOptions.add(_EditDropdownOption(
        optionId: o.optionId,
        labelCtrl: TextEditingController(text: o.label),
        valueCtrl: TextEditingController(text: o.value),
      ));
    }

    _dropdownOptions.add(_EditDropdownOption());
  }

  @override
  void dispose() {
    _fieldNameController.dispose();
    for (final r in _validationRules) {
      r.nameCtrl.dispose();
      r.valueCtrl.dispose();
      r.errorCtrl.dispose();
    }
    for (final o in _dropdownOptions) {
      o.labelCtrl.dispose();
      o.valueCtrl.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final notifier = ref.read(customFieldProvider.notifier);

    final validations = _validationRules
        .where((r) => r.nameCtrl.text.trim().isNotEmpty)
        .map((r) => ValidationRuleModel(
              validationId: r.validationId,
              ruleName: r.nameCtrl.text.trim(),
              ruleValue: r.valueCtrl.text.trim(),
              message: r.errorCtrl.text.trim(),
            ))
        .toList();

    final options = _dropdownOptions
        .where((o) =>
            o.labelCtrl.text.trim().isNotEmpty ||
            o.optionId != null)
        .map((o) => FieldOptionModel(
              optionId: o.optionId,
              label: o.labelCtrl.text.trim(),
              value: o.valueCtrl.text.trim(),
            ))
        .toList();

    final updated = CustomFieldModel(
      fieldId: widget.field.fieldId,
      fieldName: _fieldNameController.text.trim(),
      fieldKey: widget.field.fieldKey,
      active: widget.field.active,
      fieldDataTypes: [
        CustomFieldDataTypeModel(
          customFieldLinkId: widget.field.fieldDataTypes.isNotEmpty ? widget.field.fieldDataTypes.first.customFieldLinkId : null,
          fieldDataTypeId: _selectedDataType!,
          validations: validations,
          options: options,
        )
      ],
    );

    final err = await notifier.edit(widget.field.fieldId!, updated);
    if (mounted) {
      if (err == null) {
        CustomSnackbar.show(
          context,
          message: '${updated.fieldName} updated successfully',
          type: SnackBarType.success,
        );
        Navigator.pop(context);
      } else {
        CustomSnackbar.show(
          context,
          message: err,
          type: SnackBarType.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.primaryColor;
    final isSaving = ref.watch(customFieldProvider).isSaving;

    final bgColor = theme.scaffoldBackgroundColor;
    final cardColor = theme.cardColor;
    final borderColor = theme.dividerColor;
    final textColor = theme.textTheme.bodyMedium?.color ??
        (isDark ? Colors.white : Colors.black87);
    final mutedColor =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final errorColor = theme.colorScheme.error;

    InputDecoration inputDec({required String hint}) => InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: bgColor,
          hintStyle: TextStyle(color: mutedColor, fontSize: 14),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: borderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: primary, width: 2),
          ),
        );

    Widget sectionCard(String title, Widget child) => Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
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
                  color: mutedColor,
                ),
              ),
              const SizedBox(height: 16),
              child,
            ],
          ),
        );

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor.withValues(alpha: 0.95),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.chevron_left, color: primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'VOICEFIRST',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
                color: primary,
              ),
            ),
            const Text(
              'Edit Custom Field',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                height: 1.1,
              ),
            ),
          ],
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
          children: [
            sectionCard(
              'Basic Configuration',
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Field Name *',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _fieldNameController,
                    style: TextStyle(color: textColor),
                    decoration: inputDec(hint: 'Enter field name'),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Data Type *',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Consumer(
                    builder: (context, ref, child) {
                      final datatypesAsync = ref.watch(lookupDataTypesProvider);
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
                                _validationRules.clear();
                                _validationRules.add(_EditValidationRule());
                              });
                            },
                          );
                        },
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (e, st) => Text('Error loading datatypes: $e', style: TextStyle(color: errorColor)),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            if (_selectedDataType != null)
              Consumer(
                builder: (context, ref, child) {
                  final rulesAsync = ref.watch(lookupValidationRulesProvider(_selectedDataType!));
                  return rulesAsync.when(
                    data: (apiRules) {
                      return _EditValidationRulesSection(
                        rules: _validationRules,
                        apiRules: apiRules,
                        onAddRule: () =>
                            setState(() => _validationRules.add(_EditValidationRule())),
                        onRemoveRule: (i) =>
                            setState(() => _validationRules.removeAt(i)),
                      );
                    },
                    loading: () => const Center(child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    )),
                    error: (e, st) => Text('Error loading rules', style: TextStyle(color: errorColor)),
                  );
                },
              ),
            if (_selectedDataType != null) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: borderColor),
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
                            color: mutedColor,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.add, color: primary, size: 22),
                          onPressed: () =>
                              setState(() => _dropdownOptions.add(_EditDropdownOption())),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ..._dropdownOptions.asMap().entries.map((entry) {
                      final i = entry.key;
                      final opt = entry.value;
                      final isLast = i == _dropdownOptions.length - 1;
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
                                  style: TextStyle(
                                      color: textColor, fontSize: 13),
                                  decoration: InputDecoration(hintText: isLast ? 'Add Label...' : 'Label'),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: opt.valueCtrl,
                                  enabled: !isLast,
                                  style: TextStyle(
                                      color: textColor, fontSize: 13),
                                  decoration: InputDecoration(hintText: isLast ? 'Add Value...' : 'Value'),
                                ),
                              ),
                              const SizedBox(width: 4),
                              if (!isLast)
                                IconButton(
                                  icon: Icon(Icons.delete_outline,
                                      color: mutedColor, size: 20),
                                  onPressed: () => setState(
                                      () => _dropdownOptions.removeAt(i)),
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
              ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: bgColor.withValues(alpha: 0.98),
          border: Border(top: BorderSide(color: borderColor)),
        ),
        padding: EdgeInsets.fromLTRB(
            16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
        child: Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: borderColor),
                  ),
                ),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: isSaving ? null : _save,
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
                  isSaving ? 'Saving…' : 'Save Changes',
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w700),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: primary.withValues(alpha: 0.6),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 8,
                  shadowColor: primary.withValues(alpha: 0.4),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          hint: Text(hint, style: TextStyle(color: theme.hintColor, fontSize: 14)),
          dropdownColor: theme.cardColor,
          style: TextStyle(color: theme.textTheme.bodyMedium?.color, fontSize: 14),
          icon: Icon(Icons.keyboard_arrow_down, color: theme.hintColor),
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _EditValidationRulesSection extends StatelessWidget {
  final List<_EditValidationRule> rules;
  final List<LookupValidationRuleModel> apiRules;
  final VoidCallback onAddRule;
  final ValueChanged<int> onRemoveRule;

  const _EditValidationRulesSection({
    required this.rules,
    required this.apiRules,
    required this.onAddRule,
    required this.onRemoveRule,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('VALIDATION RULES', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1.5, color: theme.hintColor)),
            GestureDetector(
              onTap: onAddRule,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: theme.primaryColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(50)),
                child: Text('ADD RULE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: theme.primaryColor)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...rules.asMap().entries.map((entry) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _EditRuleCard(rule: entry.value, apiRules: apiRules, onRemove: () => onRemoveRule(entry.key)),
        )),
      ],
    );
  }
}

class _EditRuleCard extends StatelessWidget {
  final _EditValidationRule rule;
  final List<LookupValidationRuleModel> apiRules;
  final VoidCallback onRemove;

  const _EditRuleCard({required this.rule, required this.apiRules, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(20), border: Border.all(color: theme.dividerColor)),
          child: Column(
            children: [
              _StyledDropdown<String>(
                hint: 'Select Rule',
                value: apiRules.any((r) => r.ruleName == rule.nameCtrl.text) ? rule.nameCtrl.text : null,
                items: apiRules.map((r) => DropdownMenuItem(value: r.ruleName, child: Text(r.ruleName))).toList(),
                onChanged: (v) => rule.nameCtrl.text = v ?? '',
              ),
              const SizedBox(height: 16),
              TextField(controller: rule.valueCtrl, decoration: const InputDecoration(labelText: 'Value')),
              const SizedBox(height: 16),
              TextField(controller: rule.errorCtrl, decoration: const InputDecoration(labelText: 'Error Message')),
            ],
          ),
        ),
        Positioned(top: -8, right: -8, child: IconButton(onPressed: onRemove, icon: Icon(Icons.close, color: theme.colorScheme.error))),
      ],
    );
  }
}

class _EditValidationRule {
  final int? validationId;
  final TextEditingController nameCtrl;
  final TextEditingController valueCtrl;
  final TextEditingController errorCtrl;

  _EditValidationRule({
    this.validationId,
    TextEditingController? nameCtrl,
    TextEditingController? valueCtrl,
    TextEditingController? errorCtrl,
  })  : nameCtrl = nameCtrl ?? TextEditingController(),
        valueCtrl = valueCtrl ?? TextEditingController(),
        errorCtrl = errorCtrl ?? TextEditingController();
}

class _EditDropdownOption {
  final int? optionId;
  final TextEditingController labelCtrl;
  final TextEditingController valueCtrl;

  _EditDropdownOption({
    this.optionId,
    TextEditingController? labelCtrl,
    TextEditingController? valueCtrl,
  })  : labelCtrl = labelCtrl ?? TextEditingController(),
        valueCtrl = valueCtrl ?? TextEditingController();
}
