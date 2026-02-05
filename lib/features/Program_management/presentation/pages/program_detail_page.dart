import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/core/widgets/recovery_bottom_sheet.dart';
import 'package:voice_first_admin/core/widgets/delete_bottom_sheet.dart';
import 'package:voice_first_admin/core/widgets/custom_snackbar.dart';
import 'package:voice_first_admin/core/widgets/standard_detail_page_buttons.dart';
import 'package:voice_first_admin/features/Program_management/models/program_management_model.dart';
import 'package:voice_first_admin/features/Program_management/presentation/providers/program_provider.dart';
import 'package:voice_first_admin/features/Applications/Providers/application_provider.dart';
import 'package:voice_first_admin/features/Program_Action/presentation/providers/program_action_lookup_provider.dart';

class ProgramDetailPage extends ConsumerStatefulWidget {
  const ProgramDetailPage({super.key, required this.programId});

  final int programId;

  @override
  ConsumerState<ProgramDetailPage> createState() => _ProgramDetailPageState();
}

class _ProgramDetailPageState extends ConsumerState<ProgramDetailPage> {
  static const primaryColor = Color(0xFF0D7FF2);

  late TextEditingController _nameCtrl;
  late TextEditingController _labelCtrl;
  late TextEditingController _routeCtrl;

  late int _applicationId;
  late Set<int> _selectedActionIds;

  bool _isEditing = false;

  ProgramModel _getProgram() {
    return ref
        .read(programProvider)
        .all
        .firstWhere(
          (p) => p.sysProgramId == widget.programId,
          orElse: () => throw Exception("Program not found"),
        );
  }

  @override
  void initState() {
    super.initState();

    final program = _getProgram();

    _nameCtrl = TextEditingController(text: program.programName);
    _labelCtrl = TextEditingController(text: program.labelName);
    _routeCtrl = TextEditingController(text: program.programRoute);

    _applicationId = program.applicationId;
    // Initially select only actions that are active for this program
    _selectedActionIds = program.actions
        .where((a) => a.active)
        .map((a) => a.actionId)
        .toSet();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _labelCtrl.dispose();
    _routeCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final program = _getProgram();

    final name = _nameCtrl.text.trim();
    final label = _labelCtrl.text.trim();
    var route = _routeCtrl.text.trim();

    if (name.isEmpty || label.isEmpty || route.isEmpty) {
      CustomSnackbar.show(
        context,
        message: 'Name, label and route are required',
        type: SnackBarType.error,
      );
      return;
    }

    if (!route.startsWith('/')) route = '/$route';

    final updated = program.copyWith(
      programName: name,
      labelName: label,
      programRoute: route,
      applicationId: _applicationId,

      /// 🔥 rebuild actions correctly
      actions:
          program.actions.map((a) {
            return ProgramActionSummary(
              actionId: a.actionId,
              actionName: a.actionName,
              active: _selectedActionIds.contains(a.actionId),
              createdUser: a.createdUser,
              createdDate: a.createdDate,
              modifiedUser: a.modifiedUser,
              modifiedDate: a.modifiedDate,
            );
          }).toList()..addAll(
            /// NEW actions
            _selectedActionIds
                .where((id) => !program.actions.any((a) => a.actionId == id))
                .map(
                  (id) => ProgramActionSummary(
                    actionId: id,
                    actionName: '',
                    active: true,
                  ),
                ),
          ),
    );

    try {
      await ref.read(programProvider.notifier).updateProgram(updated: updated);

      if (!mounted) return;

      setState(() {
        _isEditing = false;
      });

      CustomSnackbar.show(
        context,
        message: 'Program updated successfully',
        type: SnackBarType.success,
      );
    } catch (e) {
      CustomSnackbar.show(
        context,
        message: 'Failed to update program',
        type: SnackBarType.error,
      );
    }
  }

