import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/core/widgets/paginated_search_dropdown.dart';
import 'package:voice_first_admin/core/widgets/standard_page_layout.dart';
import 'package:voice_first_admin/features/plan_management/data/models/program_action_link_lookup.dart';
import 'package:voice_first_admin/features/plan_management/presentation/providers/add_plan_provider.dart';
import 'package:voice_first_admin/features/plan_management/presentation/providers/program_action_link_lookup_provider.dart';

class SelectedAction {
  final int id;
  final String name;

  SelectedAction({required this.id, required this.name});
}

/// Computes selected actions grouped by program using a typed model.
final groupedSelectedByProgramProvider =
    Provider<Map<String, List<SelectedAction>>>((ref) {
      final programs = ref.watch(
        programLookupProvider.select((s) => s.programs),
      );
      final selectedIds = ref.watch(addPlanProvider.select((s) => s.actionIds));

      final Map<String, List<SelectedAction>> grouped = {};

      for (final program in programs) {
        for (final action in program.actions) {
          if (selectedIds.contains(action.actionLinkId)) {
            grouped.putIfAbsent(program.programName, () => []);
            grouped[program.programName]!.add(
              SelectedAction(id: action.actionLinkId, name: action.actionName),
            );
          }
        }
      }

      return grouped;
    });

class AddPlanPage extends ConsumerStatefulWidget {
  const AddPlanPage({super.key});

  @override
  ConsumerState<AddPlanPage> createState() => _AddPlanPageState();
}

class _AddPlanPageState extends ConsumerState<AddPlanPage> {
  final TextEditingController _nameController = TextEditingController();

  DateTime? _lastScrollFetch;
  // final Set<int> _expandedProgramIds = {};
  bool _isSelectedExpanded = true;
  final TextEditingController _searchController = TextEditingController();
  // String _searchQuery = '';
  Timer? _debounce;
  // ScrollController for dropdown Scrollbar
  final ScrollController _dropdownScrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    _dropdownScrollController.addListener(() {
      if (!_dropdownScrollController.hasClients) return;

      final extentAfter = _dropdownScrollController.position.extentAfter;
      final notifier = ref.read(programLookupProvider.notifier);
      final state = ref.read(programLookupProvider);

      final now = DateTime.now();
      if (_lastScrollFetch != null &&
          now.difference(_lastScrollFetch!) <
              const Duration(milliseconds: 600)) {
        return;
      }

      if (extentAfter < 200 && !state.isLoading && state.hasMore) {
        _lastScrollFetch = now;
        notifier.loadNextPage();
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _searchController.dispose();
    _dropdownScrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(addPlanProvider);
    final notifier = ref.read(addPlanProvider.notifier);

    if (_nameController.text != state.planName) {
      _nameController.value = TextEditingValue(
        text: state.planName,
        selection: TextSelection.collapsed(offset: state.planName.length),
      );
    }

    return StandardPageLayout(
      title: 'Add Plan',
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildBasicInfo(theme, notifier),
              const SizedBox(height: 16),
              _buildDropdownSection(theme, state, notifier),
            ]),
          ),
        ),
      ],
      bottomNavigationBar: _buildBottomBar(theme, state, notifier),
    );
  }

  // Skeleton placeholders removed — keep UI focused and simple.

  ////////////////////////////////////////////////////////////
  /// BASIC INFO
  ////////////////////////////////////////////////////////////

  Widget _buildBasicInfo(ThemeData theme, AddPlanNotifier notifier) {
    return Container(
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
            'Plan Name',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _nameController,
            onChanged: notifier.setName,
            decoration: InputDecoration(
              hintText: 'Enter plan name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  ////////////////////////////////////////////////////////////
  /// DROPDOWN WITH EXPANSION LIST
  ////////////////////////////////////////////////////////////
  Widget _buildDropdownSection(
    ThemeData theme,
    AddPlanState state,
    AddPlanNotifier notifier,
  ) {
    final lookupState = ref.watch(programLookupProvider);
    // programs list used only by dropdown; grouped selection is provided
    final programs = lookupState.programs;

    final grouped = ref.watch(groupedSelectedByProgramProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //////////////////////////////////////////////////////
          /// SELECTED SECTION
          //////////////////////////////////////////////////////
          if (grouped.isNotEmpty) ...[
            InkWell(
              onTap: () {
                setState(() {
                  _isSelectedExpanded = !_isSelectedExpanded;
                });
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Selected (${state.actionIds.length})',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Icon(
                    _isSelectedExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 250),
              crossFadeState: _isSelectedExpanded
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              firstChild: Column(
                children: grouped.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.key,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        ...entry.value.map(
                          (action) => CheckboxListTile(
                            dense: true,
                            value: true,
                            onChanged: (_) =>
                                notifier.removeActionId(action.id),
                            title: Text(action.name),
                            controlAffinity: ListTileControlAffinity.leading,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              secondChild: const SizedBox(),
            ),
            const Divider(height: 30),
          ],

          //////////////////////////////////////////////////////
          /// DROPDOWN HEADER
          //////////////////////////////////////////////////////
          PaginatedSearchDropdown<ProgramActionLinkProgram>(
            id: 'add_plan_programs',
            openGroup: null,
            label: 'Choose Programs',
            hintText: 'Search program or action...',
            asyncItems: lookupState.isLoading && programs.isEmpty
                ? const AsyncValue<List<ProgramActionLinkProgram>>.loading()
                : AsyncValue<List<ProgramActionLinkProgram>>.data(programs),
            selectedItem: null,
            displayText: (p) => p.programName,
            itemId: (p) => p.programId,
            onItemSelected: (_) {},
            onSearch: (value) {
              ref
                  .read(programLookupProvider.notifier)
                  .reset(searchText: value.trim());
            },
            onLoadMore: () {
              ref.read(programLookupProvider.notifier).loadNextPage();
            },
            itemBuilder: (context, itemTheme, program, isSelected) {
              // Reuse existing expansion-tile UI for each program.
              return _buildExpandableTile(itemTheme, program, state, notifier);
            },
          ),
        ],
      ),
    );
  }

  // Grouping logic moved to `groupedSelectedByProgramProvider` to avoid
  // recomputation on every rebuild and keep UI declarative.

  ////////////////////////////////////////////////////////////
  /// EXPANSION TILE
  ////////////////////////////////////////////////////////////

  Widget _buildExpandableTile(
    ThemeData theme,
    ProgramActionLinkProgram program,
    AddPlanState state,
    AddPlanNotifier notifier,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: ExpansionTile(
        key: PageStorageKey(program.programId),
        title: Text(
          program.programName,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        children: program.actions.map((a) {
          final checked = state.actionIds.contains(a.actionLinkId);

          return CheckboxListTile(
            value: checked,
            onChanged: (v) {
              if (v == true) {
                notifier.addActionId(a.actionLinkId);
              } else {
                notifier.removeActionId(a.actionLinkId);
              }
            },
            title: Text(a.actionName),
            secondary: Text(
              '#${a.actionLinkId}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.disabledColor,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  ////////////////////////////////////////////////////////////
  /// BOTTOM BAR
  ////////////////////////////////////////////////////////////

  Widget _buildBottomBar(
    ThemeData theme,
    AddPlanState state,
    AddPlanNotifier notifier,
  ) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FilledButton.icon(
            onPressed: state.isSubmitting
                ? null
                : () async {
                    final created = await notifier.submit();
                    if (created != null && mounted) {
                      Navigator.pop(context, created.planId);
                    }
                  },
            icon: state.isSubmitting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save),
            label: const Text('Create Plan'),
          ),
        ],
      ),
    );
  }
}
