import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/core/widgets/custom_snackbar.dart';
import 'package:voice_first_admin/core/widgets/delete_bottom_sheet.dart';
import 'package:voice_first_admin/core/widgets/recovery_bottom_sheet.dart';
import 'package:voice_first_admin/core/widgets/standard_detail_page_buttons.dart';
import '../../models/plan_model.dart';
import '../providers/plan_provider.dart';

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
      statusText = "Inactive";
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
                                                        : "Inactive",
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
                                                          : "Inactive",
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

              /// HISTORY (always visible)
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
                        children: const [
                          Icon(Icons.history),
                          SizedBox(width: 8),
                          Text(
                            "History",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          Spacer(),
                          Text(
                            "Audit information",
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        childAspectRatio: 2.6,
                        children: [
                          _GridItem(
                            label: "Created By",
                            value:
                                (detail?.createdUser ??
                                    widget.plan.createdUser) ??
                                "N/A",
                          ),
                          _GridItem(
                            label: "Created Date",
                            value: _fmtDate(
                              detail?.createdDate ?? widget.plan.createdDate,
                            ),
                          ),
                          _GridItem(
                            label: "Modified By",
                            value:
                                (detail?.modifiedUser ??
                                    widget.plan.modifiedUser) ??
                                "N/A",
                          ),
                          _GridItem(
                            label: "Modified Date",
                            value: _fmtDate(
                              detail?.modifiedDate ?? widget.plan.modifiedDate,
                            ),
                          ),
                        ],
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

  ////////////////////////////////////////////////////////

  List<Widget> _buildPrograms(Plan? detail) {
    final list = detail?.programPlanDetails;
    if (list == null || list.isEmpty) {
      return [
        const Center(
          child: Padding(
            padding: EdgeInsets.all(12),
            child: Text("No linked programs"),
          ),
        ),
      ];
    }

    return list
        .map(
          (p) => _GridItem(
            label: p.programName,
            value: "${p.actions.length} actions",
          ),
        )
        .toList();
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
/// REUSABLE ADMIN COMPONENTS
////////////////////////////////////////////////////////////

class _ExpandableAdminCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool initiallyExpanded;
  final List<Widget> children;

  const _ExpandableAdminCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.initiallyExpanded = false,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        initiallyExpanded: initiallyExpanded,
        shape: const Border(),
        collapsedShape: const Border(),
        leading: Icon(icon),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        children: [
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 2.6,
            children: children,
          ),
        ],
      ),
    );
  }
}

////////////////////////////////////////////////////////////

class _GridItem extends StatelessWidget {
  final String label;
  final String value;

  const _GridItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label.toUpperCase(), style: const TextStyle(fontSize: 10)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

////////////////////////////////////////////////////////////

class _StatusChip extends StatelessWidget {
  final bool active;
  final bool deleted;

  const _StatusChip({required this.active, required this.deleted});

  @override
  Widget build(BuildContext context) {
    Color color;
    String text;

    if (deleted) {
      color = Colors.red;
      text = "Deleted";
    } else if (active) {
      color = Colors.green;
      text = "Active";
    } else {
      color = Colors.orange;
      text = "Inactive";
    }

    return Chip(
      label: Text(text),
      backgroundColor: color.withOpacity(.12),
      labelStyle: TextStyle(color: color),
      side: BorderSide.none,
    );
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