  void _cancelEdit() {
    final program = _getProgram();

    setState(() {
      _nameCtrl.text = program.programName;
      _labelCtrl.text = program.labelName;
      _routeCtrl.text = program.programRoute;

      _applicationId = program.applicationId;
      _selectedActionIds = program.actions
          .where((a) => a.active)
          .map((a) => a.actionId)
          .toSet();

      _isEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final program = ref.watch(
      programProvider.select(
        (s) => s.all.firstWhere(
          (p) => p.sysProgramId == widget.programId,
          orElse: () => throw Exception("Program not found"),
        ),
      ),
    );

    /// 🔥 VERY ADVANCED FIX — controller sync
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isEditing) {
        if (_nameCtrl.text != program.programName) {
          _nameCtrl.text = program.programName;
        }
        if (_labelCtrl.text != program.labelName) {
          _labelCtrl.text = program.labelName;
        }
        if (_routeCtrl.text != program.programRoute) {
          _routeCtrl.text = program.programRoute;
        }

        _applicationId = program.applicationId;
        // Keep selection in sync with active program actions
        _selectedActionIds = program.actions
            .where((a) => a.active)
            .map((a) => a.actionId)
            .toSet();
      }
    });

    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDeleted = program.deleted ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Program Details'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: cs.outlineVariant),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 110),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  /// PRIMARY INFO CARD (Program Name + Status)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Expanded(child: _Label('PROGRAM NAME')),
                            const SizedBox(width: 12),
                            Text(
                              program.programName,
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
                            const Expanded(child: _Label('STATUS')),
                            const SizedBox(width: 12),
                            Builder(
                              builder: (context) {
                                final bool deleted = isDeleted;
                                final bool active = program.active ?? true;
                                String statusText;
                                Color statusColor;
                                if (deleted) {
                                  statusText = 'Deleted';
                                  statusColor = Colors.red;
                                } else if (active) {
                                  statusText = 'Active';
                                  statusColor = Colors.green;
                                } else {
                                  statusText = 'Inactive';
                                  statusColor = Colors.orange;
                                }

                                return Text(
                                  statusText,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: statusColor,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// BASIC INFO
                  _DetailSection(
                    title: 'Basic Information',
                    primaryColor: primaryColor,
                    children: _isEditing
                        ? [
                            _editField(_nameCtrl, 'Program Name'),
                            _editField(_labelCtrl, 'Label Name'),
                            _editField(_routeCtrl, 'Route'),
                          ]
                        : [
                            _DetailItem(
                              label: 'Program Name',
                              value: program.programName,
                              primaryColor: primaryColor,
                            ),
                            _DetailItem(
                              label: 'Label Name',
                              value: program.labelName,
                              primaryColor: primaryColor,
                            ),
                            _DetailItem(
                              label: 'Route',
                              value: program.programRoute,
                              primaryColor: primaryColor,
                            ),
                          ],
                  ),

                  const SizedBox(height: 24),

                  /// APPLICATION
                  ref
                      .watch(applicationProvider)
                      .when(
                        data: (apps) {
                          // If there are no applications in the system, hide section
                          if (apps.isEmpty) {
                            return const SizedBox.shrink();
                          }

                          final hasLinkedApplication =
                              _applicationId > 0 &&
                              apps.any((a) => a.platformId == _applicationId);

                          final currentId = hasLinkedApplication
                              ? _applicationId
                              : null;
                          final currentAppName = currentId != null
                              ? apps
                                    .firstWhere(
                                      (a) => a.platformId == currentId,
                                    )
                                    .platformName
                              : null;

                          return Container(
                            decoration: BoxDecoration(
                              color: theme.cardColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ExpansionTile(
                              shape: const Border(),
                              collapsedShape: const Border(),
                              tilePadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              childrenPadding: const EdgeInsets.fromLTRB(
                                12,
                                0,
                                12,
                                12,
                              ),
                              title: Row(
                                children: [
                                  const Text(
                                    'Application',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const Spacer(),
                                  
                                ],
                              ),
                              children: [
                                const SizedBox(height: 8),
                                if (!_isEditing)
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      currentAppName ?? 'No application linked',
                                    ),
                                  )
                                else
                                  DropdownButtonFormField<int>(
                                    initialValue: currentId,
                                    items: [
                                     
                                      ...apps.map(
                                        (a) => DropdownMenuItem<int>(
                                          value: a.platformId,
                                          child: Text(a.platformName),
                                        ),
                                      ),
                                    ],
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: theme.cardColor,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    onChanged: (val) {
                                      setState(() {
                                        _applicationId = val ?? 0;
                                      });
                                    },
                                  ),
                              ],
                            ),
                          );
                        },
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                      ),

                  const SizedBox(height: 24),

                  /// PROGRAM ACTIONS
                  Container(
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ref
                        .watch(programActionLookupProvider)
                        .when(
                          data: (actions) {
                            return ExpansionTile(
                              shape: const Border(),
                              collapsedShape: const Border(),
                              tilePadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              childrenPadding: const EdgeInsets.fromLTRB(
                                12,
                                0,
                                12,
                                12,
                              ),
                              title: Row(
                                children: [
                                  const Text(
                                    'Program Actions',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const Spacer(),
                                ],
                              ),
                              children: [
                                const SizedBox(height: 8),
                                if (actions.isEmpty)
                                  const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(12),
                                      child: Text('No actions linked'),
                                    ),
                                  )
                                else if (!_isEditing)
                                  Builder(
                                    builder: (context) {
                                      final activeIds = program.actions
                                          .where((a) => a.active)
                                          .map((a) => a.actionId)
                                          .toSet();

                                      if (activeIds.isEmpty) {
                                        return const Center(
                                          child: Padding(
                                            padding: EdgeInsets.all(12),
                                            child: Text('No actions linked'),
                                          ),
                                        );
                                      }

                                      return Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: activeIds.map((id) {
                                          final action = actions.firstWhere(
                                            (a) => a.actionId == id,
                                            orElse: () => actions.first,
                                          );

                                          return Chip(
                                            label: Text(action.actionName),
                                            backgroundColor: primaryColor
                                                .withAlpha(20),
                                            labelStyle: const TextStyle(
                                              color: primaryColor,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            side: BorderSide.none,
                                            materialTapTargetSize:
                                                MaterialTapTargetSize
                                                    .shrinkWrap,
                                            visualDensity:
                                                VisualDensity.compact,
                                          );
                                        }).toList(),
                                      );
                                    },
                                  )
                                else
                                  SizedBox(
                                    height: 260,
                                    child: ListView.builder(
                                      itemCount: actions.length,
                                      itemBuilder: (_, i) {
                                        final action = actions[i];
                                        final selected = _selectedActionIds
                                            .contains(action.actionId);

                                        return CheckboxListTile(
                                          value: selected,
                                          title: Text(action.actionName),
                                          onChanged: (checked) {
                                            setState(() {
                                              if (checked == true) {
                                                _selectedActionIds.add(
                                                  action.actionId,
                                                );
                                              } else {
                                                _selectedActionIds.remove(
                                                  action.actionId,
                                                );
                                              }
                                            });
                                          },
                                        );
                                      },
                                    ),
                                  ),
                              ],
                            );
                          },
                          loading: () => const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: LinearProgressIndicator(minHeight: 2),
                          ),
                          error: (_, __) => const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Failed to load actions'),
                          ),
                        ),
                  ),

                  const SizedBox(height: 24),

                  /// HISTORY (Created / Modified info)
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
                                'History',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              Spacer(),
                              Text(
                                'Audit information',
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
                                label: 'Created By',
                                value: program.createdUser ?? 'N/A',
                              ),
                              _GridItem(
                                label: 'Created Date',
                                value: _fmtDate(program.createdDate),
                              ),
                              _GridItem(
                                label: 'Modified By',
                                value: program.modifiedUser ?? 'N/A',
                              ),
                              _GridItem(
                                label: 'Modified Date',
                                value: _fmtDate(program.modifiedDate),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  if (isDeleted)
                    StandardRecoveryButton(
                      label: 'Recover Program',
                      onPressed: () {
                        showRecoveryBottomSheet(
                          context: context,
                          itemName: program.programName,
                          onRecover: () async {
                            final error = await ref
                                .read(programProvider.notifier)
                                .recover(program.sysProgramId!);

                            if (!mounted) return;

                            if (error != null) {
                              CustomSnackbar.show(
                                context,
                                message: error,
                                type: SnackBarType.error,
                              );
                            } else {
                              CustomSnackbar.show(
                                context,
                                message: 'Program recovered',
                                type: SnackBarType.success,
                              );
                            }
                          },
                        );
                      },
                    ),
                ],
              ),
            ),
          ),

          /// FOOTER
          if (!isDeleted)
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
                    if (_isEditing) ...[
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _cancelEdit,
                          style: OutlinedButton.styleFrom(
                            backgroundColor: theme.cardColor,
                            side: BorderSide(color: cs.outline),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Cancel',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _save,
                          style: OutlinedButton.styleFrom(
                            backgroundColor: theme.cardColor,
                            side: BorderSide(color: cs.primary),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Save Changes',
                            style: TextStyle(color: cs.primary),
                          ),
                        ),
                      ),
                    ] else ...[
                      Expanded(
                        child: StandardEditButton(
                          label: 'Edit Program',
                          onPressed: () => setState(() => _isEditing = true),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StandardDeleteButton(
                          label: 'Delete',
                          onPressed: () => showDeleteBottomSheet(
                            context: context,
                            itemName: program.programName,
                            onDelete: () async {
                              try {
                                await ref
                                    .read(programProvider.notifier)
                                    .delete(program.sysProgramId!);

                                if (!mounted) return;

                                CustomSnackbar.show(
                                  context,
                                  message: 'Program deleted successfully',
                                  type: SnackBarType.success,
                                );
                              } catch (e) {
                                if (!mounted) return;

                                CustomSnackbar.show(
                                  context,
                                  message: 'Failed to delete program',
                                  type: SnackBarType.error,
                                );
                              }
                            },
                          ),
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

  Widget _editField(TextEditingController c, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  String _fmtDate(DateTime? dt) {
    if (dt == null) return 'N/A';
    final d = dt;
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final yyyy = d.year.toString();
    final hh = d.hour.toString().padLeft(2, '0');
    final min = d.minute.toString().padLeft(2, '0');
    return '$dd/$mm/$yyyy $hh:$min';
  }
}

class _DetailItem extends StatelessWidget {
  final String label;
  final String value;
  final Color primaryColor;
  final Color? valueColor;

  const _DetailItem({
    required this.label,
    required this.value,
    required this.primaryColor,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(width: 0),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: valueColor ?? Colors.grey.shade900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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

/// 🔹 SHARED DETAIL UI

class _DetailSection extends StatelessWidget {
  final String title;
  final Color primaryColor;
  final List<Widget> children;

  const _DetailSection({
    required this.title,
    required this.primaryColor,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                for (int i = 0; i < children.length; i++) ...[
                  children[i],
                  if (i < children.length - 1) const Divider(),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
