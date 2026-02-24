import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/core/widgets/standard_page_layout.dart';
import '../providers/program_action_link_lookup_provider.dart';
import '../../models/program_action_link_lookup.dart';
import '../providers/add_plan_provider.dart';

class AddPlanPage extends ConsumerStatefulWidget {
  const AddPlanPage({super.key});

  @override
  ConsumerState<AddPlanPage> createState() => _AddPlanPageState();
}

class _AddPlanPageState extends ConsumerState<AddPlanPage> {
  final TextEditingController _nameController = TextEditingController();

  bool _isDropdownOpen = false;
  final Set<int> _expandedProgramIds = {};
  bool _isSelectedExpanded = true;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // ScrollController for dropdown Scrollbar
  final ScrollController _dropdownScrollController = ScrollController();

  @override
  void dispose() {
    _nameController.dispose();
    _searchController.dispose();
    _dropdownScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(addPlanProvider);
    final notifier = ref.read(addPlanProvider.notifier);

    if (_nameController.text != state.planName) {
      _nameController.text = state.planName;
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Consumer(
        builder: (context, ref, _) {
          final lookupAsync = ref.watch(programActionLinkLookupProvider);

          return lookupAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, st) => Text(
              'Failed to load programs',
              style: TextStyle(color: theme.colorScheme.error),
            ),
            data: (programs) {
              /// GROUP SELECTED BY PROGRAM
              final Map<String, List<Map<String, dynamic>>> grouped = {};

              for (final program in programs) {
                for (final action in program.actions) {
                  if (state.actionIds.contains(action.actionLinkId)) {
                    grouped.putIfAbsent(program.programName, () => []);
                    grouped[program.programName]!.add({
                      "id": action.actionLinkId,
                      "name": action.actionName,
                    });
                  }
                }
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //////////////////////////////////////////////////////
                  /// 🔥 COLLAPSIBLE SELECTED SECTION
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
                    const SizedBox(height: 10),

                    AnimatedCrossFade(
                      duration: const Duration(milliseconds: 250),
                      crossFadeState: _isSelectedExpanded
                          ? CrossFadeState.showFirst
                          : CrossFadeState.showSecond,
                      firstChild: Column(
                        children: grouped.entries.map((entry) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 14),
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
                                    onChanged: (v) {
                                      notifier.removeActionId(action["id"]);
                                    },
                                    title: Text(action["name"]),
                                    controlAffinity:
                                        ListTileControlAffinity.leading,
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
                  /// 🔥 ANIMATED DROPDOWN HEADER
                  //////////////////////////////////////////////////////
                  InkWell(
                    onTap: () {
                      setState(() {
                        _isDropdownOpen = !_isDropdownOpen;
                      });
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: theme.dividerColor),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Choose Programs and Actions'),
                          Icon(
                            _isDropdownOpen
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                          ),
                        ],
                      ),
                    ),
                  ),

                  //////////////////////////////////////////////////////
                  /// 🔥 ANIMATED DROPDOWN BODY
                  //////////////////////////////////////////////////////
                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: _isDropdownOpen
                        ? Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Container(
                              constraints: const BoxConstraints(maxHeight: 400),
                              child: Column(
                                children: [
                                  /// 🔍 SEARCH FIELD
                                  TextField(
                                    controller: _searchController,
                                    onChanged: (val) {
                                      setState(() {
                                        _searchQuery = val.toLowerCase();
                                      });
                                    },
                                    decoration: InputDecoration(
                                      hintText: 'Search program or action...',
                                      prefixIcon: const Icon(Icons.search),
                                      isDense: true,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 12),

                                  /// 🔥 FILTERED LIST WITH SCROLLBAR
                                  Expanded(
                                    child: Scrollbar(
                                      thumbVisibility: true,
                                      controller: _dropdownScrollController,
                                      child: SingleChildScrollView(
                                        controller: _dropdownScrollController,
                                        child: Column(
                                          children: programs
                                              .where((program) {
                                                if (_searchQuery.isEmpty) {
                                                  return true;
                                                }

                                                final programMatch = program
                                                    .programName
                                                    .toLowerCase()
                                                    .contains(_searchQuery);

                                                final actionMatch = program
                                                    .actions
                                                    .any(
                                                      (a) => a.actionName
                                                          .toLowerCase()
                                                          .contains(
                                                            _searchQuery,
                                                          ),
                                                    );

                                                return programMatch ||
                                                    actionMatch;
                                              })
                                              .map(
                                                (program) =>
                                                    _buildExpandableTile(
                                                      theme,
                                                      program,
                                                      state,
                                                      notifier,
                                                    ),
                                              )
                                              .toList(),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : const SizedBox(),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
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
