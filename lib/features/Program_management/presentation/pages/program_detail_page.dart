import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/features/Business_activity/presentation/widgets/custom_snackbar.dart';
import 'package:voice_first_admin/features/Program_management/models/program_management_model.dart';
import 'package:voice_first_admin/features/Program_management/presentation/providers/program_provider.dart';
import 'package:voice_first_admin/features/Applications/Providers/application_provider.dart';
import 'package:voice_first_admin/features/Program_Action/presentation/providers/program_action_lookup_provider.dart';

class ProgramDetailPage extends ConsumerStatefulWidget {
  const ProgramDetailPage({super.key, required this.program});

  final ProgramManagementModel program;

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

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.program.programName);
    _labelCtrl = TextEditingController(text: widget.program.labelName);
    _routeCtrl = TextEditingController(text: widget.program.programRoute);

    _applicationId = widget.program.applicationId > 0
        ? widget.program.applicationId
        : 1;

    _selectedActionIds = widget.program.programActionIds.toSet();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _labelCtrl.dispose();
    _routeCtrl.dispose();
    super.dispose();
  }

  void _save() {
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

    // final updated = widget.program.copyWith(
    //   programName: name,
    //   labelName: label,
    //   programRoute: route,
    //   applicationId: _applicationId,
    //   companyId: null,
    //   actions: widget.program.actions
    //       .where((a) => _selectedActionIds.contains(a.actionId))
    //       .toList(),
    // );

    // ref.read(programProvider.notifier).update(updated);
    final updated = widget.program.copyWith(
      programName: name,
      labelName: label,
      programRoute: route,
      applicationId: _applicationId,
      actions: widget.program.actions
          .where((a) => _selectedActionIds.contains(a.actionId))
          .toList(),
    );

    ref
        .read(programProvider.notifier)
        .update(updated, updateBasic: true, updateActions: true);

    CustomSnackbar.show(
      context,
      message: 'Program updated successfully',
      type: SnackBarType.success,
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDeleted = widget.program.deleted ?? false;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        title: const Text(
          'Program Details',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (!isDeleted)
            TextButton(
              onPressed: () => setState(() => _isEditing = !_isEditing),
              child: Text(
                _isEditing ? 'View' : 'Edit',
                style: const TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            /// 🔷 HEADER
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: primaryColor.withAlpha(20),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.program.programName,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _statusChip(
                          isDeleted
                              ? 'Deleted'
                              : (widget.program.active ?? true)
                              ? 'Active'
                              : 'Inactive',
                          isDeleted
                              ? Colors.red
                              : (widget.program.active ?? true)
                              ? Colors.green
                              : Colors.orange,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// 🔹 BASIC INFORMATION
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
                              value: widget.program.programName,
                              primaryColor: primaryColor,
                            ),
                            _DetailItem(
                              label: 'Label Name',
                              value: widget.program.labelName,
                              primaryColor: primaryColor,
                            ),
                            _DetailItem(
                              label: 'Route',
                              value: widget.program.programRoute,
                              primaryColor: primaryColor,
                            ),
                          ],
                  ),

                  const SizedBox(height: 24),

                  /// 🔹 APPLICATION
                  _DetailSection(
                    title: 'Application',
                    primaryColor: primaryColor,
                    children: [
                      ref
                          .watch(applicationProvider)
                          .when(
                            data: (apps) {
                              final current =
                                  apps.any(
                                    (a) => a.platformId == _applicationId,
                                  )
                                  ? _applicationId
                                  : null;

                              return DropdownButtonFormField<int>(
                                value: current,
                                items: apps
                                    .map(
                                      (a) => DropdownMenuItem<int>(
                                        value: a.platformId,
                                        child: Text(a.platformName),
                                      ),
                                    )
                                    .toList(),
                                decoration: const InputDecoration(
                                  filled: true,
                                  border: OutlineInputBorder(),
                                ),
                                onChanged: !_isEditing
                                    ? null
                                    : (val) =>
                                          setState(() => _applicationId = val!),
                              );
                            },
                            loading: () =>
                                const LinearProgressIndicator(minHeight: 2),
                            error: (_, __) =>
                                const Text('Failed to load applications'),
                          ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // /// 🔹 PROGRAM ACTIONS
                  // _DetailSection(
                  //   title: 'Program Actions',
                  //   primaryColor: primaryColor,
                  //   children: [
                  //     ref
                  //         .watch(programActionLookupProvider)
                  //         .when(
                  //           data: (actions) {
                  //             final idToName = {
                  //               for (final a in actions)
                  //                 a.actionId: a.actionName,
                  //             };

                  //             return Wrap(
                  //               spacing: 8,
                  //               runSpacing: 8,
                  //               children: _selectedActionIds
                  //                   .map(
                  //                     (id) => Chip(
                  //                       label: Text(
                  //                         idToName[id] ?? 'Action #$id',
                  //                       ),
                  //                     ),
                  //                   )
                  //                   .toList(),
                  //             );
                  //           },
                  //           loading: () =>
                  //               const LinearProgressIndicator(minHeight: 2),
                  //           error: (_, __) =>
                  //               const Text('Failed to load actions'),
                  //         ),
                  //   ],
                  // ),
                  /// 🔹 PROGRAM ACTIONS
                  _DetailSection(
                    title: 'Program Actions',
                    primaryColor: primaryColor,
                    children: [
                      ref
                          .watch(programActionLookupProvider)
                          .when(
                            data: (actions) {
                              final idToName = {
                                for (final a in actions)
                                  a.actionId: a.actionName,
                              };

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  /// Selected actions
                                  if (_selectedActionIds.isEmpty)
                                    const Text('No actions linked')
                                  else
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: _selectedActionIds
                                          .map(
                                            (id) => Chip(
                                              label: Text(
                                                idToName[id] ?? 'Action #$id',
                                              ),
                                            ),
                                          )
                                          .toList(),
                                    ),
                                  if (_isEditing) ...[
                                    const SizedBox(height: 12),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: FilledButton.tonalIcon(
                                        icon: const Icon(Icons.settings),
                                        label: const Text('Manage Actions'),
                                        onPressed: () => _openActionManager(
                                          context,
                                          actions,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              );
                            },
                            loading: () =>
                                const LinearProgressIndicator(minHeight: 2),
                            error: (_, __) =>
                                const Text('Failed to load actions'),
                          ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  /// 🔹 CREATED INFORMATION
                  if (widget.program.createdUser != null ||
                      widget.program.createdDate != null) ...[
                    _DetailSection(
                      title: 'Created Information',
                      primaryColor: primaryColor,
                      children: [
                        _DetailItem(
                          label: 'Created By',
                          value: widget.program.createdUser ?? 'N/A',
                          primaryColor: primaryColor,
                        ),
                        _DetailItem(
                          label: 'Created Date',
                          value: widget.program.createdDate != null
                              ? _formatDateTime(widget.program.createdDate!)
                              : 'N/A',
                          primaryColor: primaryColor,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],

                  /// 🔹 MODIFIED INFORMATION
                  if (widget.program.modifiedUser != null ||
                      widget.program.modifiedDate != null) ...[
                    _DetailSection(
                      title: 'Modified Information',
                      primaryColor: primaryColor,
                      children: [
                        _DetailItem(
                          label: 'Modified By',
                          value: widget.program.modifiedUser ?? 'N/A',
                          primaryColor: primaryColor,
                        ),
                        _DetailItem(
                          label: 'Modified Date',
                          value: widget.program.modifiedDate != null
                              ? _formatDateTime(widget.program.modifiedDate!)
                              : 'Not modified',
                          primaryColor: primaryColor,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],

                  /// 🔹 DELETED INFORMATION
                  if (isDeleted) ...[
                    _DetailSection(
                      title: 'Deleted Information',
                      primaryColor: primaryColor,
                      children: [
                        _DetailItem(
                          label: 'Deleted By',
                          value: widget.program.deletedUser?.isEmpty ?? true
                              ? 'N/A'
                              : widget.program.deletedUser!,
                          primaryColor: primaryColor,
                        ),
                        _DetailItem(
                          label: 'Deleted Date',
                          value: widget.program.deletedDate != null
                              ? _formatDateTime(widget.program.deletedDate!)
                              : 'N/A',
                          primaryColor: primaryColor,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                  if (isDeleted)
                    FilledButton.icon(
                      onPressed: () async {
                        final error = await ref
                            .read(programProvider.notifier)
                            .recover(widget.program.sysProgramId!);

                        if (context.mounted) {
                          if (error != null) {
                            CustomSnackbar.show(
                              context,
                              message: error,
                              type: SnackBarType.error,
                            );
                          } else {
                            CustomSnackbar.show(
                              context,
                              message: 'Program recovered successfully',
                              type: SnackBarType.success,
                            );
                            Navigator.pop(context);
                          }
                        }
                      },
                      icon: const Icon(Icons.restore),
                      label: const Text('Recover Program'),
                    ),

                  /// 🔹 SAVE BUTTON
                  if (_isEditing)
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton(
                            onPressed: _save,
                            style: FilledButton.styleFrom(
                              backgroundColor: primaryColor,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text('Save Changes'),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🧩 HELPERS

  Widget _editField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _statusChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(38),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/'
        '${dateTime.month.toString().padLeft(2, '0')}/'
        '${dateTime.year} '
        '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _openActionManager(
    BuildContext context,
    List<dynamic> actions,
  ) async {
    final tempSelection = Set<int>.from(_selectedActionIds);

    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setStateDialog) {
            return AlertDialog(
              title: const Text('Select Program Actions'),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView(
                  shrinkWrap: true,
                  children: actions.map((a) {
                    return CheckboxListTile(
                      value: tempSelection.contains(a.actionId),
                      title: Text(a.actionName),
                      onChanged: (checked) {
                        setStateDialog(() {
                          checked == true
                              ? tempSelection.add(a.actionId)
                              : tempSelection.remove(a.actionId);
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    setState(() {
                      _selectedActionIds = tempSelection;
                    });
                    Navigator.pop(ctx);
                  },
                  child: const Text('Apply'),
                ),
              ],
            );
          },
        );
      },
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
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              for (int i = 0; i < children.length; i++) ...[
                children[i],
                if (i < children.length - 1)
                  Divider(height: 0, color: Colors.grey.shade200),
              ],
            ],
          ),
        ),
      ],
    );
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
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
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
