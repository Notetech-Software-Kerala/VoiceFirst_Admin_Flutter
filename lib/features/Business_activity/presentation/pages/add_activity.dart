import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/core/widgets/custom_snackbar.dart';
import 'package:voice_first_admin/features/Business_activity/presentation/providers/business_activity_provider.dart';
import 'package:voice_first_admin/features/Business_activity/presentation/providers/custom_field_lookup_provider.dart';

class AddActivityPage extends ConsumerStatefulWidget {
  const AddActivityPage({super.key});

  @override
  ConsumerState<AddActivityPage> createState() => _AddActivityPageState();
}

class _AddActivityPageState extends ConsumerState<AddActivityPage> {
  final TextEditingController _nameCtrl = TextEditingController();

  final Set<int> _selectedCustomFieldIds = <int>{};

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();

    if (name.isEmpty) {
      CustomSnackbar.show(
        context,
        message: "Activity name is required",
        type: SnackBarType.error,
      );
      return;
    }

    final error = await ref.read(businessActivityProvider.notifier).add(
          name,
          customFieldIds: _selectedCustomFieldIds.toList(),
        );

    if (!mounted) return;

    if (error != null) {
      CustomSnackbar.show(context, message: error, type: SnackBarType.error);
      return;
    }

    CustomSnackbar.show(
      context,
      message: "Activity created successfully",
      type: SnackBarType.success,
    );
    Navigator.pop(context);
  }


  Future<void> _openCustomFieldsBottomSheet(List fields) async {
    final theme = Theme.of(context);

    final Set<int> tempSelected = {..._selectedCustomFieldIds};
    String searchQuery = '';

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, modalSetState) {
            final filtered = fields.where((f) {
              final q = searchQuery.toLowerCase();
              if (q.isEmpty) return true;

              final name = (f.fieldName ?? '').toLowerCase();
              return name.contains(q);
            }).toList();

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.75,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// HEADER
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Select Custom Fields',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),

                    /// SEARCH
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search fields...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          isDense: true,
                        ),
                        onChanged: (value) {
                          modalSetState(() {
                            searchQuery = value.trim();
                          });
                        },
                      ),
                    ),

                    const SizedBox(height: 8),

                    /// LIST
                    Expanded(
                      child: filtered.isEmpty
                          ? const Center(child: Text('No fields found'))
                          : ListView.separated(
                              itemCount: filtered.length,
                              separatorBuilder: (_, _) =>
                                  const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final field = filtered[index];

                                final isChecked = tempSelected
                                    .contains(field.customFieldId);

                                return CheckboxListTile(
                                  title: Text(field.fieldName),
                                  subtitle: Text(field.fieldDataType),
                                  value: isChecked,
                                  dense: true,
                                  controlAffinity:
                                      ListTileControlAffinity.leading,
                                  onChanged: (checked) {
                                    modalSetState(() {
                                      if (checked ?? false) {
                                        tempSelected
                                            .add(field.customFieldId);
                                      } else {
                                        tempSelected
                                            .remove(field.customFieldId);
                                      }
                                    });
                                  },
                                );
                              },
                            ),
                    ),

                    /// FOOTER
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      child: Row(
                        children: [
                          TextButton(
                            onPressed: () {
                              modalSetState(() {
                                tempSelected.clear();
                              });
                            },
                            child: const Text('Clear All'),
                          ),
                          const Spacer(),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _selectedCustomFieldIds
                                  ..clear()
                                  ..addAll(tempSelected);
                              });

                              Navigator.pop(context);
                            },
                            child: const Text('Apply'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final fieldsAsync = ref.watch(customFieldLookupProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Add Activity")),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.only(bottom: 120),
            children: [
              const SizedBox(height: 16),

              /// ACTIVITY INFO CARD
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
                    Text(
                      'ACTIVITY INFO',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        color: theme.hintColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _nameCtrl,
                      decoration: InputDecoration(
                        labelText: 'Activity Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              /// CUSTOM FIELD SECTION
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'CUSTOM FIELDS',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    color: theme.hintColor,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: fieldsAsync.when(
                  data: (fields) {
                    final selected = fields
                        .where((f) =>
                            _selectedCustomFieldIds.contains(f.customFieldId))
                        .toList();

                    final selectedLabel = selected.isEmpty
                        ? 'No fields selected'
                        : selected.length <= 2
                            ? selected.map((e) => e.fieldName).join(', ')
                            : '${selected.length} fields selected';

                    return Container(
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: theme.dividerColor),
                      ),
                      child: InkWell(
                        onTap: () => _openCustomFieldsBottomSheet(fields),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 14),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Select Custom Fields',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      selectedLabel,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: theme.hintColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.arrow_drop_up),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  loading: () => const LinearProgressIndicator(minHeight: 2),
                  error: (_, _) =>
                      const Text('Failed to load custom fields'),
                ),
              ),
            ],
          ),

          /// SAVE BUTTONS
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _save,
                      child: const Text('Save Activity'),
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