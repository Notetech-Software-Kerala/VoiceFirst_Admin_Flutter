import 'package:flutter/material.dart';
import '../models/base_filter_model.dart';

class GlobalFilterBottomSheet extends StatefulWidget {
  final BaseFilterModel currentFilter;
  final Function(BaseFilterModel) onApply;
  final Map<String, String> searchOptions; // Value -> Label
  final Map<String, String> sortOptions; // Value -> Label
  final Widget? extraContent;

  const GlobalFilterBottomSheet({
    super.key,
    required this.currentFilter,
    required this.onApply,
    required this.searchOptions,
    required this.sortOptions,
    this.extraContent,
  });

  @override
  State<GlobalFilterBottomSheet> createState() =>
      _GlobalFilterBottomSheetState();
}

class _GlobalFilterBottomSheetState extends State<GlobalFilterBottomSheet> {
  late BaseFilterModel _filter;

  @override
  void initState() {
    super.initState();
    _filter = widget.currentFilter;
  }

  void _reset() {
    setState(() {
      _filter = const BaseFilterModel();
      // Note: extraContent might need its own reset mechanism if it has internal state.
      // Ideally, parent handles reset if state is lifted, but here we only control base state.
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: theme.dividerColor)),
            ),
            child: Column(
              children: [
                Container(
                  width: 48,
                  height: 6,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[700] : Colors.grey[300],
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Filter Results",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        _reset();
                        // We might need to notify parent to reset extra content fields?
                        // For now simpler to just reset base and let user re-apply.
                      },
                      child: Text(
                        "Reset All",
                        style: TextStyle(
                          color: theme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                // Search By
                if (widget.searchOptions.isNotEmpty) ...[
                  _SectionTitle("Search Criteria"),
                  const SizedBox(height: 12),
                  _DropdownField(
                    label: "Search Field",
                    value: _filter.searchBy,
                    items: widget.searchOptions.entries.map((e) {
                      return DropdownMenuItem(
                        value: e.key,
                        child: Text(e.value),
                      );
                    }).toList(),
                    onChanged: (v) =>
                        setState(() => _filter = _filter.copyWith(searchBy: v)),
                  ),
                  const SizedBox(height: 24),
                ],

                // Sort By
                if (widget.sortOptions.isNotEmpty) ...[
                  _SectionTitle("Sorting"),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _DropdownField(
                          label: "Sort By",
                          value: _filter.sortBy,
                          items: widget.sortOptions.entries.map((e) {
                            return DropdownMenuItem(
                              value: e.key,
                              child: Text(e.value),
                            );
                          }).toList(),
                          onChanged: (v) => setState(
                            () => _filter = _filter.copyWith(sortBy: v),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _DropdownField(
                          label: "Order",
                          value: _filter.sortOrder,
                          items: const [
                            DropdownMenuItem(value: 'Asc', child: Text('Asc')),
                            DropdownMenuItem(
                              value: 'Desc',
                              child: Text('Desc'),
                            ),
                          ],
                          onChanged: (v) => setState(
                            () => _filter = _filter.copyWith(sortOrder: v),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],

                // Extra Content (Feature Specific)
                if (widget.extraContent != null) ...[
                  widget.extraContent!,
                  const SizedBox(height: 24),
                ],

                // Status
                _SectionTitle("Status"),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _FilterChip(
                        label: "Active",
                        isSelected: _filter.active == true,
                        onTap: () {
                          setState(() {
                            _filter = _filter.copyWith(
                              active: _filter.active == true ? null : true,
                            );
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _FilterChip(
                        label: "Suspended",
                        isSelected: _filter.active == false,
                        onTap: () {
                          setState(() {
                            _filter = _filter.copyWith(
                              active: _filter.active == false ? null : false,
                            );
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _FilterChip(
                        label: "Deleted",
                        isSelected: _filter.deleted == true,
                        onTap: () {
                          setState(() {
                            _filter = _filter.copyWith(
                              deleted: _filter.deleted == true ? null : true,
                            );
                          });
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Date Ranges
                _SectionTitle("Created Date"),
                const SizedBox(height: 12),
                _DateRangePicker(
                  fromLabel: "Created From",
                  toLabel: "Created To",
                  from: _filter.createdFromDate,
                  to: _filter.createdToDate,
                  onFromChanged: (d) => setState(
                    () => _filter = _filter.copyWith(createdFromDate: d),
                  ),
                  onToChanged: (d) => setState(
                    () => _filter = _filter.copyWith(createdToDate: d),
                  ),
                ),

                const SizedBox(height: 16),
                _SectionTitle("Updated Date"),
                const SizedBox(height: 12),
                _DateRangePicker(
                  fromLabel: "Updated From",
                  toLabel: "Updated To",
                  from: _filter.updatedFromDate,
                  to: _filter.updatedToDate,
                  onFromChanged: (d) => setState(
                    () => _filter = _filter.copyWith(updatedFromDate: d),
                  ),
                  onToChanged: (d) => setState(
                    () => _filter = _filter.copyWith(updatedToDate: d),
                  ),
                ),
              ],
            ),
          ),

          // Footer
          Padding(
            padding: const EdgeInsets.all(24),
            child: ElevatedButton(
              onPressed: () {
                widget.onApply(_filter);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
              ),
              child: const Text(
                "Apply Filters",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- HELPER WIDGETS ---

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);
  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
        color: Theme.of(context).hintColor,
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.primaryColor.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? theme.primaryColor : theme.dividerColor,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected
                ? theme.primaryColor
                : theme.textTheme.bodyMedium?.color,
          ),
        ),
      ),
    );
  }
}

class _DropdownField extends StatelessWidget {
  final String label;
  final String? value;
  final List<DropdownMenuItem<String>> items;
  final ValueChanged<String?> onChanged;

  const _DropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: theme.hintColor,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: theme.dividerColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.dividerColor),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              items: items,
              onChanged: onChanged,
              hint: const Text("--"),
              icon: Icon(Icons.arrow_drop_down, color: theme.hintColor),
            ),
          ),
        ),
      ],
    );
  }
}

class _DateRangePicker extends StatelessWidget {
  final String fromLabel;
  final String toLabel;
  final DateTime? from;
  final DateTime? to;
  final ValueChanged<DateTime?> onFromChanged;
  final ValueChanged<DateTime?> onToChanged;

  const _DateRangePicker({
    required this.fromLabel,
    required this.toLabel,
    this.from,
    this.to,
    required this.onFromChanged,
    required this.onToChanged,
  });

  Future<void> _pickDate(
    BuildContext context,
    ValueChanged<DateTime?> onChanged,
    DateTime? current,
  ) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _DateBox(
            label: fromLabel,
            date: from,
            onTap: () => _pickDate(context, onFromChanged, from),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Icon(Icons.arrow_forward, size: 16, color: Colors.grey),
        ),
        Expanded(
          child: _DateBox(
            label: toLabel,
            date: to,
            onTap: () => _pickDate(context, onToChanged, to),
          ),
        ),
      ],
    );
  }
}

class _DateBox extends StatelessWidget {
  final String label;
  final DateTime? date;
  final VoidCallback onTap;

  const _DateBox({
    required this.label,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = date != null
        ? "${date!.day}/${date!.month}/${date!.year}"
        : "Select Date";
    final isSelected = date != null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.dividerColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? theme.primaryColor : theme.dividerColor,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: theme.hintColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              text,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? theme.textTheme.bodyMedium?.color
                    : theme.hintColor,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
