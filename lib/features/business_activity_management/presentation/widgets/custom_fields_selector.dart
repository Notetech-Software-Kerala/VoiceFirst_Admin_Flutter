import 'package:flutter/material.dart';

/// Shows a modal bottom sheet to select custom fields and returns the
/// selected set of `customFieldId`s when user taps "Apply".
Future<Set<int>?> showCustomFieldsBottomSheet(
  BuildContext context,
  List<dynamic> fields,
  Set<int> initialSelected,
) async {
  final theme = Theme.of(context);

  final Set<int> tempSelected = {...initialSelected};
  String searchQuery = '';

  return showModalBottomSheet<Set<int>>(
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

                              final isChecked = tempSelected.contains(
                                field.customFieldLinkId,
                              );

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
                                      tempSelected.add(field.customFieldLinkId);
                                    } else {
                                      tempSelected.remove(
                                        field.customFieldLinkId,
                                      );
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
                            Navigator.pop(context, tempSelected);
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
