import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/core/widgets/custom_snackbar.dart';
import 'package:voice_first_admin/core/widgets/delete_bottom_sheet.dart';
import 'package:voice_first_admin/core/widgets/recovery_bottom_sheet.dart';
import 'package:voice_first_admin/core/widgets/standard_detail_page_buttons.dart';
import 'package:voice_first_admin/features/plan/data/models/plan_model.dart';
import 'package:voice_first_admin/features/plan/presentation/providers/plan_provider.dart';

class PlanDetailPage extends ConsumerStatefulWidget {
  final Plan plan;
  const PlanDetailPage({super.key, required this.plan});

  @override
  ConsumerState<PlanDetailPage> createState() => _PlanDetailPageState();
}

class _PlanDetailPageState extends ConsumerState<PlanDetailPage> {
  // Track expansion for better UX
  final Set<int> _expandedPrograms = {};
  final Set<int> _expandedActions = {};

  @override
  void initState() {
    super.initState();
    final id = widget.plan.planId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(planProvider.notifier).selectPlan(id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    // Watch provider state for detail and loading
    final planState = ref.watch(planProvider);
    final detail = planState.selectedPlan?.planId == widget.plan.planId
        ? planState.selectedPlan
        : null;
    final List<ProgramPlanDetail> programDetails =
        detail?.programPlanDetails ?? const <ProgramPlanDetail>[];
    final isLoading = planState.isDetailLoading;
    final notifier = ref.read(planProvider.notifier);

    // final isDeleted = detail?.deleted ?? (widget.plan.deleted == true);
    final bool isDeleted = detail?.deleted ?? widget.plan.deleted;
    final bool isActive = detail?.active ?? widget.plan.active;

    String statusText;
    Color statusColor;

    if (isDeleted) {
      statusText = "Deleted";
      statusColor = Colors.red;
    } else if (isActive) {
      statusText = "Active";
      statusColor = Colors.green;
    } else {
      statusText = "Suspended";
      statusColor = Colors.orange;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Plan Details"),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: isLoading
              ? const LinearProgressIndicator(minHeight: 1)
              : Divider(height: 1, color: cs.outlineVariant),
        ),
      ),

      body: Stack(
        children: [
          /// MAIN LIST
          ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
            children: [
              /// PRIMARY INFO CARD
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Row: Plan Name
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Expanded(child: _Label("PLAN NAME")),
                        const SizedBox(width: 12),
                        Text(
                          (detail?.planName ?? widget.plan.planName),
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Expanded(child: _Label("STATUS")),
                        const SizedBox(width: 12),
                        Text(
                          statusText,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// PROGRAMS & ACTIONS SECTION (expanded list with details)
              Container(
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // const Icon(Icons.account_tree_outlined),
                          const SizedBox(width: 8),
                          const Text(
                            "Programs & Actions",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            programDetails.isEmpty
                                ? ""
                                : "${programDetails.length} programs",
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      if (programDetails.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(12),
                            child: Text("No linked programs"),
                          ),
                        )
                      else
                        ...programDetails.map((p) {
                          final isOpen = _expandedPrograms.contains(
                            p.programId,
                          );
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: theme.cardColor,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: ExpansionTile(
                                  initiallyExpanded: isOpen,
                                  shape: const Border(),
                                  collapsedShape: const Border(),
                                  onExpansionChanged: (expanded) {
                                    setState(() {
                                      if (expanded) {
                                        _expandedPrograms.add(p.programId);
                                      } else {
                                        _expandedPrograms.remove(p.programId);
                                      }
                                    });
                                  },
                                  title: Text(
                                    p.programName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  childrenPadding: const EdgeInsets.fromLTRB(
                                    8,
                                    0,
                                    8,
                                    12,
                                  ),
                                  children: [
                                    if (p.actions.isEmpty)
                                      const Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text("No actions"),
                                      )
                                    else
                                      ...p.actions.map((a) {
                                        final isActionOpen = _expandedActions
                                            .contains(a.actionLinkId);
                                        return Container(
                                          margin: const EdgeInsets.symmetric(
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: theme.cardColor,
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: ExpansionTile(
                                            initiallyExpanded: isActionOpen,
                                            shape: const Border(),
                                            collapsedShape: const Border(),
                                            onExpansionChanged: (expanded) {
                                              setState(() {
                                                if (expanded) {
                                                  _expandedActions.add(
                                                    a.actionLinkId,
                                                  );
                                                } else {
                                                  _expandedActions.remove(
                                                    a.actionLinkId,
                                                  );
                                                }
                                              });
                                            },
                                            title: Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    a.actionName,
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                                // quick status badge
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 4,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color:
                                                        (a.active
                                                                ? Colors.green
                                                                : Colors.orange)
                                                            .withAlpha(31),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          999,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    a.active
                                                        ? "Active"
                                                        : "Suspended",
                                                    style: TextStyle(
                                                      color: a.active
                                                          ? Colors.green
                                                          : Colors.orange,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 8,
                                                    ),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    _InfoRow(
                                                      label: "Status",
                                                      value: a.active
                                                          ? "Active"
                                                          : "Suspended",
                                                      valueColor: a.active
                                                          ? Colors.green
                                                          : Colors.orange,
                                                    ),
                                                    if (a.createdUser != null ||
                                                        a.createdDate !=
                                                            null) ...[
                                                      const SizedBox(height: 6),
                                                      _InfoRow(
                                                        label: "Created By",
                                                        value:
                                                            a.createdUser ??
                                                            "N/A",
                                                      ),
                                                      _InfoRow(
                                                        label: "Created Date",
                                                        value: _fmtDate(
                                                          a.createdDate,
                                                        ),
                                                      ),
                                                    ],
                                                    if (a.modifiedUser !=
                                                            null ||
                                                        a.modifiedDate !=
                                                            null) ...[
                                                      const SizedBox(height: 6),
                                                      _InfoRow(
                                                        label: "Modified By",
                                                        value:
                                                            a.modifiedUser ??
                                                            "N/A",
                                                      ),
                                                      _InfoRow(
                                                        label: "Modified Date",
                                                        value: _fmtDate(
                                                          a.modifiedDate,
                                                        ),
                                                        valueColor: null,
                                                      ),
                                                    ],
                                                    if ((a.deleted ?? false) &&
                                                        (a.deletedUser !=
                                                                null ||
                                                            a.deletedDate !=
                                                                null)) ...[
                                                      const SizedBox(height: 6),
                                                      _InfoRow(
                                                        label: "Deleted By",
                                                        value:
                                                            a.deletedUser ??
                                                            "N/A",
                                                      ),
                                                      _InfoRow(
                                                        label: "Deleted Date",
                                                        value: _fmtDate(
                                                          a.deletedDate,
                                                        ),
                                                        valueColor: cs.error,
                                                      ),
                                                    ],
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                            ],
                          );
                        }),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              /// HISTORY (expandable)
              Container(
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.dividerColor),
                ),
                child: Theme(
                  data: theme.copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    leading: const Icon(Icons.history),
                    title: const Text(
                      'History',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      'Created, updated & deleted information',
                      style: theme.textTheme.bodySmall,
                    ),
                    children: [
                      _PlanHistorySection(
                        plan: detail ?? widget.plan,
                        isDeleted: isDeleted,
                        formatDate: _fmtDate,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          /// STICKY FOOTER
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 26),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    theme.scaffoldBackgroundColor,
                    theme.scaffoldBackgroundColor.withAlpha(230),
                    theme.scaffoldBackgroundColor.withAlpha(0),
                  ],
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: isDeleted
                        ? StandardRecoveryButton(
                            label: 'Recover Plan',
                            onPressed: () {
                              showRecoveryBottomSheet(
                                context: context,
                                itemName:
                                    detail?.planName ?? widget.plan.planName,
                                onRecover: () async {
                                  final success = await notifier.recoverPlan(
                                    widget.plan.planId,
                                  );

                                  if (!context.mounted) return;

                                  CustomSnackbar.show(
                                    context,
                                    message: success
                                        ? 'Plan recovered successfully'
                                        : 'Failed to recover plan',
                                    type: success
                                        ? SnackBarType.success
                                        : SnackBarType.error,
                                  );
                                },
                              );
                            },
                          )
                        : StandardDeleteButton(
                            label: 'Delete',
                            onPressed: () {
                              showDeleteBottomSheet(
                                context: context,
                                itemName:
                                    detail?.planName ?? widget.plan.planName,
                                onDelete: () async {
                                  final success = await notifier.deletePlan(
                                    widget.plan.planId,
                                  );

                                  if (!context.mounted) return;

                                  CustomSnackbar.show(
                                    context,
                                    message: success
                                        ? 'Plan deleted successfully'
                                        : 'Failed to delete plan',
                                    type: success
                                        ? SnackBarType.success
                                        : SnackBarType.error,
                                  );
                                },
                              );
                            },
                          ),
                  ),

                  if (!isDeleted) ...[
                    const SizedBox(width: 12),

                    Expanded(
                      child: StandardEditButton(
                        label: 'Edit Plan',
                        onPressed: () {
                          // Edit flow not implemented yet
                          CustomSnackbar.show(
                            context,
                            message: 'Edit plan is not implemented yet',
                            type: SnackBarType.info,
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

 

  String _fmtDate(DateTime? dt) {
    if (dt == null) return "N/A";
    final d = dt;
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final yyyy = d.year.toString();
    final hh = d.hour.toString().padLeft(2, '0');
    final min = d.minute.toString().padLeft(2, '0');
    return "$dd/$mm/$yyyy $hh:$min";
  }
}


////////////////////////////////////////////////////////////

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        letterSpacing: 1.2,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

////////////////////////////////////////////////////////////

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: valueColor ?? theme.textTheme.bodyMedium?.color,
          ),
        ),
      ],
    );
  }
}

////////////////////////////////////////////////////////////

class _PlanHistorySection extends StatelessWidget {
  final Plan plan;
  final bool isDeleted;
  final String Function(DateTime?) formatDate;

  const _PlanHistorySection({
    required this.plan,
    required this.isDeleted,
    required this.formatDate,
  });

  String _formatUser(String? value, {String fallback = 'N/A'}) {
    if (value == null || value.trim().isEmpty) return fallback;
    return value;
  }

  String _formatDateSafe(DateTime? value, {String fallback = 'N/A'}) {
    if (value == null) return fallback;
    return formatDate(value);
  }

  @override
  Widget build(BuildContext context) {
    final hasModifiedInfo =
        plan.modifiedUser != null || plan.modifiedDate != null;
    return Column(
      children: [
        _HistoryExpansionTile(
          icon: Icons.flag_circle_outlined,
          title: 'Created Info',
          subtitle:
              'Created by ${_formatUser(plan.createdUser, fallback: 'Unknown')}',
          initiallyExpanded: true,
          entries: [
            _HistoryEntry(
              label: 'Created By',
              value: _formatUser(plan.createdUser, fallback: 'Unknown'),
            ),
            _HistoryEntry(
              label: 'Created Date',
              value: _formatDateSafe(plan.createdDate),
            ),
          ],
        ),
        if (hasModifiedInfo)
          _HistoryExpansionTile(
            icon: Icons.history,
            title: 'Modified Info',
            subtitle:
                'Modified by ${_formatUser(plan.modifiedUser, fallback: 'Unknown')}',
            initiallyExpanded: !isDeleted,
            entries: [
              _HistoryEntry(
                label: 'Modified By',
                value: _formatUser(plan.modifiedUser, fallback: 'Unknown'),
              ),
              _HistoryEntry(
                label: 'Modified Date',
                value: _formatDateSafe(plan.modifiedDate),
              ),
            ],
          ),
        if (isDeleted)
          _HistoryExpansionTile(
            icon: Icons.delete_forever_outlined,
            title: 'Deleted Info',
            subtitle:
                'Deleted by ${_formatUser(plan.deletedUser, fallback: 'Unknown')}',
            initiallyExpanded: true,
            entries: [
              _HistoryEntry(
                label: 'Deleted By',
                value: _formatUser(plan.deletedUser, fallback: 'Unknown'),
              ),
              _HistoryEntry(
                label: 'Deleted Date',
                value: _formatDateSafe(plan.deletedDate),
              ),
            ],
          ),
      ],
    );
  }
}

class _HistoryExpansionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<_HistoryEntry> entries;
  final bool initiallyExpanded;

  const _HistoryExpansionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.entries,
    this.initiallyExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: Icon(icon, color: theme.colorScheme.primary),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(subtitle, style: theme.textTheme.bodySmall),
          children: [
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: entries.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 2.4,
              ),
              itemBuilder: (context, index) =>
                  _HistoryChip(entry: entries[index]),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryEntry {
  final String label;
  final String value;
  const _HistoryEntry({required this.label, required this.value});
}

class _HistoryChip extends StatelessWidget {
  final _HistoryEntry entry;
  const _HistoryChip({required this.entry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? theme.cardColor.withAlpha(153)
            : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.dividerColor.withAlpha(153)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            entry.label.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.6,
              color: theme.hintColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            entry.value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
