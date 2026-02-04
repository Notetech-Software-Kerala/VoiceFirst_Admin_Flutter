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
  final TextEditingController _actionController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _actionController.dispose();
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
      leading: InkWell(
        onTap: () => Navigator.pop(context),
        borderRadius: BorderRadius.circular(50),
        child: Container(
          margin: const EdgeInsets.all(8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: theme.brightness == Brightness.dark
                ? Colors.white.withAlpha(13)
                : Colors.grey[100],
          ),
          child: const Icon(Icons.arrow_back_ios_new, size: 20),
        ),
      ),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Basic Info
              Container(
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
                      'Basic Information',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _nameController,
                      onChanged: notifier.setName,
                      decoration: InputDecoration(
                        labelText: 'Plan Name',
                        hintText: 'Enter plan name',
                        filled: true,
                        fillColor: theme.cardColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: theme.dividerColor),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Program & Actions selection
              Container(
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
                      'Select Program Actions',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Consumer(
                      builder: (context, ref, _) {
                        final lookupAsync = ref.watch(
                          programActionLinkLookupProvider,
                        );
                        return lookupAsync.when(
                          loading: () => const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Center(child: CircularProgressIndicator()),
                          ),
                          error: (e, st) => Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Failed to load program actions',
                              style: TextStyle(color: theme.colorScheme.error),
                            ),
                          ),
                          data: (programs) {
                            if (programs.isEmpty) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'No programs available',
                                  style: theme.textTheme.bodySmall,
                                ),
                              );
                            }
                            return Column(
                              children: programs.map((p) {
                                return _ProgramActionsTile(
                                  program: p,
                                  selectedIds: state.actionIds,
                                  onToggle: (id, checked) {
                                    if (checked) {
                                      notifier.addActionId(id);
                                    } else {
                                      notifier.removeActionId(id);
                                    }
                                  },
                                );
                              }).toList(),
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: state.actionIds
                          .map(
                            (id) => Chip(
                              label: Text('Selected: $id'),
                              deleteIcon: const Icon(Icons.close),
                              onDeleted: () => notifier.removeActionId(id),
                            ),
                          )
                          .toList(),
                    ),
                    if (state.actionIds.isEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Select at least one program action to proceed',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.disabledColor,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (state.error != null) ...[
                const SizedBox(height: 12),
                Text(
                  state.error!,
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ],
            ]),
          ),
        ),
      ],
      bottomNavigationBar: Container(
        height: 70,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FilledButton.icon(
              onPressed: state.isSubmitting
                  ? null
                  : () async {
                      final created = await notifier.submit();
                      if (created != null) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Plan created successfully'),
                            ),
                          );
                          Navigator.pop(context, created.planId);
                        }
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
      ),
    );
  }
}

class _ProgramActionsTile extends StatelessWidget {
  final ProgramActionLinkProgram program;
  final List<int> selectedIds;
  final void Function(int id, bool checked) onToggle;

  const _ProgramActionsTile({
    required this.program,
    required this.selectedIds,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: ExpansionTile(
        title: Text(
          program.programName,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        children: [
          ...program.actions.map((a) {
            final checked = selectedIds.contains(a.actionLinkId);
            return CheckboxListTile(
              value: checked,
              onChanged: (v) => onToggle(a.actionLinkId, v ?? false),
              title: Text(a.actionName),
              secondary: Text(
                '#${a.actionLinkId}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.disabledColor,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
