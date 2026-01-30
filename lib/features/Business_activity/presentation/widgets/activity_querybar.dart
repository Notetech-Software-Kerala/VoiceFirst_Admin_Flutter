import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/features/Business_activity/models/activity_date_filter_type.dart';
import 'package:voice_first_admin/features/Business_activity/models/activity_searchby.dart';
import 'package:voice_first_admin/features/Business_activity/models/activity_filter_option.dart';
import 'package:voice_first_admin/features/Business_activity/presentation/providers/business_activity_provider.dart';

class ActivityQueryBar extends ConsumerStatefulWidget {
  const ActivityQueryBar({super.key});

  @override
  ConsumerState<ActivityQueryBar> createState() => _ActivityQueryBarState();
}

class _ActivityQueryBarState extends ConsumerState<ActivityQueryBar> {
  final _searchCtrl = TextEditingController();

  ActivitySearchBy _searchBy = ActivitySearchBy.activityName;
  ActivityDateType _dateType = ActivityDateType.created;

  DateTime? _fromDate;
  DateTime? _toDate;

  String? _sortBy;
  String _sortOrder = 'Asc';

  Future<void> _pickDate(bool isFrom) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked == null) return;

    setState(() {
      isFrom ? _fromDate = picked : _toDate = picked;
    });

    _apply();
  }

  void _apply() {
    ref
        .read(businessActivityProvider.notifier)
        .load(
          query: ref
              .read(businessActivityProvider)
              .query
              .copyWith(
                searchBy: _searchCtrl.text.isEmpty ? null : _searchBy,
                searchText: _searchCtrl.text.isEmpty ? null : _searchCtrl.text,
                sortBy: _sortBy,
                sortOrder: _sortBy == null ? null : _sortOrder,

                createdFromDate: _dateType == ActivityDateType.created
                    ? _fromDate
                    : null,
                createdToDate: _dateType == ActivityDateType.created
                    ? _toDate
                    : null,

                updatedFromDate: _dateType == ActivityDateType.updated
                    ? _fromDate
                    : null,
                updatedToDate: _dateType == ActivityDateType.updated
                    ? _toDate
                    : null,

                deletedFromDate: _dateType == ActivityDateType.deleted
                    ? _fromDate
                    : null,
                deletedToDate: _dateType == ActivityDateType.deleted
                    ? _toDate
                    : null,

                pageNumber: 1,
              ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        children: [
          // ───────── SEARCH ROW ─────────
          Row(
            children: [
              DropdownButton<ActivitySearchBy>(
                value: _searchBy,
                underline: const SizedBox(),
                items: ActivitySearchBy.values
                    .map(
                      (e) => DropdownMenuItem(value: e, child: Text(e.label)),
                    )
                    .toList(),
                onChanged: (v) {
                  if (v == null) return;
                  setState(() => _searchBy = v);
                  _apply();
                },
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (_) => _apply(),
                  decoration: InputDecoration(
                    hintText: 'Search',
                    prefixIcon: const Icon(Icons.search),

                    // 🔥 FILTER BUTTON INSIDE SEARCH BAR
                    suffixIcon: PopupMenuButton<ActivityFilterOption>(
                      tooltip: 'Filter',
                      icon: const Icon(Icons.tune),
                      onSelected: (option) {
                        ref
                            .read(businessActivityProvider.notifier)
                            .setFilter(option);
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(
                          value: ActivityFilterOption.all,
                          child: Text('All'),
                        ),
                        PopupMenuItem(
                          value: ActivityFilterOption.active,
                          child: Text('Active'),
                        ),
                        PopupMenuItem(
                          value: ActivityFilterOption.inactive,
                          child: Text('Inactive'),
                        ),
                        PopupMenuItem(
                          value: ActivityFilterOption.available,
                          child: Text('Available'),
                        ),
                        PopupMenuItem(
                          value: ActivityFilterOption.deleted,
                          child: Text('Deleted'),
                        ),
                      ],
                    ),

                    filled: true,
                    fillColor: theme.colorScheme.surfaceVariant,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // ───────── FILTER ROW ─────────
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _Chip(
                  label: _dateType.label,
                  icon: Icons.event,
                  onTap: () async {
                    final selected = await showMenu<ActivityDateType>(
                      context: context,
                      position: const RelativeRect.fromLTRB(100, 200, 0, 0),
                      items: ActivityDateType.values
                          .map(
                            (e) =>
                                PopupMenuItem(value: e, child: Text(e.label)),
                          )
                          .toList(),
                    );

                    if (selected != null) {
                      setState(() {
                        _dateType = selected;
                        _fromDate = null;
                        _toDate = null;
                      });
                      _apply();
                    }
                  },
                ),

                _Chip(
                  label: _fromDate == null ? 'From date' : _fmt(_fromDate!),
                  icon: Icons.calendar_today,
                  onTap: () => _pickDate(true),
                  onClear: _fromDate == null
                      ? null
                      : () {
                          setState(() => _fromDate = null);
                          _apply();
                        },
                ),

                _Chip(
                  label: _toDate == null ? 'To date' : _fmt(_toDate!),
                  icon: Icons.calendar_today,
                  onTap: () => _pickDate(false),
                  onClear: _toDate == null
                      ? null
                      : () {
                          setState(() => _toDate = null);
                          _apply();
                        },
                ),

                if (_sortBy != null)
                  _Chip(
                    label: _sortOrder,
                    icon: Icons.swap_vert,
                    onTap: () {
                      setState(() {
                        _sortOrder = _sortOrder == 'Asc' ? 'Desc' : 'Asc';
                      });
                      _apply();
                    },
                  ),

                _Chip(
                  label: _sortBy ?? 'Sort by',
                  icon: Icons.sort,
                  onTap: () async {
                    final selected = await showMenu<String>(
                      context: context,
                      position: const RelativeRect.fromLTRB(100, 200, 0, 0),
                      items: const [
                        PopupMenuItem(
                          value: 'createdDate',
                          child: Text('Created Date'),
                        ),
                        PopupMenuItem(
                          value: 'modifiedDate',
                          child: Text('Updated Date'),
                        ),
                        PopupMenuItem(
                          value: 'activityName',
                          child: Text('Activity Name'),
                        ),
                      ],
                    );

                    if (selected != null) {
                      setState(() => _sortBy = selected);
                      _apply();
                    }
                  },
                ),

                IconButton(
                  icon: const Icon(Icons.clear_all),
                  tooltip: 'Clear filters',
                  onPressed: () {
                    setState(() {
                      _searchCtrl.clear();
                      _searchBy = ActivitySearchBy.activityName;
                      _fromDate = null;
                      _toDate = null;
                      _sortBy = null;
                      _sortOrder = 'Asc';
                      _dateType = ActivityDateType.created;
                    });

                    ref
                        .read(businessActivityProvider.notifier)
                        .clearAllFilters();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _fmt(DateTime d) => '${d.day}/${d.month}/${d.year}';
}

// ───────── CHIP ─────────
class _Chip extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  const _Chip({
    required this.label,
    required this.icon,
    required this.onTap,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InputChip(
        avatar: Icon(icon, size: 16),
        label: Text(label),
        onPressed: onTap,
        onDeleted: onClear,
      ),
    );
  }
}
